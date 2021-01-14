-- Sound player made by yours truly

freeslot("MT_SOUNDPLAYER")

mobjinfo[MT_SOUNDPLAYER] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	spawnhealth = 1000,
	radius = 8,
	height = 8,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOBLOCKMAP|MF_NOSECTOR|MF_SCENERY
}

addHook("MobjThinker", function(m) -- Custom sound player actions
	if not S_OriginPlaying(m) then P_RemoveMobj(m) end -- pop out of existance when sound is no longer playing
end, MT_SOUNDPLAYER)

local function S_StartSoundMobj(x, y, z, sound)
	local k = P_SpawnMobj(x, y, z, MT_SOUNDPLAYER)
	S_StartSound(k, sound)
end

rawset(_G, "S_StartSoundMobj", S_StartSoundMobj)