local ServerTagModule = {}

-- Dirs
local MiscPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Misc"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameLeaderboardFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Leaderboard"]
local SharedCachesModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Caches"]

-- Client

-- CACHES
local AppearanceCacheModule = require(SharedCachesModulesFolder["Appearance"])

-- Modules
--local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local SpleefTileConnections = {}

-- Functions
-- MECHANICS
local function Initialise(SpleefTile)
	-- CORE
	local CanTouch = true
	
	-- Functions
	-- MECHANICS
	local function Touched()
		-- Functions
		-- INIT
		if not CanTouch then
			return nil
		end
		
		CanTouch = false
		
		SpleefTile:SetAttribute("Touched", true)
		
		task.wait(5)
		
		SpleefTile:SetAttribute("Touched", false)
		
		--
		
		task.wait(1)
		
		CanTouch = true
	end
	
	-- DIRECT
	local Connection1 = SpleefTile.Touched:Connect(function()
		return Touched()
	end)
	
	-- INIT
	SpleefTileConnections[SpleefTile] = {Connection1}
end

local function End(SpleefTile)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(SpleefTileConnections[SpleefTile])
end

-- DIRECT
function ServerTagModule.Initialise(NilParam, Part)
	return Initialise(Part)
end

function ServerTagModule.End(NilParam, Character)
	return End(Character)
end


return ServerTagModule