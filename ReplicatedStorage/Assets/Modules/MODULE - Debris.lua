local DebrisModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function CheckPropertiesAgainstItem(_Instance, PropertiesToMatch)
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(PropertiesToMatch) do
		if _Instance[PropertyName] ~= PropertyValue then
			return false
		end
	end
	
	return true
end

local function RemoveCollections(_Instance)
	-- Functions
	-- INIT
	for i, CollectionName in pairs(CollectionService:GetTags(_Instance)) do
		CollectionService:RemoveTag(_Instance, CollectionName)
	end
end

local function Destroy(_Instance, PropertiesToMatch, Connections)
	-- Functions
	-- INIT
	if _Instance then
		if not PropertiesToMatch then
			if Connections then
				UtilitiesModule:DisconnectConnections(Connections)
			end

			RemoveCollections(_Instance)
			return _Instance:Destroy()
		else
			if CheckPropertiesAgainstItem(_Instance, PropertiesToMatch) then
				if Connections then
					UtilitiesModule:DisconnectConnections(Connections)
				end

				RemoveCollections(_Instance)
				return _Instance:Destroy()
			end
		end
	end
end

local function AddItem(_Instance, Time, PropertiesToMatch, Connections)
	-- Functions
	-- INIT
	if not _Instance then
		return nil
	end
	
	if Time then
		coroutine.wrap(function()
			pcall(function()
				if Time then
					task.wait(Time)
				end
				
				return Destroy(_Instance, PropertiesToMatch, Connections)
			end)
		end)()
	else
		pcall(function()
			return Destroy(_Instance, PropertiesToMatch, Connections)
		end)
	end
end

-- DIRECT
function DebrisModule.AddItem(NilParam, ...)
	return AddItem(...)
end

return DebrisModule