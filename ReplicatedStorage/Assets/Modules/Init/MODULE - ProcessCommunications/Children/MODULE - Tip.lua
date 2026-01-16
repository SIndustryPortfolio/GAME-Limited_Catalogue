local ProcessCommunicationModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function ServerRequest(...)
	-- CORE
	local PagesToUnload = {"Catalog", "LoadCatalog", "CategorySelect"}
	
	-- Functions
	-- INIT
	for i, PageName in pairs(PagesToUnload) do
		InterfacesModule:UnloadPage("Custom", PageName)
	end
	
	InterfacesModule:LoadPage("Custom", "Tip")
end

-- DIRECT
function ProcessCommunicationModule.ServerRequest(NilParam, ...)
	return ServerRequest(...)
end

return ProcessCommunicationModule