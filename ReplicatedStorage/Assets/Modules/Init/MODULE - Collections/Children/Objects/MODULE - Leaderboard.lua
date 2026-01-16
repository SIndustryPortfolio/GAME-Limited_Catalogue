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
local LeaderboardConnections = {}
local DanceAnimationIds = {"rbxassetid://17854491023", "rbxassetid://17854527770", "rbxassetid://17854535503"}

-- Functions
-- MECHANICS
local function Update(LeaderboardModel)
	-- Elements
	-- FOLDERS
	local LeaderboardFolder = GameLeaderboardFolder[LeaderboardModel.Name]

	-- MODELS
	local TopPlayerModel = UtilitiesModule:WaitForChildTimed(LeaderboardModel, "TopPlayer")
	local DummyModel = TopPlayerModel["Dummy"]

	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(DummyModel, "Humanoid")

	-- Functions
	-- INIT
	local FoundTopValue = LeaderboardFolder:FindFirstChild("1")

	if not FoundTopValue then
		return nil
	end

	local TopUserId = FoundTopValue:GetAttributes()["UserId"]
	local TopUserValue = FoundTopValue.Value

end

local function HandleTopUser(LeaderboardModel)
	-- Elements
	-- FOLDERS
	local LeaderboardFolder = GameLeaderboardFolder[LeaderboardModel.Name]

	-- MODELS
	local TopPlayerModel = UtilitiesModule:WaitForChildTimed(LeaderboardModel, "TopPlayer")
	local DummyModel = TopPlayerModel["Dummy"]
	
	-- PARTS
	local InterfacePart = TopPlayerModel["Interface"]
	local HeadPart = UtilitiesModule:WaitForChildTimed(DummyModel, "Head")
		
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(DummyModel, "Humanoid")

	-- Functions
	-- DIRECT
	local Connection1 = LeaderboardFolder:GetAttributeChangedSignal("UpdatedTime"):Connect(function()
		return Update(LeaderboardModel)
	end)
	
	-- INIT
	
	InterfacesModule:LoadSurface(InterfacePart, "TopUser", LeaderboardModel.Name)
	local UI = InterfacesModule:LoadBillboard(DummyModel, "TopUser", false)
		
	local DanceAnimation = Instance.new("Animation")
	DanceAnimation.AnimationId = DanceAnimationIds[math.random(1, #DanceAnimationIds)]
	DanceAnimation.Parent = TopPlayerModel
	
	local Success, Error = pcall(function()
		local DanceAnimationLoad = Humanoid:LoadAnimation(DanceAnimation)
		DanceAnimationLoad:Play()
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | HandleTopUser | LeaderboardModel: ".. tostring(LeaderboardModel).. " | Error: ".. tostring(Error))
	end
	
	Update(LeaderboardModel)
	
	return {Connection1}
end

local function Initialise(LeaderboardModel)
	-- Elements
	-- FOLDERS
	local LeaderboardFolder = GameLeaderboardFolder[LeaderboardModel.Name]
	
	-- Functions
	-- INIT
	InterfacesModule:LoadSurface(LeaderboardModel.PrimaryPart, "Leaderboard", LeaderboardModel.Name)
	
	local _Connections1 = HandleTopUser(LeaderboardModel)
	
	LeaderboardConnections[LeaderboardModel] = _Connections1
end

local function End(LeaderboardModel)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(LeaderboardConnections[LeaderboardModel])
end

-- DIRECT
function TagModule.Initialise(NilParam, Part)
	return Initialise(Part)
end

function TagModule.End(NilParam, Character)
	return End(Character)
end


return TagModule