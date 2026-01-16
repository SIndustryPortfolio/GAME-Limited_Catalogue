local InitModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedPartsItemsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Items"]
local RenderedMannequinsFolder = workspace:WaitForChild("Mannequins")

-- Info Modules
local CategoriesInfoModule = require(SharedInfoModulesFolder["Categories"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Services
local InsertService = game:GetService("InsertService")

-- Functions
-- MECHANICS
local function Initialise()
	-- CORE
	local AllItemInfo = CategoriesInfoModule:GetAllItemInfo()
	local TotalNumberOfItems = UtilitiesModule:GetSizeOfDict(AllItemInfo)
	local Loading = 0
	
	-- Functions
	-- MECHANICS
	local function UpdateMannequin(Mannqeuin, ItemFolder)
		-- Functions
		-- INIT
		for i, Model in pairs(ItemFolder:GetChildren()) do
			local FoundAccessory = Model:FindFirstChildOfClass("Accessory")
			
			if not FoundAccessory then
				continue
			end
			
			FoundAccessory:Clone().Parent = Mannqeuin
		end
	end
	
	-- INIT
	for CategoryName, CategoryModule in pairs(CategoriesInfoModule:GetAllCategoryInfo()) do
		if SharedPartsItemsFolder:FindFirstChild(CategoryName) then
			continue
		end
		
		local CategoryPartFolder = Instance.new("Folder")
		CategoryPartFolder.Name = CategoryName
		CategoryPartFolder.Parent = SharedPartsItemsFolder
	end
	
	coroutine.wrap(function()
		for CategoryName, CategoryModule in pairs(CategoriesInfoModule:GetAllCategoryInfo()) do
			local CategoryPartFolder = SharedPartsItemsFolder:FindFirstChild(CategoryName)
			local CategoryMannequinsFolder = RenderedMannequinsFolder:FindFirstChild(CategoryName)
			
			for ItemName, ItemInfo in pairs(CategoryModule:GetAllItemInfo()) do
				
				-- CHECKING IF MODEL EXISTS IN GAME
				local ItemFolder = CategoryPartFolder:FindFirstChild(ItemName)

				local FoundMannequin = nil
				local Skip = false

				if CategoryMannequinsFolder then
					FoundMannequin = CategoryMannequinsFolder:FindFirstChild(ItemName)
				end

				if ItemFolder then
					Loading +=1

					UpdateMannequin(FoundMannequin, ItemFolder)

					ItemFolder:SetAttribute("Loaded", true)
					SharedPartsItemsFolder:SetAttribute("CurrentLoaded", Loading)
					Skip = true
				end
				--
				
				coroutine.wrap(function()
					if Skip then
						return
					end
					
					-- LOADING IN MODEL IF NOT
					
					ItemFolder = Instance.new("Folder")
					ItemFolder.Name = ItemName
					ItemFolder.Parent = CategoryPartFolder
					
					ItemFolder:SetAttribute("Moderated", false)
					
					
					
					for Index, IdInfo in pairs(ItemInfo["Parts"]) do
						local Success, Model = pcall(function()
							return InsertService:LoadAsset(IdInfo["Id"])
						end)
						
						if not Success then
							--DebugModule:Print(script.Name.. " | Initialise | ItemName: ".. tostring(ItemName).. " | Index: ".. tostring(Index).. " | Error: ".. tostring(Model))
							ItemFolder:SetAttribute("Moderated", true)
							continue	
						end
						
						Model.Name = tostring(Index)
						Model.Parent = ItemFolder
						
						--[[if FoundMannequin then
							local FoundAccessory = Model:FindFirstChildOfClass("Accessory")
							local MannequinHumanoid = UtilitiesModule:WaitForChildOfClass(FoundMannequin, "Humanoid")
							
							if FoundAccessory then
								MannequinHumanoid:AddAccessory(FoundAccessory:Clone())
							end
						end]]
					end
					UpdateMannequin(FoundMannequin, ItemFolder)
					
					Loading +=1
					
					ItemFolder:SetAttribute("Loaded", true)
					SharedPartsItemsFolder:SetAttribute("CurrentLoaded", Loading)
				end)()
				
				if not Skip then
					task.wait(0.2) -- 400 items per 60 seconds
				end
			end
		end
	end)()
end

-- DIRECT
function InitModule.Initialise()
	return Initialise()
end

return InitModule