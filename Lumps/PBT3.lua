local thosbutons = {
	"up","down","left","right",
	"spin","jump",
	"attack","nextwep","prevwep",
	"custom1","custom2","custom3",
	"moving","hmoving","vmoving"
}
for k,v in ipairs(thosbutons) do
	thosbutons[v] = true
end

rawset(_G, "pbtDaemon", function(p)
	--if deepcopy == nil then error("deepcopy missing", 2) end
	// Does a cool thing
	local cmdbt = p.cmd.buttons
	local cmdfm = p.cmd.forwardmove
	local cmdsm = p.cmd.sidemove
	
	if not p.bttimestamp then p.bttimestamp = -1 end
	
	if p.bttimestamp ~= leveltime then
		// Prevent this from running more than once if multiple daemons are in place (why would there be more than one)
		
		if not p.bt then
			p.bt = {}
			p.btx = {}
			p.btprev = {}
			for _,v in ipairs(thosbutons) do
				p.bt[v] = 0
				p.btprev[v] = 0
				p.btx[v] = 0
			end
		end
		local sens = 20
		
		for i = 1,#thosbutons do
			local ix = thosbutons[i]
			p.btprev[ix] = p.bt[ix]
		end // Old values
		
		p.bt.up = cmdfm > sens and $+1 or 0
		p.bt.down = cmdfm < -sens and $+1 or 0
		p.bt.right = cmdsm > sens and $+1 or 0
		p.bt.left = cmdsm < -sens and $+1 or 0
		
		if p.bt.up > 0 and p.bt.down > 0 then p.bt.up = 0; p.bt.down = 0 end
		if p.bt.right > 0 and p.bt.left > 0 then p.bt.right = 0; p.bt.left = 0 end
		
		p.bt.spin = (cmdbt & BT_USE) > 0 and $+1 or 0
		p.bt.jump = (cmdbt & BT_JUMP) > 0 and $+1 or 0
		p.bt.attack = (cmdbt & BT_ATTACK) > 0 and $+1 or 0
		
		p.bt.nextwep = (cmdbt & BT_WEAPONNEXT) > 0 and $+1 or 0
		p.bt.prevwep = (cmdbt & BT_WEAPONPREV) > 0 and $+1 or 0
		
		p.bt.custom1 = (cmdbt & BT_CUSTOM1) > 0 and $+1 or 0
		p.bt.custom2 = (cmdbt & BT_CUSTOM2) > 0 and $+1 or 0
		p.bt.custom3 = (cmdbt & BT_CUSTOM3) > 0 and $+1 or 0
		
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
		
		p.bttimestamp = leveltime
	end
end)

/*
pbt usage:

p.bt holds button held time
p.btprev holds the value in the previous frame for that respective button

Want to check if a player is holding jump?
p.bt.jump > 0

Want to check for a tap on the jump button (not held, but the instant it is pressed)?
p.bt.jump == 1

Want to check when jump was just released?
p.bt.jump < p.btprev.jump
normally btprev is smaller than bt when the button is held, so if it is larger, it must have been released


or use one of the shortcut functions like a baby
*/

local function checks(p, key)
	if not p then error("Bad argument #1 (expected player)", 3) end
	if not p.bt then
		error("Are you running pbtDaemon()?", 3)
	end
	if key == nil then error("Key argument is nil", 3) end
	if not thosbutons[key] then
		error("Button "..key.." not in the list", 3)
	end
end

rawset(_G, "PBT_Up", function(p, key) checks(p,key)
	return not p.bt[key] // If 0, true
end)
rawset(_G, "PBT_Down", function(p, key) checks(p,key)
	return not not p.bt[key] // If >0, true
end)

rawset(_G, "PBT_JustPressed", function(p, key) checks(p,key)
	// Button has just been pressed after not being pressed
	return p.bt[key] and p.btprev[key] == 0
end)
rawset(_G, "PBT_JustReleased", function(p, key) checks(p,key)
	// Button is no longer being pressed after being pressed press press press press press press press press press press 
	return p.bt[key] < p.btprev[key]
end)























