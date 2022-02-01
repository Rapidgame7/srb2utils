-- originally named Fuck LIB xdd
-- Using SLADE? Do Ctrl+Shift+[ to fold everything

-- Polar 2 Cartesian stuff

rawset(_G, "p2c", function(ang, rad, m)
	if ang == nil then error("ang missing", 2) end
	if rad == nil then error("rad missing", 2) end
	if m == nil then m = {scale=FRACUNIT} end
	
	rad = FixedMul(rad, m.scale)
	return FixedMul( cos(ang), rad ), FixedMul( sin(ang), rad )
end)

rawset(_G, "p2c3d", function(hang, vang, rad, m)
	if hang == nil then error("hAng missing", 2) end
	if vang == nil then error("vAng missing", 2) end
	if rad == nil then error("rad missing", 2) end
	if m == nil then m = {scale=FRACUNIT} end
	
	rad = FixedMul(rad, m.scale)
	return FixedMul( FixedMul( rad, cos(hang) ), cos(vang) ), -- x
		   FixedMul( FixedMul( rad, sin(hang) ), cos(vang) ), -- y
		   FixedMul( rad, sin(vang) ) -- z
end)

-- aka
rawset(_G, "polar2cartesian", p2c)
rawset(_G, "polar2cartesian3D", p2c3d)
rawset(_G, "cSpd", p2c) -- legacy
rawset(_G, "cSpdEx", p2c3d) -- legacy



-- Collision checkers

rawset(_G, "collZCheck", function(m, n)
	return m.z < n.z+n.height and n.z < m.z+m.height
end)

rawset(_G, "collCheck", function(ms, ml, ns, nl)
	return ms < ns+nl and ns < ms+ml
end)

rawset(_G, "collRadiusCheck", function(m, n)
	return m.x-m.radius < n.x+n.radius and m.x+m.radius > n.x-n.radius
	   and m.y-m.radius < n.y+n.radius and m.y+m.radius > n.y-n.radius
end)




rawset(_G, "isValid", function(mo)
	return mo and mo.valid
end)



-- Value manipulation stuff

rawset(_G, "valClamp", function(v, min, max) -- Clamps value to min and max
	if min > max then
		min,max = max,min
	end
	local hasClamp = false
	if v < min then v = min;hasClamp = true end
	if v > max then v = max;hasClamp = true end
	return v, hasClamp
end)

rawset(_G, "valWrap", function(n, min, max) -- Wrap value if it surpasses either bounds
	if n == nil then error("#1 nil", 2) end
	if min == nil then error("#2 nil", 2) end
	if max == nil then error("#3 nil", 2) end
	if min > max then
		min,max = max,min
	end
	local dist = abs(min - max)+1
	while n > max do n = n - dist end
	while n < min do n = n + dist end
	return n
end)

rawset(_G, "valSplit", function(n, div) -- Divides by this much and returns two values
	local r = n/div
	return r,n-r
end)

rawset(_G, "valEpsilon", function(n, thr) -- Returns 0 if n is near zero ("near" defined by epsilon)
	if abs(n) < thr then return 0 else return n end
end)

rawset(_G, "valDist", function(v1, v2) -- Returns numerical distance between two values
	return abs(v1, v2)
end)

rawset(_G, "valSign", function(n, rel) -- Returns sign of value (relative to zero or to argument #2)
	rel = rel or 0
	if n > rel then return 1
	elseif n < rel then return -1
	else return 0 end
end)

rawset(_G, "valApproach", function(n, target, step, overshoot) -- Attempts to move n towards step.
	if step == 0 then return n end
	local dist = vDist(n, target)
	if step > 0 and abs(step) > dist and overshoot ~= true then step = dist end
	local tstep = step
	
	if n > target then tstep = -$ end
	
	return n + tstep
end)



-- ?
-- TODO HERE

local function IpointInfo(o, m) -- Returns horizontal distance, distance, horizontal angle and vertical angle from o to m.

	if m == nil then error("mobj is nil", 2) end
	
	local hdistT = R_PointToDist2(o.x, o.y, m.x, m.y)
	local hangT = R_PointToAngle2(o.x, o.y, m.x, m.y)
	local vangT = R_PointToAngle2(0, o.z, hdistT, m.z)
	local distT = R_PointToDist2(hdistT, o.z, 0, m.z)
	
	return hdistT,distT,hangT,vangT
end
rawset(_G, "pointInfo", IpointInfo)
rawset(_G, "pointToDist3D", function(o, m)
	if m == nil then error("mobj is nil", 2) end
	
	local hdistT = R_PointToDist2(o.x, o.y, m.x, m.y)
	local distT = R_PointToDist2(hdistT, o.z, 0, m.z)
	
	return distT,hdistT
end)
rawset(_G, "teleTowards", function(m, vx, vy, vz, fracmul)
	if m == nil then error("mobj is nil", 2) end
	
	hdistT,distT,hangT,vangT = IpointInfo(m, {x=vx,y=vy,z=vz})
	
	local rx,ry,rz = cSpdEx(hangT, vangT, FixedMul(distT, fracmul))
	
	if m and m.valid then P_TeleportMove(m, m.x+rx, m.y+ry, m.z+rz) end
	return rx,ry,rz
end)

rawset(_G, "getClosestSolidFlat", function(s, z, getceiling) -- Gets the closest (solid) flat relative to this Z
	
	local flats = {}
	
	local cc = s.floorheight
	if getceiling then cc = s.ceilingheight end
	flats[1] = {s, z=cc, flat=(getceiling and s.ceilingpic or s.floorpic)}
	
	local goodflags = FF_EXISTS|FF_BLOCKPLAYER
	-- Rover must exist and at least block players for this
	for rv in s.ffloors() do
		if (rv.flags & goodflags) ~= goodflags then continue end -- Not this one
		local cc = rv.topheight
		if getceiling then cc = rv.bottomheight end
		flats[#flats+1] = {rv.sector, z=cc, flat=(getceiling and rv.bottompic or rv.toppic)}
	end
	
	if not getceiling then
		table.sort(flats, function(a,b) return a.z < b.z end)
		if z < flats[1].z then return flats[1] end -- Below everything, somehow? Give up immediately
		for i = 1,#flats-1 do
			if flats[i].z <= z
			and z < flats[i+1].z then
				return flats[i]
			end
		end
		return flats[#flats] -- Above everything, somehow? Return topmost flat
	else
		table.sort(flats, function(a,b) return a.z > b.z end)
		if z > flats[1].z then return flats[1] end -- Above everything, somehow? Give up immediately
		for i = 1,#flats-1 do
			if flats[i].z >= z
			and z > flats[i+1].z then
				return flats[i]
			end
		end
		return flats[#flats] -- Below everything, somehow? Return bottommost flat
	end
end)

rawset(_G, "findValueInTable", function(t, v) -- Only returns the first instance
	for i = 1,#t do
		if t[i] == v then return i end
	end
	return nil
end)

rawset(_G, "deepcopy", function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end)
rawset(_G, "deepcompare", function(t1,t2,ignore_mt) -- snippet taken from some site
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
		local v2 = t2[k1]
		if v2 == nil or not deepcompare(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
		local v1 = t1[k2]
		if v1 == nil or not deepcompare(v1,v2) then return false end
	end
	return true
end)

rawset(_G, "randomChoose", function(t)
	if type(t) ~= "table" then error("this takes a table",2) end
	if #t == 0 then return nil end
	if #t == 1 then return t[1] end
	return t[P_RandomRange(1,#t)]
end)

rawset(_G, "shuffleTable", function(t)
	if type(t) ~= "table" then error("this takes a table",2) end
	for i = #t, 2, -1 do
		local j = P_RandomRange(1,i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end)

rawset(_G, "makeRange", function(...)
	local min,max,step = 1,1,1
	local args = {...}
	if #args >= 1 and #args <= 3 then
		max = args[1]
		if #args >= 2 then
			min = args[1]
			max = args[2]
			if #args == 3 then step = args[3] end
		end
	else error("what",2) end
	local t = {}
	for i = min,max,step do t[#t+1] = i end
	return t
end)

rawset(_G, "createFlags", function(t)
	for i = 1,#t do
		rawset(_G, t[i], 2^(i-1))
	end
end)
rawset(_G, "createEnum", function(t, from)
	if from == nil then from = 0 end
	for i = 1,#t do
		rawset(_G, t[i], from+(i-1))
	end
end)

--rawset(_G, "explodeString", function(str)
function string.explode(str)
	local tb = {}
	local quoted = false
	for word in string.gmatch(str, "[%S]+") do
		if quoted == false then
			table.insert(tb, word)
		else
			tb[#tb] = tb[#tb].." "..word
		end
		
		if word:sub(1,1) == '"' then quoted = true end
		if word:sub(-1,-1) == '"' then quoted = false end
	end
	return tb
end
--end)

rawset(_G, "makeconst", function(val, ...)
	for i = 1, select('#', ...) do
		local str = select(i, ...)
		if type(str) ~= "string" then error("Argument "..(i+1).." is not a string",2) end
		rawset(_G, str, val)
	end
end)
rawset(_G, "ifNilUseNext", function(...)
	for i = 1, select('#', ...) do
		local v = select(i, ...)
		if v ~= nil then return v end
	end
end)
rawset(_G, "fetchFromG", function(what) -- for pcall
	return _G[what]
end)

rawset(_G, "angleDiff", function(a, b, raw)
	a,b = AngleFixed($1),AngleFixed($2)
	
	-- difference between two angles
	-- returns the difference, or "sum this to A to get to B"
	
	local diff = b - a
	
	diff = $ + (180*FRACUNIT) -- % (360*FRACUNIT) - (180*FRACUNIT)
	
	while diff >= 360*FRACUNIT do diff = $ - 360*FRACUNIT end
	while diff < 0 do diff = $ + 360*FRACUNIT end
	
	diff = $ - (180*FRACUNIT)
	
	if not raw then diff = FixedAngle(diff) end
	return diff
end)