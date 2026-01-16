local BotModule = {}

-- Dirs
local RenderedNodesFolder = workspace:WaitForChild("Nodes")
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Remotes"]["ClientServer"]["Remotes"]

-- INFO MODULES
local CategoriesInfoModule = require(SharedInfoModulesFolder["Categories"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Services
local PathFindingService = game:GetService("PathfindingService")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- CORE
local MaxPositionOffset = 3 -- Studs
local PurchaseMinTime = 75
local PurchaseMaxTime = 30000

-- Functions
-- MECHANICS
local function Initialise(BotModel)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(BotModel, "Humanoid")
	
	-- PARTS
	local HumanoidRootPart = BotModel:WaitForChild("HumanoidRootPart")
	
	-- CORE
	local PurchaseMessageEvery = UtilitiesModule:MinutesToSeconds(math.random(PurchaseMinTime, PurchaseMaxTime)  / 100)
	
	local LastMessageSendTick = tick()
	
	local Path = PathFindingService:CreatePath(
		{
			["AgentRadius"] = 2,
			["AgentHeight"] = Humanoid.HipHeight,
			["AgentCanJump"] = true,
			["Costs"] = 
				{
					["Snow"] = math.huge,
					["Metal"] = math.huge,
					["SmoothPlastic"] = math.huge
				}
		}
	)
	
	-- Functions
	-- MECHANICS
	local function SendPurchaseMessage()
		-- CORE
		local AllCategoryFolders = ShortcutsModule:GetAllPopulatedCategoryFolders()
		local CategoryFolder = AllCategoryFolders[math.random(1, #AllCategoryFolders)]
		local AllCategoryItems = CategoryFolder:GetChildren()
		local ItemFolder = AllCategoryItems[math.random(1, #AllCategoryItems)]
		
		local ItemInfo = CategoriesInfoModule:GetCategoryInfo(CategoryFolder.Name):GetItemInfo(ItemFolder.Name)
		
		local PartIndex = math.random(1, UtilitiesModule:GetSizeOfDict(ItemInfo["Parts"]))
		local ProductInfo = MarketplaceService:GetProductInfo(ItemInfo["Parts"][PartIndex]["Id"])
		
		-- Functions
		-- INIT
		if not ProductInfo or not ProductInfo["PriceInRobux"] then
			return nil
		end
		
		PurchaseMessageEvery = UtilitiesModule:MinutesToSeconds(math.random(PurchaseMinTime, PurchaseMaxTime)  / 100)
		
		local ChatString = "<font color='rgb(1,1,1)'>[Server]: </font>".. tostring(BotModel.Name).. " has just purchased ".. tostring(ProductInfo["Name"]).. " for: <font color='rgb(0, 255, 127)'>".. tostring(ProductInfo["PriceInRobux"]).. " Robux</font>!"

		GameProcessRemote:FireAllClients("ChatMessage", "Add", ChatString, Color3.fromRGB(255, 255, 255), "Purchase")
		GameProcessRemote:FireAllClients("Notification", "Add", "Purchase", BotModel, ItemInfo["Category"], ItemFolder.Name, PartIndex)
	end
	
	-- INIT
	CollectionService:AddTag(BotModel, "Bot")
	ShortcutsModule:SetCollisionGroup(BotModel, "Characters")

	local AllNodes = RenderedNodesFolder:GetChildren()

	while Humanoid and Humanoid.Health > 0 and task.wait() do
		if #AllNodes <= 0 then
			AllNodes = RenderedNodesFolder:GetChildren()
		end
		
		local SelectedNodeIndex = math.random(1, #AllNodes)
		
		local DestinationNode = AllNodes[SelectedNodeIndex]
		
		table.remove(AllNodes, SelectedNodeIndex)
		
		local RandomXOffset = math.random(-(MaxPositionOffset * 100), MaxPositionOffset * 100) / 100
		local RandomZOffset = math.random(-(MaxPositionOffset * 100), MaxPositionOffset * 100) / 100
		
		local DestinationPosition = Vector3.new(DestinationNode.Position.X, HumanoidRootPart.Position.Y, DestinationNode.Position.Z) + Vector3.new(RandomXOffset, 0, RandomZOffset)
		
		local Success, Error = pcall(function()
			return Path:ComputeAsync(HumanoidRootPart.Position, DestinationPosition)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Initialise | BotModel: ".. tostring(BotModel).. " | Error: ".. tostring(Error))
			continue	
		end
		
		if Path.Status == Enum.PathStatus.Success then
			local Waypoints = Path:GetWaypoints()
			
			local PathIndex = 1
			
			local Connection1 = nil
			local Connection2 = nil				
			
			-- MECHANICS
			local function NextPath()
				-- CORE
				local ReachedWaypoint = false

				-- MECHANICS
				local function Finished()
					UtilitiesModule:DisconnectConnections({Connection1})

					PathIndex += 1
					ReachedWaypoint = true

					coroutine.wrap(function()
						NextPath()
					end)()
				end

				-- DIRECT
				Connection1 = Humanoid.MoveToFinished:Connect(function(Reached)
					return Finished()
				end)
				
				if PathIndex > #Waypoints then
					return nil
				end
				
				local Waypoint = Waypoints[PathIndex]
				
				if Waypoint.Action == Enum.PathWaypointAction.Jump then
					Humanoid.Jump = true
					
					return Finished()
				else
					Humanoid:MoveTo(Waypoint.Position)
				end
			end
			
			Connection2 = RunService.Heartbeat:Connect(function()
				local TimeNow = tick()

				if TimeNow - LastMessageSendTick > PurchaseMessageEvery then
					LastMessageSendTick = TimeNow
					SendPurchaseMessage()
				end

				if Humanoid.Sit then
					Humanoid.Jump = true
				end
			end)
			
			NextPath()
			
			repeat
				task.wait()
			until PathIndex > #Waypoints
			
			UtilitiesModule:DisconnectConnections({Connection1, Connection2})
			
			--[[for _, Waypoint in Path:GetWaypoints() do
				local Connection1 = nil				
				local ReachedWaypoint = false
				
				Connection1 = Humanoid.MoveToFinished:Connect(function(Reached)
					UtilitiesModule:DisconnectConnections({Connection1})
					
					ReachedWaypoint = true
				end)
				
				Humanoid:MoveTo(Waypoint.Position)
				
				repeat
					local TimeNow = tick()
					
					if TimeNow - LastMessageSendTick > PurchaseMessageEvery then
						SendPurchaseMessage()
						LastMessageSendTick = TimeNow
					end
					
					if Humanoid.Sit then
						Humanoid.Jump = true
					end
					
					task.wait(.05)
				until ReachedWaypoint or not Humanoid or Humanoid.Health <= 0
				
				UtilitiesModule:DisconnectConnections({Connection1})
			end]]
			
			task.wait(math.random(1, 3))
		end		
	end	
end

local function End()
	
end

-- DIRECT
function BotModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return BotModule