local BrickColorsInfoModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
--local CharacterInfoModule = require(InfoModulesFolder["Character"])

-- CORE
local BrickColorNames = {}

-- Functions
-- DIRECT
function BrickColorsInfoModule.GetBrickColourNames()
	return BrickColorNames
end

-- INIT
--local CharacterColours = CharacterInfoModule:GetCharacterInfo("Colours")

--[[for i, Colour in pairs(CharacterColours) do
	table.insert(BrickColorNames, Colour.Name)
end]]

for i = 1, 1032 do
	local Success, Color = pcall(function()
		return BrickColor.palette(i)
	end)
	
	if Success then
		--[[if table.find(CharacterColours, Color) then
			continue
		end]]
		
		table.insert(BrickColorNames, Color.Name)
	end
end

return BrickColorsInfoModule