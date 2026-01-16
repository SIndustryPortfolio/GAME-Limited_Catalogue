local DeveloperProductsInfoModule = {}

-- CORE
local DeveloperProductsInfo = 
{
	["10RobuxTip"] = {Id = 1854016710},
	["50RobuxTip"] = {Id = 1854016708},
	["100RobuxTip"] = {Id = 1854016709}		
}

-- Functions
-- DIRECT
function DeveloperProductsInfoModule.GetDeveloperProductInfo(NilParam, SettingName)
	return DeveloperProductsInfo[SettingName]
end

function DeveloperProductsInfoModule.GetAllDeveloperProductInfo()
	return DeveloperProductsInfo
end

return DeveloperProductsInfoModule