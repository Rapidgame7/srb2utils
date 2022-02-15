
-- PBT4
local majv,minv,relv = 4,0,0
local verstr = tonumber(("%02d%02d%02d"):format(4,0,0))
local ver = tonumber(verstr)

print("Loading PBT"..verstr)
if PBT ~= nil then
	print("PBT already loaded.")
	return
end
rawset(_G, "PBT", ver)

local sens = 15
local thosbutons = {
	{"up"   , function(cmd) return cmd.forwardmove >  sens end},
	{"down" , function(cmd) return cmd.forwardmove < -sens end},
	{"left" , function(cmd) return cmd.sidemove    >  sens end},
	{"right", function(cmd) return cmd.sidemove    < -sens end},
	
	{"spin", function(cmd) return (cmd.buttons & BT_USE ) > 0 end},
	{"jump", function(cmd) return (cmd.buttons & BT_JUMP) > 0 end},
	
	{"fire"      , function(cmd) return (cmd.buttons & BT_ATTACK    ) > 0 end},
	{"firenormal", function(cmd) return (cmd.buttons & BT_FIRENORMAL) > 0 end},
	{"weaponnext", function(cmd) return (cmd.buttons & BT_WEAPONNEXT) > 0 end},
	{"weaponprev", function(cmd) return (cmd.buttons & BT_WEAPONPREV) > 0 end},
	{"tossflag"  , function(cmd) return (cmd.buttons & BT_TOSSFLAG  ) > 0 end},
	
	{"camleft" , function(cmd) return (cmd.buttons & BT_CAMLEFT ) > 0 end},
	{"camright", function(cmd) return (cmd.buttons & BT_CAMRIGHT) > 0 end},
	
	{"custom1", function(cmd) return (cmd.buttons & BT_CUSTOM1) > 0 end},
	{"custom2", function(cmd) return (cmd.buttons & BT_CUSTOM2) > 0 end},
	{"custom3", function(cmd) return (cmd.buttons & BT_CUSTOM3) > 0 end},
	
	-- pbt specific
	{"hmoving", function(_,bt) return bt.left   >0 or bt.right  >0 end},
	{"vmoving", function(_,bt) return bt.up     >0 or bt.down   >0 end},
	{ "moving", function(_,bt) return bt.hmoving>0 or bt.vmoving>0 end},
	
	/*
		p.bt.hmoving = (p.bt.left or p.bt.right) and $~=nil and $+1 or 0
		p.bt.vmoving = (p.bt.up or p.bt.down) and $~=nil and $+1 or 0
		p.bt.moving = (p.bt.up or p.bt.down or p.bt.left or p.bt.right) and $~=nil and $+1 or 0
		
		local sum = 0
		local sidesum = 0
		
		if cmdsm < 0 then sidesum = 45 end
		if cmdsm > 0 then sidesum = -45 end
		
		if cmdfm == 0 then sidesum = $*2 end
		if cmdfm < 0 then sidesum = -sidesum;sum = 180 end
		
		local res = sum + sidesum
		--return FixedAngle( res*FRACUNIT )
		p.bt.dirAsAngle = FixedAngle( res*FRACUNIT )
	*/
}



rawset(_G, "pbtxDaemon", function(p)
	local cmdbt = p.cmd.buttons
	local cmdfm = p.cmd.forwardmove
	local cmdsm = p.cmd.sidemove
	
	if p.bttimestamp == nil then p.bttimestamp = -1 end
	
	if p.bttimestamp ~= leveltime then
		// Prevent this from running more than once if multiple daemons are in place (why would there be more than one)	
		if not p.bt then
			p.bt = {} -- "for how long has it been pressed?"
			p.btprev = {} -- "what was the previous value?"
			p.btrel = {} -- "for how long has it been released?"
			for i = 1,#thosbutons do
				local v = thosbutons[i][1]
				p.bt[v] = 0
				p.btprev[v] = 0
				p.btrel[v] = 0
			end
		end
		
		local cmd = p.cmd
		for i = 1,#thosbutons do
			local entry = thosbutons[i]
			local name = entry[1]
			local f = entry[2]
			
			p.btprev[name] = p.bt[name]
			
			local r = f(cmd,p.bt,p)
			p.bt[name]    =     r and $+1 or 0
			p.btrel[name] = not r and $+1 or 0
		end
		
		p.bttimestamp = leveltime
	end
end)

