local SpawnModule = {}

-- DIRS
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	InterfacesModule:LoadPage("Custom", "Hud")
end

local function End()
	
end

-- DIRECT
function SpawnModule.Initialise()
	return Initialise()
end

function SpawnModule.End()
	return End()
end

return SpawnModule