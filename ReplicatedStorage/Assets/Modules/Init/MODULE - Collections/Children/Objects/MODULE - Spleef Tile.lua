local TagModule = {}

-- Dirs
local MiscPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Misc"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local GameLeaderboardFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Leaderboard"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
--local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(ModulesFolder["Debug"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local SpleefTileConnections = {}
local TweenDict = {}
local EffectInfo = 
{
	["Duration"] = 1,
	["Style"] = Enum.EasingStyle.Linear,
	["Direction"] = Enum.EasingDirection.InOut		
}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function Touched(SpleefTile)
	-- Functions
	-- INIT
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local tweeningInfo = {}
	
	if SpleefTile:GetAttributes()["Touched"] then
		tweeningInfo.Transparency = 1
	else
		SpleefTile.CanCollide = true
		tweeningInfo.Transparency = 0
	end
	
	UtilitiesModule:CancelTween(SpleefTile, TweenDict)
	TweenDict[SpleefTile] = TweenService:Create(SpleefTile, tweenInfo, tweeningInfo)
	TweenDict[SpleefTile]:Play()
	UtilitiesModule:CompleteTween(SpleefTile, TweenDict)
	
	TweenDict[SpleefTile].Completed:Wait()
	
	if SpleefTile:GetAttributes()["Touched"] then
		SpleefTile.CanCollide = false
	end
end

local function Initialise(SpleefTile)
	-- Functions
	-- DIRECT
	local Connection1 = SpleefTile:GetAttributeChangedSignal("Touched"):Connect(function()
		return Touched(SpleefTile)
	end)
	
	-- Connections
	SpleefTileConnections[SpleefTile] = {Connection1}
end

local function End(SpleefTile)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(SpleefTileConnections[SpleefTile])
end

-- DIRECT
function TagModule.Initialise(NilParam, Part)
	return Initialise(Part)
end

function TagModule.End(NilParam, Character)
	return End(Character)
end


return TagModule