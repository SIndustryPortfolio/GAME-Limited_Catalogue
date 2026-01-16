local CharacterProcessModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Elements
-- FOLDERS
local CharacterClientServerRemotesFolder = UtilitiesModule:WaitForChildTimed(Character, "Remotes")["ClientServer"]["Remotes"]

-- REMOTES
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]

-- CORE
local Connections = {}
local RequiredModules = UtilitiesModule:RunSubModules(script, true)

-- Functions
-- MECHANICS
local function onCharacterProcessEventFired(Player, ModuleName, ...)
	-- Functions
	-- INIT
	if Player ~= game.Players:GetPlayerFromCharacter(Character) then
		return nil
	end
	
	return RequiredModules[ModuleName]:ClientRequest(Player, ...)
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = CharacterProcessRemote.OnServerEvent:Connect(onCharacterProcessEventFired)
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function CharacterProcessModule.Initialise()
	return Initialise()
end

function CharacterProcessModule.End()
	return End()
end

return CharacterProcessModule