local InterfacesModule = {}

repeat
	task.wait()
until game.Players.LocalPlayer

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ScreenInterfacesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Interfaces"]["Screen"]
local FirstScreenInterfacesFolder = game:GetService("ReplicatedFirst"):WaitForChild("Assets")["Interfaces"]["Screen"]
local BillboardInterfacesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Interfaces"]["Billboards"]
local SurfaceInterfacesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Interfaces"]["Surface"]
--local SurfaceInterfacesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Interfaces"]["Surfaces"]

-- Client
local Player = game.Players.LocalPlayer


local PlayerGui = Player:WaitForChild("PlayerGui") 

-- InfoModules
local InterfacesInfoModule = require(InfoModulesFolder["Interfaces"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local Pages = {}
local ClosingPages = {}

local PagesToConnections = {}

local CoreUiToDisable = {Enum.CoreGuiType.Backpack, Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Health}

local CoreUiToStayEnabled = {Enum.CoreGuiType.Chat}

local CoreUiTypes = {Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Chat, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health}

-- Services
local StarterGui = game:GetService("StarterGui")

-- Functions
-- MECHANICS
local function SetupUITypeFolders()
	-- Functions
	-- INIT
	for TypeName, Info in pairs(InterfacesInfoModule:GetInterfaceTypes()) do
		if PlayerGui:FindFirstChild(TypeName) then
			continue
		end
		
		local Folder = Instance.new("Folder")
		Folder.Name = TypeName
		Folder.Parent = PlayerGui
	end
end

local function Initialise()
	-- Functions
	-- INIT
	local Connection1 = Player.CharacterAdded:Connect(function()
		return SetupUITypeFolders()
	end)
	
	if UtilitiesModule:GetCharacter(Player, true) then
		SetupUITypeFolders()
	end
end

local function FilterPages()
	-- Functions
	-- INIT
	for Ui, Type in pairs(Pages) do
		if not Ui or not Ui.Parent then
			Pages[Ui] = nil
		end
	end
end

local function GetConnectionsCache(PageName)
	return PagesToConnections[PageName]
end

local function EnableCoreUi()
	-- Functions
	-- INIT
	for i, CoreUiType in pairs(CoreUiTypes) do
		StarterGui:SetCoreGuiEnabled(CoreUiType, true)
	end
end

local function DisableAllCoreUi()
	-- Functions
	-- INIT
	for i, CoreUiType in pairs(CoreUiTypes) do
		if not table.find(CoreUiToStayEnabled, CoreUiType) then
			StarterGui:SetCoreGuiEnabled(CoreUiType, false)
		end
	end
end

local function DisableCoreUi()
	-- Functions
	-- INIT
	for i, CoreUiType in pairs(CoreUiToDisable) do
		StarterGui:SetCoreGuiEnabled(CoreUiType, false)
	end
end

local function GetAllNoneCoreUITypes()
	-- CORE
	local Types = {}
	
	-- Functions
	-- INIT
	for Type, TypeInfo in pairs(InterfacesInfoModule:GetInterfaceTypes()) do
		if TypeInfo.DisableCoreUi then
			table.insert(Types, Type)
		end
	end
	
	return Types
end

local function CanEnableCoreUi()
	-- CORE
	local DisableTypes = GetAllNoneCoreUITypes()
	
	-- Functions
	-- INIT
	for Page, PageType in pairs(Pages) do
		if table.find(DisableTypes, PageType) then
			return false
		end
	end
	
	return true
end

local function RemoveFromCache(PageName)
	-- CORE
	if PageName == nil then
		return nil
	end
	
	local Connections = PagesToConnections[PageName]
	
	if not Connections then
		return nil
	end
	
	-- Functions
	-- INIT
	for i, Connection in pairs(Connections) do
		Connection:Disconnect()
	end
	
	PagesToConnections[PageName] = nil
end

local function AddConnectionsToCache(PageName, Connections)
	if PagesToConnections[PageName] == nil then
		PagesToConnections[PageName] = {}
	end
	
	-- Functions
	-- INIT
	for i, Connection in pairs(Connections) do
		table.insert(PagesToConnections[PageName], Connection)
	end
end

local function GetPage(Page, IsFirst)
	if typeof(Page) ~= "string" then
		return Page
	else
		if not IsFirst then
			return ScreenInterfacesFolder:FindFirstChild(Page)
		else
			return FirstScreenInterfacesFolder:FindFirstChild(Page)
		end
	end
end

local function GetSurface(Page)
	if typeof(Page) ~= "string" then
		return Page
	else
		return SurfaceInterfacesFolder:FindFirstChild(Page)
	end
end

local function GetBillboard(Page)
	if typeof(Page) ~= "string" then
		return Page
	else
		return BillboardInterfacesFolder:FindFirstChild(Page)
	end
end

local function OpenPage(Ui, Type)
	Pages[Ui] = Type
end

local function ClosePage(Ui, GarbageCollect)
	if not Ui or  typeof(Ui) ~= "Instance" then
		return nil
	end

	if table.find(ClosingPages, Ui) then
		return nil
	end
	
	if Ui.Name == "Chat" then
		return nil
	end
	
	-- Elements
	-- FOLDERS
	if Ui.FindFirstChild == nil then
		return nil
	end
	
	local CoreFolder = Ui:FindFirstChild("Core")
	
	if not CoreFolder then
		return nil
	end
	
	-- Modules
	local InterfaceModule = nil

	if CoreFolder then
		InterfaceModule = require(CoreFolder["Interface"])
	end

	-- Functions
	-- INIT
	RemoveFromCache(Ui)
	Pages[Ui] = nil
	table.insert(ClosingPages, Ui)
	
	if InterfaceModule then
		if InterfaceModule.End ~= nil then
			local Success, Error = pcall(function()
				return InterfaceModule:End()
			end)
			
			if not Success then
				DebugModule:Print("Interfaces | ClosePage | Error: ".. tostring(Error))
			end
		end
		
		if GarbageCollect then
			if InterfaceModule.GarbageCollect ~= nil then
				local Success, Error = pcall(function()
					return InterfaceModule:GarbageCollect()
				end)
				
				if not Success then
					DebugModule:Print("Interfaces | ClosePage | GarbageCollect | Error: ".. tostring(Error))
				end
			end
		end
	end
	
	if workspace:FindFirstChild("Dump") then
		if Ui:IsDescendantOf(workspace["Dump"]) then
			Ui.Parent:Destroy()
		end
	end
	
	if Ui then
		Ui:Destroy()
	end
	
	local FoundIndex = table.find(ClosingPages, Ui)
	
	if FoundIndex then
		table.remove(ClosingPages, FoundIndex)
	end
		
	local Response = CanEnableCoreUi()

	if Response then
		EnableCoreUi()
	end
end

local function ClosePages(Dir, Name)
	for i, Page in pairs(Dir:GetChildren()) do
		if Page:IsA("ScreenGui") then
			if Name then
				if Page.Name ~= Name then
					continue
				end
			end
			
			coroutine.wrap(function()
				ClosePage(Page)
			end)()
		end
	end
end

-- DIRECT
function InterfacesModule.DisableCoreUi()
	return DisableCoreUi()
end

function InterfacesModule.EnableCoreUi()
	return EnableCoreUi()
end

function InterfacesModule.IsPageOpen(NilParam, PageType, PageName)
	local PageTypeFolder = nil
	
	if PageType == "StarterGui" then
		PageTypeFolder = PlayerGui
	else
		PageTypeFolder = PlayerGui:WaitForChild(PageType)
	end
	
	if PageTypeFolder then
		return PageTypeFolder:FindFirstChild(PageName)
	end
end

function InterfacesModule.ClosePage(NilParam, Ui, GarbageCollect)
	ClosePage(Ui, GarbageCollect)
end

--[[function InterfacesModule.LoadSurfaceUi(NilParam, PageName, Parent)
	-- Functions
	-- INIT
	local FoundSurfaceUi = SurfaceInterfacesFolder:FindFirstChild(PageName)
	
	if not FoundSurfaceUi then
		return nil
	end
	
	FoundSurfaceUi = FoundSurfaceUi:Clone()
	FoundSurfaceUi.Parent = Parent
	FoundSurfaceUi.Adornee = Parent
	
	-- Elements
	-- FOLDERS
	local CoreFolder = FoundSurfaceUi:WaitForChild("Core")
	
	-- Modules
	local RequiredModule = require(CoreFolder["Interface"])
	
	return FoundSurfaceUi, RequiredModule:Initialise()
end]]

function InterfacesModule.UnloadPage(NilParam, PageType, Page)
	-- Dirs
	local FoundPageTypeFolder = nil
	
	if PageType == "StarterGui" then
		FoundPageTypeFolder = PlayerGui
	else
		FoundPageTypeFolder = PlayerGui:FindFirstChild(PageType)
	end
		
	-- Functions
	-- INIT
	if typeof(Page) == "string" then
		if FoundPageTypeFolder then
			--Page = FoundPageTypeFolder:FindFirstChild(Page)
			
			for i, Ui in pairs(FoundPageTypeFolder:GetChildren()) do
				if Ui and Ui.Name == Page and not table.find(ClosingPages, Ui) then
					ClosePage(Ui)
				end
			end
		end
	end
	
	if Page and typeof(Page) == "Instance" then
		ClosePage(Page)
	end
end

function InterfacesModule.LoadFirstPage(NilParam, PageType, Page, ...)
	-- Dirs
	local FoundPageTypeFolder = UtilitiesModule:WaitForChildTimed(PlayerGui, PageType) or PlayerGui:WaitForChild(PageType)

	-- Functions
	-- INIT
	local PageTypeInfo = InterfacesInfoModule:GetInterfaceType(PageType)

	if PageTypeInfo then
		if not PageTypeInfo.MultiPaged then
			ClosePages(FoundPageTypeFolder)
		end
	end

	if not FoundPageTypeFolder then
		return nil
	end

	-- Instancing
	local Ui = GetPage(Page, true)
	if Ui then
		Ui = Ui:Clone()
	else
		return nil
	end
	Ui.Parent = FoundPageTypeFolder

	-- Elements
	-- FOLDERS
	local CoreFolder = Ui:WaitForChild("Core")

	-- Modules
	local InterfaceModule = require(CoreFolder["Interface"])
	
	-- Functions
	-- INIT
	RemoveFromCache(Page)
	
	OpenPage(Ui, PageType)
	return Ui, InterfaceModule:Initialise(...)
end

function InterfacesModule.LoadSurface(NilParam, Parent, Page, ...)
	-- Functions
	-- INIT
	if not Parent then
		return nil
	end

	local Page = GetSurface(Page)

	if not Page then
		return nil
	end

	Page = Page:Clone()

	if typeof(Parent) == "Vector3" then
		local Part = Instance.new("Part")
		Part.CFrame = CFrame.new(Parent)
		Part.Transparency = 1
		Part.Anchored = true
		Part.CanCollide = false
		Part.Size = Vector3.new(0.1, 0.1, 0.1)
		Part.Name = "UiHolder"
		Part.Parent = workspace["Dump"]["Misc"]

		Page.Parent = Part
	else
		Page.Parent = Parent
	end	
	-- Elements
	-- FOLDERS
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Page, "Core")

	-- MODULES
	local InterfaceModule = UtilitiesModule:WaitForChildTimed(CoreFolder, "Interface")

	-- INIT
	local RequiredModule = require(InterfaceModule)

	if RequiredModule and RequiredModule.Initialise ~= nil then
		return Page, RequiredModule:Initialise(...)
	end
end

function InterfacesModule.LoadBillboard(NilParam, Parent, Page, IsClient, ...)
	-- Functions
	-- INIT
	if not Parent then
		return nil
	end
	
	local Page = GetBillboard(Page)
	
	if not Page then
		return nil
	end

	local _Adornee = nil
	local _Parent = nil
	
	Page = Page:Clone()
	
	if typeof(Parent) == "Vector3" then
		local Part = Instance.new("Part")
		Part.CFrame = CFrame.new(Parent)
		Part.Transparency = 1
		Part.Anchored = true
		Part.CanCollide = false
		Part.Size = Vector3.new(0.1, 0.1, 0.1)
		Part.Name = "UiHolder"
		Part.Parent = workspace["Dump"]["Misc"]
		
		_Parent = Part
		_Adornee = Part
		--Page.Parent = Part
		--Page.Adornee = Part
	else
		_Parent = Parent
		_Adornee = Parent
		--Page.Parent = Parent
		--Page.Adornee = Parent
	end
	
	Page.Parent = _Parent
	Page.Adornee = _Adornee
	
	if IsClient then
		Page.Parent = PlayerGui:WaitForChild("Billboards")
		Page.Adornee = _Adornee
	end
	
	-- Elements
	-- FOLDERS
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Page, "Core")
	
	-- MODULES
	local InterfaceModule = UtilitiesModule:WaitForChildTimed(CoreFolder, "Interface")
	
	-- INIT
	local RequiredModule = require(InterfaceModule)
	
	if RequiredModule and RequiredModule.Initialise ~= nil then
		return Page, RequiredModule:Initialise(...)
	end
	
	return Page	
end

function InterfacesModule.LoadPage(NilParam, PageType, Page, CloseOtherPages, ...)
	-- Dirs
	local FoundPageTypeFolder = nil
	
	if PageType ~= "StarterGui" then
		FoundPageTypeFolder = PlayerGui:WaitForChild(PageType)
	else
		FoundPageTypeFolder = Player:WaitForChild("PlayerGui")
	end
	
	-- CORE
	local Connections = {}
	
	-- Functions
	-- INIT
	local PageTypeInfo = InterfacesInfoModule:GetInterfaceType(PageType)

	if PageTypeInfo then
		if not PageTypeInfo.MultiPaged then
			ClosePages(FoundPageTypeFolder)
		end
	end
	
	if not FoundPageTypeFolder then
		return nil
	end

	-- Instancing
	local Ui = GetPage(Page)
	if Ui then
		Ui = Ui:Clone()
	else
		return nil
	end
	
	if CloseOtherPages then
		for i, _Page in pairs(FoundPageTypeFolder:GetChildren()) do
			if _Page.Name == Ui.Name then
				coroutine.wrap(function()
					ClosePage(_Page)
				end)()
			end
		end
	end


	-- Elements
	-- FOLDERS
	local CoreFolder = Ui:WaitForChild("Core")

	-- Modules
	local InterfaceModule = require(CoreFolder["Interface"])
	local RequirementsModule = CoreFolder:FindFirstChild("Requirements")
	
	-- Functions
	-- INIT
	if RequirementsModule then
		RequirementsModule = require(RequirementsModule)
		
		if not RequirementsModule:Authenticate(...) then
			Ui:Destroy()
			return false
		end
	end
	
	Ui.Parent = FoundPageTypeFolder
	
	if PageTypeInfo and PageTypeInfo.DisableCoreUi then
		DisableCoreUi()
	end
	
	-- DIRECT
	local Connection1 = nil
	
	if not Ui.ResetOnSpawn and not Ui:GetAttributes()["GuiIgnore"] then
		
		if GetConnectionsCache(Page) == nil then
			local Args = {...}

			Connection1 = Player:GetPropertyChangedSignal("Character"):Connect(function() --Player.CharacterAdded:Connect(function()
				if not Player.Character then
					Connection1:Disconnect()
					return nil
				end
				
				if not Ui:GetAttributes()["IgnoreAutoUnload"] then
					RemoveFromCache(Ui)
					local Response = InterfacesModule:LoadPage(PageType, Page, true, unpack(Args))
					
					if not Response then
						-- Connection1:Disconnect()
					end
				end
				
				Connection1:Disconnect()
			end)

			-- CONNECTIONS
			table.insert(Connections, Connection1)
		end
	end
	
	-- INIT
	local Connection2 = nil
	
	Connection2 = Ui:GetPropertyChangedSignal("Parent"):Connect(function()
		if not Ui.Parent then
			Connection2:Disconnect()
			pcall(function()
				InterfacesModule:ClosePage(Page, true)
			end)
			if InterfaceModule and InterfaceModule.End ~= nil then
				pcall(function()
					InterfaceModule:End()
				end)
			end
			if InterfaceModule and InterfaceModule.GarbageCollect ~= nil then
				pcall(function()
					InterfaceModule:GarbageCollect()
				end)
			end
			RemoveFromCache(Ui)
		end
	end)
	
	table.insert(Connections, Connection2)
	
	AddConnectionsToCache(Page, Connections)
	
	OpenPage(Ui, PageType)
	
	if InterfaceModule.Initialise then
		return Ui, InterfaceModule:Initialise(...)
	else
		return Ui, nil
	end
end

function InterfacesModule.GetUiModuleFromType(NilParam, PageType, PageName, _Wait)
	local Ui = nil 
	
	if _Wait then
		Ui = UtilitiesModule:WaitForChildTimed(PlayerGui:WaitForChild(PageType), PageName)
	else
		Ui = PlayerGui:WaitForChild(PageType):FindFirstChild(PageName)	
	end
	
	if not Ui then
		DebugModule:Print("Interfaces | Not found Ui to get module from | Type: ".. tostring(PageType).. " | Name: ".. tostring(PageName))
		--DebugModule:Print"Not found Ui | Type: ".. tostring(PageType).. " | Name: ".. tostring(PageName))
		return nil
	end
	
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Ui, "Core")

	if CoreFolder then
		return require(CoreFolder["Interface"])
	end
end

function InterfacesModule.GetUiModule(NilParam, Ui)
	if not Ui then
		return nil
	end
	
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Ui, "Core")
	
	if CoreFolder then
		return require(CoreFolder["Interface"])
	end
end

function InterfacesModule.Request(NilParam, FunctionName, ...)
	return InterfacesModule[FunctionName](nil, ...)	
end

function InterfacesModule.FilterPages()
	return FilterPages()
end

function InterfacesModule.CanEnableCoreUi()
	return CanEnableCoreUi()
end

function InterfacesModule.DisableAllCoreUi()
	return DisableAllCoreUi()
end

-- INIT
Initialise()

return InterfacesModule