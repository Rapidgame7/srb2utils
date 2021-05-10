// Fuck LIB xdd

rawset(_G, "collZCheck", function(m, n)
	return m.z < n.z+n.height and m.z+m.height > n.z
end)
rawset(_G, "collRadiusCheck", function(m, n)
	return m.x-m.radius < n.x+n.radius and m.x+m.radius > n.x-n.radius
	   and m.y-m.radius < n.y+n.radius and m.y+m.radius > n.y-n.radius
end)
rawset(_G, "collCheck", function(mz, mh, nz, nh)
	return mz < nz+nh and mz+mh > nz
end)

rawset(_G, "isValid", function(mo)
	return mo and mo.valid
end)

rawset(_G, "getDelta", function(x1,y1,z1,x2,y2,z2)
	//print("PRONT",x1,y1,z1,x2,y2,z2,"END PRONT")
	local r = R_PointToDist2(R_PointToDist2(x1, y1, x2, y2), z1, 0, z2)
	return r
end)
rawset(_G, "getPackDelta", function(s1,s2)
	// Assumes s1 and s2 are two sets of coords or have coords
	local x1,y1,z1 = s1.x,s1.y,s1.z
	if x1 == nil then x1,y1,z1 = s1[1],s1[2],s1[3] end
	local x2,y2,z2 = s2.x,s2.y,s2.z
	if x2 == nil then x2,y2,z2 = s2[1],s2[2],s2[3] end
	return getDelta(x1,y1,z1,x2,y2,z2)
end)

rawset(_G, "explodeString", function(str)
	local tb = {}
	local quoted = false
	for word in string.gmatch(str, "[%S]+") do
		if quoted == false then
			table.insert(tb, word)
		else
			tb[#tb] = tb[#tb].." "..word
		end
		
		if word:sub(1,1) == "\"" then quoted = true end
		if word:sub(-1,-1) == "\"" then quoted = false end
	end
	return tb
end)

rawset(_G, "vClamp", function(v, min, max) // Clamps value to min and max
	if min > max then
		min,max = max,min
	end
	local hasClamp = false
	if v < min then v = min;hasClamp = true end
	if v > max then v = max;hasClamp = true end
	return v, hasClamp
end)
rawset(_G, "vWrap", function(n, min, max) // Wraps around
	if min > max then
		min,max = max,min
	end
	local dist = abs(min - max)
	while n > max do n = n - dist end
	while n < min do n = n + dist end
	return n
end)
rawset(_G, "vWrapSuper", function(n, min, max) // Wraps around even better (?)
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

rawset(_G, "vSplit", function(n, div) // Divides by this much and returns two values
	local r = n/div
	return r,n-r
end)

rawset(_G, "vClose", function(n, thr) // Returns 0 if below threshold
	if abs(n) < thr then return 0 else return n end
end)

rawset(_G, "vDist", function(v, t) // Returns numerical distance between two values
	return abs(v - t)
end)

rawset(_G, "vSign", function(n, rel) // Returns sign of value, or relative to another value
	if relativeto == nil then
		if n > 0 then return 1
		elseif n < 0 then return -1
		else return 0 end
	else
		if n > rel then return 1
		elseif n < rel then return -1
		else return 0 end
	end
end)

rawset(_G, "vApproach", function(n, target, step, overshoot) // Tries to reach target
	if step == 0 then return n end
	local dist = vDist(n, target)
	if step > 0 and abs(step) > dist and overshoot ~= true then step = dist end
	local tstep = step
	
	if n > target then tstep = -$ end
	
	return n + tstep
end)
rawset(_G, "pointInfo", function(o, m)

	if m == nil then error("mobj is nil", 2) end
	
	local hdistT = R_PointToDist2(o.x, o.y, m.x, m.y)
	local hangT = R_PointToAngle2(o.x, o.y, m.x, m.y)
	local vangT = R_PointToAngle2(0, o.z, hdistT, m.z)
	local distT = R_PointToDist2(hdistT, o.z, 0, m.z)
	
	return hdistT,distT,hangT,vangT
end)
rawset(_G, "pointToDist3D", function(o, m)
	if m == nil then error("mobj is nil", 2) end
	
	local hdistT = R_PointToDist2(o.x, o.y, m.x, m.y)
	local distT = R_PointToDist2(hdistT, o.z, 0, m.z)
	
	return distT,hdistT
end)
rawset(_G, "cSpd", function(ang, spd, m)
	if m == nil then m = {scale=FRACUNIT} end
	spd = FixedMul(spd, m.scale)
	return FixedMul( cos(ang), spd ), FixedMul( sin(ang), spd )
	//returns x and y of calc
end)
rawset(_G, "cSpdEx", function(hang, vang, spd, m)
	if hang == nil then error("hAng missing", 2) end
	if vang == nil then error("vAng missing", 2) end
	if spd == nil then error("spd missing", 2) end
	if m == nil then m = {scale=FRACUNIT} end
	spd = FixedMul(spd, m.scale)
	local x = FixedMul( FixedMul( spd, cos(hang) ), cos(vang) )
	local y = FixedMul( FixedMul( spd, sin(hang) ), cos(vang) )
	local z = FixedMul( spd, sin(vang) )
	return x,y,z
	//returns x and y of calc
end)
rawset(_G, "launchAbsolute", function(m, hang, vang, spd)
	// Uses cSpdEx to immediately launch some dumb brick lmao
	local cx,cy,cz = cSpdEx(hang,vang,spd,m)
	m.momx = cx
	m.momy = cy
	m.momz = cz
end)
rawset(_G, "launchScatter", function(m, spd)
	--launchAbsolute(mom, p.mo.angle, p.aiming, 12*FRACUNIT)
	local ha = FixedAngle(P_RandomRange(0,359)*FRACUNIT)
	local va = FixedAngle(P_RandomRange(0,90)*FRACUNIT)
	launchAbsolute(m, ha, va, spd)
end)
rawset(_G, "teleTowards", function(m, vx, vy, vz, fracmul)

	if m == nil then error("mobj is nil", 2) end
	
	local hdistT = R_PointToDist2(m.x, m.y, vx, vy)
	local hangT = R_PointToAngle2(m.x, m.y, vx, vy)
	local vangT = R_PointToAngle2(0, m.z, hdistT, vz)
	local distT = R_PointToDist2(hdistT, m.z, 0, vz)
	
	local rx,ry,rz = cSpdEx(hangT, vangT, FixedMul(distT, fracmul))
	
	if m and m.valid then P_TeleportMove(m, m.x+rx, m.y+ry, m.z+rz) end
	return rx,ry,rz
end)

local function getClosestBottomFlatFromThisPosition(s, z)
	// Checks all rovers, disregards intangible (non-solid) ones,
	// and fuck off
	
	local flats = {}
	// Add the sector flat, since it is a flat after all lol
	flats[1] = {s,z=s.floorheight}
	local goodflags = FF_EXISTS|FF_BLOCKPLAYER
	// Rover must exist and block players for this to even be a boost panel
	for rv in s.ffloors() do
		if (rv.flags & goodflags) ~= goodflags then continue end // Not this one
		flats[#flats+1] = {rv.sector, z=rv.topheight}
	end
	table.sort(flats, function(a,b) return a.z < b.z end)
	
	if z < flats[1].z then return flats[1] end // Below everything, somehow? Give up immediately
	for i = 1,#flats-1 do
		if flats[i].z <= z
		and z < flats[i+1].z then
			return flats[i]
		end
	end
	return flats[#flats] // Above everything, somehow? Return topmost flat
end

rawset(_G, "getClosestSolidFlat", function(s, z, getceiling)
	// Gets the closest (solid) flat relative to this Z
	// Returns both the flat texture and the relevant sector/control sector
	
	local flats = {}
	
	local cc = s.floorheight
	if getceiling then cc = s.ceilingheight end
	flats[1] = {s, z=cc, flat=(getceiling and s.ceilingpic or s.floorpic)}
	
	local goodflags = FF_EXISTS|FF_BLOCKPLAYER
	// Rover must exist and at least block players for this
	for rv in s.ffloors() do
		if (rv.flags & goodflags) ~= goodflags then continue end // Not this one
		local cc = rv.topheight
		if getceiling then cc = rv.bottomheight end
		flats[#flats+1] = {rv.sector, z=cc, flat=(getceiling and rv.bottompic or rv.toppic)}
	end
	
	if not getceiling then
		table.sort(flats, function(a,b) return a.z < b.z end)
		if z < flats[1].z then return flats[1] end // Below everything, somehow? Give up immediately
		for i = 1,#flats-1 do
			if flats[i].z <= z
			and z < flats[i+1].z then
				return flats[i]
			end
		end
		return flats[#flats] // Above everything, somehow? Return topmost flat
	else
		table.sort(flats, function(a,b) return a.z > b.z end)
		if z > flats[1].z then return flats[1] end // Above everything, somehow? Give up immediately
		for i = 1,#flats-1 do
			if flats[i].z >= z
			and z > flats[i+1].z then
				return flats[i]
			end
		end
		return flats[#flats] // Below everything, somehow? Return bottommost flat
	end
end)










rawset(_G, "findValueInTable", function(t, v) // Only returns the first instance
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


local cvd = CV_RegisterVar({"showdebug", "1", 0, CV_YesNo})
rawset(_G, "recursiveTableContents", function(dw, pos, t, level)
	if not cvd.value then return end
	if level == nil then level = 0 end
	if level == 0 then
		local ttype = type(t)
		if type(pos) ~= "table" then error("arg POS not a table",2) end
		if ttype ~= "table" then error("arg TABLE not a table, is "..ttype,2) end
	end
	for k,v in pairs(t) do
		local str = type(v)
		
		if str == "number" or str == "string" then str = v
		elseif str == "boolean" then str = v and "true" or "false" end
		
		dw.drawString(pos.x, pos.y, string.rep("  ",level)..k.." \131"..str, V_ALLOWLOWERCASE, "small")
		pos.y = $+4
		
		if type(v) == "table" then
			if not v._RECURSIVEHIDE then
				recursiveTableContents(dw, pos, v, level+1)
			else
				dw.drawString(pos.x, pos.y, string.rep("  ",level+1).."\131".."hidden", V_ALLOWLOWERCASE, "small")
				pos.y = $+4
			end
		end
	end
end)

