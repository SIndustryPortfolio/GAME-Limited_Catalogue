local RotateAroundViewportPartModule = {}

-- Client
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local UserInputService = game:GetService("UserInputService")

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
	local MouseDown = false
	
	if not UpdateTable then
		UpdateTable = {}
	end
	
	local PartToRotateAround = nil
	
	if UpdateTable[1] then
		PartToRotateAround = Part or UpdateTable[1]	
	else
		PartToRotateAround = Part or Viewport:FindFirstChildWhichIsA("BasePart") or Viewport:FindFirstChildOfClass("Model")
	end
	
	--DebugModule:Print(script.Name.. " | Iniitalise | PartToRotateAround: ".. tostring(PartToRotateAround).. " | UpdateTable[1]: ".. tostring(UpdateTable[1]))
	
	--local PartToShift = UtilitiesModule:GetPartToShift(PartToRotateAround)
	local XAngle = 0
	local YAngle = 0
	local Offset = 0 -- Studs
	
	if PartToRotateAround:IsA("Model") then
		Offset = (PartToRotateAround:GetExtentsSize().X + PartToRotateAround:GetExtentsSize().Z) * 2
	else
		Offset = (PartToRotateAround.Size.X + PartToRotateAround.Size.Z)
	end
	
	if ZOffset then
		Offset += ZOffset
	end
	
	local StartPosition = nil
	local Size = nil
	local ViewportCamera = nil
	local Subject = nil
	
	-- Functions
	-- MECHANICS
	local function Update()
		-- CORE
		local Delta = UserInputService:GetMouseDelta()

		-- Elements
		-- CAMERAS
		local ViewportCamera = Viewport.CurrentCamera

		-- Functions
		-- INIT
		XAngle += (Delta.X * 0.10)
		YAngle = math.clamp(YAngle + (Delta.Y * 0.10), -60, 60)

		--[[local Subject = UpdateTable[1] or UtilitiesModule:GetRootModel(ViewportCamera.CameraSubject)

		local StartPosition = nil
		local Size = nil

		if Subject:IsA("Model") then
			StartPosition = Subject:GetBoundingBox().p
			Size = Subject:GetExtentsSize()
		else
			StartPosition = Subject.Position
			Size = Subject.Size
		end]]

		ViewportCamera.CFrame = CFrame.new(StartPosition) * CFrame.Angles(math.rad(YAngle), math.rad(XAngle), 0) * CFrame.new(0, 0, Offset)
		ViewportCamera.Focus = CFrame.new(StartPosition)
	end
	
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
		XAngle += StartAngle
	end
	
	local Connection1 = Mouse.Button1Down:Connect(function()
		if Mouse.X > Viewport.AbsolutePosition.X and Mouse.X < (Viewport.AbsolutePosition.X + Viewport.AbsoluteSize.X) then
			if Mouse.Y > Viewport.AbsolutePosition.Y and Mouse.Y < (Viewport.AbsolutePosition.Y + Viewport.AbsoluteSize.Y) then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				MouseDown = true
				return nil
			end
		end
		
		MouseDown = false
	end)
	
	local Connection2 = Mouse.Button1Up:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		MouseDown = false
	end)
	
	local Connection3 = Mouse.Move:Connect(function()
		if MouseDown then
			Update()
		end
	end)
	
	local Connection4 = UserInputService.TouchMoved:Connect(function()
		if MouseDown then
			Update()
		end
	end)
	
	local Connection5 = nil
	local Connection6 = nil
	
	Connection5 = CustomConnection:GetPropertyChangedSignal("Value"):Connect(function()
		if not CustomConnection or not CustomConnection.Value then
			return UtilitiesModule:DisconnectConnections({Connection1, Connection2, Connection3, Connection4, Connection5, Connection6})
		end
	end)
	
	Connection6 = Viewport:GetPropertyChangedSignal("Parent"):Connect(function()
		if not Viewport then
			return UtilitiesModule:DisconnectConnections({Connection1, Connection2, Connection3, Connection4, Connection5, Connection6})
		end
	end)
	
	-- INIT
	ViewportCamera = Viewport.CurrentCamera
	Subject = UpdateTable[1] or UtilitiesModule:GetRootModel(ViewportCamera.CameraSubject)

	if Subject:IsA("Model") then
		StartPosition = Subject:GetBoundingBox().p
		Size = Subject:GetExtentsSize()
	else
		StartPosition = Subject.Position
		Size = Subject.Size
	end
	
	Update()
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