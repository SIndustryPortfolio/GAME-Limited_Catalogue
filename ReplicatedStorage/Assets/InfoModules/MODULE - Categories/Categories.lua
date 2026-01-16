local CategoriesInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local MannequinsFolder = workspace:WaitForChild("Mannequins")

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local CategoriesInfo = UtilitiesModule:RunSubModules(script, true)
local IsLoading = false
local Loading = {}

local ItemsOrderedBySales = {}

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function Load(CategoryName, ItemName--[[, ItemInfo]])
	-- Functions
	-- INIT

	if table.find(Loading, CategoryName.. ItemName) ~= nil then
		return nil
	end

	table.insert(Loading, CategoryName.. ItemName)

	local ItemInfo = CategoriesInfo[CategoryName]:GetItemInfo(ItemName)

	local FullPrice = 0
	local FullSales = 0

	local IsForSale = true
	local IsLimited = false
	local IsLimitedUnique = false

	local CreatedDate = nil

	local Description = ""
	local Creators = {}
	local AssetTypes = {}

	local FailedToLoad = false

	for Index, PartInfo in pairs(ItemInfo["Parts"]) do
		local ProductInfo = nil
		local Success, Error = false, nil

		local Attempts = 0

		while not Success and Attempts < 6 do
			Success, Error = pcall(function()
				ProductInfo = MarketplaceService:GetProductInfo(PartInfo["Id"], Enum.InfoType.Asset)
			end)

			Attempts += 1

			if not Success then
				DebugModule:Print(script.Name.. " | Initialise | CategoryName: ".. tostring(CategoryName).. " | ItemName: ".. tostring(ItemName).. " | Error: ".. tostring(Error))
				task.wait(.5)
			end
		end

		if not ProductInfo then
			PartInfo["FailedToLoad"] = true
			FailedToLoad = true
			continue
		end

		if ProductInfo["ProductType"] == "Collectible Item" and ProductInfo["CollectiblesItemDetails"]["CollectibleLowestResalePrice"] then
			PartInfo["Price"] = ProductInfo["CollectiblesItemDetails"]["CollectibleLowestResalePrice"]
		else
			PartInfo["Price"] = ProductInfo["PriceInRobux"]
		end

					--[[if ItemName == "[?]Black valk 5" then
						print(ProductInfo)
						print(ProductInfo["PriceInRobux"])
					end]]

		if PartInfo["Price"] == nil then
			PartInfo["Price"] = 0
		end

		PartInfo["IsForSale"] = ProductInfo["IsForSale"]

		PartInfo["Creator"] = ProductInfo["Creator"]
		PartInfo["Description"] = ProductInfo["Description"]
		PartInfo["IsLimited"] = ProductInfo["IsLimited"]
		PartInfo["IsLimitedUnique"] = ProductInfo["IsLimitedUnique"]
		PartInfo["Sales"] = ProductInfo["Sales"]
		PartInfo["Created"] = string.sub(ProductInfo["Created"], 1, 10)

		if PartInfo["IsLimited"] then
			IsLimited = true
		end

		if PartInfo["IsLimitedUnique"] then
			IsLimitedUnique = true
		end

		if PartInfo["Description"] then
			Description = PartInfo["Description"]
		end

		local FoundCreator = false

		for i, Info in pairs(Creators) do
			if Info["Name"] == PartInfo["Creator"]["Name"] then
				FoundCreator = true
				break
			end
		end

		if not FoundCreator then
			table.insert(Creators, ProductInfo["Creator"])
		end

		for i, AssetType in pairs(Enum.AssetType:GetEnumItems()) do
			if AssetType.Value == ProductInfo["AssetTypeId"] then
				PartInfo["AssetType"] = AssetType["Name"]
				break
			end
		end

		if table.find(AssetTypes, PartInfo["AssetType"]) == nil then
			table.insert(AssetTypes, PartInfo["AssetType"])
		end

		PartInfo["Icon"] = "rbxthumb://type=Asset&id="..tostring(PartInfo["Id"]).."&w=150&h=150"

		if not PartInfo["IsForSale"] or ProductInfo.Name == "[ Content Deleted ]" then
			IsForSale = false
		end

		FullPrice += PartInfo["Price"]
		FullSales += PartInfo["Sales"]
		CreatedDate = PartInfo["Created"]

		if Index ~= UtilitiesModule:GetSizeOfDict(ItemInfo["Parts"]) then
			task.wait(.1)
		end
	end

	if FailedToLoad then
		ItemInfo["FailedToLoad"] = true
	end

	ItemInfo["AssetTypes"] = AssetTypes
	ItemInfo["IsLimitedUnique"] = IsLimitedUnique
	ItemInfo["IsLimited"] = IsLimited
	ItemInfo["Description"] = Description
	ItemInfo["Creators"] = Creators
	ItemInfo["IsForSale"] = IsForSale
	ItemInfo["Price"] = FullPrice
	ItemInfo["Sales"] = FullSales
	ItemInfo["Created"] = CreatedDate
	ItemInfo["Category"] = CategoryName

	ItemInfo["Loaded"] = true

	script:SetAttribute("CurrentLoaded", script:GetAttributes()["CurrentLoaded"] + 1)

	table.insert(ItemsOrderedBySales, {Name = ItemName, Category = CategoryName})
	
	table.sort(ItemsOrderedBySales, function(a, b)
		local ItemInfo1 = CategoriesInfoModule:GetCategoryInfo(a["Category"]):GetItemInfo(a["Name"])
		local ItemInfo2 = CategoriesInfoModule:GetCategoryInfo(b["Category"]):GetItemInfo(b["Name"])

		return ItemInfo1["Sales"] > ItemInfo2["Sales"]
	end)
	
	--print(ItemsOrderedBySales[1]["Name"])
end

local function Initialise()
	-- Functions
	-- INIT
	if RunService:IsServer() then
		return nil
	end

	coroutine.wrap(function()
		for i, CategoryFolder in pairs(MannequinsFolder:GetChildren()) do
			for x, MannequinModel in pairs(CategoryFolder:GetChildren()) do
				Load(CategoryFolder.Name, MannequinModel.Name, CategoriesInfoModule:GetCategoryInfo(CategoryFolder.Name):GetItemInfo(MannequinModel.Name))
				task.wait(.2) -- 300 items per 60 seconds	
			end
		end
		
		
		for CategoryName, Module in pairs(CategoriesInfoModule:GetAllCategoryInfo()) do
			for ItemName, ItemInfo in pairs(Module:GetAllItemInfo()) do
				Load(CategoryName, ItemName, ItemInfo)
				
				task.wait(.2) -- 300 items per 60 seconds
			end
		end
	end)()
end

local function GetAllItemInfo()
	-- CORE
	local AllItems = {}
	
	-- Functions
	-- INIT
	for CategoryName, CategoryModule in pairs(CategoriesInfoModule:GetAllCategoryInfo()) do
		for ItemName, ItemInfo in pairs(CategoryModule:GetAllItemInfo()) do
			ItemInfo["Category"] = CategoryName --> Force
			
			AllItems[ItemName] = ItemInfo
		end
	end
		
	return AllItems
end

-- DIRECT
function CategoriesInfoModule.ForceLoad(NilParam, ...)
	return Load(...)
end

function CategoriesInfoModule.GetAllItemInfo()
	return GetAllItemInfo()
end

function CategoriesInfoModule.GetAllCategoryInfo()
	return CategoriesInfo
end

function CategoriesInfoModule.GetCategoryInfo(NilParam, SettingName)
	return CategoriesInfo[SettingName]
end

-- INIT
Initialise()

return CategoriesInfoModule