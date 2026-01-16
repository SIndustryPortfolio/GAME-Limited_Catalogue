local LeaderstatsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]

-- Info Modules
local OrderedDataStoreInfoModule = require(ServerInfoModulesFolder["OrderedDataStore"])
local LeaderboardsInfoModule = require(SharedInfoModulesFolder["Leaderboards"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local Connections = {}

-- Functions
-- MECHANICS
local function PlayerAdded(Player)
	-- CORE
	local PlayerConnections = {}
	local DataStoreFolder = Player:WaitForChild("DataStore")
	
	-- Functions
	-- INIT
	local LeaderstatsFolder = Instance.new("Folder")
	LeaderstatsFolder.Name = "leaderstats"
	LeaderstatsFolder.Parent = Player
	
	for i, StoreName in pairs(OrderedDataStoreInfoModule:GetOrderedDataStoreInfo("Leaderstats")) do
		local NumberValue = Instance.new("NumberValue")
		NumberValue.Name = LeaderboardsInfoModule:GetLeaderboardInfo(StoreName)["Name"]
		NumberValue.Parent = LeaderstatsFolder
		
		-- DIRECT
		local Connection1 = DataStoreFolder:GetAttributeChangedSignal(StoreName):Connect(function()
			NumberValue.Value = DataStoreFolder:GetAttribute(StoreName)
		end)
		
		-- INIT
		NumberValue.Value = DataStoreFolder:GetAttribute(StoreName)
	end
	
	
	Connections[Player] = PlayerConnections
end

local function PlayerRemoved(Player)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections[Player])
	Connections[Player] = nil
end

-- DIRECT
function LeaderstatsModule.PlayerAdded(NilParam, ...)
	return PlayerAdded(...)
end

function LeaderstatsModule.PlayerRemoved(NilParam, ...)
	return PlayerRemoved(...)
end

return LeaderstatsModule