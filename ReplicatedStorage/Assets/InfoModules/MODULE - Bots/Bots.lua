local BotsInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- CORE
local UtilitiesModule = require(ModulesFolder["Utilities"])

local RequiredModules = UtilitiesModule:RunSubModules(script)

-- Functions
-- DIRECT
function BotsInfoModule.GetBotInfo(NilParam, SettingName)
	return RequiredModules[SettingName]
end

function BotsInfoModule.GetAllBotInfo()
	return RequiredModules
end

return BotsInfoModule