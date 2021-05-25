-- naive implementation of vector3 tailored for srb2
-- borrowed from bjornbytes/maf.lua and modified for my purposes

/*

*/

local vtmp1
local vtmp2
local vec3

--rawset(_G, "vec3", {
vec3 = {
	__call = function(_,x,y,z)
		return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vec3)
	end,
	
	__tostring = function(v)
		return string.format('(%d, %d, %d)', v.x/FRACUNIT, v.y/FRACUNIT, v.z/FRACUNIT)
	end,
	
	__add = function(v, o) return v:add(o) end,
	__sub = function(v, o) return v:sub(o) end,
	__mul = function(v, o)
		if vec3.isvec3(o) then return v:mul(o)
		--elseif type(o) == 'number' then return v:scale(o)
		elseif type(o) == 'number' then return v:iscale(o)
		else error("can only operate with other vec3s or integers",2) end --or fixed point
	end,
	__div = function(v, o)
		if vec3.isvec3(o) then return v:div(o)
		--elseif type(o) == 'number' then return v:scale(1 / u, vec3())
		--elseif type(o) == 'number' then return v:scale(FixedDiv(FRACUNIT, o)) -- Prevent issues
		--elseif type(o) == 'number' then return v:nscale(FixedDiv(FRACUNIT, o)) -- Prevent issues
		else error("can only operate with other vec3s",2) end --or fixed point
		--else error("can only operate with other vec3s or integers",2) end --or fixed point
	end,
	__unm = function(v) return v:scale(-1) end,
	__len = function(v) return v:length() end,
	
	__index = {
		-- should probably be a function?
		-- that way we check for the vec3lity of v
		-- if called directly from the global
		
		tostring = function(v)
			return string.format('(%d, %d, %d)', v.x/FRACUNIT, v.y/FRACUNIT, v.z/FRACUNIT)
		end,
		tostringFixed = function(v)
			return string.format('(%d, %d, %d)', v.x, v.y, v.z)
		end,
		
		isvec3 = function(x)
			return getmetatable(x) == vec3
		end,
		
		set = function(v,x,y,z)
			if vec3.isvec3(x) then x,y,z = x.x,x.y,x.z end
			v.x,v.y,v.z = x,y,z
			return v
		end,
		
		clone = function(v)
			return vec3(v.x, v.y, v.z)
		end,
	
		unpack = function(v)
			return v.x, v.y, v.z
		end,
		
		add = function(v,o)
			v.x = $ + o.x
			v.y = $ + o.y
			v.z = $ + o.z
			return v
		end,
		
		sub = function(v,o)
			v.x = $ - o.x
			v.y = $ - o.y
			v.z = $ - o.z
			return v
		end,
		
		mul = function(v,o)
			v.x = FixedMul($, o.x)
			v.y = FixedMul($, o.y)
			v.z = FixedMul($, o.z)
			return v
		end,
		scale = function(v,n)
			v.x = FixedMul($, n)
			v.y = FixedMul($, n)
			v.z = FixedMul($, n)
			return v
		end,
		iscale = function(v,n)
			v.x = $ * n
			v.y = $ * n
			v.z = $ * n
			return v
		end,
		invert = function(v)
			return v:scale(-FRACUNIT)
		end,
		
		div = function(v,o)
			v.x = FixedDiv($, o.x)
			v.y = FixedDiv($, o.y)
			v.z = FixedDiv($, o.z)
			return v
		end,
		idiv = function(v,n) -- incomplete?
			--v:scale(FixedDiv(FRACUNIT, o))
			v.x = $ / n
			v.y = $ / n
			v.z = $ / n
			return v
		end,
		
		length = function(v)
			-- return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
			-- yeah no that's fucking stupid, instead:
			--return R_PointToDist2(0, 0, R_PointToDist2(0, 0, v.x, v.y), v.z)
			return FixedHypot(FixedHypot(v.x, v.y), v.z)
		end,
		
		normalize = function(v)
			local len = v:length()
			--return len == 0 and v or v:scale(1 / len, out)
			return len == 0 and v or v:scale(FixedDiv(FRACUNIT, len))
		end,
		
		dot = function(v,o) -- returns single number representing "perpendicularity"
			-- positive if both head the same direction, negative otherwise
			-- approaching zero if approaching perpendicularity
			return FixedMul(v.x, o.x) + FixedMul(v.y, o.y) + FixedMul(v.z, o.z)
		end,
	
		cross = function(v,o)
			-- vector heading is 0 if vectors are parallel
			-- assuming v and o are in same plane:
			-- A to the left of B: heading is down
			-- A to the right of B: heading is up
			local out = vec3()
			--local a, b, c = v.x, v.y, v.z
			out.x = FixedMul(v.y, o.z) - FixedMul(o.y, v.z)
			out.y = FixedMul(v.z, o.x) - FixedMul(o.z, v.x)
			out.z = FixedMul(v.x, o.y) - FixedMul(o.x, v.y)
			return out
		end,
		
		angle = function(v, u) -- thanks kays
			--return math.acos(v:dot(u) / (v:length() + u:length()))
			local adjacent = FixedDiv(v:dot(u), (v:length() + u:length())) -- assume hypotenuse of 1 and cosine becomes adjacent/1
			local opposite = FixedSqrt(FRACUNIT - FixedMul(adjacent, adjacent)) -- FRACUNIT is 1^2
			
			return R_PointToAngle2(0, 0, adjacent, opposite)
		end,
		
		/*
		distance = function(v, u)
			return vec3.sub(v, u, vtmp1):length()
		end,
		*/
		distance = function(v,o)
			--return vec3.sub(v, u, vtmp1):length()
			--return v:clone():sub(o):length()
			return vtmp1:set(v):sub(o):length()
		end,
		
		/*
		project = function(v, u, out)
			out = out or v
			local unorm = vtmp1
			u:normalize(unorm)
			local dot = v:dot(unorm)
			out.x = unorm.x * dot
			out.y = unorm.y * dot
			out.z = unorm.z * dot
			return out
		end,
		*/
		project = function(v, n)
			local norm = vtmp1
			norm:set(n):normalize()
			local dot = v:dot(norm)
			v.x = FixedMul(norm.x, dot)
			v.y = FixedMul(norm.y, dot)
			v.z = FixedMul(norm.z, dot)
			return v
		end,
		
		/*
		lerp = function(v, u, t, out)
			out = out or v
			out.x = v.x + (u.x - v.x) * t
			out.y = v.y + (u.y - v.y) * t
			out.z = v.z + (u.z - v.z) * t
			return out
		end,
		*/
		
		/*
		rotate = function(v, q, out)
			out = out or v
			local u, c, o = vtmp1, vtmp2, out
			u.x, u.y, u.z = q.x, q.y, q.z
			o.x, o.y, o.z = v.x, v.y, v.z
			u:cross(v, c)
			local uu = u:dot(u)
			local uv = u:dot(v)
			o:scale(q.w * q.w - uu)
			u:scale(2 * uv)
			c:scale(2 * q.w)
			return o:add(u:add(c))
		end
		*/
		rotate = function(v, q, out)
			-- not implemented yet - don't use
			out = out or v
			local u, c, o = vtmp1, vtmp2, out
			u.x, u.y, u.z = q.x, q.y, q.z
			o.x, o.y, o.z = v.x, v.y, v.z
			u:cross(v, c)
			local uu = u:dot(u)
			local uv = u:dot(v)
			o:scale(q.w * q.w - uu)
			u:scale(2 * uv)
			c:scale(2 * q.w)
			return o:add(u:add(c))
		end,
		
		/*
		function v_reflect( v, n )
		local dot = v_dot( v, n )
		local wdnv = v_mults( v_mults( n, dot ), 2.0 )
		local refv = v_subv( v, wdnv )
		return refv
		end
		
		http://www.3dkingdoms.com/weekly/weekly.php?a=2 says:
		Vnew = -2*(V dot N)*N + V
		
		if projection is (V dot N)*N then...
		-2 * proj(v,n) + V
		*/
		
		reflect = function(v,n)
			--return = v:dot(n):scale(-2*FRACUNIT):mul(n):add(v)
			return v:project(n):scale(-2*FRACUNIT):add(v)
		end,
		
		toCartesian = function(v, rad,hang,vang)
			-- args: f(vec3 v)
			-- translates v's coords to cartesian
			-- args: f(vec3 v, vec3 rad)
			-- translates rad to cartesian and sets v with it
			-- args: f(vec3 v, fixed_t rad, angle_t azimuth, [angle_t polar=0])
			-- translates given coordinates to cartesian and sets v with it
			
			-- by iso specifications, the order of arguments is as follows:
			-- rad theta phi
			-- rad is... rad, theta is polar, phi is azimuth
			-- rad being distance from origin,
			-- polar being angle with respect of polar axis, [vang]
			-- azimuth being angle of rotation from initial meridian plane. [hang]
			-- but it is in my belief that hang is more important than vang
			-- so those two positions get swapped
			-- math books do it, why can't i?
			-- get FUCKED, STUPID
			
			--local rad,hang,vang -- source vals
			if hang ~= nil then -- all(?) values entered directly(?)
				vang = $ or 0 -- make sure it is *something*
				 --rad,hang,vang = x,y,z -- yeah i don't need to do that - it's all set, right?
			elseif vec3.isvec3(rad) then -- rad is vector?
				 rad,hang,vang = rad:unpack()
			else
				rad,hang,vang = v:unpack() -- okay then it's just us i guess lo
			end
			if vang ~= 0 then
				v:set(
					FixedMul( FixedMul( rad, cos(hang) ), cos(vang) ),
					FixedMul( FixedMul( rad, sin(hang) ), cos(vang) ),
					FixedMul( rad, sin(vang) )
				)
			else -- lite version
				v:set(
					FixedMul( rad, cos(hang) ),
					FixedMul( rad, sin(hang) ),
					0
				)
			end
			return v
		end,
		toPolar = function(v)
			-- assumes xyz refer to cartesian coordinates
			-- nvm too hard
			
			-- local rad, phi, theta =
		end,
		
		newFromPolar = function(v, hang, vang, rad)
			/*
			spd = FixedMul(spd, m.scale)
			local x = FixedMul( FixedMul( spd, cos(hang) ), cos(vang) )
			local y = FixedMul( FixedMul( spd, sin(hang) ), cos(vang) )
			local z = FixedMul( spd, sin(vang) )
			return x,y,z
			*/
			
		end,
	}
}

registerMetatable(vec3)

setmetatable(vec3, vec3)

vtmp1 = vec3()
vtmp2 = vec3()

rawset(_G, "vec3", vec3)