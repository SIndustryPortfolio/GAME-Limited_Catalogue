local ServerInitModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

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
	
end

-- DIRECT
function ServerInitModule.Initialise()
	return Initialise()
end

function ServerInitModule.End()
	return End()
end

return ServerInitModule