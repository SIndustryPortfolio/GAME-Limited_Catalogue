local DebugModule = {}

-- Dirs
--local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
--local ClientSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Signals"]
--local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer

-- Elements
-- REMOTES
--local ClientProcessRemote = ClientRemotesFolder["ClientProcess"]

-- SIGNALS
--local ClientRequestSignal = ClientSignalsFolder["ClientRequest"]

-- CORE
local BackLog = {}
local BackLogLimit = 200
local DebugMode = false

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECAHNICS
local function ReEnabled()
	-- Functions
	-- INIT
	for i = 1, #BackLog do
		local Success, Error = pcall(function()
			return DebugModule:Print("BACKLOGGED | ".. BackLog[i]["String"].. " | Time: ".. tostring(BackLog[i]["Time"])--[[.. " | Tick: ".. tostring(BackLog[i]["Tick"])]], BackLog[i]["Type"])
		end)
		
		table.remove(BackLog, #BackLog)
	end
end

local function Print(String, Type)
	-- Functions
	-- INIT
	--[[if not DebugMode and not RunService:IsStudio() then
		return nil
	end]]
	
	--[[if DebugMode then
		--[[if ConsoleUiModule then
			ConsoleUiModule:Add("Debug", "DEBUG", String)
		end]]
		--[[if Player then
			ClientProcessRemote:Fire("Debug", "Debug", "DEBUG", String)
		end
	end]]
	
	table.insert(BackLog, {["Type"] = Type, ["String"] = String, ["Tick"] = tick(), ["Time"] = os.date("*t")["hour"].. ":".. os.date("*t")["min"].. ":".. os.date("*t")["sec"]})
	
	if #BackLog > 200 then
		table.remove(BackLog, #BackLog)
	end
	
	if not Type or Type == "Normal" then
		if script:GetAttribute("Enabled") then
			print(tostring(String))
		end
	elseif Type == "Error" then
		error(tostring(String))
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Print"] = function(String, Type)
		return Print(String, Type)
	end,	
}

-- DIRECT
function DebugModule.Request(NilParam, FunctionName, ...)
	return ClientRequests[FunctionName](...)
end

function DebugModule.Print(NilParam, String, Type)
	return Print(String, Type)
end

-- CONNECTIONS
local Connection1 = script:GetAttributeChangedSignal("Enabled"):Connect(function()
	if script:GetAttribute("Enabled") then
		return ReEnabled()
	end
end)

return DebugModule