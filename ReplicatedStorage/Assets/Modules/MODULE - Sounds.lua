local SoundModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Services
local SoundService = game:GetService("SoundService")

-- Info Modules
local SoundsInfoModule = require(InfoModulesFolder["Sounds"])

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local Muted = false
local TweenDict = {}

local SoundCache = {}

local FadeEffectInfo = 
{
	["Duration"] = 2,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.InOut
}

local NameToInstanceClass = 
{
	["Pitch"] = "PitchShiftSoundEffect",
	["Equalizer"] = "EqualizerSoundEffect"
}

-- Instancing
local BackingTrackFolder = Instance.new("Folder", SoundService)
BackingTrackFolder.Name = "BackingTrack"

local MainMusicSound = Instance.new("Sound", BackingTrackFolder)
MainMusicSound.Name = "Music"
MainMusicSound.Volume = 0.1

local SoundEffectsCacheFolder = Instance.new("Folder", SoundService)
SoundEffectsCacheFolder.Name = "SoundEffects"

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function CreateSoundCache(Sound, Properties)
	if SoundCache[Sound] == nil then
		SoundCache[Sound] = {}
	end
	
	for i, PropertyName in pairs(Properties) do
		if SoundCache[Sound][PropertyName] == nil then
			SoundCache[Sound][PropertyName] = Sound[PropertyName]
		end
	end
	
end

local function CancelTween(TweenElement)
	if TweenDict[TweenElement] ~= nil then
		TweenDict[TweenElement]:Cancel()
		TweenDict[TweenElement]:Destroy()
	end
end

local function CompleteTween(TweenElement)
	if TweenDict[TweenElement] ~= nil then
		local Connection
		
		Connection = TweenDict[TweenElement].Completed:Connect(function(PlaybackState)
			if PlaybackState == Enum.PlaybackState.Completed then
				TweenDict[TweenElement]:Destroy()
			end
			
			Connection:Disconnect()
		end)
	end
end

local function AddSoundEffectsFromArgs(Sound, EffectData)
	for EffectName, EffectProperties in pairs(EffectData) do
		local EffectInstance = nil
		if EffectName == "Sound" then
			EffectInstance = Sound
		else
			EffectInstance = Sound:FindFirstChildOfClass(NameToInstanceClass[EffectName])
			if not EffectInstance then
				EffectInstance = Instance.new(NameToInstanceClass[EffectName], Sound)
			end
		end
		
		for PropertyName, PropertyValue in pairs(EffectProperties) do
			EffectInstance[PropertyName] = PropertyValue
		end
	end
end

local function RemoveSoundEffectsFromArgs(Sound, EffectData)
	for EffectName, EffectProperties in pairs(EffectData) do
		local EffectInstance = Sound:FindFirstChildOfClass(NameToInstanceClass[EffectName])
		
		if EffectInstance then
			EffectInstance:Destroy()
		end
	end
end

local function PlaySound(Id, Parent, Effects, DestroyWhenDone, SoundInstance, Loop, Fade, Properties, SoundName, FromTime, EndTime, PlayOnDestroy)
	local Sound = nil
	local TempBlock = nil
	
	if typeof(Parent) == "Vector3" then
		local NewBlock = Instance.new("Part")
		NewBlock.Size = Vector3.new(1,1,1)
		NewBlock.CanCollide = false
		NewBlock.CanTouch = false
		NewBlock.CanQuery = false
		NewBlock.Anchored = false
		NewBlock.Transparency = 1
		NewBlock.Position = Parent
		
		TempBlock = NewBlock
		Parent = TempBlock
	end
	
	if not SoundInstance then
		if Parent then
			Sound = Instance.new("Sound")
			Sound.Parent = Parent
			
			Sound.RollOffMaxDistance = 30
		else
			return nil
		end
	else
		Sound = SoundInstance
	end
	
	if Properties then
		for PropertyName, PropertyValue in pairs(Properties) do
			Sound[PropertyName] = PropertyValue
		end
	end
	
	local OldVolume = nil
		
	if Fade then
		if not Muted then
			OldVolume = nil
			
			if SoundInstance then
				OldVolume = SoundInstance.Volume
			else
				OldVolume = Sound.Volume
			end
			
			-- TWEEN
			local FadeTweenInfo = TweenInfo.new(FadeEffectInfo["Duration"], FadeEffectInfo["Style"], FadeEffectInfo["Direction"])
			local tweeningInfo = {}
			tweeningInfo.Volume = 0
			
			CancelTween(Sound)
			TweenDict[Sound] = TweenService:Create(SoundInstance, FadeTweenInfo, tweeningInfo)
			TweenDict[Sound]:Play()
			CompleteTween(Sound)
			
			TweenDict[Sound].Completed:Wait()
			Sound:Stop()
		end
	end
	
	Sound.SoundId = Id
	Sound.Looped = Loop
	
	if Effects ~= nil then
		AddSoundEffectsFromArgs(Sound, Effects)
	end
	
	if SoundName then
		Sound:SetAttribute("SoundName", SoundName)
	else
		Sound:SetAttribute("SoundName", "")
	end
	
	if FromTime then
		Sound.TimePosition = FromTime
	end
	
	if PlayOnDestroy ~= nil then
		Sound.PlayOnRemove = PlayOnDestroy
	end
	
	local PlayTime = tick()
	Sound:Play()
	
	if EndTime then
		coroutine.wrap(function()
			repeat
				task.wait()
			until Sound.TimePosition >= EndTime or not Sound
			
			if Sound then
				Sound:Stop()
				Sound:Destroy()
			end
			
			--[[local TimeNeededToWait = EndTime - FromTime
			
			local TimeNow = tick()
			
			repeat
				local Difference = tick() - PlayTime
				task.wait()
			until Difference >= TimeNeededToWait or not Sound
			
			if Sound then
				Sound:Stop()
				Sound:Destroy()
			end]]
		end)()
		
		--[[local Connection = nil
		
		Connection = Sound:GetPropertyChangedSignal("TimePosition"):Connect(function()
			if Sound.TimePosition >= EndTime then
				Sound:Stop()
				Sound:Destroy()
				Connection:Disconnect()
			end
		end)]]
	end
	
	if Fade then
		if not Muted then
			-- TWEEN
			local FadeTweenInfo = TweenInfo.new(FadeEffectInfo["Duration"], FadeEffectInfo["Style"], FadeEffectInfo["Direction"])
			local tweeningInfo = {}
			tweeningInfo.Volume = OldVolume
			
			CancelTween(Sound)
			TweenDict[Sound] = TweenService:Create(Sound, FadeTweenInfo, tweeningInfo)
			TweenDict[Sound]:Play()
			CompleteTween(Sound)
		end
	end
	
	if DestroyWhenDone then
		local Connection
		
		Connection = Sound.Ended:Connect(function()
			if not Loop then
				if TempBlock then
					DebrisModule:AddItem(TempBlock)
				end
				
				Sound:Destroy()
				Connection:Disconnect()
			end
		end)

	end
	
	return Sound
end

local function UpdateMutedAttribute()
	-- Functions
	-- INIT
	script:SetAttribute("Muted", Muted)
end

-- DIRECT
function SoundModule.IsMusicPlaying()
	return MainMusicSound.IsPlaying
end

function SoundModule.GetMuted()
	return Muted
end

function SoundModule.GetMusic()
	return MainMusicSound
end

function SoundModule.UnmuteSound()
	-- Functions
	-- INIT
	Muted = false
	MainMusicSound.Volume = SoundCache[MainMusicSound]["Volume"]
	
	UpdateMutedAttribute()
end

function SoundModule.MuteSound()
	-- Functions
	-- INIT
	Muted = true
	MainMusicSound.Volume = 0
	
	UpdateMutedAttribute()
end

function SoundModule.RemoveAllEffectsFromMusic()
	local EffectClasses = SoundsInfoModule:GetSoundEffectClasses()
	
	for i, Effect in pairs(MainMusicSound:GetChildren()) do
		for x, EffectClass in pairs(EffectClasses) do
			if Effect:IsA(EffectClass) then
				Effect:Destroy()
			end
		end
	end
end

function SoundModule.RemoveSoundEffectsFromMusic(NilParam, Effects)
	if typeof(Effects) == "string" then
		local MusicEffects = SoundsInfoModule:GetMusicEffects()
		Effects = MusicEffects[Effects]
	end
	
	RemoveSoundEffectsFromArgs(MainMusicSound, Effects)
end

function SoundModule.AddEffectsToMusic(NilParam, Effects)
	if typeof(Effects) == "string" then
		local MusicEffects = SoundsInfoModule:GetMusicEffects()
		Effects = MusicEffects[Effects]
	end
	
	AddSoundEffectsFromArgs(MainMusicSound, Effects)
end

function SoundModule.StopMusic()
	MainMusicSound:Stop()
end

function SoundModule.PlayMusicByName(NilParam, SoundName, Effects)
	local MusicSounds = SoundsInfoModule:GetSounds("Music")
	
	if typeof(Effects) == "string" then
		local MusicEffects = SoundsInfoModule:GetMusicEffects()
		Effects = MusicEffects[Effects]
	end
	
	local MusicTrack = MusicSounds[SoundName]
	
	if MusicTrack == nil then
		return nil
	end
	
	if MainMusicSound:GetAttribute("SoundName") == SoundName then
		if not SoundModule:IsMusicPlaying() then
			return MainMusicSound:Play()
		end
		
		return nil
	end
	
	coroutine.wrap(function()
		local Sound = PlaySound(MusicTrack.Id, nil, Effects, false, MainMusicSound, true, true, nil, SoundName)
	end)()
end

function SoundModule.PlaySoundEffectById(NilParam, SoundId, Effects, Parent, Loop, Properties, SoundName, FromTime, EndTime, PlayOnDestroy)
	if Muted then
		return nil
	end

	local Sound = nil
	if Parent == nil then
		Sound = PlaySound(SoundId, SoundEffectsCacheFolder, Effects, true, nil, Loop, nil, Properties, SoundName, FromTime, EndTime, PlayOnDestroy)
	else		
		Sound = PlaySound(SoundId, Parent, Effects, true, nil, Loop, nil, Properties, SoundName, FromTime, EndTime, PlayOnDestroy)
	end

	return Sound
end

function SoundModule.PlaySoundEffectByName(NilParam, SoundTypeName, SoundName, Effects, Parent, Loop, Properties, FromTime, EndTime, PlayOnDestroy)
	if Muted then
		return nil
	end
	
	local SoundEffects = SoundsInfoModule:GetSounds("Effects")
	
	local SoundsInType = SoundEffects[SoundTypeName]
	
	if SoundsInType == nil then
		return nil
	end
	
	local SoundToPlay = SoundsInType[SoundName]
	
	if SoundToPlay == nil then
		return nil
	end
	
	local Sound = nil
	if not Parent then
		Sound = PlaySound(SoundToPlay.Id, SoundEffectsCacheFolder, Effects, true, nil, Loop, nil, Properties, SoundName, SoundToPlay.FromTime, SoundToPlay.EndTime, PlayOnDestroy)
	else		
		Sound = PlaySound(SoundToPlay.Id, Parent, Effects, true, nil, Loop, nil, Properties, SoundName, SoundToPlay.FromTime, SoundToPlay.EndTime, PlayOnDestroy)
	end
	
	return Sound
end

-- Init
CreateSoundCache(MainMusicSound, {"Volume"})

--[[coroutine.wrap(function()
	if Player then
		local MusicSetting = SettingsModule:GetSettingValueInstance("Game", "Music")
		
		repeat
			MusicSetting = SettingsModule:GetSettingValueInstance("Game", "Music")
			task.wait()
		until MusicSetting
		
		local Connection1 = MusicSetting:GetPropertyChangedSignal("Value"):Connect(function()
			if not SettingsModule:GetSettingValue("Game", "Music", true) then
				SoundModule:MuteSound()
			else
				SoundModule:UnmuteSound()
			end
		end)
	end
end)()]]

return SoundModule