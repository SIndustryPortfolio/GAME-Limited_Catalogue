local InitModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedPartsItemsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Items"]
local RenderedCollectionsFolder = workspace:WaitForChild("Collections")

-- Info Modules
local CategoriesInfoModule = require(SharedInfoModulesFolder["Categories"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	for i, CollectionFolder in pairs(RenderedCollectionsFolder:GetChildren()) do
		for x, CollectionItem in pairs(CollectionFolder:GetChildren()) do
			CollectionService:AddTag(CollectionItem, CollectionFolder.Name)
		end
	end
end

-- DIRECT
function InitModule.Initialise()
	return Initialise()
end

return InitModule