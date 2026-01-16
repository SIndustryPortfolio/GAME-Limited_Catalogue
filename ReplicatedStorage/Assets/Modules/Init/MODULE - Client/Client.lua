local ClientModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsCharactersFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Characters"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])

-- CORE
local RequiredModules = {}

local Connections = {}
local CharacterRequiredModules = {}
local CharacterConnections = {}

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()
	
	coroutine.wrap(function()
		return InterfacesModule:LoadFirstPage("Custom", "Intro")
	end)()
	
	RequiredModules = UtilitiesModule:RunSubModules(script)

end

-- DIRECT
function ClientModule.Initialise()
	return Initialise()
end

return ClientModule