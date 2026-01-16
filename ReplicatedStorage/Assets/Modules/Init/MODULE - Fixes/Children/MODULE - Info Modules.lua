local FixInfoModulesInitModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	for i, InfoModule in pairs(InfoModulesFolder:GetChildren()) do
		require(InfoModule)
	end
end

-- DIRECT
function FixInfoModulesInitModule.Initialise()
	return Initialise()
end

return FixInfoModulesInitModule