local InitModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Modules
local OrderedDataStoreHandlerModule = require(ServerModulesFolder["OrderedDataStoreHandler"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local UpdateEvery = UtilitiesModule:MinutesToSeconds(3)
local LastTickUpdate = 0
local CoinsToReward = 5

local Connections = {}

-- SERVICES
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function Update()
	-- CORE
	local TimeNow = tick()
	
	-- Functions
	-- INIT
	if (TimeNow - LastTickUpdate) < UpdateEvery then
		return nil
	end
	
	LastTickUpdate = TimeNow
	
	for i, Player in pairs(game.Players:GetPlayers()) do
		if not Player:GetAttributes()["PlayerCoreLoaded"] then
			continue
		end
		
		Player["DataStore"]:SetAttribute("Coins", math.floor(Player["DataStore"]:GetAttribute("Coins") + CoinsToReward))
		--OrderedDataStoreHandlerModule:Set(Player, "TimeSpent", math.floor(OrderedDataStoreHandlerModule:Get(Player, "TimeSpent") + (tick() - Player:GetAttributes()["LastTimeSpentTick"])))
		
		OrderedDataStoreHandlerModule:SaveAsync(Player, "Coins")
	end
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = RunService.Heartbeat:Connect(function()
		return Update()
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
end

-- DIRECT
function InitModule.Initialise()
	return Initialise()
end

return InitModule