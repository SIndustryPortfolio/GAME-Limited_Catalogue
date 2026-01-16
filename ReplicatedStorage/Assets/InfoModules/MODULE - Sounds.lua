local SoundsInfoModule = {}

-- CORE
local EffectClassNames = {"FlangeSoundEffect", "EqualizerSoundEffect", "ReverbSoundEffect", "EchoSoundEffect", "CompressorSoundEffect", "TremoloSoundEffect"}

local Music = 
{
	["Track1"] = {Id = "rbxassetid://17793669669"},
	["Track2"] = {Id = "rbxassetid://17793671133"},
	["Track3"] = {Id = "rbxassetid://17793670455"}
}

local SoundEffects = 
{
	["Button"] = 
	{
		["Press"] = {Id = "rbxassetid://8622833875"}		
	},
	["Switch"] = 
	{
		["Press"] = {Id = "rbxassetid://9119713951"}
	},
	["Misc"] = 
	{
		["Purchase"] = {Id = "rbxassetid://7945410242"}	
	}
}


local MusicEffectLists = 
{
	["InterfaceOverlay"] = {Equalizer = {HighGain = -80, MidGain = -80, LowGain = 0}}
}

--
local SoundTypes = 
{
	["Effects"] = SoundEffects,
	["Music"] = Music
}

-- Functions

function SoundsInfoModule.GetSounds(NilParam, SoundType)
	return SoundTypes[SoundType]
end

function SoundsInfoModule.GetMusicEffects()
	return MusicEffectLists
end

function SoundsInfoModule.GetSoundEffectClasses()
	return EffectClassNames
end

return SoundsInfoModule