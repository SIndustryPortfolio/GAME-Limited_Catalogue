local AccessoriesProcessModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsCharactersFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Characters"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local ParticlesModule = require(SharedModulesFolder["Particles"])

-- Functions
-- MECHANICS
local function DeleteAccessoriesFromCharacter(Character, ToIgnoreAccessories)
	-- Functions
	-- INIT
	for i, Accessory in pairs(ShortcutsModule:GetAccessoriesFromCharacter(Character)) do
		
		local Skip = false
		
		if ToIgnoreAccessories then
			for i, Table in pairs(ToIgnoreAccessories) do
				if Accessory.Name ~= Table["ItemName"] then
					continue
				end
				
				if not Table["Indexs"] or #Table["Indexs"] <= 0 or table.find(Table["Indexs"], (Accessory:GetAttributes()["Index"] or 0)) then
					Skip = true
				end
			end
		end
		
		if Skip then
			continue
		end
		
		Accessory:Destroy()
	end
end

local function GetAccessoryNameArray(Accessories)
	-- CORE
	local Names = {}
	
	-- Functions
	-- INIT
	for i, Table in pairs(Accessories) do
		table.insert(Names, Table["ItemName"])
	end
	
	return Names
end

local function RemoveAccessories(Player, Accessories)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local AccessoryNames = GetAccessoryNameArray(Accessories)

	-- Functions
	-- INIT
	for i, Table in pairs(Accessories) do
		if not Table["Category"] then
			continue
		end

		for x, Accessory in pairs(ShortcutsModule:GetAccessoriesFromCharacter(Character)) do
			if Accessory.Name == Table["ItemName"] and table.find(Table["Indexs"], Accessory:GetAttributes()["Index"]) then
				Accessory:Destroy()	
			end
		end
	end
	
	ParticlesModule:LoadParticle("Smoke", Character["HumanoidRootPart"], 0.3, true)
end

local function AddAccessories(Player, Accessories)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local AccessoryNames = GetAccessoryNameArray(Accessories)
	
	-- Functions
	-- INIT
	for i, Table in pairs(Accessories) do
		if not Table["Category"] then
			continue
		end

		ShortcutsModule:AddItemToNPC(Character, Table["Category"], Table["ItemName"], Table["Indexs"])
	end
	
	ParticlesModule:LoadParticle("Smoke", Character["HumanoidRootPart"], 0.3, true)
end

local function ChangeAccessories(Player, Accessories)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local AccessoryNames = GetAccessoryNameArray(Accessories)
	
	-- Functions
	-- INIT
	if not Character then
		return nil
	end
	
	DeleteAccessoriesFromCharacter(Character, Accessories)
	
	AddAccessories(Player, Accessories)
end

local function ResetAccessories(Player)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)

	-- Functions
	-- INIT
	DeleteAccessoriesFromCharacter(Character)
	
	for i, Accessory in pairs(ShortcutsModule:GetAccessoriesFromCharacter(UtilitiesModule:WaitForChildTimed(PartsCharactersFolder, Player.Name))) do
		local AccessoryClone = Accessory:Clone()
		Character["Humanoid"]:AddAccessory(AccessoryClone)
	end
	
	ParticlesModule:LoadParticle("Smoke", Character["HumanoidRootPart"], 0.3, true)
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["ChangeAccessories"] = ChangeAccessories,
	["AddAccessories"] = AddAccessories,
	["RemoveAccessories"] = RemoveAccessories,
	["ResetAccessories"] = ResetAccessories
}

-- MECHANICS
local function ClientRequest(Player, FunctionName, ...)
	-- Functions
	-- INIT
	return ClientRequests[FunctionName](Player, ...)
end

-- DIRECT
function AccessoriesProcessModule.ClientRequest(NilParam, ...)
	return ClientRequest(...)
end

return AccessoriesProcessModule