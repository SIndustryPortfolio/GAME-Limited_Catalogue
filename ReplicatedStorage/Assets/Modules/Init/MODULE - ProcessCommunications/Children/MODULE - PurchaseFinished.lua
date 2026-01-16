local ProcessCommunicationModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function ServerRequest(...)
	InterfacesModule:LoadPage("Custom", "PurchaseFinished", false, ...)
end

-- DIRECT
function ProcessCommunicationModule.ServerRequest(NilParam, ...)
	return ServerRequest(...)
end

return ProcessCommunicationModule