local FixesInitModule = {}

-- Dirs
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

-- DIRECT
function FixesInitModule.Initialise()
	return Initialise()
end

return FixesInitModule