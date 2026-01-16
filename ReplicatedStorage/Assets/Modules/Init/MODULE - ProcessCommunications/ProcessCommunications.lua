local ProcessCommunicationsModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Remotes"]["ClientServer"]["Remotes"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local Connections = {}
local RequiredModules = UtilitiesModule:RunSubModules(script, true)

-- Functions
-- MECHANICS
local function OnGameProcessRemoteFired(ModuleName, ...)
	-- Functions
	-- INIT
	return RequiredModules[ModuleName]:ServerRequest(...)
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = GameProcessRemote.OnClientEvent:Connect(OnGameProcessRemoteFired)
	
	-- Connections
	table.insert(Connections, Connection1)
end

-- DIRECT
function ProcessCommunicationsModule.Initialise()
	return Initialise()
end

return ProcessCommunicationsModule