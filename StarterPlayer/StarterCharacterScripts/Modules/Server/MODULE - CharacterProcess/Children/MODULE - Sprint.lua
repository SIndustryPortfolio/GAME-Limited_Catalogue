local SprintProcessModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent

local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsCharactersFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Characters"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local ParticlesModule = require(SharedModulesFolder["Particles"])

-- Elements
-- HUMANOIDS
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

-- CORE
local SprintSpeed = 32
local NormalSpeed = 16

-- Functions
-- MECHANICS
local function Toggle()
	-- Functions
	-- INIT
	if Humanoid.WalkSpeed == SprintSpeed then
		Humanoid.WalkSpeed = NormalSpeed
	else
		Humanoid.WalkSpeed = SprintSpeed	
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Toggle"] = Toggle
}

-- MECHANICS
local function ClientRequest(Player, FunctionName, ...)
	-- Functions
	-- INIT
	return ClientRequests[FunctionName](Player, ...)
end

-- DIRECT
function SprintProcessModule.ClientRequest(NilParam, ...)
	return ClientRequest(...)
end

return SprintProcessModule