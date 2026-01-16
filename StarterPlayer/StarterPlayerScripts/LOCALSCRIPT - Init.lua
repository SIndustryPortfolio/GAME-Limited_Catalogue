-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ModulesInitFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]["Init"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function RunInitModules()
	-- Functions
	-- INIT
	for i, Module in pairs(ModulesInitFolder:GetChildren()) do
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				local RequiredModule = require(Module)
				
				if RequiredModule.Initialise ~= nil then
					RequiredModule:Initialise()
				end
				
				return RequiredModule
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | Module: ".. tostring(Module).. " | Error: ".. tostring(Error))
			end
		end)()
	end
end

-- INIT
RunInitModules()