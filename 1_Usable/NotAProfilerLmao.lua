-- Not A Profiler Lmao

local gtm = getTimeMicros

local maxsamples = 40

local snaps = {}
local avgs = {}
local function resetsnap() snaps = {} end
local function snap()
	snaps[#snaps+1] = gtm()
end

local function snapcalc()
	for i = 1,#snaps-1 do
		local c,n = snaps[i],snaps[i+1]
		if p~=nil then
			avgs[i] = $ or {i=0,b=INT32_MAX,w=INT32_MIN}
			local avg = avgs[i]
			
			avg[avg.i+1] = n-c
			avg.i = ($+1) % maxsamples
			
			local sum = 0
			for j = 1,#avg do
				local e = avg[j]
				sum = $+e
				avg.b = min($,e)
				avg.w = max($,e)
			end
			avg.avg = sum/#avg
		end
	end
end

rawset(_G, "PERFDISPENSE", function() return resetsnap,snap,snapcalc end)
rawset(_G, "SNAPS", snaps)
rawset(_G, "AVGS", avgs)

rawset(_G, "PERFDRAW", function(v, unit, ...)
	local labels = {...}
	for i = 1,#avgs do
		local j = i-1
		local e = avgs[i]
		local avg,bst,wst = e.avg,e.b,e.w
		
		v.drawString(180, 50+0+j*12,
			"~"..avg.."us | "..(labels[i] or "[]"), V_ALLOWLOWERCASE, "small")
		v.drawString(180, 50+4+j*12,
			"   "..bst.."us best", V_ALLOWLOWERCASE, "small")
		v.drawString(180, 50+8+j*12,
			"   "..wst.."us worst", V_ALLOWLOWERCASE, "small")
	end
end)

-- local snaps,avgs,resetsnap,snap,snapcalc = SNAPS,AVGS,PERFDISPENSE()

--[[
/* example code

local resetsnap,snap,snapcalc = PERFDISPENSE()

local function f1(...)
	--code
end

addHook("ThinkFrame", function()
	resetsnap()
	snap()
	
	f1()
	
	snap()
	snapcalc()
end)


hud.add(function(v) PERFDRAW(v,nil,
	"XD"
)end)

*/]]