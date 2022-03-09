-- ok

local fontpfx = "[UDS] "
local function fontpront(s, crit)
	if crit or devparm then
		if not crit and devparm and paused then return end -- shut up!
		print(fontpfx..s)
	end
end

local major,minor,release = 0,0,2
local verstr = ("%d.%d.%03d"):format(major, minor, release)
fontpront("Preparing UDS "..verstr)

local has = ULTIMATEDRAWSTRING
if has then
	local old = (has[1] > major or has[2] > minor or has[3] > release) and  1 -- This is old. Loaded is newer
			 or (has[1] < major or has[2] < minor or has[3] < release) and -1 -- This is new. Loaded is older
			 or 0 -- Same version
	
	fontpront("Can't load: Already loaded. ("..(
		   old>0 and "This one is older..."
		or old<0 and "This one is newer."
		or "Same version!"
	)..")")
	return
end

rawset(_G, "ULTIMATEDRAWSTRING", {major,minor,release})

-- TODO: Assign better library name
-- TODO: uh

local ROTANGLES = 72
local ROTANGDIFF = (360 / ROTANGLES) // 5 degrees
local ROTANGLES_F = ROTANGLES*FRACUNIT
local ROTANGDIFF_F = ROTANGDIFF*FRACUNIT
-- residual constants, for spritefont but unimplemented for now

local vip = nil
-- Very Important Patch
-- if it becomes invalid, something horrible happened (like what?)
-- Forces sentinel to recache all fonts

local function createFlags(t)for i = 1,#t do rawset(_G, t[i], 2^(i-1))end end

local function makeconst(val, ...)
	for i = 1, select('#', ...) do
		local str = select(i, ...)
		if type(str) ~= "string" then error("Argument "..(i+1).." is not a string",2) end
		rawset(_G, str, val)
	end
end

local function ifNilUseNext(...)
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		if v ~= nil then return v end
	end
end

local function fetchFromG(what) -- for pcall
	return _G[what]
end

makeconst(-FRACUNIT, "VALIGN_TOP"   , "HALIGN_LEFT")
makeconst(        0, "VALIGN_MIDDLE", "VALIGN_CENTER",
	                 "HALIGN_MIDDLE", "HALIGN_CENTER")
makeconst( FRACUNIT, "VALIGN_BOTTOM", "HALIGN_RIGHT")

createFlags{
	"WF_INTPOS", -- Multiplies position by FRACUNIT - done once at the start... just for ease of use really
	
	"WF_NOLINEFEED", -- Do not process line feed characters (\0xA, dec 10, \n) as such.
	
	"WF_WORDWRAP", -- Makes the line wrapper attempt to break lines between words rather than within words.
	
	"WF_MONOSPACE", -- Pretends all glyphs are of the same width
}

local fonts = {}

-- Creates a new font.
-- Takes a name (must start with "FONT_") and a table.
rawset(_G, "FNT_NewFont", function(name, t)
	-- Note: you can continue accessing t, but
	-- You usually don't need to
	--local f = {}
	
	if type(name) ~= "string" then error("bad type for arg #1",2) end
	if name:sub(1,5) ~= "FONT_" then error("no, i don't want that",2) end
	
	fontpront("Creating a new font: "..name)
	
	t.iname,t.name = name,name
	t.docache = true
	
	if t.spritefont then
		t.unusable = true
		error("Sprite-based fonts have not been implemented.",2)
		/*
		for quad = 1,4 do
			local sprstr = ("SPR_%s%d"):format(t.prefix, quad)
			if sprstr:len() ~= 8 then
				--fontpront("Unable to use "..sprstr..": Length is not 8!")
				fontpront("Bad prefix length (must be 3)")
				t.unusable = true
				t.docache = false
				break
			end
			
			local succ,thespr = pcall(fetchFromG, sprstr)
			if not succ or thespr == nil then -- SPR constant doesn't exist
				fontpront(sprstr.." is not freeslotted, so I'm going to go do that now.")
				thespr = freeslot(sprstr) -- make it then
			end
		end
	*/ end
	
	-- small prefix check
	if t.prefix:format(0):len() > 8 then error("Malformed prefix (ix 0 exceeds 8 chars)",2) end
	if t.prefix:format(255):len() > 8 then error("Malformed prefix (ix 255 exceeds 8 chars)",2) end
	if t.prefix:format(0) == t.prefix:format(255) then error("Malformed prefix (number pattern missing?)",2) end
	
	local ix = #fonts+1
	fonts[ix] = t
	rawset(_G, name, ix)
	return ix
end)

local additional
rawset(_G, "FNT_Sentinel", function(v) -- v for vdrawer
-- TODO: Maybe allow for a second argument as to only recache the specified font?
--additional(v)
local forcecache = not (vip and vip.valid)
if forcecache then
	vip = v.cachePatch("IRRELEVANT") -- i can use the missing patch too lol
	fontpront("FNT_Sentinel: vip patch is gone, forcing recache...", true)
end
for _ix = 1,#fonts do
	local f = fonts[_ix] -- f for font
	if (f.docache or forcecache) and not f.unusable then
		fontpront("FNT_Sentinel: Caching font "..f.iname, true)
		-- (re)init all glyphs. golly!
		f.glyphs = {}
		local gs = f.glyphs -- guess
		local spritefont = f.spritefont
		
		-- TODO: Check that prefix is good
		if f.forcedwidths == nil then
			f.forcedwidths = {}
		end
		
		if f.spacewidth ~= nil then f.forcedwidths[32] = f.spacewidth end
		if f.tabwidth   ~= nil then f.forcedwidths[9]  = f.tabwidth   end
		
		local build
		local valid = 0
		for ascii = 0,255 do
			local g = {} -- g for glyph
			g.ascii = ascii
			
			if spritefont then /* DOESN'T WORK; SRB2 STUPID
				-- SPR_XXXQ
				-- XXXQF0, where
				-- XXX be prefix
				-- Q be quad (1-4)
				-- F be frame
				
				local quad = (ascii/64)+1
				local qnum = ascii % 64
				
				-- TODO
				local sprstr = ("SPR_%s%d"):format(f.prefix, quad)
				
				local succ,thespr = pcall(fetchFromG, sprstr)
				if not succ or thespr == nil then -- SPR constant doesn't exist
					fontpront(sprstr.." is not freeslotted? FNT_NewFont() should've done that...")
					f.unusable = true
					break
				end
				
				-- There are 64 frames per sprite, so
				-- We have to use 4 sprites for all 256 possible glyphs!
				g.patch = v.getSpritePatch(thespr, qnum, 0)
				if g.patch == nil then error("what") end
				-- Since this is a sprite font, we don't actually know what glyphs get to exist (gaps kill srb2)
				-- But we can cheat: If the patch is 0x0, it doesn't exist.
				
				g.rots = {}
				
				for rotation = 0,ROTANGLES-1 do
					print(rotation)
					-- yes, we're placing rot 0 in two places. what are you going to do about it
					g.rots[rotation] = v.getSpritePatch(thespr, qnum, 0, FixedAngle(ROTANGDIFF_F * rotation))
				end
				*/
				error("Lua should *not* be able to reach here. What did you do?", 2)
			else
				/*
				if f.prefix:len() ~= 5 then
					fontpront("Bad prefix length (must be 5)")
					f.unusable = true
					break
				end
				*/
				
				-- XXXXXYYY, where
				-- XXXXX be prefix
				-- YYY be ascii number
				--build = (f.prefix.."%03d"):format(ascii)
				build = f.prefix:format(ascii)
				
				g.patch = v.cachePatch(build)
			end
			
			local pch = g.patch
			
			if pch == nil then
				fontpront("Something went wrong and g.patch is nil.", true)
				f.unusable = true
				break
			end
			
			g.width = ifNilUseNext(f.forcedwidths[ascii], pch.width)
			g.height = pch.height
			g.leftoffset = pch.leftoffset
			g.topoffset = pch.topoffset
			
			if spritefont then
				g.exists = pch.width + pch.height > 0
			else
				g.exists = v.patchExists(build)
			end
			
			if g.exists then valid = $+1 end
			
			gs[ascii] = g -- go go garbage collector
		end
		
		-- TODO: Optimize (multiple 0,255 loops can be filed into a single 0,255 loop, but might get messy)
		
		if valid == 0 then
			fontpront("\133*\128 This font has no valid glyphs!", true)
			f.unusable = true
			continue
		end
		
		if f.unusable then
			fontpront("\133*\128 Font "..f.iname.." can not be used due to some error.", true)
			f.unusable = true
			f.docache = false -- unnecesary
			continue
		end
		
		-- monospace
		if f.monospacewidth == nil then
			fontpront("\130*\128 monospacewidth is nil...")
			
			local sum = 0
			for ascii = 0,255 do
				local g = gs[ascii]
				if g.exists then sum = $+g.width end
			end
			f.monospacewidth = sum/valid
			fontpront("...so I take the average of all glyphs ("..(f.monospacewidth)..").")
		end
		
		-- missing recalc
		if f.missingwidth == nil then f.missingwidth = f.monospacewidth end
		
		-- space
		if not gs[32].exists then
			fontpront("\130*\128 There is no space glyph...")
			if f.forcedwidths[32] ~= nil then
				gs[32].width = f.forcedwidths[32]
				fontpront("...but there is an entry for space width. I'm taking that.")
			else
				local v = f.monospacewidth/2
				f.forcedwidths[32] = v
				gs[32].width = v
				fontpront("...so I pretend its width is half monospace's width ("..(v)..").")
			end
		end
		
		-- recalculate missing glyph widths
		local recalc = false
		for ascii = 0,255 do
			local g = gs[ascii]
			if not g.exists then
				g.width = f.missingwidth
			end
		end
		
		-- calc height
		if f.height == nil then
			fontpront("\130*\128 height is nil...")
			local tot = 0
			for ascii = 0,255 do
				local g = gs[ascii]
				if g.exists then
					tot = $+g.height
				end
			end
			f.height = tot/valid
			fontpront("...so I assume "..(f.height)..".")
		end
		
		-- cache done!
		f.docache = false
	end
end
end)

local whitespaces = {
	[32] = true,
	--[9] = true,
}

local linetableMeta = {
	__index = function(t,k)
		local nt = {}
		rawset(t, k, nt)
		return nt
	end
}
-- Forces drawer to draw cool text, like drawString but not cringe.
rawset(_G, "FNT_Write", function(v, data, doerror)
	if data == nil then error("Argument #2 (drawdata) is nil!",2) end
	if v == nil then error("Argument #1 (drawer) is nil!",2) end
	
	-- Run sentinel so everything works like it should
	FNT_Sentinel(v)
	
	data.x = ifNilUseNext($, data[1])
	data.y = ifNilUseNext($, data[2])
	data.font = ifNilUseNext($, data[3])
	data.text = ifNilUseNext($, data[4])
	data.flags = ifNilUseNext($, data[5])
	data.color = ifNilUseNext($, data[6])
	
	-- Make sure some required parameters are there
	if data.x == nil then error("X parameter missing",2) end
	if data.y == nil then error("Y parameter missing",2) end
	if data.font == nil then error("FONT parameter missing",2) end
	if data.text == nil then error("TEXT parameter missing",2) end
	
	data.wflags = ifNilUseNext($, 0)
	data.flags = ifNilUseNext($, 0)
	
	if data.angle == nil then data.angle = 0 end
	if data.halign == nil then data.halign = HALIGN_LEFT end
	if data.valign == nil then data.valign = VALIGN_TOP end
	
	-- ensure validity
	data.text = tostring($)
	
	/*
	data.hscale = ifNilUseNext($, data.scale, FRACUNIT)
	data.vscale = ifNilUseNext($, data.scale, FRACUNIT)
	
	if data.xscale ~= nil then
		local extra = data.xscale
		data.hscale = FixedMul($, extra)
		data.vscale = FixedMul($, extra)
	end
	*/
	
	data.hscale = ifNilUseNext($, FRACUNIT)
	data.vscale = ifNilUseNext($, FRACUNIT)
	
	if data.scale ~= nil then
		local sc = data.scale
		data.hscale = FixedMul($, sc)
		data.vscale = FixedMul($, sc)
	end
	
	-- other
	data.xoff = ifNilUseNext($, 0)
	data.yoff = ifNilUseNext($, 0)
	
	data.maxwidth = ifNilUseNext($, data.maxlinewidth, 0)
	if data.maxwidth < 0 then data.maxwidth = 0 end
	--local maxwidth = data.maxwidth
	if data.hscale == 0 and data.maxwidth > 0 then error("Can't have maxwidth and 0 hscale at the same time (div0). Why both at the same time anyways?", 2) end
	local maxwidth = FixedDiv(data.maxwidth*FRACUNIT, data.hscale)/FRACUNIT
	-- TODO: Make maxwidth more precise
	-- (Might require refactoring glyph width processing)
	if maxwidth < 0 then error("Something has gone wrong.",2) end
	
	local monospaceMode = data.wflags & WF_MONOSPACE > 0
	
	data.mem = {}
	
	-- Do some wflags stuff
	if data.wflags & WF_INTPOS then -- Integer position - Multiply by FRACUNIT
		data.x,data.y = $1*FRACUNIT,$2*FRACUNIT
	end
	
	-- prepare font
	local font = fonts[data.font]
	if font.unusable then error("Unable to use font "..font.iname..": It is marked as unusable.",2) end -- end early if there is an issue
	
	--local maxlinewidth = data.maxlinewidth / FRACUNIT
	
	-- ennumerate all glyphs we will be using
	-- separate them by lines
	-- TODO: Callback function for this spot?
	local todrawlines = setmetatable({}, linetableMeta)
	local line = 1
	
	local doWrap = maxwidth > 0
	local doWordWrap = data.wflags & WF_WORDWRAP > 0
	local doNewline = data.wflags & WF_NOLINEFEED == 0
	
	local lastWhitespace = 0 -- last position of whitespace found in this line, for wordwrap
	local widthSoFar = 0 -- width of this line so far, for maxwidth cross detection
	local widthSinceWhitespace = 0 -- width since last whitespace/SOL, for... cause i'm lazy
	
	for i = 1,#data.text do
		if line > 512 then error("LINE PANIC (>512) - Is maxwidth too low?",2) end
		local thisline = todrawlines[line]
		
		local chr = data.text:sub(i,i):byte()
		if chr == 10 and doNewline then -- line feed (maybe check if > maxlinewidth?)
			line = $+1
			lastWhitespace,widthSoFar,widthSinceWhitespace = 0,0,0
		else -- a glyph!
			local whitespace = whitespaces[chr]
			if whitespace then
				lastWhitespace = #thisline+1
			end
			
			local glyph = font.glyphs[chr]
			local w = glyph.width
			if monospaceMode then w = font.monospacewidth end
			
			if doWrap then
				local doWordWrap = doWordWrap
				if widthSoFar == widthSinceWhitespace then
					-- This width is from the start of the line???
					-- Don't break-by-word, bad idea.
					doWordWrap = false
				end
				if widthSoFar+w > maxwidth then
					-- this exceeds maxwidth
					
					if whitespace then
						-- if whitespace is the one crossing the limit,
						-- just shift to new line and do nothing else lol
						line = $+1
						widthSoFar,widthSinceWhitespace = 0,0,0
						continue
					elseif doWordWrap then
						-- this glyph, plus all previous up to whitespace/SOL, go into the next line
						local prevline = thisline
						line = $+1
						thisline = todrawlines[line]
						
						for j = lastWhitespace+1,#prevline do -- all glyphs between then+1 and now
							-- put glyph into new line, invalidate it from previous line
							--prevline[#prevline+1],thisline[j] = thisline[j],nil
							thisline[#thisline+1],prevline[j] = prevline[j],nil
						end
						widthSoFar = widthSinceWhitespace -- the width of these glyphs, so we don't miscalc them later
					else
						-- this glyph goes into the next line, straight up
						line = $+1
						thisline = todrawlines[line]
						widthSoFar,widthSinceWhitespace = 0,0,0
					end
					
					lastWhitespace = 0 -- since all three cases did this on draft, i'm doing it here
					
				end
			end
			
			thisline[#thisline+1] = glyph
			widthSoFar,widthSinceWhitespace = $1+w,$2+w
			if whitespace then widthSinceWhitespace = 0 end
		end
	end
	
	-- before drawing, calculate some things
	local tew,teh = 0,0 -- total effective width & height
	local lineheight = FixedMul(font.height*FRACUNIT, data.vscale)
	-- and for each line too
	for lineix = 1,#todrawlines do
		local line = todrawlines[lineix]
		
		-- calculate line width
		local ew = 0 -- effective width
		for i = 1,#line do
			local w = line[i].width
			if monospaceMode then w = font.monospacewidth end
			ew = $ + w
		end
		ew = FixedMul($*FRACUNIT, data.hscale)
		
		-- and height
		-- ...we can do this outside the loop!
		--local eh = FixedMul(#todrawlines*FRACUNIT, lineheight) -- effective height
		local eh = FixedMul(font.height*FRACUNIT, data.vscale)
		-- ...well, uh. yeah. lmao
		
		
		line.ewidth = ew
		line.eheight = eh
		
		-- TODO: Include char sep
		tew = max($, ew)
		--teh = $+eh
		
	end
	teh = FixedMul(#todrawlines*FRACUNIT, lineheight)
	
	-- You should DRAW yourself, NOW
	
	local cx = 0 -- current x
	local cy = 0 -- current y
	
	-- adjust cx and cy depending on alignment
	-- <^ -FU      0      +FU >v
	
	-- warp aligns to values i can use
	-- halign:  -FU     0       FU
	--   real:   0     0.5      1
	local ha = (data.halign + FRACUNIT) / 2
	local va = (data.valign + FRACUNIT) / 2
	
	local charsep = ifNilUseNext(font.charsep, 0)
	
	data.curchartotal = 0
	for lineix = 1,#todrawlines do
		local line = todrawlines[lineix]
		--for i = 1,#todraw do
		--local this = todraw[i]
		
		-- where to begin drawing text
		-- take care box into account
		cx = -FixedDiv(FixedMul(line.ewidth, ha), FRACUNIT)
		--cy = -FixedDiv(FixedMul(line.eheight, va), FRACUNIT) + (lineix-1)*font.height -- same but in vertical
		cy = -FixedDiv(FixedMul(teh, va), FRACUNIT) + lineheight*(lineix-1)
		--cy = -teh + lineheight*(lineix-1)
		
		for thisix = 1,#line do
			data.curchartotal = $+1
			local this = line[thisix]
			
			--v.drawScaled(data.x, data.y, data.scale,
			if this.exists then
				local pch = this.patch
			
				if font.spritefont then
					local ang = FixedDiv(AngleFixed(data.angle),ROTANGDIFF_F) / FRACUNIT
					pch = this.rots[ang]
				end
				
				data.curascii = this.ascii
				data.curchar = thisix
				data.curline = lineix
				
				local preresult
				if data.predrawfunc then preresult = data.predrawfunc(data) end
				
				if preresult ~= false then
					local colormap = v.getColormap(TC_DEFAULT, data.color)
					v.drawStretched(
						data.x + data.xoff + cx,
						data.y + data.yoff + cy,
						data.hscale, data.vscale,
						pch, data.flags, colormap
					)
				end
				if data.postdrawfunc then data.postdrawfunc(data) end
				
				
				
			end
			
			local ascii = this.ascii
			
			local morex = this.width
			local forcew = font.forcedwidths[ascii]
			-- if monospace then forcew = monospacewidth end
			if monospaceMode then morex = font.monospacewidth
			elseif forcew ~= nil then morex = forcew end
			
			
			morex = $+charsep
			
			cx = $ + FixedMul(morex*FRACUNIT, data.hscale)
		end
	end
	
end)

--function additional(v) if not v.write then v.write = FNT_WRITE end end
-- not useful






















-- trailing newlines