-- naive implementation of quaternions tailored for srb2
-- half borrowed from bjornbytes/maf.lua and modified for my purposes
-- i say half because unlike vec3 i didn't understand it :)

/*
for me so i don't forget:
a quarternion is not normally for what is going to be explained but who the fuck cares
a quaternion is used for orientation
a quarternion is comprised of four values: w, x, y, z
x,y,z comprises an axis (because of this, they shouldn't be zero! where does a zero vector aim to???)
w represents something akin to "progress around the axis", from [-1,1]
*/

local qtmp1
local quat

--rawset(_G, "quat", {
quat = {
	__call = function(_,w,x,y,z)
		--return setmetatable({w = w or FRACUNIT, x = x or 0, y = y or 0, z = z or 0}, quat)
		-- because of srb2 i can't actually do this, thanks you'r
		local ww = FRACUNIT
		if w ~= nil then ww = w end
		return setmetatable({w = ww, x = x or 0, y = y or 0, z = z or 0}, quat)
	end,
	
	__tostring = function(q)
		return string.format('(%d, %d, %d, %d)', q.x/FRACUNIT, q.y/FRACUNIT, q.z/FRACUNIT, q.w/FRACUNIT)
	end,
	
	__add = function(q, o) return q:add(o) end,
	__sub = function(q, o) return q:sub(o) end,
	__mul = function(q, o)
		if quat.isquat(o) then return q:mul(o)
		--elseif vec3.isvec3(o) then return r:rotate(q)
		else error("can only operate with other quats or vec3s",2) end --or fixed point
	end,
	/*__div = function(q, o)
		if quat.isquat(o) then return q:div(o)
		--elseif type(o) == 'number' then return q:scale(1 / u, quat())
		--elseif type(o) == 'number' then return q:scale(FixedDiv(FRACUNIT, o)) -- Prevent issues
		--elseif type(o) == 'number' then return q:nscale(FixedDiv(FRACUNIT, o)) -- Prevent issues
		else error("can only operate with other quats",2) end --or fixed point
		--else error("can only operate with other quats or integers",2) end --or fixed point
	end,*/ -- that would be a wee bit weird
	
	__unm = function(q) return q:scale(-1) end,
	__len = function(q) return q:length() end,
	
	__index = {
		-- should probably be a function?
		-- that way we check for the quatlity of q
		-- if called directly from the global
		
		tostring = function(q)
			return string.format('(%d, %d, %d, %d)', q.w/FRACUNIT, q.x/FRACUNIT, q.y/FRACUNIT, q.z/FRACUNIT)
		end,
		tostringFixed = function(q)
			return string.format('(%d, %d, %d, %d)', q.w, q.x, q.y, q.z)
		end,
		
		isquat = function(x)
			return getmetatable(x) == quat
		end,
		
		set = function(q,w,x,y,z)
			if quat.isquat(w) then w,x,y,z = w.w,w.x,w.y,w.z end
			q.w,q.x,q.y,q.z = w,x,y,z
			return q
		end,
		
		clone = function(q)
			return quat(q.w, q.x, q.y, q.z)
		end,
	
		unpack = function(q)
			return q.w, q.x, q.y, q.z
		end,
		
		add = function(q,o)
			q.w = $ + o.w
			q.x = $ + o.x
			q.y = $ + o.y
			q.z = $ + o.z
			return q
		end,
		
		sub = function(q,o)
			q.w = $ - o.w
			q.x = $ - o.x
			q.y = $ - o.y
			q.z = $ - o.z
			return q
		end,
		
		mul = function(q,o)
			q.w = FixedMul($, o.w)
			q.x = FixedMul($, o.x)
			q.y = FixedMul($, o.y)
			q.z = FixedMul($, o.z)
			return q
		end,
		scale = function(q,n)
			q.w = FixedMul($, n)
			q.x = FixedMul($, n)
			q.y = FixedMul($, n)
			q.z = FixedMul($, n)
			return q
		end,
		
		div = function(q,o)
			q.w = FixedDiv($, o.w)
			q.x = FixedDiv($, o.x)
			q.y = FixedDiv($, o.y)
			q.z = FixedDiv($, o.z)
			return q
		end,
		
		length = function(q)
			-- return math.sqrt(q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z)
			-- yeah no that's fucking stupid, instead:
			--return R_PointToDist2(0, 0, R_PointToDist2(0, 0, q.x, q.y), q.z)
			return FixedHypot(FixedHypot(FixedHypot(q.x, q.y), q.z), q.w)
		end,
		
		
		-- And now for the funny!
		
		
		
		
		normalize = function(q)
			local len = q:length()
			--return len == 0 and q or q:scale(1 / len, out)
			return len == 0 and q or q:scale(FixedDiv(FRACUNIT, len))
		end,
	}
}

registerMetatable(quat)

setmetatable(quat, quat)

vtmp1 = quat()
vtmp2 = quat()

rawset(_G, "quat", quat)