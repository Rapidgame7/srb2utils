-- mmhj, vector3 stuf

if _MMHIJACK ~= nil then
	MMHJ["mobj_t"].launchAbsolute = function(m, hang, vang, spd)
		// Uses cSpdEx to immediately launch some dumb brick lmao
		local cx,cy,cz = cSpdEx(hang,vang,spd,m)
		m.momx = cx
		m.momy = cy
		m.momz = cz
	end
	MMHJ["mobj_t"].launchScatter = function(m, spd)
		--launchAbsolute(mom, p.mo.angle, p.aiming, 12*FRACUNIT)
		local ha = FixedAngle(P_RandomRange(0,359)*FRACUNIT)
		local va = FixedAngle(P_RandomRange(0,90)*FRACUNIT)
		m:launchAbsolute(ha, va, spd)
	end
	
	MMHJ["player_t"].getAim = function(p)
		return p.realmo.angle, p.aiming
	end
	
	if vec3 then
		MMHJ["mobj_t"].getMom = function(m, v3)
			return vec3(m.momx,m.momy,m.momz)
		end
		MMHJ["mobj_t"].setMom = function(m, v3)
			if v3 == nil then error("v3 argument missing",2) end
			m.momx,m.momy,m.momz = v3:unpack()
		end
		
		MMHJ["player_t"].getAimV3 = function(p)
			return vec3(0, p.realmo.angle, p.aiming)
		end
		/*
		MMHJ["player_t"].setAim = function(m, v3)
			m.momx,m.momy,m.momz = v3:unpack()
		end
		*/
	end
end