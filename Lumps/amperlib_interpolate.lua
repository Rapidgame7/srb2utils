/* borrowed base from Golden, thanks :)
-- Linear interpolation using fixed_t's!
local function FixedLineInterp(a, b, v) -- a is the beginning, b is the end, v is a number from 0 - FRACUNIT, all are fixed numbers
    -- Mathematical formula to get a number using a percentage ('v') from 'a' and 'b'.
    -- For example, when a = 5*FRACUNIT, b = 6*FRACUNIT, and v = FRACUNIT/2
    -- ( a = 5, b = 6, v = 50% )
    -- The output is 11*FRACUNIT/2 (5.5)
    return a + FixedMul(v, b - a)
end
local PI = 22*FRACUNIT/7
-- 3,142852783203125 -- chad me
-- 3,141592653589793 -- virgin math
rawset(_G, "FixedLineInterp", FixedLineInterp) -- Also we want to be nice and let every lua use this :)
*/
-- thanks Golden :)

local function FixedPow(base, exp)
	local r = base
	-- positive: base * base, repeat "* base" for exp times
    for i = 2,abs(exp) do
        r = FixedMul($,base)
    end
	-- negative: 1 / base^exp
	if exp < 0 then
		r = FixedDiv(FRACUNIT,r)
	end
    return r
end

-- fixed_t p
-- given progression p, returns appropiate result
-- p ==        0: start of animation (usually 0)
-- p == FRACUNIT: end of animation (usually FRACUNIT)
local function IFN_LINEAR(p)
	-- linear: p is essentially a percentage
	return FixedMul(FRACUNIT, p)
end
local function IFN_EASEINQUINT(p)
	-- return x*x*x*x*x
	return FixedPow(p, 5)
end
local function IFN_EASEOUTQUINT(p)
	-- return 1 - pow(1 - x, 5);
	return FRACUNIT - FixedPow(FRACUNIT - p, 5)
end
local function FixedInterp(a, b, p, f)
	-- fixed_t a, fixed_t b, fixed_t p, function f
	-- Uses f to interpolate a to b on line position p
	-- p ranges from 0 (start) to FRACUNIT (end), other values are capped
	
	if not f then f = IFN_LINEAR end -- If no interpolation is chosen, use linear interpolation
	p = max(0,min(FRACUNIT,$)) -- cap
	return a + FixedMul(b-a, f(p))
end

rawset(_G, "FixedInterp", FixedInterp)
rawset(_G, "FixedPow", FixedPow)

rawset(_G, "IFN_LINEAR", IFN_LINEAR)
rawset(_G, "IFN_EASEINQUINT", IFN_EASEINQUINT)
rawset(_G, "IFN_EASEOUTQUINT", IFN_EASEOUTQUINT)



/*
print(arg)
print(args)





local FRACTIME = FRACUNIT/TICRATE

hud.add(function(v,p,c)
	local x,y = 40,100
	--local ix = FixedInterp(a, b, p, f)
	local x = FixedInterp(40*FRACUNIT, 100*FRACUNIT, FRACTIME*(leveltime % 40), IFN_LINEAR)/FRACUNIT
	v.drawString(x, y+00, "lnr"..x)
	local x = FixedInterp(40*FRACUNIT, 100*FRACUNIT, FRACTIME*(leveltime % 40), IFN_EASEINQUINT)/FRACUNIT
	v.drawString(x, y+08, "eiq"..x)
	local x = FixedInterp(40*FRACUNIT, 100*FRACUNIT, FRACTIME*(leveltime % 40), IFN_EASEOUTQUINT)/FRACUNIT
	v.drawString(x, y+16, "eoq"..x)
end, "game")
*/


















