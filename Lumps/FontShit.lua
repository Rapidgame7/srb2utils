//oper("FONT_KART2", "MKFT2")
//oper(v, "FONT_KART2", "MKFT2", 8)
//oper(v, "FONT_TINY", "SMTYB", 3)
//oper(v, "FONT_TINYDARK", "SMTYD", 3)
//oper(v, "FONT_TITLE", "SMTTL", 6)

// FNT - Custom text drawer!

/*
local function HUD_IMPORTANT(v)
	FNT_MakeFont(v, "FONT_JAYNUMS", "JAYNM", 27, 14, 51)
	FNT_MakeFont(v, "FONT_CONSOLE", "COLFN", 8, 4, 8)
	FNT_MakeFont(v, "FONT_CONSOLETHIN", "CTNFN", 6, 2, 7)
end
*/

local cached = false
local checker = nil

local function oper(v, fntname, fntpref, mono, space, height)
	rawset(_G, fntname, {monospace = mono, space = space, height = height})
	for i = 0,255 do
		local build = string.format(fntpref.."%03d", i)
		if v.patchExists(build) then
			--print(build)
			_G[fntname][i] = v.cachePatch(build)
		end
	end
end

local fonts = {}

local function CHEKER(v)
	if not (checker and checker.valid) then cached = false end
	if cached then return end
	
	for i = 1,#fonts do
		local font = fonts[i]
		for i = 0,255 do
			local glyph = font[i]
			if glyph.exists then
				glyph.patch = v.cachePatch(glyph.str)
			end
		end
	end
	
	checker = v.cachePatch("K_CHECK1")
	cached = true
end

hud.add(CHEKER)
hud.add(CHEKER, "title")

-- reminder char 32 is space

rawset(_G, "FNT_MakeFont", function(v, name, prefix, monowidth, spacewidth, height)
	if fonts[name] then return false end
	local glyphs = {}
	local widths,heights = {},{}
	for i = 0,255 do
		local glyph = {}
		local str = string.format(prefix.."%03d", i)
		if v.patchExists(str) then
			local patch = v.cachePatch(str)
			-- We're caching the glyph later anyways, but
			-- We're also going to do it here just because I want some numbers now
			glyph.exists = true
			glyph.str = str
			glyph.width = patch.width
			glyph.height = patch.height
			widths[#widths+1] = glyph.width
			heights[#heights+1] = glyph.height
		end
		glyphs[i] = glyph
	end
	if monowidth == nil then
		table.sort(widths)
		glyphs.monowidth = widths[#widths/2] -- I wanted to take the mode but it would be a fucking mess, so maybe later. here's the median
	else glyphs.monowidth = monowidth end
	if spacewidth == nil then
		glyphs.spacewidth = glyphs.monowidth
	else glyphs.spacewidth = spacewidth end
	if height == nil then
		table.sort(heights)
		glyphs.height = heights[#heights]
	else glyphs.height = height end
	fonts[#fonts+1] = glyphs
	fonts[name] = true
	
	local yes = #fonts
	rawset(_G, name, yes)
	cached = false -- Reinitialize
	
	--return font
end)

-- Maybe you want to force edit a font idk
rawset(_G, "FNT_GetFont", function(ix)
	return fonts[ix]
end)


local styles = {
	--"FS_SHADOW", // Draws another string right below this (useful for monocolor fonts)
	"FS_MONOSPACE", // Fixed width
	"FS_FIXED", // Enables scaling and places things in the fixed scale, epic!
	"FS_FIXEDPOS", // Position is multiplied by FRACUNIT
	"FS_IGNOREHSCALE", // Ignore H scaling when positioning characters (does not work when callback modifies this)
	"FS_IGNOREVSCALE", // Same, but vertical lol
}
for i = 1,#styles do
	rawset(_G, styles[i], 2^(i-1))
end
rawset(_G, "FS_IGNORESCALE", FS_IGNOREHSCALE|FS_IGNOREVSCALE)

-- OLD function(v, x, y, str, fontix, flags, extra)
-- x,y,str,font,flags
-- PERFORMS NEXT TO NO ERROR CHECKING. Trek with caution.
rawset(_G, "FNT_Write", function(v, data, erlv) // color, style, flags, align)
	if erlv == nil then erlv = 2 end
	
	if data[1] ~= nil then data.x = data[1] end
	if data[2] ~= nil then data.y = data[2] end
	if data[3] ~= nil then data.str = data[3] end
	if data[4] ~= nil then data.font = data[4] end
	if data[5] ~= nil then data.flags = data[5] end
	
	local font = fonts[data.font]
	if font == nil then error("Invalid font specified", erlv) end
	
	local str = data.str
	
    //if str == "" then str = "-" end // Necessary even?
	if str == true then str = "true"
	elseif str == false then str = "false"
	elseif type(str) == "number" then str = tostring(str) end
	if type(str) ~= "string" then str = type(str) end
	
	if data.scale ~= nil then data.hscale = data.scale end // Override
	if data.hscale == nil then data.hscale = FRACUNIT end
	if data.hscale < 0 then error("Negative H scale!",erlv) end
	if data.vscale ~= nil then
		if data.vscale < 0 then error("Negative V scale!",erlv) end
		-- enddata.vscale = $ and $ > 0 and $ or FRACUNIT
	end
	
	data.style = $ or 0
	data.color = $ or 0
	
    local dt = {}
    local offset = 0
	local mono = font.monowidth
    for i = 1,#str do
        local by = string.byte(str:sub(i,i))
		local glyph = font[by]
		--print(by.." "..str:sub(i,i))
		local res = 0
		
		local d = {nil,0}
		local w = mono
		if glyph.exists then
			--d[1] = glyph.patch
			dt[#dt+1] = {(glyph.exists and glyph.patch or nil), offset}
			w = glyph.width
		else
			if by == 32 then w = font.spacewidth end
		end
		if (data.style & FS_MONOSPACE) then w = mono end
		--if (data.style & FS_FIXED) then w = FixedMul($*FRACUNIT, data.hscale) end
		w = FixedMul($*FRACUNIT, data.hscale)
		offset = $ + w
    end

    local eo = 0
    if data.align == "center" then
        eo = offset/2
    elseif data.align == "right" then
        eo = offset
    end
	
	local vo = 0
	if data.valign ~= nil then
		local height = font.height
		--if (data.style & FS_FIXED) then height = FixedMul($*FRACUNIT, data.hscale) end
		local vs = 0
		if data.vscale ~= nil then vs = data.vscale
		elseif data.scale ~= nil then vs = data.scale
		else vs = FRACUNIT end
		height = FixedMul($*FRACUNIT, vs)
		if data.valign == "center" then
			vo = (height/2)
		elseif data.valign == "bottom" then
			vo = height
		end
	end
	
	if (data.style & FS_FIXEDPOS) then data.x,data.y = $1*FRACUNIT,$2*FRACUNIT end
	
	local postfn = data.postfn
	local dopost = postfn~=nil
	local prefn = data.prefn
	local dopre = prefn~=nil
	local colormap = v.getColormap(-1, data.color)
	local storecol = data.color
    for i = 1,#dt do
        local ix = dt[i]
		data.ivalid = ix[1] ~= nil
		data.i = i
		storecol = data.color
		if dopre then prefn(data,i) end
		if data.color ~= storecol then colormap = v.getColormap(-1, data.color) end
		if ix[1] ~= nil then
			local accx = data.x+ix[2]-eo
			local accy = data.y-vo
			
			if data.vscale == nil then
				v.drawScaled(accx, accy, data.hscale, ix[1], data.flags, colormap)
			else
				v.drawStretched(accx, accy, data.hscale, data.vscale, ix[1], data.flags, colormap)
			end
			
			/*if (data.style & FS_FIXED) then
				v.drawScaled(accx, accy, data.hscale, ix[1], data.flags, colormap)
			else
				v.draw(accx, accy, ix[1], data.flags, colormap)
			end*/
		end
		if dopost then postfn(data,i) end
    end
end)

rawset(_G, "FNT_DrawString", function(v, x, y, str, fontix, flags, extra) // color, style, flags, align)
	-- Legacy
	local data = {x,y,str,fontix,flags}
	if extra ~= nil then // Useless unless using legacy version
		for k,v in pairs(extra) do data[k] = v end
	end
	FNT_Write(v, data, 3)
end)

