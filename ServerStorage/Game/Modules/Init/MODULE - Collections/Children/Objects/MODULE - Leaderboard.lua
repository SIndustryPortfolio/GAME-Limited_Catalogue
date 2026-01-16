local ServerTagModule = {}

-- Dirs
local MiscPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Misc"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameLeaderboardFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Leaderboard"]
local SharedCachesModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Caches"]

-- Client

-- CACHES
local AppearanceCacheModule = require(SharedCachesModulesFolder["Appearance"])

-- Modules
--local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local LeaderboardConnections = {}

-- Functions
-- MECHANICS
local function Update(LeaderboardModel)
	-- Elements
	-- FOLDERS
	local LeaderboardFolder = SharedGameLeaderboardFolder[LeaderboardModel.Name]

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
		DebugModule:Print(script.name.. " | Update | LeaderboardModel: ".. tostring(LeaderboardModel).. " | Error: Not Found Top Value!")
		return nil
	end
	
	local TopUserId = FoundTopValue:GetAttributes()["UserId"]
	local TopUserValue = FoundTopValue.Value
	
	local Appearance = AppearanceCacheModule:Get(TopUserId)
	
	if not Appearance then
		return DebugModule:Print(script.Name.. " | Update | LeaderboardModel: ".. tostring(LeaderboardModel).. " | TopUserId: ".. tostring(TopUserId).. " | TopUserValue: ".. tostring(TopUserValue).. " | Error: ".. tostring(Appearance))
	end
	
	Humanoid:ApplyDescription(Appearance)
end

local function Initialise(LeaderboardModel)
	-- Elements
	-- FOLDERS
	local LeaderboardFolder = SharedGameLeaderboardFolder[LeaderboardModel.Name]
	
	-- MODELS
	local TopPlayerModel = UtilitiesModule:WaitForChildTimed(LeaderboardModel, "TopPlayer")
	
	-- Functions
	-- DIRECT
	local Connection1 = LeaderboardFolder:GetAttributeChangedSignal("UpdatedTime"):Connect(function()
		return Update(LeaderboardModel)
	end)
	
	-- INIT	
	Update(LeaderboardModel)
	
	LeaderboardConnections[LeaderboardModel] = {Connection1}
end

local function End(LeaderboardModel)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(LeaderboardModel)
end

-- DIRECT
function ServerTagModule.Initialise(NilParam, Part)
	return Initialise(Part)
end

function ServerTagModule.End(NilParam, Character)
	return End(Character)
end


return ServerTagModule