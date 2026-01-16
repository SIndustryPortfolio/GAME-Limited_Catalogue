local RotateAroundViewportPartModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function SetupViewportCamera()
	-- Functions
	-- INIT
	local Camera = Instance.new("Camera")
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = nil
	
	return Camera
end

local function Initialise(CameraModule, Viewport, Part, CustomConnection, Increment, ZOffset, StartAngle, UpdateTable)
	if not CameraModule or not Viewport or not CustomConnection then
		DebugModule:Print("RotateAroundViewportPart | Cancelled rotate around viewport")
		--DebugModule:Print"CANCELLED ROTATE AROUND VIEWPORT | Camera Module: ".. tostring(CameraModule).. " | Viewport: ".. tostring(Viewport).. " | Custom Connection: ".. tostring(CustomConnection))
		return nil
	end
	
	-- CORE
	if not UpdateTable then
		UpdateTable = {}
	end
	
	local PartToRotateAround = Viewport:FindFirstChildWhichIsA("BasePart") or Viewport:FindFirstChildOfClass("Model") or UpdateTable[1]

	if UpdateTable[1] then
		PartToRotateAround = Part or UpdateTable[1]	
	else
		PartToRotateAround = Part or Viewport:FindFirstChildWhichIsA("BasePart") or Viewport:FindFirstChildOfClass("Model")
	end
	
	--DebugModule:Print(script.Name.. " | Iniitalise | PartToRotateAround: ".. tostring(PartToRotateAround).. " | UpdateTable[1]: ".. tostring(UpdateTable[1]))
	
	--local PartToShift = UtilitiesModule:GetPartToShift(PartToRotateAround)
	local Angle = 0
	local Offset = 0 -- Studs
	
	if PartToRotateAround:IsA("Model") then
		Offset = (PartToRotateAround:GetExtentsSize().X + PartToRotateAround:GetExtentsSize().Z + PartToRotateAround:GetExtentsSize().Y) / 2
	else
		Offset = (PartToRotateAround.Size.X + PartToRotateAround.Size.Z + PartToRotateAround.Size.Y) / 2
	end
	
	if ZOffset then
		Offset += ZOffset
	end
	
	-- Functions
	-- INIT
	if not Viewport.CurrentCamera then
		local Camera = SetupViewportCamera()
		Camera.CameraSubject = PartToRotateAround --PartToShift
		Camera.Parent = Viewport
		Viewport.CurrentCamera = Camera
	end
	
	if not Viewport.CurrentCamera.CameraSubject then
		Viewport.CurrentCamera.CameraSubject = PartToRotateAround
	end
	
	if StartAngle then
		Angle += StartAngle
	end
	
	coroutine.wrap(function()
		local Success, Error = pcall(function()
			--DebugModule:Print("RotateAroundViewportPart | Started Rotation")
			--DebugModule:Print(script.Name.. " | Rotating around: ".. tostring(PartToRotateAround))
			local ViewportCamera = Viewport.CurrentCamera
			
			--while CustomConnection and CustomConnection.Value and Viewport and ViewportCamera --[[and (Viewport.CurrentCamera.CameraSubject or UpdateTable[1])]] --[[and PartToShift]] and task.wait() do
			local Connection
			
			Connection = RunService.Stepped:Connect(function()
				local Subject = UpdateTable[1] or UtilitiesModule:GetRootModel(ViewportCamera.CameraSubject)
								
				local StartPosition = nil
				local Size = nil
				
				if Subject:IsA("Model") then
					local _StartCFrame = Subject:GetPivot()
					
					StartPosition = Vector3.new(_StartCFrame.X, _StartCFrame.Y, _StartCFrame.Z)
					Size = Subject:GetExtentsSize()
				else
					StartPosition = Subject.Position
					Size = Subject.Size
				end
				
				ViewportCamera.CFrame = CFrame.new(StartPosition) * CFrame.Angles(math.rad(0), math.rad(Angle), 0) * CFrame.new(0, 0, Offset)
				ViewportCamera.Focus = CFrame.new(StartPosition)
				
				--[[if Subject then 
					ViewportCamera.CFrame = (Subject.CFrame * CFrame.Angles(0, math.rad(Angle), 0)) * CFrame.new(0, 0, (Subject.Size.Z / 2) + Offset)
				end]]
				
				Angle += Increment or 1
				
				if not Viewport or not ViewportCamera then
					UtilitiesModule:DisconnectCustomConnections({CustomConnection})
				end
				
				if not CustomConnection or not CustomConnection.Value then
					UtilitiesModule:DisconnectConnections({Connection})
				end
				
			end)
			
			--[[if CustomConnection then
				UtilitiesModule:DisconnectCustomConnections({CustomConnection})
			end
			
			DebugModule:Print("RotateAroundViewport | Loop successfully broke")]]
		end)
		
		if not Success then
			DebugModule:Print("RotateAroundViewportPart | Error: ".. tostring(Error))
		end
	end)()
end

local function End(CameraModule, Type)
	
end

-- DIRECT
function RotateAroundViewportPartModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function RotateAroundViewportPartModule.End(NilParam, CameraModule, Type)
	return End(CameraModule, Type)
end

return RotateAroundViewportPartModule