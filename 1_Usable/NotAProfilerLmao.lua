-- Not A Profiler Lmao

local gtm = getTimeMicros

local maxsamples = TICRATE*10

local snaps = {}
local avgs = {}
local function resetsnap() snaps = {} end
local function snap()
	snaps[#snaps+1] = gtm()
end

local function snapcalc()
	local samp = 0
	for i = 1,#snaps-1 do
		local c,n = snaps[i],snaps[i+1]
		if p~=nil then
			avgs[i] = $ or {i=0,b=INT32_MAX,w=INT32_MIN}
			local avg = avgs[i]
			
			samp = max(#avg, $)
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
	avgs.sps = samp
end

rawset(_G, "PERFDISPENSE", function() return resetsnap,snap,snapcalc end)
rawset(_G, "SNAPS", snaps)
rawset(_G, "AVGS", avgs)

rawset(_G, "PERFDRAW", function(v, unit, ...)
	local labels = {...}
	local sx,sy = 180,50
	v.drawString(sx, sy-16, ("%3d/%3d SAMPLES"):format(avgs.sps, maxsamples), V_ALLOWLOWERCASE, "small")
	for i = 1,#avgs do
		local j = i-1
		local e = avgs[i]
		local avg,bst,wst = e.avg,e.b,e.w
		
		v.drawString(sx, sy+0+j*12,
			"~"..avg.."us | "..(labels[i] or "[]"), V_ALLOWLOWERCASE, "small")
		v.drawString(sx, sy+4+j*12,
			"   "..bst.."us best", V_ALLOWLOWERCASE, "small")
		v.drawString(sx, sy+8+j*12,
			"   "..wst.."us worst", V_ALLOWLOWERCASE, "small")
	end
end)

-- local snaps,avgs,resetsnap,snap,snapcalc = SNAPS,AVGS,PERFDISPENSE()