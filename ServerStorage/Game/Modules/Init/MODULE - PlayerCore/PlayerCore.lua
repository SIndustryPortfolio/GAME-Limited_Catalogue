local PlayerCoreModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local OrderedDataStoreHandlerModule = require(ServerModulesFolder["OrderedDataStoreHandler"])

-- CORE
local PlayerConnections = {}
local RequiredModules = UtilitiesModule:RunSubModules(script, true)

-- Functions
-- MECHANICS
local function PlayerAdded(Player)
	-- Functions
	-- INIT
	OrderedDataStoreHandlerModule:PlayerAdded(Player)
	Player:SetAttribute("LastTimeSpentTick", tick())
	
	for ModuleName, Module in pairs(RequiredModules) do
		if Module and Module.PlayerAdded ~= nil then
			Module:PlayerAdded(Player)
		end
	end
	
	Player:SetAttribute("PlayerCoreLoaded", true)
end

local function PlayerRemoved(Player)
	-- Functions
	-- INIT
	--OrderedDataStoreHandlerModule:Set(Player, "TimeSpent", math.floor(OrderedDataStoreHandlerModule:Get(Player, "TimeSpent") + (tick() - Player:GetAttributes()["LastTimeSpentTick"])))
	
	local TimeNow = tick()
	
	Player["DataStore"]:SetAttribute("TimeSpent", math.floor(Player["DataStore"]:GetAttribute("TimeSpent") + (TimeNow - Player:GetAttributes()["LastTimeSpentTick"])))
	Player["DataStore"]:SetAttribute("LastTimeSpentTick", TimeNow)
	OrderedDataStoreHandlerModule:PlayerRemoved(Player)

	UtilitiesModule:DisconnectConnections(PlayerConnections[Player])
	
	for ModuleName, Module in pairs(RequiredModules) do
		if Module and Module.PlayerRemoved ~= nil then
			Module:PlayerRemoved(Player)
		end
	end
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = game.Players.PlayerAdded:Connect(PlayerAdded)
	local Connection2 = game.Players.PlayerRemoving:Connect(PlayerRemoved)
	
end

local function End()
	-- Functions
	-- INIT
	
end

-- DIRECT
function PlayerCoreModule.Initialise()
	return Initialise()
end

function PlayerCoreModule.End()
	return End()
end

return PlayerCoreModule