local CharacterLoaderModule = {}

-- Dirs
local PartsCharactersFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Characters"]
local PartsMiscFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Misc"]
local Players = game.Players
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local SharedGameAccessoriesFolder = SharedGameFolder:WaitForChild("Accessories")

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])

-- CORE
local PlayerToModules = {}
local PlayerToConnections = {}

-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- Functions
-- MECHANICS
local function LoadDummyClone(Player)
	-- CORE
	local DummyClone = UtilitiesModule:WaitForChildTimed(PartsMiscFolder, "Dummy"):Clone()

	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(DummyClone, "Humanoid")

	-- INIT
	DummyClone.Parent = workspace
	local Success, Appearence = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(Player.UserId)
	end)

	if not Success then
		DebrisModule:AddItem(DummyClone)
		return DebugModule:Print(script.Name.. " | PlayerAdded | Error: ".. tostring(Appearence))
	end

	local Success, Error = pcall(function()
		return Humanoid:ApplyDescription(Appearence)
	end)

	if not Success then
		DebrisModule:AddItem(DummyClone)
		return DebugModule:Print(script.Name.. " | PlayerAdded | Error: ".. tostring(Error))
	end

	Humanoid.BreakJointsOnDeath = false
	DummyClone.Name = Player.Name
	DummyClone.Parent = PartsCharactersFolder
end

local function StoreCharacterAccessories(Player, Character)
	-- Functions
	-- INIT
	local CharacterAppearanceInfo = nil
	local Success, Error = nil, nil

	while not Success do
		Success, Error = pcall(function()
			CharacterAppearanceInfo = game.Players:GetCharacterAppearanceInfoAsync(Player.UserId)
		end)	

		if not Success then
			DebugModule:Print(script.Name.. " | CharacterAdded | CharacterAppearanceInfo: ".. tostring(CharacterAppearanceInfo).. " | Error: ".. tostring(Error))
			task.wait(.25)	
		end
	end

	if CharacterAppearanceInfo then
		local PlayerGameAccessoriesFolder = SharedGameAccessoriesFolder:WaitForChild(Player.UserId)

		for i, Info in pairs(CharacterAppearanceInfo.assets) do

			local Skip = false

			--
			for i, Value in pairs(PlayerGameAccessoriesFolder:GetChildren()) do
				if Value:GetAttributes()["Id"] == Info["id"] then
					Skip = true
					break
				end
			end

			if Skip then
				continue
			end
			--

			--local ProductInfo = MarketplaceService:GetProductInfo(Info["id"], Enum.InfoType.Asset)


			local ItemValue = Instance.new("StringValue")
			ItemValue.Name = Info["name"]
			ItemValue:SetAttribute("Id", Info["id"])
			ItemValue:SetAttribute("assetType", Info["assetType"]["name"])

			if string.find(Info["assetType"]["name"], "Accessory") ~= nil then
				local Success, LoadedModel = nil, nil
				local Attempts = 0

				while not Success do
					Success, LoadedModel = pcall(function()
						return game:GetService("InsertService"):LoadAsset(Info["id"])
					end)

					if not Success then
						DebugModule:Print(script.Name.. " | CharacterAdded | Character: ".. tostring(Character).. " | Player: ".. tostring(Player).. " | Error: ".. tostring(LoadedModel))
						DebugModule:Print(script.Name.. " | CharacterAdded | Character: ".. tostring(Character).. " | Player: ".. tostring(Player).. " | Retrying... | ".. tostring(Attempts).. " / 5")

						if Attempts >= 5 then
							break
						end

						task.wait(.25)
						Attempts += 1
					end
				end


				if Success then
					local FoundAccessory = LoadedModel:FindFirstChildOfClass("Accessory")

					if FoundAccessory then
						ItemValue.Name = FoundAccessory.Name
					end

					LoadedModel:Destroy()
				end
			end

			--ItemValue:SetAttribute("Price", ProductInfo["PriceInRobux"] or 0)
			ItemValue.Parent = PlayerGameAccessoriesFolder

		end
	end
end

local function CharacterAdded(Player, Character)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- FOLDERS
	local CharacterServerModulesFolder = Character:WaitForChild("Modules")["Server"]
	
	-- CORE
	local Connection1 = nil

	-- Functions
	-- MECHANICS
	local function Dead()
		-- Functions
		-- INIT
		UtilitiesModule:DisconnectConnections({Connection1})
		
		for ModuleName, Module in pairs(PlayerToModules[Player]) do
			if Module and Module.End ~= nil then
				Module:End()
			end
		end
	end
	
	-- DIRECT	
	Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			return Dead()
		end
	end)
	
	-- Connections
	
	-- INIT
	Character.Archivable = true
	
	StoreCharacterAccessories(Player, Character)
	ShortcutsModule:SetCollisionGroup(Character, "Characters")

	PlayerToModules[Player] = UtilitiesModule:RunSubModules(CharacterServerModulesFolder)
end

local function PlayerAdded(Player)
	-- Functions
	-- INIT
	if PlayerToConnections[Player] then
		UtilitiesModule:DisconnectConnections(PlayerToConnections[Player])
	end
	
	-- DIRECT
	local Connection1 = Player.CharacterAdded:Connect(function(Character)
		return CharacterAdded(Player, Character)
	end)
	
	-- INIT
	PlayerToConnections[Player] = {Connection1}
	LoadDummyClone(Player)
	
	local PlayerAccessoriesFolder = Instance.new("Folder")
	PlayerAccessoriesFolder.Name = Player.UserId
	PlayerAccessoriesFolder.Parent = SharedGameAccessoriesFolder
	
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if Character then
		return CharacterAdded(Player, Character)
	end
end

local function PlayerRemoved(Player)
	-- FUNCTIONS
	-- INIT
	local FoundDummy = PartsCharactersFolder:FindFirstChild(Player.Name)
	
	if FoundDummy then
		DebrisModule:AddItem(FoundDummy)
	end
	
	local FoundPlayerAccessoriesFolder = SharedGameAccessoriesFolder:FindFirstChild(Player.UserId)
	
	if FoundPlayerAccessoriesFolder then
		DebrisModule:AddItem(FoundPlayerAccessoriesFolder)
	end
end

-- DIRECT
function CharacterLoaderModule.PlayerAdded(NilParam, ...)
	return PlayerAdded(...)
end

function CharacterLoaderModule.PlayerRemoved(NilParam, ...)
	return PlayerRemoved(...)
end

return CharacterLoaderModule