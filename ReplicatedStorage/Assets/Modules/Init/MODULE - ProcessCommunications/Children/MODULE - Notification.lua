local ProcessCommunicationModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function ServerRequest(...)
	-- CORE
	local HudUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	-- Functions
	-- INIT
	if not HudUiModule then
		return nil
	end
	
	HudUiModule:HudProcess("Notifications", ...)
end

-- DIRECT
function ProcessCommunicationModule.ServerRequest(NilParam, ...)
	return ServerRequest(...)
end

return ProcessCommunicationModule