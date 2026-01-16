local InitModule = {}

-- Dirs
local BotsCollectionsFolder = workspace:WaitForChild("Collections")["Bot"]
local BotsPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Bots"]
local RenderedNodesFolder = workspace:WaitForChild("Nodes")
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local PartsItemsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Items"]

-- Info Modules
local CategoriesInfoModule = require(SharedInfoModulesFolder["Categories"])
local BotsInfoModule = require(SharedInfoModulesFolder["Bots"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local BotModule = require(ServerModulesFolder["Bot"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- CORE
local BotCount = 5 -- Number of Bots in Server
local MaxPositionOffset = 3 -- Studs
local MaxNumberOfAccessories = 4

local Bots = {}

-- Functions
-- MECHANICS
local function DecorateBot(BotModel)
	-- CORE
	local NumberOfAccessories = math.random(1, MaxNumberOfAccessories)
	
	local AllCategories = PartsItemsFolder:GetChildren()
	local AllBotShirts = BotsInfoModule:GetBotInfo("Shirts")
	local AllBotPants = BotsInfoModule:GetBotInfo("Pants")
	--
	local AllBotSkinTones = BotsInfoModule:GetBotInfo("SkinTones")
	local AllBotSkinToneNames = UtilitiesModule:GetDictKeys(AllBotSkinTones)
	
	-- Functions
	-- INIT
	local Shirt = Instance.new("Shirt")
	Shirt.ShirtTemplate = AllBotShirts[math.random(1, #AllBotShirts)]
	Shirt.Parent = BotModel
	
	local Pants = Instance.new("Pants")
	Pants.PantsTemplate = AllBotPants[math.random(1, #AllBotPants)]
	Pants.Parent = BotModel
	
	local ChosenSkinTone = AllBotSkinTones[AllBotSkinToneNames[math.random(1, #AllBotSkinToneNames)]]
	
	for i, BodyPart in pairs(BotModel:GetChildren()) do
		if not BodyPart:IsA("BasePart") then
			continue
		end
		
		BodyPart.BrickColor = ChosenSkinTone
	end
	
	for i = 1, NumberOfAccessories do
		local RandomCategory = nil
		
		repeat
			RandomCategory = AllCategories[math.random(1, #AllCategories)]
		until #RandomCategory:GetChildren() > 0
		
		local ItemsInCategory = RandomCategory:GetChildren()
		
		local RandomItem = ItemsInCategory[math.random(1, #ItemsInCategory)]
		
		local ItemName = RandomItem.Name
		local CategoryName = RandomCategory.Name
		local ItemInfo = CategoriesInfoModule:GetCategoryInfo(CategoryName):GetItemInfo(ItemName)
		
		ShortcutsModule:AddItemToNPC(BotModel, CategoryName, ItemName, UtilitiesModule:GetDictKeys(ItemInfo["Parts"]), false)
	end
end

local function Initialise()	
	-- CORE
	local AllNodes = RenderedNodesFolder:GetChildren()
	local BotNames = UtilitiesModule:CloneDict(BotsInfoModule:GetBotInfo("Names"))
	
	-- Functions
	-- INIT
	for i = 1, BotCount do
		local SelectedNode = AllNodes[math.random(1, #AllNodes)]
		local SelectedBotNameIndex = math.random(1, #BotNames)
		local SelectedBotName = BotNames[SelectedBotNameIndex]
		
		table.remove(BotNames, SelectedBotNameIndex)
		
		local BotModel = BotsPartsFolder["Bot"]:Clone()
	
		-- Elements
		-- HUMANOIDS
		local Humanoid = UtilitiesModule:WaitForChildOfClass(BotModel, "Humanoid")

		-- INIT
		
		BotModel.Name = SelectedBotName
		BotModel:SetPrimaryPartCFrame(SelectedNode.CFrame * CFrame.new(0, Humanoid.HipHeight + 1, 0))
		
		DecorateBot(BotModel)
		
		BotModel.Parent = BotsCollectionsFolder
		
		local Success, Error = pcall(function()
			return BotModel.PrimaryPart:SetNetworkOwner(nil)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Initialise | BotModel: ".. tostring(BotModel).. " | Error: ".. tostring(Error))
		end
		
		coroutine.wrap(function()
			return BotModule:Initialise(BotModel)
		end)()
		
		table.insert(Bots, BotModel)
	end
end

local function End()
	-- Functions
	-- INIT
	
end

-- DIRECT
function InitModule.Initialise()
	return Initialise()
end

function InitModule.End()
	return End()
end

return InitModule