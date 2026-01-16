local ClientModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsCharactersFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Characters"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local Connections = {}
local CharacterRequiredModules = {}
local CharacterConnections = {}

-- Functions
-- MECHANICS
local function CharacterDied(Character)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(CharacterConnections[Character])

	for ModuleName, Module in pairs(CharacterRequiredModules[Character]) do
		if Module and Module.End ~= nil then
			Module:End()
		end
	end
end

local function CharacterAdded(Character)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

	-- FOLDERS
	local CharacterModulesFolder = UtilitiesModule:WaitForChildTimed(Character, "Modules")

	-- Functions
	-- DIRECT
	local Connection1 = Humanoid.Died:Connect(function()
		return CharacterDied(Character)
	end)

	-- CONNECTIONS
	CharacterConnections[Character] = {Connection1}

	-- INIT
	CharacterRequiredModules[Character] = UtilitiesModule:RunSubModules(CharacterModulesFolder["Client"])
end


local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = Player.CharacterAdded:Connect(CharacterAdded)

	-- Connections
	table.insert(Connections, Connection1)

	-- INIT
	--local CharacterModel = PartsCharactersFolder:WaitForChild(Player.Name):Clone()
	--CharacterModel.Parent = workspace["Dump"]["Misc"]

	--local UI, Response = InterfacesModule:LoadPage("Custom", "CategorySelect", true)
	--InterfacesModule:LoadPage("Custom", "LoadCatalog", true, Response)

	local _LoadedCharacter = UtilitiesModule:GetCharacter(Player, true)

	if _LoadedCharacter then
		return CharacterAdded(_LoadedCharacter)
	end
end

-- DIRECT
function ClientModule.Initialise()
	return Initialise()
end

function ClientModule.End()
	return nil
end

return ClientModule