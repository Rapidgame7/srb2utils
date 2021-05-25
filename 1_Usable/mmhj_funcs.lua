// incomplete, add more or smth
MMHJ["mobj_t"].distTo = function(m, o)
	-- pack: coord tuple table or mobj. either way, it has xyz :)
	return R_PointToDist2(R_PointToDist2(m.x, m.y, o.x, o.y), m.z, 0, o.z)
end

local sortfn = function(a,b)
	return a.dist < b.dist
end
MMHJ["mobj_t"].nearbyMobjs = function(m, radius, sort)
	local radp = radius+128*FRACUNIT
	-- radius: maximum lookup distance
	-- uses searchBlockmap to create a table
	-- with all nearby mobjs to up to radius,
	-- and returns an iterator for it
	local nearby = {}
	searchBlockmap("objects", function(_,fm)
		local dist = m:distTo(fm)
		if dist <= radius then
			nearby[#nearby+1] = {m=fm, dist=dist}
		end
	end, m, m.x-radp, m.x+radp, m.y-radp, m.y+radp)
	
	if sort then
		table.sort(nearby, sortfn)
	end
	
	local cur = 0
	return function(state,v)
		cur = $+1
		return nearby[cur] and nearby[cur].m or nil
	end,nearby
end


/*
MMHJ["player_t"].isSpectating = function(p)
	return not p.spectator
end
*/
MMHJ["player_t"].isAlive = function(p)
	-- The player is playing and not spectating
	return p and p.valid and p.playerstate ~= PST_DEAD and not p.spectator
end
MMHJ["player_t"].isInMap = function(p)
	-- The player has their mobj in the map
	-- (realmo doesn't count)
	return p.mo and p.mo.valid
end
--MMHJ[players].