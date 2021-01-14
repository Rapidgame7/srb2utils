// vectors
// there are a lot of vector 3 libraries out there so i can call this one mine :stealing dab:

// modified a lil to make use of floating point
// there are out arguments but it was because each function had "out = out or v" and that's fucking idiotic
local forward
local vtmp1
local vtmp2
local qtmp1

local vec3f, quatf

rawset(_G, "vec3f", {
  __call = function(_, x, y, z)
    return vec3f.new(x, y, z)
  end,
  new = function(x, y, z)
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	if z == nil then z = 0 end
    return setmetatable({ x=x, y=y, z=z }, vec3f)
  end,

  __tostring = function(v)
    return string.format('(%d, %d, %d)', v.x/FRACUNIT, v.y/FRACUNIT, v.z/FRACUNIT)
	//return string.format('(%d, %d, %d)', v.x, v.y, v.z)
  end,

  __add = function(v, u) return v:add(u, vec3f()) end,
  __sub = function(v, u) return v:sub(u, vec3f()) end,
  __mul = function(v, u)
    if vec3f.isvec3f(u) then return v:mul(u, vec3f())
    elseif type(u) == 'number' then return v:scale(u, vec3f())
    else error('vec3fs can only be multiplied by vec3fs and numbers') end
  end,
  __div = function(v, u)
    if vec3f.isvec3f(u) then return v:div(u, vec3f())
    elseif type(u) == 'number' then return v:scale(1 / u, vec3f())
    else error('vec3fs can only be divided by vec3fs and numbers') end
  end,
  __unm = function(v) return v:scale(-1) end,
  __len = function(v) return v:length() end,

  __index = {
    isvec3f = function(x)
      return getmetatable(x) == vec3f
    end,

    clone = function(v)
      return vec3f(v.x, v.y, v.z)
    end,

    unpack = function(v)
      return v.x, v.y, v.z
    end,

    set = function(v, x, y, z)
      if vec3f.isvec3f(x) then x, y, z = x.x, x.y, x.z end
      v.x = x
      v.y = y
      v.z = z
      return v
    end,

    add = function(v, u, out)
      out = vec3f()
      out.x = v.x + u.x
      out.y = v.y + u.y
      out.z = v.z + u.z
      return out
    end,

    sub = function(v, u, out)
      out = vec3f()
      out.x = v.x - u.x
      out.y = v.y - u.y
      out.z = v.z - u.z
      return out
    end,

    mul = function(v, u, out)
      out = vec3f()
      out.x = FixedMul(v.x, u.x)
      out.y = FixedMul(v.y, u.y)
      out.z = FixedMul(v.z, u.z)
      return out
    end,

    div = function(v, u, out)
      out = vec3f()
      out.x = FixedDiv(v.x, u.x)
      out.y = FixedDiv(v.y, u.y)
      out.z = FixedDiv(v.z, u.z)
      return out
    end,

    scale = function(v, s, out)
      out = vec3f()
      out.x = FixedMul(v.x, s)
      out.y = FixedMul(v.y, s)
      out.z = FixedMul(v.z, s)
      return out
    end,

    length = function(v)
      local r = FixedMul(v.x, v.x) + FixedMul(v.y, v.y) + FixedMul(v.z, v.z)
	  if r < 0 then print("domain error") end
	  r = max(r, 0)
	  return FixedSqrt(r)
    end,
	lengthbad = function(v)
		local CROP = 16
		local r = (FixedMul(v.x, v.x)/CROP) + (FixedMul(v.y, v.y)/CROP) + (FixedMul(v.z, v.z)/CROP)
		print(r)
	  if r < 0 then error("domain error", 2) end
	  return FixedSqrt(r*CROP)
    end,

    normalize = function(v, out)
      out = vec3f()
      local len = v:length()
      return len == 0 and v or v:scale(FixedDiv(FRACUNIT, len), out)
    end,

    distance = function(v, u)
      return vec3f.sub(v, u, vtmp1):length()
    end,

    angle = function(v, u)
      return math.acos(v:dot(u) / (v:length() + u:length()))
    end,

    dot = function(v, u)
      return FixedMul(v.x, u.x) + FixedMul(v.y, u.y) + FixedMul(v.z, u.z)
    end,

    cross = function(v, u, out)
      out = vec3f()
      local a, b, c = v.x, v.y, v.z
      out.x = FixedMul(b, u.z) - FixedMul(c, u.y)
      out.y = FixedMul(c, u.x) - FixedMul(a, u.z)
      out.z = FixedMul(a, u.y) - FixedMul(b, u.x)
      return out
    end,

    lerp = function(v, u, t, out)
      out = vec3f()
      out.x = v.x + (u.x - v.x) * t
      out.y = v.y + (u.y - v.y) * t
      out.z = v.z + (u.z - v.z) * t
      return out
    end,

    project = function(v, u, out)
      out = vec3f()
      local unorm = vtmp1
      u:normalize(unorm)
      local dot = v:dot(unorm)
      out.x = FixedMul(unorm.x, dot)
      out.y = FixedMul(unorm.y, dot)
      out.z = FixedMul(unorm.z, dot)
      return out
    end,

    rotate = function(v, q, out)
      out = vec3f()
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
  }
})

quatf = {
  __call = function(_, x, y, z, w)
    --return setmetatable({ x = x, y = y, z = z, w = w }, quatf)
	return quatf.new(x,y,z,w)
  end,
  new = function(x, y, z, w)
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	if z == nil then z = 0 end
	if w == nil then w = 0 end
    return setmetatable({ x=x, y=y, z=z, w=w }, quatf)
  end,

  __tostring = function(q)
    return string.format('(%f, %f, %f, %f)', q.x/FRACUNIT, q.y/FRACUNIT, q.z/FRACUNIT, q.w/FRACUNIT)
  end,

  __add = function(q, r) return q:add(r, quatf()) end,
  __sub = function(q, r) return q:sub(r, quatf()) end,
  __mul = function(q, r)
    if quatf.isquat(r) then return q:mul(r, quatf())
    elseif vec3f.isvec3f(r) then return r:rotate(q, vec3f())
    else error('quats can only be multiplied by quats and vec3s') end
  end,
  __unm = function(q) return q:scale(-1) end,
  __len = function(q) return q:length() end,

  __index = {
    isquat = function(x)
      return ffi and ffi.istype('quatf', x) or getmetatable(x) == quatf
    end,

    clone = function(q)
      return quatf(q.x, q.y, q.z, q.w)
    end,

    unpack = function(q)
      return q.x, q.y, q.z, q.w
    end,

    set = function(q, x, y, z, w)
      if quatf.isquat(x) then x, y, z, w = x.x, x.y, x.z, x.w end
      q.x = x
      q.y = y
      q.z = z
      q.w = w
      return q
    end,

    fromAngleAxis = function(angle, x, y, z)
      return quatf():setAngleAxis(angle, x, y, z)
    end,

    setAngleAxis = function(q, angle, x, y, z)
      if vec3f.isvec3f(x) then x, y, z = x.x, x.y, x.z end
	  local s = sin(FixedMul(AngleFixed(angle), FRACUNIT/2))
	  local c = cos(FixedMul(AngleFixed(angle), FRACUNIT/2))
	  q.x = FixedMul(x, s)
	  q.y = FixedMul(y, s)
	  q.z = FixedMul(z, s)
	  q.w = c
      return q
    end,

    getAngleAxis = function(q)
      if q.w > 1 or q.w < -1 then q:normalize() end
      local s = math.sqrt(1 - q.w * q.w)
      s = s < .0001 and 1 or 1 / s
      return 2 * math.acos(q.w), q.x * s, q.y * s, q.z * s
    end,

    between = function(u, v)
      return quatf():setBetween(u, v)
    end,

    setBetween = function(q, u, v)
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
      vec3f.cross(q, v)
      q.w = 1 + dot
      return q:normalize()
    end,

    fromDirection = function(x, y, z)
      return quatf():setDirection(x, y, z)
    end,

    setDirection = function(q, x, y, z)
      if vec3f.isvec3f(x) then x, y, z = x.x, x.y, x.z end
      vtmp2.x, vtmp2.y, vtmp2.z = x, y, z
      return q:setBetween(forward, vtmp2)
    end,

    add = function(q, r, out)
      out = out or q
      out.x = q.x + r.x
      out.y = q.y + r.y
      out.z = q.z + r.z
      out.w = q.w + r.w
      return out
    end,

    sub = function(q, r, out)
      out = out or q
      out.x = q.x - r.x
      out.y = q.y - r.y
      out.z = q.z - r.z
      out.w = q.w - r.w
      return out
    end,

    mul = function(q, r, out)
      out = out or q
      local qx, qy, qz, qw = q:unpack()
      local rx, ry, rz, rw = r:unpack()
      out.x = qx * rw + qw * rx + qy * rz - qz * ry
      out.y = qy * rw + qw * ry + qz * rx - qx * rz
      out.z = qz * rw + qw * rz + qx * ry - qy * rx
      out.w = qw * rw - qx * rx - qy * ry - qz * rz
      return out
    end,

    scale = function(q, s, out)
      out = out or q
      out.x = q.x * s
      out.y = q.y * s
      out.z = q.z * s
      out.w = q.w * s
      return out
    end,

    length = function(q)
      return math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)
    end,

    normalize = function(q, out)
      out = out or q
      local len = q:length()
      return len == 0 and q or q:scale(1 / len, out)
    end,

    lerp = function(q, r, t, out)
      out = out or q
      r:scale(t, qtmp1)
      q:scale(1 - t, out)
      return out:add(qtmp1)
    end,

    slerp = function(q, r, t, out)
      out = out or q

      local dot = q.x * r.x + q.y * r.y + q.z * r.z + q.w * r.w
      if dot < 0 then
        dot = -dot
        r:scale(-1)
      end

      if 1 - dot < .0001 then
        return q:lerp(r, t, out)
      end

      local theta = math.acos(dot)
      q:scale(math.sin((1 - t) * theta), out)
      r:scale(math.sin(t * theta), qtmp1)
      return out:add(qtmp1):scale(1 / math.sin(theta))
    end
  }
}

setmetatable(vec3f, vec3f)
setmetatable(quatf, quatf)

forward = vec3f(0, 0, -FRACUNIT)
vtmp1 = vec3f()
vtmp2 = vec3f()
qtmp1 = quatf()