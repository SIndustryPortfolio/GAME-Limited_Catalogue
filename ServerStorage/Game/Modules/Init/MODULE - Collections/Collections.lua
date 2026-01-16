local CollectionsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
--local CollectionsInfoModule = require(InfoModulesFolder["Collections"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local Connections = {}
local RequiredModules = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, CategoryFolder in pairs(script:GetChildren()) do
		for x, Module in pairs(CategoryFolder:GetChildren()) do
			local Success, RequiredModule = pcall(function()
				return require(Module)
			end)
			
			if Success then
				RequiredModules[Module.Name] = RequiredModule
			else
				DebugModule:Print(script.Name.. " | RunSubModules | Error: ".. tostring(RequiredModule))
			end
		end
	end
end

--[[local function GetTagModule(TagName)
	-- Functions
	-- INIT
	local TagModule = script:FindFirstChild(TagName)
	
	if TagModule then
		local Success, Error = pcall(function()
			return require(TagModule)
		end)
		
		if Success then
			return Error
		else
			DebugModule:Print(script.Name.. " | Error: ".. tostring(Error))
			--DebugModule:PrintError, "Error")
		end
	else
		return DebugModule:Print("Collections | No tag module for: ".. tostring(TagName)) --DebugModule:Print"No tag module for: ".. tostring(TagName))
	end
end]]

local function TagToggle(Name, Object, Initialise)
	-- Functions
	-- INIT
	local TagModule = RequiredModules[Name] --GetTagModule(Name)
	
	if not TagModule then
		DebugModule:Print(script.Name.. " | No tag module for: ".. tostring(Name))
		return nil
	end
	
	local Success, Error = pcall(function()
		if Initialise then
			return TagModule:Initialise(Object)
		else
			return TagModule:End(Object)
		end
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Error: ".. tostring(Error))
		--DebugModule:Print"Tag Module: ".. tostring(TagModule)..  " | ".. tostring(Error), "Error")
	end
end

-- DIRECT
function CollectionsModule.TagAdded(NilParam, Name, Object)
	return TagToggle(Name, Object, true)
end

function CollectionsModule.TagRemoved(NilParam, Name, Object)
	return TagToggle(Name, Object, false)
end

-- INIT
RunSubModules()

for CollectionName, RequiredModule in pairs(RequiredModules) do --(CollectionsInfoModule:GetCollectionInfo("CollectionsOnStart")) do
	--DebugModule:Print"Creating collection connections for: ".. tostring(CollectionName))
		
	-- DIRECT
	local Connection1 = CollectionService:GetInstanceAddedSignal(CollectionName):Connect(function(Object)
		return TagToggle(CollectionName, Object, true)
	end)
	
	local Connection2 = CollectionService:GetInstanceRemovedSignal(CollectionName):Connect(function(Object)
		return TagToggle(CollectionName, Object, false)
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	
	-- INIT
	for i, _Instance in pairs(CollectionService:GetTagged(CollectionName)) do
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				return TagToggle(CollectionName, _Instance, true)
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | CollectionName: ".. tostring(CollectionName).. " | Instance: ".. tostring(_Instance).. " | Error: ".. tostring(Error))
			end
		end)()
	end
end

return CollectionsModule