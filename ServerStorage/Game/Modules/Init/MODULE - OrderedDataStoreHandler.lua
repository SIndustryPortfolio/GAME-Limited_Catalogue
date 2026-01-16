local OrderedDataStoreModule = {}

-- Dirs
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local OrderedDataStoreInfoModule = require(ServerInfoModulesFolder["OrderedDataStore"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local NumberOfFields = 12

local StoreNameCache = {}

local PlayerToConnections = {}

local Cache = {}

local Prefix = OrderedDataStoreInfoModule:GetOrderedDataStoreInfo("Prefix")

-- Services
local DataStoreService = game:GetService("DataStoreService")

-- Functions
-- MECHANICS
local function Get(Player, StoreName)
	-- Functions
	-- INIT
	if Cache[Player] == nil then
		Cache[Player] = {}
	end
	
	return Cache[Player][StoreName]
end

local function Set(Player, StoreName, Value)
	-- Functions
	-- INIT
	if Cache[Player] == nil then
		Cache[Player] = {}
	end
	
	Cache[Player][StoreName] = Value
end

local function SaveAll(Player)
	-- Functions
	-- INIT
	for StoreName, Value in pairs(Cache[Player]) do
		--[[local Success, Error = pcall(function()
			return StoreNameCache[StoreName]:SetAsync(Prefix.. tostring(Player.UserId), Cache[Player][StoreName])
		end)			

		if not Success then
			DebugModule:Print(script.Name.. " | PlayerRemoved | Player: ".. tostring(Player).. " | Error: ".. tostring(Error))
		end]]
		
		SaveAsync(Player, StoreName)
	end
end

function SaveAsync(Player, StoreName)
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		return StoreNameCache[StoreName]:SetAsync(Prefix.. tostring(Player.UserId), Cache[Player][StoreName])
	end)			

	if not Success then
		DebugModule:Print(script.Name.. " | PlayerRemoved | Player: ".. tostring(Player).. " | Error: ".. tostring(Error))
	end
end

local function PlayerRemoved(Player)
	-- Functions
	-- INIT
	SaveAll(Player)
	
	UtilitiesModule:DisconnectConnections(PlayerToConnections[Player])
	
	PlayerToConnections[Player] = nil
	Cache[Player] = nil
end

local function PlayerAdded(Player)
	-- CORE
	local PlayerConnections = {}
	
	-- Functions
	-- INIT
	local DataStoreFolder = Instance.new("Folder")
	DataStoreFolder.Name = "DataStore"
	DataStoreFolder.Parent = Player
	
	if not script:GetAttributes()["Loaded"] then
		repeat
			task.wait(.1)
		until script:GetAttributes()["Loaded"]
	end
	
	for StoreName, DefaultValue in pairs(OrderedDataStoreInfoModule:GetOrderedDataStoreInfo("New")) do
		local Success, DataStoreValue = pcall(function()
			return StoreNameCache[StoreName]:GetAsync(Prefix.. tostring(Player.UserId))
		end)		
		
		if not Success then
			Set(Player, StoreName, DefaultValue)
			
			DebugModule:Print(script.Name.. " | PlayerAdded | Player: ".. tostring(Player).. " | Error: ".. tostring(DataStoreValue))
			continue
		end
		
		if DataStoreValue ~= nil then
			Set(Player, StoreName, DataStoreValue)
			DataStoreFolder:SetAttribute(StoreName, DataStoreValue)
		else
			Set(Player, StoreName, DefaultValue)
			DataStoreFolder:SetAttribute(StoreName, DefaultValue)
		end
	
		-- MECHANICS
		local function Update()
			-- Functions
			-- INIT
			return Set(Player, StoreName, DataStoreFolder:GetAttribute(StoreName))
		end
		
		-- DIRECT
		local Connection1 = DataStoreFolder:GetAttributeChangedSignal(StoreName):Connect(function()
			return Update()
		end)
		
		-- Connections
		table.insert(PlayerConnections, Connection1)
	end
	
	PlayerToConnections[Player] = PlayerConnections
end

local function Initialise()
	-- Fuctions
	-- INIT
	for StoreName, DefaultValue in pairs(OrderedDataStoreInfoModule:GetOrderedDataStoreInfo("New")) do
		StoreNameCache[StoreName] = DataStoreService:GetOrderedDataStore(StoreName)
	end
	
	script:SetAttribute("Loaded", true)
end

local function GetFields(StoreName, Order)
	-- Functions
	-- INIT
	local Pages = StoreNameCache[StoreName]:GetSortedAsync(Order, NumberOfFields)
	local TopFields = Pages:GetCurrentPage()
	
	return TopFields
end

-- DIRECT
function OrderedDataStoreModule.SaveAsync(NilParam, ...)
	return SaveAsync(...)
end

function OrderedDataStoreModule.GetFields(NilParam, ...)
	return GetFields(...)
end

function OrderedDataStoreModule.Get(NilParam, ...)
	return Get(...)
end

function OrderedDataStoreModule.Set(NilParam, ...)
	return Set(...)
end

function OrderedDataStoreModule.PlayerAdded(NilParam, ...)
	return PlayerAdded(...)
end

function OrderedDataStoreModule.PlayerRemoved(NilParam, ...)
	return PlayerRemoved(...)
end

function OrderedDataStoreModule.Initialise()
	return Initialise()
end

return OrderedDataStoreModule