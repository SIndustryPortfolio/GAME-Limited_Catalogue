local LeaderboardsInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local RequiredModules = UtilitiesModule:RunSubModules(script, true)

-- Functions
-- DIRECT
function LeaderboardsInfoModule.GetLeaderboardInfo(NilParam, SettingName)
	return RequiredModules[SettingName]
end

function LeaderboardsInfoModule.GetAllLeaderboardsInfo()
	return RequiredModules
end

return LeaderboardsInfoModule