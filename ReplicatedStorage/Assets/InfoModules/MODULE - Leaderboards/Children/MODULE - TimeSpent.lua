-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Conversion(Value)
	-- Functions
	-- INIT
	return UtilitiesModule:FormatTime(Value)
end

-- CORE
local LeaderboardModule = 
{
	["Name"] = "Time Spent",
	["Unit"] = "Seconds",
	["NameColour"] = Color3.fromRGB(255, 255, 255),
	--
	["ValueColour"] = Color3.fromRGB(255, 255, 255),
	--
	["Conversion"] = Conversion
}

return LeaderboardModule