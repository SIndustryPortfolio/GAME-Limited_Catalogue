local SpawnHandlerModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script)
end

local function End()
	-- Functions
	-- INIT
	for ModuleName, Module in pairs(RequiredModules) do
		if Module and Module.End ~= nil then
			Module:End()
		end
	end
end

-- DIRECT
function SpawnHandlerModule.Initialise()
	return Initialise()
end

function SpawnHandlerModule.End()
	return End()
end

return SpawnHandlerModule