local ClientModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local SoundsInfoModule = require(InfoModulesFolder["Sounds"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])

-- Functions
-- MECHANICS
local function Initialise()
	-- CORE
	local Tracks = SoundsInfoModule:GetSounds("Music")
	
	-- Functions
	-- INIT
	local SizeOfTracks = UtilitiesModule:GetSizeOfDict(Tracks)
	local RandomTrackNumber = math.random(1, SizeOfTracks)
	
	SoundsModule:PlayMusicByName("Track".. tostring(RandomTrackNumber))
end

local function End()
	
end

-- DIRECT
function ClientModule.Initialise()
	return Initialise()
end

function ClientModule.End()
	return End()
end

return ClientModule