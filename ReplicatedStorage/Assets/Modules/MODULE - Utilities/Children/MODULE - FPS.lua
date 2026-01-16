local FPSModule = {}

-- Services
local RunService = game:GetService("RunService")

-- Core
local startTime = os.clock()
local X = 1
local FPS_Counter = 0
local fps = nil

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
--local FPSLabel = script.Parent


-- Functions
-- MECHANICS
local function GetFPS()
	FPS_Counter+=1
	if (os.clock() - startTime) >= X  then 
		fps = math.floor(FPS_Counter / (os.clock() - startTime))
		--FPSLabel.Text = ''..fps..''
		FPS_Counter = 0
		startTime = os.clock()
	end
	--return FPS_Counter
end

-- DIRECT
function FPSModule.GetFPS()
	return fps
end

-- INIT
Heartbeat:Connect(GetFPS)

return FPSModule