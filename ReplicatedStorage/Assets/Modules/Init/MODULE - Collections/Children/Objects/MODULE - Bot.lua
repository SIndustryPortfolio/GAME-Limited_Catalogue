local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local BotToConnections = {}

-- Functions
-- MECHANICS
local function Initialise(BotModel)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(BotModel, "Humanoid")

	-- CORE
	local Connections = {}
	
	local RunningAnimation = Instance.new("Animation")
	RunningAnimation.AnimationId = "rbxassetid://17821815231"
	
	local RunningAnimationLoad = Humanoid:LoadAnimation(RunningAnimation)
	
	-- Functions
	-- MECHANICS
	local function Running(Speed)
		-- Functions
		-- INIT
		if Speed > 0 then
			if not RunningAnimationLoad.IsPlaying then
				RunningAnimationLoad:Play()
			end
		else
			RunningAnimationLoad:Stop()
		end
	end
	
	-- DIRECT
	local Connection1 = Humanoid.Running:Connect(function(...)
		return Running(...)
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
	
	-- INIT
	BotToConnections[BotModel] = Connections
end

local function End(BotModel)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(BotToConnections[BotModel])
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule