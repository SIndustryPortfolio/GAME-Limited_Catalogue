local TipsInfoModule = {}

-- CORE
local TipsInfo = 
{
	["10"] = {Name = "10RobuxTip"},
	["50"] = {Name = "50RobuxTip"},
	["100"] = {Name = "100RobuxTip"}
}

-- Functions
-- DIRECT
function TipsInfoModule.GetTipInfo(NilParam, SettingName)
	return TipsInfo[SettingName]
end

function TipsInfoModule.GetAllTipInfo()
	return TipsInfo
end

return TipsInfoModule