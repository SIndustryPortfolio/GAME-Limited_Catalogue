local CameraModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
--local CameraSequencesModule = require(ModulesFolder["CameraSequences"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local CameraAttributes = 
{
	["Offset"] = Vector3.new()	
}

local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, Module in pairs(script:GetChildren()) do
		local Success, RequiredModule = pcall(function()
			return require(Module)
		end)

		if Success then
			RequiredModules[Module.Name] = RequiredModule
		else
			--DebugModule:PrintRequiredModule, "Error")
		end
	end
end

local function GetCamera()
	-- Functions
	-- INIT
	return workspace.CurrentCamera
end

local function SetupCamera()
	-- CORE
	local Camera = GetCamera()
	
	-- Functions
	-- INIT
	for AttributeName, AttributeValue in pairs(CameraAttributes) do
		Camera:SetAttribute(AttributeName, AttributeValue)
	end
end

local function GetCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function ResetCamera(FullReset)
	-- CORE
	local Camera = GetCamera()
	local Character = UtilitiesModule:GetCharacter(Player, true) --GetCharacter()
	local FoundBlur = Camera:FindFirstChildOfClass("BlurEffect")
	
	-- Functions
	-- INIT
	--CameraSequencesModule:StopAllSequences()
	task.wait()
		
	if FoundBlur then
		FoundBlur.Size = 0
	end
		
	for ModuleName, RequiredModule in pairs(RequiredModules) do
		if RequiredModule and RequiredModule.Reset ~= nil then
			RequiredModule:Reset()
		end
	end
	
	if Camera:GetAttributes()["Offset"] ~= nil then
		Camera:SetAttribute("Offset", Vector3.new())
	end
	
	if FullReset then
		Character = Character or UtilitiesModule:GetCharacter(Player)

		UtilitiesModule:WaitUntilLoaded(Character)
		
		if not Character then
			return nil
		end
		
		Camera.CFrame = Character:WaitForChild("HumanoidRootPart").CFrame
		Camera.CameraSubject = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
		Camera.CameraType = Enum.CameraType.Custom
	end
end	

local function CameraProcess(FunctionName, Toggle, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
		
		if Toggle then
			if RequiredModule.Initialise ~= nil then
				return RequiredModule:Initialise(CameraModule, unpack(Args))
			end
		else
			if RequiredModule.End ~= nil then
				return RequiredModule:End(CameraModule, unpack(Args))
			end
		end
	end)
	
	if Success then
		return Error
	else
		DebugModule:Print(script.Name.. " | CameraProcess | FunctionName: ".. tostring(FunctionName).. " | Toggle: ".. tostring(Toggle).. " | Args: ".. tostring({...}).. " | Error: ".. tostring(Error))
		--DebugModule:PrintError, "Error")
	end
end

local function CreateBlurEffect()
	-- Instancing
	local Blur = GetCamera():FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect")
	Blur.Size = 0
	Blur.Parent = GetCamera()
	
	return Blur
end

-- DIRECT
function CameraModule.CreateBlurEffect()
	return CreateBlurEffect()
end

function CameraModule.GetCamera()
	return GetCamera()
end

function CameraModule.CameraProcess(NilParam, FunctionName, Toggle, ...)
	return CameraProcess(FunctionName, Toggle, ...)
end

function CameraModule.SetupCamera()
	return SetupCamera()
end

function CameraModule.ResetCamera(NilParam, ...)
	return ResetCamera(...)
end

-- INIT
RunSubModules()

return CameraModule