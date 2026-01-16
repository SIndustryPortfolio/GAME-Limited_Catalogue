local CategoryInfo = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local CategoryItems = UtilitiesModule:RunSubModules(script, true)

local FocusPartName = "Head"
local IconItemName = ""

-- Functions
-- MECHANICS
local function GetIconItemName()
	-- Functions
	-- INIT
	--[[if IconItemName == "" or not IconItemName then
		if UtilitiesModule:GetSizeOfDict(CategoryItems) <= 0 then
			return nil
		end

		local AllItems = UtilitiesModule:GetDictKeys(CategoryItems)	
		IconItemName = AllItems[math.random(1, #AllItems)]
	end]]

	return IconItemName
end

-- Functions
-- DIRECT
function CategoryInfo.GetIconItemName()
	return GetIconItemName()
end

function CategoryInfo.GetFocusPartName()
	return FocusPartName
end

function CategoryInfo.GetItemInfo(NilParam, SettingName)
	return CategoryItems[SettingName]
end

function CategoryInfo.GetAllItemInfo()
	return CategoryItems
end

return CategoryInfo