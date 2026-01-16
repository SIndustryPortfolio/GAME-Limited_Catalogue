local TagModule = {}

-- Dirs
local MiscPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Misc"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
--local SoundsModule = require(ModulesFolder["Sounds"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local DebrisModule = require(ModulesFolder["Debris"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- CORE
local Connections = {}
local DebounceTime = 1

local ElementCache = {}

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function ChangeColour(GradientWall, RGBColour)
	-- Functions
	-- INIT
	for i, SurfaceUi in pairs(UtilitiesModule:WaitForChildTimed(GradientWall, "Surfaces"):GetChildren()) do
		pcall(function()
			local Gradient = UtilitiesModule:WaitForChildTimed(SurfaceUi, "Gradient")["UIGradient"]
			
			if RGBColour == nil then
				RGBColour = Color3.fromRGB(255, 255, 255)
			end
			
			pcall(function()
				Gradient.Color = ColorSequenceKeypoint.new()
			end)
					
			Gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, RGBColour),
				ColorSequenceKeypoint.new(1, RGBColour)			
			})
		end)
	end
end

local function SelectWalls(Wall, RGBColour)
	-- Functions
	-- INIT
	for i, Part in pairs(Wall:WaitForChild("Dump")["GradientWalls"]:GetChildren()) do
		if not string.find(Part.Name, "GradientWall") then
			continue
		end
		
		if Part:FindFirstChildOfClass("SelectionBox") then
			continue
		end
		
		local SelectionBox = Instance.new("SelectionBox")
		SelectionBox.LineThickness = 0.05
		SelectionBox.Color3 = RGBColour or Color3.fromRGB(255, 255, 255)
		SelectionBox.Parent = Part
		
		
		local Connection1 = nil
		local Index = math.random(0, 100) / 100
		local Speed = 1
		
		Connection1 = RunService.Stepped:Connect(function()
			if not SelectionBox then
				return UtilitiesModule:DisconnectConnections({Connection1})
			end
			
			--ChangeColour(Part, Color3.fromHSV(Index, 1, 1))
			
			SelectionBox.Color3 = Color3.fromHSV(Index, 1, 1)
			Index += 0.001 * Speed
			Index %= 1
			SelectionBox.Adornee = Part
		end)
	end
end

local function UnSelectWalls(Wall, BaseColour)
	-- Functions
	-- INIT
	for i, Part in pairs(Wall:WaitForChild("Dump")["GradientWalls"]:GetChildren()) do
		if not string.find(Part.Name, "GradientWall") then
			continue
		end
		
		local FoundSelectionBox = Part:FindFirstChildOfClass("SelectionBox")

		if FoundSelectionBox then
			DebrisModule:AddItem(FoundSelectionBox)
		end
		
		--[[RunService.Stepped:Wait()
		task.wait()
		
		ChangeColour(Part, Wall:GetAttributes()["Colour"])]]
	end
end

local function SetEffect(Part)
	-- Functions
	-- INIT
	local Coords = {"X", "Z"}

	Part.Transparency = 1
	Part.CanCollide = false
	
	local PartDumpFolder = Instance.new("Folder")
	PartDumpFolder.Name = "Dump"
	PartDumpFolder.Parent = Part
	
	local SubFolders = {"GradientWalls", "NeonFloors"}
	
	for i, FolderName in pairs(SubFolders) do
		local Folder = Instance.new("Folder")
		Folder.Name = FolderName
		Folder.Parent = PartDumpFolder
	end
	
	for i, _Coord in pairs(Coords) do
		local OtherCoord = nil

		if _Coord == "X" then
			OtherCoord = "Z"
		else
			OtherCoord = "X"
		end

		local NeonSizeVectorTable = {[OtherCoord] = Part.Size[OtherCoord], [_Coord] = .5, ["Y"] = .1}

		local NeonFloor1 = Instance.new("Part")
		NeonFloor1.Material = Enum.Material.Neon
		NeonFloor1.Size = UtilitiesModule:TableToVector3(NeonSizeVectorTable)
		NeonFloor1.Color = Part:GetAttributes()["Colour"] or Color3.fromRGB(255, 255, 255)
		NeonFloor1.CanCollide = false
		NeonFloor1.Anchored = true
		NeonFloor1.Parent = PartDumpFolder["NeonFloors"]

		local NeonFloor2 = NeonFloor1:Clone()
		NeonFloor2.Parent = PartDumpFolder["NeonFloors"]

		local GradientWall = MiscPartsFolder["GradientWall"]:Clone()
		--[[GradientWall.Size[_Coord] = Part.Size[_Coord]
		GradientWall.Size.Y = Part.Size.Y]]
		ChangeColour(GradientWall, Part:GetAttributes()["Colour"])

		local SizeVectorTable = {[OtherCoord] = .1, [_Coord] = Part.Size[OtherCoord], ["Y"] = Part.Size.Y}

		GradientWall.Size = UtilitiesModule:TableToVector3(SizeVectorTable)
		GradientWall.Parent = PartDumpFolder["GradientWalls"]

		local GradientWall2 = GradientWall:Clone()
		GradientWall2.Parent = PartDumpFolder["GradientWalls"]

		local VectorTable = {["Y"] = Part.Position.Y, [OtherCoord] = Part.Position[OtherCoord], [_Coord] = (Part.Position[_Coord] + (Part.Size[_Coord] / 2) - GradientWall.Size[OtherCoord] / 2)}
		local VectorTable2 = UtilitiesModule:CloneDict(VectorTable)
		VectorTable2[_Coord] = Part.Position[_Coord] - ((Part.Size[_Coord] / 2) - GradientWall.Size[OtherCoord] / 2)

		local VectorTable3 = {["Y"] = Part.Position.Y - ((Part.Size.Y / 2) - .1), [OtherCoord] = Part.Position[OtherCoord], [_Coord] = (Part.Position[_Coord] + (Part.Size[_Coord] / 2) - NeonFloor1.Size[_Coord] / 2)}
		local VectorTable4 = UtilitiesModule:CloneDict(VectorTable3)
		VectorTable4[_Coord] = Part.Position[_Coord] - ((Part.Size[_Coord] / 2) - NeonFloor2.Size[_Coord] / 2)

		GradientWall.Position = UtilitiesModule:TableToVector3(VectorTable)
		GradientWall2.Position = UtilitiesModule:TableToVector3(VectorTable2)
		NeonFloor1.Position = UtilitiesModule:TableToVector3(VectorTable3)
		NeonFloor2.Position = UtilitiesModule:TableToVector3(VectorTable4)
	end
end

local function Touched(Part)
	-- Elements
	-- FOLDERS
	local CoreFolder = Part:FindFirstChild("Core")
	
	-- Functions
	-- INIT
	
	if not CoreFolder then
		return nil
	end
	
	Part:SetAttribute("Touching", true)
	
	SelectWalls(Part, Part:GetAttribute("Colour"))
	
	local TouchModule = require(CoreFolder["Touch"])
	
	if TouchModule and TouchModule.Enter ~= nil then
		return TouchModule:Enter()
	end
end

local function TouchEnd(Part)
	-- Functions
	-- INIT
	local CoreFolder = Part:FindFirstChild("Core")

	-- Functions
	-- INIT

	if not CoreFolder then
		return nil
	end
	
	Part:SetAttribute("Touching", false)
	
	UnSelectWalls(Part, Part:GetAttribute("Colour"))

	local TouchModule = require(CoreFolder["Touch"])

	if TouchModule and TouchModule.Leave ~= nil then
		return TouchModule:Leave()
	end
end

local function Initialise(Part)
	-- CORE
	local LastTouchedTime = tick()
	local CharacterTouchingParts = {}
	
	-- Elements
	-- Functions
	-- MECHANICS
	local function IsTouching()
		-- Functions
		-- INIT
		local Character = UtilitiesModule:GetCharacter(Player, true)
		
		if not Character then
			return nil
		end
		
		for i, HitPart in pairs(Part:GetTouchingParts()) do
			if HitPart:IsDescendantOf(Character) then
				return true
			end
		end
	end	
	
	-- DIRECT
	local Connection1 = Part.Touched:Connect(function(Hit)
		if tick() - LastTouchedTime < DebounceTime then
			return nil
		end
		
		if not IsTouching() then
			return nil
		end
		
		CharacterTouchingParts[Hit] = true
		
		LastTouchedTime = tick()
		
		Touched(Part)
		
		local Connection2 = nil
		
		Connection2 = RunService.Stepped:Connect(function()
			if not IsTouching() then
				UtilitiesModule:DisconnectConnections({Connection2})
				
				return TouchEnd(Part)
			end
		end)
		
		-- Connections
		table.insert(Connections[Part], Connection2)
	end)
	
	-- Connections
	Connections[Part] = {Connection1}
	
	-- INIT
	SetEffect(Part)
		
	local CoreFolder = Part:FindFirstChild("Core")

	if CoreFolder then
		local TouchModule = require(CoreFolder["Touch"])
		
		if TouchModule and TouchModule.Initialise ~= nil then
			return TouchModule:Initialise()
		end
	end
end

local function End(Part)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections[Part])
end

-- DIRECT
function TagModule.Initialise(NilParam, Part)
	return Initialise(Part)
end

function TagModule.End(NilParam, Character)
	return End(Character)
end


return TagModule