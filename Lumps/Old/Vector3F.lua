// vectors
// there are a lot of vector 3 libraries out there so i can call this one mine :stealing dab:

// modified a lil to make use of floating point
// there are out arguments but it was because each function had "out = out or v" and that's fucking idiotic
local forward
local vtmp1
local vtmp2

local vec3f

rawset(_G, "vec3f", {
  __call = function(_, x, y, z)
    return vec3f:new(x, y, z)
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

setmetatable(vec3f, vec3f)

forward = vec3f(0, 0, -FRACUNIT)
vtmp1 = vec3f()
vtmp2 = vec3f()