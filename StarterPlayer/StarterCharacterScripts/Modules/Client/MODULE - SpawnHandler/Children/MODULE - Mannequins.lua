local MannequinsGameClientModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local MannequinsFolder = workspace:WaitForChild("Mannequins")
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- CORE
local ClickDetectors = {}

-- Functions
-- MECHANICS
local function IsClientBillboardOpen(Name, Adornee)
	-- Functions
	-- INIT
	for i, Ui in pairs(Player:WaitForChild("PlayerGui")["Billboards"]:GetChildren()) do
		if Ui.Name == Name and Ui.Adornee == Adornee then
			return true
		end
	end
	
	return false
end

local function OpenMannequinUi(MannequinModel)
	-- CORE
	local MannequinRootPart = MannequinModel["HumanoidRootPart"]
	
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Initialise | MannequinModel: ".. tostring(MannequinModel)..  " | Clicked!")
	
	--[[for Mannequin, ClickDetector in pairs(ClickDetectors) do
		ClickDetector.MaxActivationDistance = 0
	end]]

	if not IsClientBillboardOpen("MannequinHover", MannequinRootPart) then
		return InterfacesModule:LoadBillboard(MannequinRootPart, "MannequinHover", true, MannequinModel)
	end
end

local function Initialise()
	-- Functions
	-- INIT
	for i, CategoryFolder in pairs(MannequinsFolder:GetChildren()) do
		for x, Mannequin in pairs(CategoryFolder:GetChildren()) do
			-- INIT
			local ClickDetector = Instance.new("ClickDetector")
			ClickDetector.Parent = Mannequin
			
			ClickDetectors[Mannequin] = ClickDetector
			
			coroutine.wrap(function()
				InterfacesModule:LoadBillboard(Mannequin:WaitForChild("Head"), "Item", true, Mannequin)
				
				local Connection1 = ClickDetector.MouseClick:Connect(function()
					return OpenMannequinUi(Mannequin)
				end)
				
			end)()
		end
	end
end

local function Reset()
	-- Functions
	-- INIT
	for MannequinModel, ClickDetector in pairs(ClickDetectors) do
		ClickDetector.MaxActivationDistance = 50
	end
end

local function End()
	
end

-- DIRECT
function MannequinsGameClientModule.Reset()
	return Reset()
end

function MannequinsGameClientModule.Initialise()
	return Initialise()
end

function MannequinsGameClientModule.End()
	return End()
end

return MannequinsGameClientModule