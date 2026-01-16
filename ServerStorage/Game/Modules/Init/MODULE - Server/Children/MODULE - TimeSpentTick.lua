local InitModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Modules
local OrderedDataStoreHandlerModule = require(ServerModulesFolder["OrderedDataStoreHandler"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local UpdateEvery = UtilitiesModule:MinutesToSeconds(1.5)
local LastTickUpdate = 0

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
		
		Player["DataStore"]:SetAttribute("TimeSpent", math.floor(Player["DataStore"]:GetAttribute("TimeSpent") + (TimeNow - Player:GetAttributes()["LastTimeSpentTick"])))
		--OrderedDataStoreHandlerModule:Set(Player, "TimeSpent", math.floor(OrderedDataStoreHandlerModule:Get(Player, "TimeSpent") + (tick() - Player:GetAttributes()["LastTimeSpentTick"])))
		Player:SetAttribute("LastTimeSpentTick", TimeNow)
		
		OrderedDataStoreHandlerModule:SaveAsync(Player, "TimeSpent")
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