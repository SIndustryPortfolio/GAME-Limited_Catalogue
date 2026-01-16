local ProcessCommunicationModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local ChatMessageModule = require(ModulesFolder["ChatMessage"])

-- Functions
-- MECHANICS
local function ServerRequest(...)
	-- Functions
	-- INIT
	return ChatMessageModule:ServerRequest(...)
end

-- DIRECT
function ProcessCommunicationModule.ServerRequest(NilParam, ...)
	return ServerRequest(...)
end

return ProcessCommunicationModule