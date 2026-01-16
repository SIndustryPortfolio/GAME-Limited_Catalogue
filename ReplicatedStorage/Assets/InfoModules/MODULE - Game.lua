local GameInfoModule = {}

-- CORE
local GameInfo = 
{
	["MaxAccessories"] = 10,
	["LimitedCoinsPurchaseMultiplier"] = 0.5
}

-- Functions
-- DIRECT
function GameInfoModule.GetGameInfo(NilParam, SettingName)
	return GameInfo[SettingName]
end

function GameInfoModule.GetAllGameInfo()
	return GameInfo
end

return GameInfoModule