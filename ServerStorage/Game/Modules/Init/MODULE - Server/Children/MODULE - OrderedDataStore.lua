local InitModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedLeaderboardsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Leaderboard"]

-- Info Modules
local OrderedDataStoreInfoModule = require(ServerInfoModulesFolder["OrderedDataStore"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local OrderedDataStoreHandlerModule = require(ServerModulesFolder["OrderedDataStoreHandler"])

-- CORE
local LastTickTime = 0
local UpdateEvery = UtilitiesModule:MinutesToSeconds(1)

-- SERVICES
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	coroutine.wrap(function()
		-- INIT
		OrderedDataStoreHandlerModule:Initialise()
		
		-- MECHANICS
		local function Update()			
			-- Functions
			-- INIT
			local TimeNow = tick()
			
			if (TimeNow - LastTickTime < UpdateEvery) then
				return nil
			end
			
			LastTickTime = TimeNow
			
			--
			for StoreName, Info in pairs(OrderedDataStoreInfoModule:GetOrderedDataStoreInfo("New")) do
				local TopFields = OrderedDataStoreHandlerModule:GetFields(StoreName, false)
				
				SharedLeaderboardsFolder[StoreName]:ClearAllChildren()
				
				for Rank, Data in ipairs(TopFields) do
					local Key = Data.key
					local Value = Data.value
					
					local UserId = string.sub(Key, string.len(OrderedDataStoreInfoModule:GetOrderedDataStoreInfo("Prefix")) + 1, string.len(Key))
					
					local NumberValue = Instance.new("NumberValue")
					NumberValue.Name = Rank
					NumberValue.Value = Value
					NumberValue:SetAttribute("UserId", UserId)
					NumberValue.Parent = SharedLeaderboardsFolder[StoreName]
				end
				
				SharedLeaderboardsFolder[StoreName]:SetAttribute("UpdatedTime", tick())
			end
			
			
			--
			
			
		end
		
		
		-- DIRECT
		
		local Connection1 = RunService.Heartbeat:Connect(function()
			return Update()
		end)
	end)()
end

-- DIRECT
function InitModule.Initialise()
	return Initialise()
end

return InitModule