local MarketplaceInitModule = {}

-- Dirs
local SharedCachesModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Caches"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Remotes"]["ClientServer"]["Remotes"]

-- CACHES
local ProfilePictureCacheModule = require(SharedCachesModulesFolder["ProfilePicture"])
local AssetThumbnailCacheModule = require(SharedCachesModulesFolder["AssetThumbnail"])

-- Info Modules
local GameInfoModule = require(SharedInfoModulesFolder["Game"])
local CategoriesInfoModule = require(SharedInfoModulesFolder["Categories"])
local DeveloperProductsInfoModule = require(SharedInfoModulesFolder["DeveloperProducts"])
local TipsInfoModule = require(SharedInfoModulesFolder["Tips"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local OrderedDataStoreHandlerModule = require(ServerModulesFolder["OrderedDataStoreHandler"])

-- CORE
local WebhookURLS = 
{
	["Purchases"] = "https://discord.com/api/webhooks/1249314180159246336/ugu7ZYP_fH5GsY4PmXckQYupTQmTn8tflATHTlfYPlaHSnP2XtTFcjyrov8qj3-8KvGR",
	["Tips"] = "https://ptb.discord.com/api/webhooks/1253290820879253616/SFMEFoJo5Lze9FxGWPkwY0k3DV8_CLaJx86kP-tshARm8aKxzkm5hpNDiz4rGYk-Sbqb"
}

local ProxyURL = "roproxy.com"

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Services
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

-- CORE
--local PurchasesStore = DataStoreService:GetDataStore("Purchases")

-- Functions
-- MECHANICS
local function PurchasedProduct(ReceiptInfo)
	-- CORE
	local UserId = ReceiptInfo.PlayerId
	local PurchaseId = ReceiptInfo.PurchaseId
	local ProductId = ReceiptInfo.ProductId
	
	local Player = game.Players:GetPlayerByUserId(UserId)
	
	-- Functions
	-- INIT
	local ProductName = ""
	local TipValue = 0
	
	--
	for _ProductName, _ProductInfo in pairs(DeveloperProductsInfoModule:GetAllDeveloperProductInfo()) do
		if _ProductInfo["Id"] == ProductId then
			ProductName = _ProductName
			break
		end
	end
	
	for _TipValue, _TipInfo in pairs(TipsInfoModule:GetAllTipInfo()) do
		if _TipInfo["Name"] == ProductName then
			TipValue = _TipValue
			break
		end
	end
	--
	
	local RobuxSpentValue = Player["DataStore"]:GetAttribute("RobuxSpent") --OrderedDataStoreHandlerModule:Get(Player, "RobuxSpent")
	local ToStoreRobuxSpentValue = RobuxSpentValue + TipValue
	--OrderedDataStoreHandlerModule:Set(Player, "RobuxSpent", ToStoreRobuxSpentValue)
	Player["DataStore"]:SetAttribute("RobuxSpent", ToStoreRobuxSpentValue)

	OrderedDataStoreHandlerModule:SaveAsync(Player, "RobuxSpent")
	
	Player["DataStore"]:SetAttribute("Coins", math.floor(Player["DataStore"]:GetAttribute("Coins") + (TipValue * GameInfoModule:GetGameInfo("LimitedCoinsPurchaseMultiplier"))))
	--OrderedDataStoreHandlerModule:Set(Player, "TimeSpent", math.floor(OrderedDataStoreHandlerModule:Get(Player, "TimeSpent") + (tick() - Player:GetAttributes()["LastTimeSpentTick"])))

	OrderedDataStoreHandlerModule:SaveAsync(Player, "Coins")

	coroutine.wrap(function()
		local ChatString = "<font color='rgb(1,1,1)'>[Server]: </font>".. tostring(Player.Name).. " has just tipped: <font color='rgb(0, 255, 127)'>".. tostring(TipValue).. " Robux</font>!"

		GameProcessRemote:FireAllClients("ChatMessage", "Add", ChatString, Color3.fromRGB(255, 255, 255), "Purchase")
		GameProcessRemote:FireAllClients("Notification", "Add", "Tip", Player, TipValue)
		
		local PackagedData = 
			{
				["embeds"] = 
				{
					{
						["username"] = Player.Name,
						["title"] = "Tipped: **".. TipValue.. " R$**",
						["type"] = "rich",
						["color"] = tonumber(0x00FF00),
						["author"] = 
						{
							["name"] = Player.DisplayName or Player.Name,
							["url"] = "https://www.roblox.com/users/".. tostring(Player.UserId).. "/profile"
						},
						["thumbnail"] = 
						{
							["url"] = ProfilePictureCacheModule:Get(Player.UserId) --UserThumbnailResponse["data"][1]["imageUrl"]
						},
						["footer"] = 
						{
							["text"] = "Want to donate? Join the game!"
						}
					}	
				}
			}

		local Success, Error = pcall(function()
			return HttpService:PostAsync(WebhookURLS["Tips"], HttpService:JSONEncode(PackagedData))
		end)

		if not Success then
			DebugModule:Print(script.Name.. " | Purchased | Player: ".. tostring(Player).. " | ProductId: ".. tostring(ProductId).. " | Error: ".. tostring(Error))
		end
	end)()
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function Purchased(Player, AssetId, IsPurchased)
	-- Functions
	-- INIT
	if not IsPurchased then
		return nil
	end
	
	local ItemName, ItemInfo = nil, nil
	local PartName, PartInfo = nil, nil
	local PartIndex = nil
	
	for _ItemName, _ItemInfo in pairs(CategoriesInfoModule:GetAllItemInfo()) do
		for Index, _PartInfo in pairs(_ItemInfo["Parts"]) do
			if _PartInfo["Id"] == AssetId then
				ItemName = _ItemName
				ItemInfo = _ItemInfo
				PartIndex = Index
				PartName = Index
				PartInfo = _PartInfo
				break
			end
		end
	end
	
	local ProductInfo = nil
	
	local Success = false
	
	while not Success do
		Success, ProductInfo = pcall(function()
			return MarketplaceService:GetProductInfo(AssetId, Enum.InfoType.Asset)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Purchased | Error: ".. tostring(ProductInfo))
			task.wait(1)
		end
	end
	
	DebugModule:Print(script.Name.. " | Purchased | Player: ".. tostring(Player).. " | ItemName: ".. tostring(ItemName).. " | ItemInfo: ".. tostring(ItemInfo).. " | PartName: ".. tostring(PartName).. " | PartInfo: ".. tostring(PartInfo))
	
	local RobuxSpentValue = Player["DataStore"]:GetAttribute("RobuxSpent") --OrderedDataStoreHandlerModule:Get(Player, "RobuxSpent")
	local ToStoreRobuxSpentValue = RobuxSpentValue + ProductInfo["PriceInRobux"]
	--OrderedDataStoreHandlerModule:Set(Player, "RobuxSpent", ToStoreRobuxSpentValue)
	Player["DataStore"]:SetAttribute("RobuxSpent", ToStoreRobuxSpentValue)
	
	OrderedDataStoreHandlerModule:SaveAsync(Player, "RobuxSpent")

	local ChatString = "<font color='rgb(1,1,1)'>[Server]: </font>".. tostring(Player.Name).. " has just purchased ".. tostring(ProductInfo["Name"]).. " for: <font color='rgb(0, 255, 127)'>".. tostring(ProductInfo["PriceInRobux"]).. " Robux</font>!"
	
	GameProcessRemote:FireAllClients("ChatMessage", "Add", ChatString, Color3.fromRGB(255, 255, 255), "Purchase")
	GameProcessRemote:FireAllClients("Notification", "Add", "Purchase", Player, ItemInfo["Category"], ItemName, PartIndex)
	
	GameProcessRemote:FireClient(Player, "Tip") -- OPEN TIP UI CLIENT
	GameProcessRemote:FireClient(Player, "PurchaseFinished", ItemInfo["Category"], ItemName, PartIndex, ItemInfo)
	
	Player["DataStore"]:SetAttribute("Coins", math.floor(Player["DataStore"]:GetAttribute("Coins") + (ProductInfo["PriceInRobux"] * GameInfoModule:GetGameInfo("LimitedCoinsPurchaseMultiplier"))))
	--OrderedDataStoreHandlerModule:Set(Player, "TimeSpent", math.floor(OrderedDataStoreHandlerModule:Get(Player, "TimeSpent") + (tick() - Player:GetAttributes()["LastTimeSpentTick"])))

	OrderedDataStoreHandlerModule:SaveAsync(Player, "Coins")
	
	--local PurchaseInfo = {["ItemName"] = ItemName, ["Category"] = ItemInfo["Category"]}	
	
	local PackagedData = 
	{
		["embeds"] = 
		{
			{
				["username"] = Player.Name,
				["title"] = tostring(ProductInfo["Name"]),
				["url"] = "https://www.roblox.com/catalog/".. tostring(AssetId),
				["description"] = "Purchased for: **".. tostring(ProductInfo["PriceInRobux"]).. " R$**",
				["type"] = "rich",
				["color"] = tonumber(0x00FF00),
				["author"] = 
				{
					["name"] = Player.DisplayName or Player.Name,
					["url"] = "https://www.roblox.com/users/".. tostring(Player.UserId).. "/profile"
				},
				["thumbnail"] = 
				{
					["url"] = ProfilePictureCacheModule:Get(Player.UserId) --UserThumbnailResponse["data"][1]["imageUrl"]
				},
				["fields"] = 
				{
					{
						["name"] = "Description",
						["value"] = ProductInfo["Description"]
					}
				},
				["image"] = 
				{
					["url"] = AssetThumbnailCacheModule:Get(AssetId) --AssetThumbnailResponse["data"][1]["imageUrl"],
				},
				["footer"] = 
				{
					["text"] = "Want to purchase? Join the game!"
				}
			}	
		}
	}

	local Success, Error = pcall(function()
		return HttpService:PostAsync(WebhookURLS["Purchases"], HttpService:JSONEncode(PackagedData))
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Purchased | Player: ".. tostring(Player).. " | AssetId: ".. tostring(AssetId).. " | Error: ".. tostring(Error))
	end
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = MarketplaceService.PromptPurchaseFinished:Connect(function(...)
		return Purchased(...)
	end)
	
	-- INIT
	MarketplaceService.ProcessReceipt = PurchasedProduct
end

-- DIRECT
function MarketplaceInitModule.Initialise()
	return Initialise()
end

return MarketplaceInitModule