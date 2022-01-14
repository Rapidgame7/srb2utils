-- MMHJ - MetaMethodHiJack
-- core lib, neccesary to fuck shit up

if __MMHIJACK ~= nil then return end -- already exists, ok

-- This all shouldn't be synched, it's metatable stuff after all
rawset(_G, "_MMHIJACK", 1)

local mmhj = setmetatable({}, {
	__newindex = function(t,k,v)
		-- You shouldn't assign anything here.
		error("Do not assign on this table. Indexing the thing works just fine.",2)
	end,
	__index = function(t,k) -- When trying to index a metatable not recorded here...
		-- That means it wasn't hijacked yet. So... let's do that now.
		local um
		-- It can be either an USERDATA or a STRING.
		-- If it is a string, it has to be a valid userdata type (e.g. "mobj_t")
		if type(k) == "string" then
			um = userdataMetatable(k)
		elseif type(k) == "userdata" and userdataType(k) == "unknown" then
			-- If it is userdata, it has to be one of the global ones
			-- like players or thinkers. (i can't check proper, so...)
			um = k -- lol this will break badly
		else
			error("String/Userdata key expected, got "..type(k),2)
		end
		
		-- First, is the userdata metatable valid?
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
			local owo = type(k) == "string" and k or "whatever this is"
			error("There's no metatable for "..owo,2)
		end
	end,
})

rawset(_G, "MMHJ", mmhj)

/*
examples:
MMHJ["mobj_t"].something = function(m) end

MMHJ["player_t"].getName = function(p) return p.name end
MMHJ["player_t"].isPlaying = function(p) return p.mo and p.mo.valid end


*/