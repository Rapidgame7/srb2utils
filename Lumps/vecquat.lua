-- naive (and incomplete) implementation of vector3 and quaternions tailored for srb2
-- some of it borrowed from bjornbytes/maf.lua and modified for & my purposes &
-- kind of, at least, because after all of this i still have no idea how well this works. yay!

/*

*/

local vtmp1
local vtmp2
local vec3

local qtmp1
local quat

local qattr = {"w","x","y","z"}

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
		
		/*
			RotateVectorQuaternion(vec3 vector, quat quaternion)
			- add w=0 component to vector
			- temp < clone(quaternion)
			- temp < temp*vector
			- vector < conjugate(quaternion)
			- vector < temp*vector
			- remove w component from vector
			-- ACIDENTALLY COMPLETE IN quat.mul
		*/
		rotate_test = function(v, q)
			local qq = q:clone()
			local r = qq:mul(v)
			return v:set(r.x, r.y, r.z)
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

/*
for me so i don't forget:
a quarternion is not normally for what is going to be explained but who the fuck cares
a quaternion is used for orientation
a quarternion is comprised of four values: w, x, y, z
x,y,z comprises an axis (because of this, they shouldn't be zero! where does a zero vector aim to???)
w represents something akin to "progress around the axis", from [-1,1]
*/
--rawset(_G, "quat", {
quat = { -- ay, if it helps, "q" often refers to this quaternion, and "o" to "Other"
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
			if not quat.isquat(q) then error("not quat, please leave",2) end
			if quat.isquat(o) then
				/*  Quaternion q;
					q.W = W * rhs.W - X * rhs.X - Y * rhs.Y - Z * rhs.Z;
					q.X = X * rhs.W + W * rhs.X + Y * rhs.Z - Z * rhs.Y;
					q.Y = W * rhs.Y - X * rhs.Z + Y * rhs.W + Z * rhs.X;
					q.Z = W * rhs.Z + X * rhs.Y - Y * rhs.X + Z * rhs.W;
					*this = q;
					return *this;
				*/
				// do multiplication first because of course we do that otherwise it looks awful
				local m = {} -- it was going to be called "matrixgaming" but writing that multiple times sucks
				-- let qattr be {"w","x","y","z"}
				for i1 = 1,4 do local c1 = qattr[i1]
				for i2 = 1,4 do local c2 = qattr[i2]
					m[c1..c2] = FixedMul(q[c1], o[c2])
				end end
				-- and then we
				q.w = m.ww - m.xx - m.yy - m.zz
				q.x = m.wx + m.xw + m.yz - m.zy
				q.y = m.wy - m.xz + m.yw + m.zx
				q.z = m.wz + m.xy - m.yx + m.zw
				
			elseif vec3.isvec3(o) then
				/*
				https://stackoverflow.com/questions/4870393/rotating-coordinate-system-via-a-quaternion
				Quaternion-vector multiplication is then a matter of converting your vector
				into a quaternion (by setting w = 0 and leaving x, y, and z the same)
				and then multiplying q * v * q_conjugate(q):
				
				def qv_mult(q1, v1):
					q2 = (0.0,) + v1
					return q_mult(q_mult(q1, q2), q_conjugate(q1))[1:]
				
				-- Rotation (around the origin)
				-- Pout = q * Pin * conj(q)
				-- http://www.euclideanspace.com/maths/algebra/realNormedAlgebra/quaternions/transforms/index.htm
				
				
					RotateVectorQuaternion(vec3 vector, quat quaternion)
					- add w=0 component to vector
					- temp < clone(quaternion)
					- temp < temp*vector
					- vector < conjugate(quaternion)
					- vector < temp*vector
					- remove w component from vector
				*/
				
				local qc = q:clone() -- quaternion clone
				local qcj = q:clone():conjugate() -- quaternion clone conjugate
				local qv = quat(0, o.x, o.y, o.z) -- quaternion vector
				
				--local qr = quat.mul(quat.mul(q1, q2), q1:conjugate())
				local qr = quat.mul(quat.mul(qc, qv), qcj) -- quaternion result
				
				q:set(qr)
				return q
				
			else
				-- i should probably throw an error here
				q.w = FixedMul($, o.w)
				q.x = FixedMul($, o.x)
				q.y = FixedMul($, o.y)
				q.z = FixedMul($, o.z)
			end
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
		-- some sources:
		-- https://gist.github.com/ColonelThirtyTwo/1735522
		-- https://github.com/MartinWeigel/Quaternion/blob/master/Quaternion.c (not really)
		-- https://stackoverflow.com/questions/4870393/rotating-coordinate-system-via-a-quaternion
		
		/*
		def axisangle_to_q(v, theta):
			v = normalize(v)
			x, y, z = v
			theta /= 2
			w = cos(theta)
			x = x * sin(theta)
			y = y * sin(theta)
			z = z * sin(theta)
			return w, x, y, z
		
		--- Converts <ang> to a quaternion
		function Quaternion.fromAngle(ang)
			local p, y, r = ang.p, ang.y, ang.r
			p = p*deg2rad*0.5
			y = y*deg2rad*0.5
			r = r*deg2rad*0.5
			local qr = {cos(r), sin(r), 0, 0}
			local qp = {cos(p), 0, sin(p), 0}
			local qy = {cos(y), 0, 0, sin(y)}
			return qmul(qy,qmul(qp,qr))
		end
		
		
		
		def axisangle_to_q(v, theta):
			v = normalize(v)
			x, y, z = v
			theta /= 2
			w = cos(theta)
			x = x * sin(theta)
			y = y * sin(theta)
			z = z * sin(theta)
			return w, x, y, z
		*/
		
		/*
			--- Rotate a quaternion a given number of degrees around the given axis.
			--- @param quaternion base The quaternion to rotate.
			--- @param vector3 normal The normal to rotate vector around.
			--- @param angle angle The angle to rotate vector by.
			RotateQuaternion(quat base, vec3 normal, angle_t angle)
			- temp < AngleAxisToQuat(normal, angle) (is this correct??)
			local sinhalf = sin(angle/2)
			local temp = {
				w = cos(angle/2),
				x = FixedMul(normal.x, sinhalf),
				y = FixedMul(normal.y, sinhalf),
				z = FixedMul(normal.z, sinhalf),
			}
			- base < temp*base
			- base < Normalize(base)
		*/
		
		-- Based on RotateQuaternion(quat base, vec3 normal, angle_t angle):
		-- Rotate <base> this much (<angle>) around the <normal> axis.
		-- @param quat base The quaternion to rotate.
		-- @param vec3 normal The axis the rotation will be done around.
		-- @param angle_t angle The "how much".
		-- @return an epic quaternion!
		rotate_test = function(base, normal, angle)
			local q = fromAxisAngle(normal, angle)
			q:mul(base)
			q:normalize()
			return q
		end,
		
		/*setBetween = function(q, u, v)
			local dot = u:dot(v)
			if dot > .99999 then
				q.x, q.y, q.z, q.w = 0, 0, 0, 1
				return q
			elseif dot < -.99999 then
				vtmp1.x, vtmp1.y, vtmp1.z = 1, 0, 0
				vtmp1:cross(u)
				if #vtmp1 < .00001 then
					vtmp1.x, vtmp1.y, vtmp1.z = 0, 1, 0
					vtmp1:cross(u)
				end
				vtmp1:normalize()
				return q:setAngleAxis(math.pi, vtmp1)
			end
			
			q.x, q.y, q.z = u.x, u.y, u.z
			vec3.cross(q, v)
			q.w = 1 + dot
			return q:normalize()
		end,*/
		
		-- Creates a quaternion that represents a rotation of <angle> around <axis>.
		-- @param vec3 axis The axis.
		-- @param angle_t angle Take a guess.
		-- @return A quaternion.
		fromAxisAngle = function(axis, angle)
			axis:normalize()
			--local q = quat(0, axis:unpack())
			local q = quat(0, axis.x, axis.y, axis.z)
			local theta = angle/2
			local sintheta = sin(theta)
			q.w = cos(theta)
			q.x = FixedMul($, sintheta)
			q.y = FixedMul($, sintheta)
			q.z = FixedMul($, sintheta)
			return q
		end,
		
		-- From a vector containing euler angles, returns a quaternion.
		-- @param quat q Quaternion.
		-- @param vec3 v A vector containing epic angle_ts in the form of yaw/pitch/roll
		-- @return That same quaternion but with... the thing. Yea
		fromEulerZYX = function(q, v)
			/*
			w = c1 c2 c3 - s1 s2 s3
			x = s1 s2 c3 + c1 c2 s3
			y = s1 c2 c3 + c1 s2 s3
			z = c1 s2 c3 - s1 c2 s3
			
			where:
			
			c1 = cos(heading / 2)
			c2 = cos(attitude / 2)
			c3 = cos(bank / 2)
			s1 = sin(heading / 2)
			s2 = sin(attitude / 2)
			s3 = sin(bank / 2)
			
			heading yaw
			attitude pitch
			bank roll
			ok
			
			 public final void rotate(double heading, double attitude, double bank) {
			// Assuming the angles are in radians.
			double c1 = Math.cos(heading/2);
			double s1 = Math.sin(heading/2);
			double c2 = Math.cos(attitude/2);
			double s2 = Math.sin(attitude/2);
			double c3 = Math.cos(bank/2);
			double s3 = Math.sin(bank/2);
			double c1c2 = c1*c2;
			double s1s2 = s1*s2;
			w =c1c2*c3 - s1s2*s3;
			x =c1c2*s3 + s1s2*c3;
			y =s1*c2*c3 + c1*s2*s3;
			z =c1*s2*c3 - s1*c2*s3;
			}
			*/
			
			
			local cy = cos(v.x / 2)
			local sy = sin(v.x / 2)
			local cp = cos(v.y / 2)
			local sp = sin(v.y / 2)
			local cr = cos(v.z / 2)
			local sr = sin(v.z / 2)
			
			--q.w = cy cp cr - sy sp sr
			--q.x = sy sp cr + cy cp sr
			--q.y = sy cp cr + cy sp sr
			--q.z = cy sp cr - sy cp sr
			
			q.w = FixedMul(FixedMul(cy,cp),cr) - FixedMul(FixedMul(sy,sp),sr)
			q.x = FixedMul(FixedMul(cy,cp),sr) + FixedMul(FixedMul(sy,sp),cr)
			q.y = FixedMul(FixedMul(sy,cp),cr) + FixedMul(FixedMul(cy,sp),sr)
			q.z = FixedMul(FixedMul(cy,sp),cr) - FixedMul(FixedMul(sy,cp),sr)
			
			
			return q
		end,
		
		conjugate = function(q)
			q.x,q.y,q.z = -q.x,-q.y,-q.z
			return q
		end,
		
		normalize = function(q)
			local len = q:length()
			--return len == 0 and q or q:scale(1 / len, out)
			return len == 0 and q or q:scale(FixedDiv(FRACUNIT, len))
		end,
	}
}

registerMetatable(vec3)
registerMetatable(quat)

setmetatable(vec3, vec3)
setmetatable(quat, quat)

vtmp1 = vec3()
vtmp2 = vec3()
qtmp1 = quat()

rawset(_G, "vec3", vec3)
rawset(_G, "quat", quat)
