local ParticlesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsParticlesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Particles"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local RequiredModules = UtilitiesModule:RunSubModules(script)

-- Functions
-- MECHANICS
local function LoadParticle(ParticleName, Parent, Duration, IgnoreDuplicates)
	if IgnoreDuplicates then
		for i, Child in pairs(workspace["Dump"]["Particles"]:GetChildren()) do
			local ManualWeld = Child:FindFirstChildOfClass("ManualWeld")
			
			if not ManualWeld then
				continue
			end
			
			if ManualWeld.Part1 ~= Parent then
				continue
			end
			
			if Child:GetAttributes()["Particle"] and Child.Name == ParticleName then
				return nil
			end
		end
	end
	
	
	-- Elements
	-- PARTS
	local ParticlePart = UtilitiesModule:WaitForChildTimed(PartsParticlesFolder, ParticleName):Clone()
	ParticlePart:SetAttribute("Particle", true)
	
	-- Functions
	-- INIT
	ParticlePart.CFrame = Parent.CFrame
	ParticlePart.Parent = workspace["Dump"]["Particles"]
	
	UtilitiesModule:WeldParts(ParticlePart, Parent)
	
	coroutine.wrap(function()
		task.wait(Duration or 1)
		
		for i, Particle in pairs(ParticlePart:GetChildren()) do
			if not Particle:IsA("ParticleEmitter") then
				continue
			end
			
			Particle.Enabled = false
		end
		
		DebrisModule:AddItem(ParticlePart, Duration or 1)
	end)()
	
	RequiredModules[ParticleName]:Initialise(ParticlePart)
end

local function UnloadParticle(Particle)
	-- Functions
	-- INIT
end

-- DIRECT
function ParticlesModule.LoadParticle(NilParam, ...)
	return LoadParticle(...)
end

function ParticlesModule.UnloadParticle(NilParam, ...)
	return UnloadParticle(...)
end

return ParticlesModule