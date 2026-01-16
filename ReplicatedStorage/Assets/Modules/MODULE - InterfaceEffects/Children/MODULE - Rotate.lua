local RotateModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local DefaultIncrement = 1

-- Functions
-- MECHANICS
local function Rotate(Element, CustomConnection, Increment)
	-- Functions
	-- INIT
	local _Inc = Increment or DefaultIncrement
	
	coroutine.wrap(function()
		while Element and CustomConnection and CustomConnection.Value and task.wait() do
			Element.Rotation += _Inc
		end
		
		if CustomConnection then
			UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end
	end)()
end

-- DIRECT
function RotateModule.Initialise(NilParam, Element, CustomConnection, Increment)
	return Rotate(Element, CustomConnection, Increment)
end

function RotateModule.End()
	
end

return RotateModule