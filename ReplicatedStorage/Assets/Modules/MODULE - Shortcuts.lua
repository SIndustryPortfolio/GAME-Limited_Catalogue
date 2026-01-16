local ShortcutsModule = {}

-- Client
local Player = nil

local Success, Error = pcall(function()
	Player = game.Players.LocalPlayer
end)

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsItemsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Items"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- Services
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Functions
-- MECHANICS
local function BuyItem(ItemInfo)
	-- Functions
	-- INIT
	--[[if PromptingBulkPurchase then
		return false
	end

	PromptingBulkPurchase = true]]

	for Index, PartInfo in pairs(ItemInfo["Parts"]) do
		MarketplaceService:PromptPurchase(Player, PartInfo["Id"])
		MarketplaceService.PromptPurchaseFinished:Wait()
	end

	--PromptingBulkPurchase = false
end

local function GetModelFromItem(CategoryName, ItemName, _CustomConnection)
	-- Elements
	-- FOLDERS
	local CategoryFolder = PartsItemsFolder:WaitForChild(CategoryName)
	
	local ItemFolder = UtilitiesModule:WaitForChildTimed(CategoryFolder, ItemName, nil, true, _CustomConnection)
	
	-- CORE
	local IsCustomConnection = false
	
	if _CustomConnection ~= nil then
		IsCustomConnection = true
	end
	
	local NewModel = Instance.new("Model")
	NewModel.Name = tostring(ItemName)
	
	-- Functions
	-- INIT
	repeat
		task.wait()
	until (IsCustomConnection and (not _CustomConnection or not _CustomConnection.Value)) or ItemFolder:GetAttributes()["Loaded"] == true
	
	if (IsCustomConnection and (not _CustomConnection or not _CustomConnection.Value)) then
		return nil
	end
	
	for i, Model in pairs(ItemFolder:GetChildren()) do
		for x, Content in pairs(Model:GetChildren()) do
			Content:Clone().Parent = NewModel
		end
	end
	
	return NewModel
end

local function WeldAccessory(Character, Accessory)
	-- Functions
	-- INIT	
	local Handle = Accessory:FindFirstChild("Handle")
	local AccessoryAttachment = Accessory:FindFirstChildOfClass("Attachment") or Handle:FindFirstChildOfClass("Attachment")

	--print(Accessory:GetChildren())
	
	if not AccessoryAttachment then
		DebugModule:Print(script.Name.. " | WeldAccessory | No AccessoryAttachment")
		return nil
	end
	
	local FoundToAttach = Character["Head"]:FindFirstChild(AccessoryAttachment.Name)
	
	if not FoundToAttach then
		local ToLoop = Character:GetChildren()
		
		table.remove(ToLoop, table.find(ToLoop, Character["Head"]))
		
		for i, Part in pairs(ToLoop) do
			FoundToAttach = Part:FindFirstChild(AccessoryAttachment.Name)
			
			if FoundToAttach then
				break
			end
		end
	end
	
	if not FoundToAttach then
		DebugModule:Print(script.Name.. " | WeldAccessory | No FoundToAttach")
		return nil
	end
	
	Handle.Anchored = true
	Handle.CFrame = FoundToAttach.WorldCFrame * AccessoryAttachment.CFrame:Inverse()
end

local function GetAccessoriesFromCharacter(Character)
	-- CORE
	local Accessories = {}
	
	-- Functions
	-- INIT
	for i, Accessory in pairs(Character:GetChildren()) do
		if Accessory:IsA("Accessory") then
			table.insert(Accessories, Accessory)
		end
	end
	
	return Accessories
end

local function IsCharacterWearingAccessory(Character, ItemName)
	-- Functions
	-- INIT

	for i, Accessory in pairs(ShortcutsModule:GetAccessoriesFromCharacter(Character)) do
		if string.sub(Accessory.Name, 1, string.len(ItemName.. "-")) == ItemName.. "-" then
			return true, Accessory
		end
		
		if Accessory.Name == ItemName then
			return true, Accessory
		end
	end
	
	return false
end

local function GetAllPopulatedCategoryFolders()
	-- CORE
	local Folders = {}
	
	-- Functions
	-- INIT
	for i, Folder in pairs(PartsItemsFolder:GetChildren()) do
		if #Folder:GetChildren() > 0 then
			table.insert(Folders, Folder)
		end
	end
	
	return Folders
end

local function AddItemToNPC(Character, CategoryName, ItemName, IndexsToCover, ClientSide)
	-- CORE
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	--local OldParent = Character.Parent
	
	-- Elements
	-- FOLDERS
	local CategoryFolder = PartsItemsFolder:WaitForChild(CategoryName)
	local ItemFolder = CategoryFolder:WaitForChild(ItemName)
	
	-- Functions
	-- INIT
	--Character.Parent = workspace
	
	local Accessories = {}
	
	for i, Model in pairs(ItemFolder:GetChildren()) do
		if IndexsToCover and not table.find(IndexsToCover, tonumber(Model.Name)) then
			continue
		end
		
		local FoundAccessory = Model:FindFirstChildOfClass("Accessory")
		
		if not FoundAccessory then
			continue
		end
		
		local Skip = false
		
		for i, Accessory in pairs(ShortcutsModule:GetAccessoriesFromCharacter(Character)) do
			if Accessory.Name ~= ItemName then
				continue
			end
			
			if Accessory:GetAttributes()["Index"] == tonumber(Model.Name) then
				Skip = true
				break
			end
		end
		
		if Skip then
			continue
		end
		
		local AccessoryClone = FoundAccessory:Clone()
		AccessoryClone.Name = ItemName
		AccessoryClone:SetAttribute("Category", CategoryName)
		AccessoryClone:SetAttribute("Index", tonumber(Model.Name))
		--AccessoryClone.Parent = Character
		Humanoid:AddAccessory(AccessoryClone)
		
		table.insert(Accessories, AccessoryClone)
		
		if ClientSide then
			ShortcutsModule:WeldAccessory(Character, AccessoryClone)
		end
	end
	
	
	--RunService.Stepped:Wait()
	--Character.Parent = OldParent
	return Accessories
end

local function SetCollisionGroup(Model, GroupName)
	-- Functions
	-- INIT
	for i, Part in pairs({Model, unpack(Model:GetChildren())}) do
		if Part:IsA("BasePart") then
			Part.CollisionGroup = GroupName
		end
	end
end

-- DIRECT
function ShortcutsModule.SetCollisionGroup(NilParam, ...)
	return SetCollisionGroup(...)
end

function ShortcutsModule.GetAllPopulatedCategoryFolders()
	return GetAllPopulatedCategoryFolders()
end

function ShortcutsModule.BuyItem(NilParam, ...)
	return BuyItem(...)
end

function ShortcutsModule.GetAccessoriesFromCharacter(NilParam, ...)
	return GetAccessoriesFromCharacter(...)
end

function ShortcutsModule.IsCharacterWearingAccessory(NilParam, ...)
	return IsCharacterWearingAccessory(...)
end

function ShortcutsModule.GetModelFromItem(NilParam, ...)
	return GetModelFromItem(...)
end

function ShortcutsModule.WeldAccessory(NilParam, ...)
	return WeldAccessory(...)
end

function ShortcutsModule.AddItemToNPC(NilParam, ...)
	return AddItemToNPC(...)
end

return ShortcutsModule