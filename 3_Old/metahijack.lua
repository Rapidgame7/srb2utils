-- This all shouldn't be synched


rawset(_G, "_MMHIJACK", 1)

local mms = setmetatable({}, {
	__newindex = function(t,k,v)
		-- You shouldn't assign anything here, otherwise the hijacker won't kick in.
		error("Do not assign on this table, stupid. Indexing the thing works just fine.",2)
	end,
	__index = function(t,k) -- When trying to index a metatable not recorded here...
		-- That means it wasn't hijacked yet. So... let's do that now.
		if type(k) ~= "string" then error("String key expected, got "..type(k),2) end
		-- First, is the userdata metatable valid?
		local um = userdataMetatable(k)
		if um then
			-- It is, so we create the table now.
			rawset(t, k, {})
			local umx = t[k]
			-- Additionally we replace the __index metamethod from mt with our own,
			-- that will pull values from t[k] *then* ogix.
			local ogix = um.__index
			um.__index = function(mt,mk)
				if umx[mk] ~= nil then return umx[mk]
				else return ogix(mt, mk) end
			end
			return umx
			-- All set up! emjoy :)
		else
			-- It isn't, therefore we error and leave.
			error("There's no metatable for userdata "..k,2)
		end
	end,
})

rawset(_G, "MMS", mms)