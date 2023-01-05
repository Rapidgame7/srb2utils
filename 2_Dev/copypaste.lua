rawset(_G, "copyMobj", function(m)
	// Stores in a table the entire mobj bullshit
	local t = {}
	t._HIDE = true
	t.x = m.x
	t.y = m.y
	t.z = m.z
	t.angle = m.angle
	t.rollangle = m.rollangle
	t.sprite = m.sprite
	t.frame = m.frame
	t.sprite2 = m.sprite2
	t.anim_duration = m.anim_duration
	t.radius = m.radius
	t.height = m.height
	t.momx = m.momx
	t.momy = m.momy
	t.momz = m.momz
	t.pmomz = m.pmomz
	t.tics = m.tics
	t.state = m.state
	t.flags = m.flags
	t.flags2 = m.flags2
	t.eflags = m.eflags
	--t.skin = m.skin
	t.color = m.color
	t.colorized = m.colorized
	t.hnext = m.hnext
	t.hprev = m.hprev
	t.health = m.health
	t.movedir = m.movedir
	t.movecount = m.movecount
	t.target = m.target
	t.reactiontime = m.reactiontime
	t.threshold = m.threshold
	t.lastlook = m.lastlook
	t.spawnpoint = m.spawnpoint
	t.tracer = m.tracer
	t.friction = m.friction
	t.movefactor = m.movefactor
	t.fuse = m.fuse
	t.scale = m.scale
	t.destscale = m.destscale
	t.scalespeed = m.scalespeed
	t.extravalue1 = m.extravalue1
	t.extravalue2 = m.extravalue2
	t.cusval = m.cusval
	t.cvmem = m.cvmem
	
	return t
end)

rawset(_G, "pasteMobj", function(m, t)
	// Takes a table and drops it in the mobj
	-- P_TeleportM i'm actually not going to do that
	m.angle = t.angle
	m.rollangle = t.rollangle
	m.sprite = t.sprite
	m.frame = t.frame
	m.sprite2 = t.sprite2
	m.anim_duration = t.anim_duration
	m.radius = t.radius
	m.height = t.height
	m.momx = t.momx
	m.momy = t.momy
	m.momz = t.momz
	m.pmomz = t.pmomz
	m.tics = t.tics
	m.state = t.state
	m.flags = t.flags
	m.flags2 = t.flags2
	m.eflags = t.eflags
	--m.skin = t.skin
	m.color = t.color
	m.colorized = t.colorized
	m.hnext = t.hnext
	m.hprev = t.hprev
	m.health = t.health
	m.movedir = t.movedir
	m.movecount = t.movecount
	m.target = t.target
	m.reactiontime = t.reactiontime
	m.threshold = t.threshold
	m.lastlook = t.lastlook
	m.spawnpoint = t.spawnpoint
	m.tracer = t.tracer
	m.friction = t.friction
	m.movefactor = t.movefactor
	m.fuse = t.fuse
	m.scale = t.scale
	m.destscale = t.destscale
	m.scalespeed = t.scalespeed
	m.extravalue1 = t.extravalue1
	m.extravalue2 = t.extravalue2
	m.cusval = t.cusval
	m.cvmem = t.cvmem
end)