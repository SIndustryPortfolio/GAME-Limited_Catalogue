local OrderedDataStoreInfoModule = {}

-- CORE
local OrderedDataStoreInfo = 
{
	["Prefix"] = "Test1-",
	["New"] = 
	{
		["RobuxSpent"] = 0, -- Robux
		["TimeSpent"] = 0, -- Seconds	
		["Coins"] = 0
	},
	["Leaderstats"] = {"Coins", "RobuxSpent"}
}

-- Functions
-- DIRECT
function OrderedDataStoreInfoModule.GetOrderedDataStoreInfo(NilParam, SettingName)
	return OrderedDataStoreInfo[SettingName]
end

function OrderedDataStoreInfoModule.GetAllOrderedDataStoreInfo()
	return OrderedDataStoreInfo
end

return OrderedDataStoreInfoModule