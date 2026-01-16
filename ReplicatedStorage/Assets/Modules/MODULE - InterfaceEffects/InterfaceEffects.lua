local InterfaceEffectsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
--local Player = game.Players.LocalPlayer
--local Mouse = Player:GetMouse()

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

local AllEffectInfo = 
{
	["Switch"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,

		["On"] = 
		{
			["Colour"] = Color3.fromRGB(0, 255, 127),
			["Position"] = UDim2.new(1, 0, 0.5, 0)
		},
		["Off"] = 
		{
			["Colour"] = Color3.fromHSV(0, 1, 1),
			["Position"] = UDim2.new(0, 0, 0.5, 0)
		}
	},
	["CategorySelectButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		
		["RGBAmplifier"] = -75,
		["HoverSizeMultiplier"] = 0.25
	},
	["TextButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		["RGBAmplifier"] = -75
	},
	["ItemSplitTile"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		["RGBAmplifier"] = -75
	},
	["CategoryTile"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,

		["RGBAmplifier"] = -75
	},
	["GridTile"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		
		["RGBAmplifier"] = -75
	},
	
	["MainButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
			
		["HoverSizeMultiplier"] = 0.25,
		["RGBAmplifier"] = -75
	},
	["Fade"] = 
	{
		["Duration"] = 1,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["ExpandElement"] = 
	{
		["Duration"] = 0.5,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["ShrinkElement"] = 
	{
		["Duration"] = 0.5,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut	
	},
	
	["XTransitionIn"] = 
	{
		["Duration"] = .5,
		["Style"] = Enum.EasingStyle.Circular,
		["Direction"] = Enum.EasingDirection.Out
	},
	["XTransitionOut"] = 
	{
		["Duration"] = .5,
		["Style"] = Enum.EasingStyle.Circular,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["YTransitionIn"] = 
	{
		["Duration"] = .5,
		["Style"] = Enum.EasingStyle.Circular,
		["Direction"] = Enum.EasingDirection.Out
	},
	["YTransitionOut"] = 
	{
		["Duration"] = .5,
		["Style"] = Enum.EasingStyle.Circular,
		["Direction"] = Enum.EasingDirection.InOut
	}
}

local ElementCache = {}
local TweenDict = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, Module in pairs(script:GetChildren()) do
		local Success, RequiredModule = pcall(function()
			return require(Module)
		end)

		if Success then
			RequiredModules[Module.Name] = RequiredModule
		else
			DebugModule:Print(script.Name.. " | Error: ".. tostring(RequiredModule))
		end
	end
end


local function TweenWait(TweenElement)
	if TweenElement.PlaybackState == Enum.PlaybackState.Playing then
		TweenElement.Completed:Wait()
	end
end

local function IsUiAdditionalElement(Element)
	-- CORE
	local ClassNames = {"UIAspectRatioConstraint", "UIListLayout", "UIGradient", "UIGridLayout", "UIStroke" , "UIPadding", "Frame", "TextLabel", "Configuration"}
	
	-- Functions
	-- INIT
	for i, ClassName in pairs(ClassNames) do
		if Element:IsA(ClassName) then
			return true
		end
	end
	
	return false
end

local function MultiplyUDim2(UDim2Value, Multiplier)
	return UDim2.new(UDim2Value.X.Scale * Multiplier, UDim2Value.X.Offset * Multiplier, UDim2Value.Y.Scale * Multiplier, UDim2Value.Y.Offset * Multiplier)
end

local function Color3FromRGB(RGBValue)
	return Color3.fromRGB(RGBValue.R, RGBValue.G, RGBValue.B)
end

local function Color3ToRGB(Color3Value)
	return {R = Color3Value.r * 255, G = Color3Value.g * 255, B = Color3Value.b * 255}
end


local function AddToColor3(RGBValue, Amplifier)
	RGBValue = Color3ToRGB(RGBValue)
	
	local NewR = math.clamp(RGBValue.R + Amplifier, 0, 255)
	local NewG = math.clamp(RGBValue.G + Amplifier, 0, 255)
	local NewB = math.clamp(RGBValue.B + Amplifier, 0, 255)
	
	return {R = NewR, G = NewG, B = NewB}
	
	--return {R = RGBValue.R + Amplifier, G = RGBValue.G + Amplifier, B = RGBValue.B + Amplifier}
end


local function CancelTween(TweenElement)
	if TweenDict[TweenElement] ~= nil then
		TweenDict[TweenElement]:Cancel()
		TweenDict[TweenElement]:Destroy()
	end
end

local function CompleteTween(TweenElement)
	if TweenDict[TweenElement] ~= nil then
		local Connection
		
		Connection = TweenDict[TweenElement].Completed:Connect(function(PlaybackStatus)
			if PlaybackStatus == Enum.PlaybackState.Completed then
				TweenDict[TweenElement]:Destroy()
			end
			
			Connection:Disconnect()
		end)
	end
end

local function CreateElementCache(Element, Properties, Overwrite)
	if not Element then
		return nil
	end
	
	if ElementCache[Element] == nil then
		ElementCache[Element] = {}
	end
	
	if not Properties then
		return nil
	end
	
	for i, PropertyName in pairs(Properties) do
		if ElementCache[Element][PropertyName] == nil or Overwrite then
			local Success, Error = pcall(function()
				ElementCache[Element][PropertyName] = Element[PropertyName]
			end)
			
			if not Success then
				ElementCache[Element][PropertyName] = Element:GetAttributes()[PropertyName]
			end
		end
	end
	
	return ElementCache[Element]
end

-- DIRECT
-- SINGLE LOADERS
function InterfaceEffectsModule.Fade(NilParam, Element, Type, _Wait, CustomEffectInfo, IgnoreProperties, ForceTweenTo, StartTransparency, IgnoreDescendants)
	if not Element then
		return nil
	end
	
	-- CORE
	local EffectInfo = CustomEffectInfo or AllEffectInfo["Fade"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	local ClassToBackgroundProperties = 
	{
		["ImageLabel"] = {"ImageTransparency", "BackgroundTransparency"},
		["TextLabel"] = {"TextTransparency", "BackgroundTransparency", "TextStrokeTransparency"},
		["UIStroke"] = {"Transparency"},
		["Frame"] = {"BackgroundTransparency"},
		["ScrollingFrame"] = {"BackgroundTransparency"}
	}
	
	local ChosenArrayOfProperties = ClassToBackgroundProperties[Element.ClassName]
	
	-- Functions
	-- INIT
	if IgnoreProperties then
		for i, PropertyName in pairs(IgnoreProperties) do
			local FoundIndex = table.find(ChosenArrayOfProperties, PropertyName)
			
			if FoundIndex then
				table.remove(ChosenArrayOfProperties, FoundIndex)
			end
		end
	end
	
	CreateElementCache(Element, ChosenArrayOfProperties)
	
	if StartTransparency then
		for i, PropertyName in pairs(ChosenArrayOfProperties) do
			Element[PropertyName] = StartTransparency
		end
	end
	
	-- Tween
	local tweeningInfo = {}
	
	for i, PropertyName in pairs(ChosenArrayOfProperties) do
		if Type == "In" then
			Element[PropertyName] = 1
			
			local ToTweenTo = ElementCache[Element][PropertyName] or 0
			
			if ForceTweenTo then
				ToTweenTo = ForceTweenTo
			end
			
			--[[if ToTweenTo == 1 then
				ToTweenTo = 0
			end]]
			
			tweeningInfo[PropertyName] = ToTweenTo
		elseif Type == "Out" then
			tweeningInfo[PropertyName] = 1
		end
	end

	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if not IgnoreDescendants then
		for i, _Element in pairs(Element:GetDescendants()) do
			if ClassToBackgroundProperties[_Element.ClassName] ~= nil then
				InterfaceEffectsModule:Fade(_Element, Type, false, CustomEffectInfo, IgnoreProperties, ForceTweenTo, StartTransparency)
			end
		end
	end
	
	if _Wait then
		TweenDict[Element].Completed:Wait()
	end
end

function InterfaceEffectsModule.XTransitionOut(NilParam, Element, _Wait, Reverse)
	-- CORE
	local EffectInfo = AllEffectInfo["XTransitionOut"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Functions
	-- INIT
	CreateElementCache(Element, {"Position", "Size"})

	local ElementOldPosition = ElementCache[Element]["Position"]
	local ElementOldSize = ElementCache[Element]["Size"]

	-- Tween
	local tweeningInfo = {}

	if not Reverse then
		tweeningInfo.Position = UDim2.new(-ElementOldSize.X.Scale, -ElementOldSize.X.Offset, ElementOldPosition.Y.Scale, ElementOldPosition.Y.Offset)
	else
		tweeningInfo.Position = UDim2.new(1 + ElementOldSize.X.Scale, 1 + ElementOldSize.X.Offset, ElementOldPosition.Y.Scale, ElementOldPosition.Y.Offset)
	end

	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)

	if _Wait then
		TweenWait(TweenDict[Element])
	end
end

function InterfaceEffectsModule.YTransitionOut(NilParam, Element, _Wait, Reverse)
	-- CORE
	local EffectInfo = AllEffectInfo["YTransitionOut"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	-- Functions
	-- INIT
	CreateElementCache(Element, {"Position", "Size"})
	
	local ElementOldPosition = ElementCache[Element]["Position"]
	local ElementOldSize = ElementCache[Element]["Size"]
	
	-- Tween
	local tweeningInfo = {}
	
	if not Reverse then
		tweeningInfo.Position = UDim2.new(ElementOldPosition.X.Scale, ElementOldPosition.X.Offset, -ElementOldSize.Y.Scale, -ElementOldSize.Y.Offset - 36)
	else
		tweeningInfo.Position = UDim2.new(ElementOldPosition.X.Scale, ElementOldPosition.X.Offset, 1 + ElementOldSize.Y.Scale,  1 + ElementOldSize.Y.Offset + 36)
	end
	
	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenWait(TweenDict[Element])
	end
end

function InterfaceEffectsModule.HandleScrollingTiles(NilParam, TileImage)
	-- CORE
	local EffectInfo = AllEffectInfo["ScrollingTile"]
	local OriginalClone = TileImage:Clone()
	TileImage.Visible = false
	
	local CustomConnection = UtilitiesModule:CreateCustomConnection()
	
	-- Functions
	-- INIT
	local Parent = TileImage.Parent
	
	if Parent then
		Parent.ClipsDescendants = true
	end
	
	local TileSize = TileImage.TileSize
	
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local tweeningInfo = {}
	tweeningInfo.Position = UDim2.new(-TileSize.X.Scale, -TileSize.X.Offset, -TileSize.Y.Scale, -TileSize.Y.Offset)
	
	coroutine.wrap(function()
		while TileImage and Parent and CustomConnection and CustomConnection.Value do
			local NewTile = OriginalClone:Clone()
			NewTile.Parent = Parent
			
			local Connection1 = TileImage:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
				NewTile.ImageTransparency = TileImage.ImageTransparency
			end)
			
			UtilitiesModule:CancelTween(NewTile, TweenDict)
			TweenDict[NewTile] = TweenService:Create(NewTile, tweenInfo, tweeningInfo)
			TweenDict[NewTile]:Play()
			UtilitiesModule:CompleteTween(NewTile, TweenDict)
			
			TweenDict[NewTile].Completed:Wait()
			
			UtilitiesModule:DisconnectConnections({Connection1})
			
			NewTile:Destroy()
		end
		
		OriginalClone:Destroy()
	end)()
	
	return CustomConnection
end

function InterfaceEffectsModule.XTransitionIn(NilParam, Element, _Wait, Reverse)
	-- CORE
	local EffectInfo = AllEffectInfo["XTransitionIn"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Functions
	-- INIT
	CreateElementCache(Element, {"Position", "Size"})

	local ElementOldPosition = ElementCache[Element]["Position"]
	local ElementOldSize = ElementCache[Element]["Size"]

	-- Properties
	if not Reverse then
		Element.Position = UDim2.new(-ElementOldSize.X.Scale, -ElementOldSize.X.Offset, ElementOldPosition.Y.Scale, ElementOldPosition.Y.Offset)
	else
		Element.Position = UDim2.new(1 + ElementOldSize.X.Scale, 1 + ElementOldSize.X.Offset, ElementOldPosition.Y.Scale, ElementOldPosition.Y.Offset)
	end

	-- TWEEN
	local tweeningInfo = {}
	tweeningInfo.Position = ElementOldPosition

	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)

	if _Wait then
		TweenWait(TweenDict[Element])
	end
end

function InterfaceEffectsModule.YTransitionIn(NilParam, Element, _Wait, Reverse)
	-- CORE
	local EffectInfo = AllEffectInfo["YTransitionIn"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	-- Functions
	-- INIT
	CreateElementCache(Element, {"Position", "Size"})
	
	local ElementOldPosition = ElementCache[Element]["Position"]
	local ElementOldSize = ElementCache[Element]["Size"]
	
	-- Properties
	if not Reverse then
		Element.Position = UDim2.new(ElementOldPosition.X.Scale, ElementOldPosition.X.Offset, -ElementOldSize.Y.Scale, -ElementOldSize.Y.Offset - 36)
	else
		Element.Position = UDim2.new(ElementOldPosition.X.Scale, ElementOldPosition.X.Offset, 1 + ElementOldSize.Y.Scale, 1  + ElementOldSize.Y.Offset + 36)
	end
	
	-- TWEEN
	local tweeningInfo = {}
	tweeningInfo.Position = ElementOldPosition
	
	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
		
	if _Wait then
		TweenWait(TweenDict[Element])
	end
end

function InterfaceEffectsModule.ExpandElement(NilParam, Element, _Wait, Axis, _Duration)
	-- CORE
	local EffectInfo = AllEffectInfo["ExpandElement"]
	local tweenInfo = TweenInfo.new(_Duration or EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Functions
	-- INIT
	CreateElementCache(Element, {"Size"})
	
	-- Properties
	if Axis then
		if string.lower(Axis) == "x" then
			Element.Size = UDim2.new(0, 0, Element.Size.Y.Scale, Element.Size.Y.Offset)
		elseif string.lower(Axis) == "y" then
			Element.Size = UDim2.new(Element.Size.X.Scale, Element.Size.X.Offset, 0, 0)
		end
	else
		Element.Size = UDim2.new()
	end
	
	-- TWEEN
	local tweeningInfo = {}
	tweeningInfo.Size = ElementCache[Element]["Size"]
	
	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenWait(TweenDict[Element])
	end
	
	return TweenDict[Element]
end

function InterfaceEffectsModule.ShrinkElement(NilParam, Element, _Wait, Axis)
	-- CORE
	local EffectInfo = AllEffectInfo["ShrinkElement"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Functions
	-- INIT
	CreateElementCache(Element, {"Size"})

	-- TWEEN
	local tweeningInfo = {}
	
	if Axis then
		if string.lower(Axis) == "x" then
			tweeningInfo.Size = UDim2.new(0, 0, Element.Size.Y.Scale, Element.Size.Y.Offset)
		elseif string.lower(Axis) == "y" then
			tweeningInfo.Size = UDim2.new(Element.Size.X.Scale, Element.Size.X.Offset, 0, 0)
		end		
	else
		tweeningInfo.Size = UDim2.new()
	end

	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenWait(TweenDict[Element])
	end

	return TweenDict[Element]
end

function InterfaceEffectsModule.GetElementCache(NilParam, Element)
	-- Functions
	-- INTI
	if Element then
		return ElementCache[Element]
	else
		return ElementCache
	end
end

function InterfaceEffectsModule.CreateElementCache(NilParam, Element, Properties, Overwrite)
	-- Functions
	-- INIT
	return CreateElementCache(Element, Properties, Overwrite)
end

function InterfaceEffectsModule.InitialiseCategorySelectButton(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- Elements
	-- IMAGEBUTTONS
	local _Button = UtilitiesModule:WaitForChildTimed(Button, "Button")
	
	if not _Button then
		return nil
	end
	
	-- CORE
	local EffectInfo = AllEffectInfo["CategorySelectButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])	

	UtilitiesModule:CreateElementCache(_Button, {"Size", "ImageColor3"}, ElementCache)

	-- Functions
	-- DIRECT
	local Connection1 = _Button.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Press")
	end)
	
	local Connection2 = _Button.MouseEnter:Connect(function()
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[_Button]["ImageColor3"], EffectInfo["RGBAmplifier"]))
		local NewSizeX = ElementCache[_Button]["Size"]["X"]["Scale"] + (ElementCache[_Button]["Size"]["X"]["Scale"] * EffectInfo["HoverSizeMultiplier"])
		local NewSizeY = ElementCache[_Button]["Size"]["Y"]["Scale"] + (ElementCache[_Button]["Size"]["Y"]["Scale"] * EffectInfo["HoverSizeMultiplier"])


		local tweeningInfo = {}
		tweeningInfo["ImageColor3"] = NewColour
		tweeningInfo["Size"] = UDim2.new(NewSizeX, 0, NewSizeY, 0)

		CancelTween(_Button)
		TweenDict[_Button] = TweenService:Create(_Button, tweenInfo, tweeningInfo)
		TweenDict[_Button]:Play()
		CompleteTween(_Button)
	end)

	local Connection3 = _Button.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo["ImageColor3"] = ElementCache[_Button]["ImageColor3"]
		tweeningInfo["Size"] = ElementCache[_Button]["Size"]

		CancelTween(_Button)
		TweenDict[_Button] = TweenService:Create(_Button, tweenInfo, tweeningInfo)
		TweenDict[_Button]:Play()
		CompleteTween(_Button)
	end)
	
	return {Connection1, Connection2, Connection3}
end


function InterfaceEffectsModule.InitialiseMainButton(NilParam, Button)
	if not Button then
		return nil
	end

	-- Elements
	-- FRAMES
	local InnerBackingFrame = Button["InnerBacking"]
	
	-- BUTTONS
	local _Button = Button["Button"]

	-- CORE
	local EffectInfo = AllEffectInfo["TextButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	UtilitiesModule:CreateElementCache(InnerBackingFrame, {"BackgroundColor3"}, ElementCache)

	-- Functions
	-- DIRECT
	local Connection1 = _Button.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Press")
	end)

	local Connection2 = _Button.MouseEnter:Connect(function()
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[InnerBackingFrame]["BackgroundColor3"], EffectInfo["RGBAmplifier"]))

		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = NewColour

		CancelTween(InnerBackingFrame)
		TweenDict[InnerBackingFrame] = TweenService:Create(InnerBackingFrame, tweenInfo, tweeningInfo)
		TweenDict[InnerBackingFrame]:Play()
		CompleteTween(InnerBackingFrame)
	end)

	local Connection3 = _Button.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = ElementCache[InnerBackingFrame]["BackgroundColor3"]

		CancelTween(InnerBackingFrame)
		TweenDict[InnerBackingFrame] = TweenService:Create(InnerBackingFrame, tweenInfo, tweeningInfo)
		TweenDict[InnerBackingFrame]:Play()
		CompleteTween(InnerBackingFrame)
	end)

	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseTextButton(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- CORE
	local EffectInfo = AllEffectInfo["TextButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	UtilitiesModule:CreateElementCache(Button, {"BackgroundColor3"}, ElementCache)
	
	-- Functions
	-- DIRECT
	local Connection1 = Button.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Press")
	end)
	
	local Connection2 = Button.MouseEnter:Connect(function()
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[Button]["BackgroundColor3"], EffectInfo["RGBAmplifier"]))

		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = NewColour

		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, tweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
	end)
	
	local Connection3 = Button.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = ElementCache[Button]["BackgroundColor3"]

		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, tweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
	end)
	
	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseSwitch(NilParam, Button, _Toggle)
	if not Button then
		return nil
	end
	
	-- Elements
	-- FRAMES
	local BarFrame = UtilitiesModule:WaitForChildTimed(Button, "Bar")
	local CircleFrame = BarFrame["Circle"]
	
	-- BUTTONS
	local _Button = UtilitiesModule:WaitForChildTimed(Button, "Button")
	
	-- CORE
	local ClickedEvent = Instance.new("BindableEvent")
	
	local EffectInfo = AllEffectInfo["Switch"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local Toggle = _Toggle
	
	local ValueToEffectName = 
	{
		[true] = "On",
		[false] = "Off"		
	}
	
	-- Functions
	-- MECHANICS
	local function Update()
		-- Functions
		-- INIT
		local _EffectInfo = EffectInfo[ValueToEffectName[Toggle]]

		local tweeningInfo = {}
		tweeningInfo.Position = _EffectInfo["Position"]

		local tweeningInfo1 = {}
		tweeningInfo1.BackgroundColor3 = _EffectInfo["Colour"]

		UtilitiesModule:CancelTween(CircleFrame, TweenDict)
		UtilitiesModule:CancelTween(BarFrame, TweenDict)
		TweenDict[CircleFrame] = TweenService:Create(CircleFrame, tweenInfo, tweeningInfo)
		TweenDict[BarFrame] = TweenService:Create(BarFrame, tweenInfo, tweeningInfo1)
		TweenDict[CircleFrame]:Play()
		TweenDict[BarFrame]:Play()
		UtilitiesModule:CompleteTween(CircleFrame, TweenDict)
		UtilitiesModule:CompleteTween(BarFrame, TweenDict)
	end
	
	local function OnClick()
		-- Functions
		-- INIT
		Toggle = not Toggle
		
		SoundsModule:PlaySoundEffectByName("Switch", "Press")
		ClickedEvent:Fire(Toggle)
		Update()
	end
	
	-- DIRECT
	local Connection1 = _Button.MouseButton1Down:Connect(function()
		return OnClick()
	end)
	
	-- INIT
	Update()
	
	return {Connection1}, ClickedEvent
end

function InterfaceEffectsModule.InitialiseItemSplitTile(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- Elements
	-- IMAGES
	
	-- BUTTONS
	local _Button = UtilitiesModule:WaitForChildTimed(Button, "Button")
	
	-- CORE
	local EffectInfo = AllEffectInfo["ItemSplitTile"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	UtilitiesModule:CreateElementCache(Button, {"BackgroundColor3"}, ElementCache)
	
	-- Functions
	-- DIRECT
	local Connection1 = _Button.MouseButton1Down:Connect(function()
		
	end)
	
	local Connection2 = _Button.MouseEnter:Connect(function()
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[Button]["BackgroundColor3"], EffectInfo["RGBAmplifier"]))

		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = NewColour

		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, tweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
	end)
	
	local Connection3 = _Button.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = ElementCache[Button]["BackgroundColor3"]

		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, tweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
	end)
	
	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseCategoryTile(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- Elements
	-- FRAMES
	local IconBackingFrame = UtilitiesModule:WaitForChildTimed(Button, "IconBacking")
	local InfoBackingFrame = UtilitiesModule:WaitForChildTimed(Button, "InfoBacking")
	
	-- BUTTONS
	local _Button = UtilitiesModule:WaitForChildTimed(Button, "Button")
	
	-- CORE
	local EffectInfo = AllEffectInfo["CategoryTile"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	UtilitiesModule:CreateElementCache(IconBackingFrame, {"BackgroundColor3"}, ElementCache)
	UtilitiesModule:CreateElementCache(InfoBackingFrame, {"BackgroundColor3"}, ElementCache)

	-- Functions
	-- DIRECT
	local Connection1 = _Button.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Press")
	end)

	local Connection2 = _Button.MouseEnter:Connect(function()
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[IconBackingFrame]["BackgroundColor3"], EffectInfo["RGBAmplifier"]))
		local NewColour2 = Color3FromRGB(AddToColor3(ElementCache[InfoBackingFrame]["BackgroundColor3"], EffectInfo["RGBAmplifier"]))

		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = NewColour
		
		local tweeningInfo2 = {}
		tweeningInfo2["BackgroundColor3"] = NewColour2

		CancelTween(IconBackingFrame)
		CancelTween(InfoBackingFrame)
		
		TweenDict[IconBackingFrame] = TweenService:Create(IconBackingFrame, tweenInfo, tweeningInfo)
		TweenDict[InfoBackingFrame] = TweenService:Create(InfoBackingFrame, tweenInfo, tweeningInfo2)
		
		TweenDict[IconBackingFrame]:Play()
		TweenDict[InfoBackingFrame]:Play()

		CompleteTween(IconBackingFrame)
		CompleteTween(InfoBackingFrame)
	end)

	local Connection3 = _Button.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = ElementCache[IconBackingFrame]["BackgroundColor3"]

		local tweeningInfo2 = {}
		tweeningInfo2["BackgroundColor3"] = ElementCache[InfoBackingFrame]["BackgroundColor3"]

		CancelTween(IconBackingFrame)
		CancelTween(InfoBackingFrame)

		TweenDict[IconBackingFrame] = TweenService:Create(IconBackingFrame, tweenInfo, tweeningInfo)
		TweenDict[InfoBackingFrame] = TweenService:Create(InfoBackingFrame, tweenInfo, tweeningInfo2)


		TweenDict[IconBackingFrame]:Play()
		TweenDict[InfoBackingFrame]:Play()

		CompleteTween(IconBackingFrame)
		CompleteTween(InfoBackingFrame)
	end)

	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseGridTile(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- Elements
	-- FRAMES
	local ItemBackingFrame = UtilitiesModule:WaitForChildTimed(Button, "ItemBacking")
	
	-- TEXTS
	local ItemNameText = UtilitiesModule:WaitForChildTimed(Button, "ItemName")
	local ItemPriceText = UtilitiesModule:WaitForChildTimed(Button, "ItemPrice")
	
	-- BUTTONS
	local _Button = UtilitiesModule:WaitForChildTimed(Button, "Button")
	
	-- CORE
	local EffectInfo = AllEffectInfo["GridTile"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	UtilitiesModule:CreateElementCache(ItemBackingFrame, {"BackgroundColor3"}, ElementCache)
	
	-- Functions
	-- DIRECT
	local Connection1 = _Button.MouseButton1Down:Connect(function()
		
	end)
	
	local Connection2 = _Button.MouseEnter:Connect(function()
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[ItemBackingFrame]["BackgroundColor3"], EffectInfo["RGBAmplifier"]))

		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = NewColour

		CancelTween(ItemBackingFrame)
		TweenDict[ItemBackingFrame] = TweenService:Create(ItemBackingFrame, tweenInfo, tweeningInfo)
		TweenDict[ItemBackingFrame]:Play()
		CompleteTween(ItemBackingFrame)
	end)
	
	local Connection3 = _Button.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo["BackgroundColor3"] = ElementCache[ItemBackingFrame]["BackgroundColor3"]

		CancelTween(ItemBackingFrame)
		TweenDict[ItemBackingFrame] = TweenService:Create(ItemBackingFrame, tweenInfo, tweeningInfo)
		TweenDict[ItemBackingFrame]:Play()
		CompleteTween(ItemBackingFrame)
	end)
	
	return {Connection1, Connection2, Connection3}
end

-- CONVERSION
local ButtonTypes = 
{
	["Main"] = {Function = InterfaceEffectsModule.InitialiseMainButton, ClassName = "Frame"},
	["GridTile"] = {Function = InterfaceEffectsModule.InitialiseGridTile, ClassName = "Frame"},
	["CategoryTile"] = {Function = InterfaceEffectsModule.InitialiseCategoryTile, ClassName = "Frame"},
	["TextButton"] = {Function = InterfaceEffectsModule.InitialiseTextButton, ClassName = "TextButton"},
	["CategorySelect"] = {Function = InterfaceEffectsModule.InitialiseCategorySelectButton, ClassName = "Frame"}
}

-- GROUP LOADERS
function InterfaceEffectsModule.InitialiseButtons(NilParam, ButtonsFolder, ButtonType, ...)
	-- CORE
	local ButtonConnections = {}
	
	-- Functions
	-- INIT
	local InitialiseFunction = ButtonTypes[ButtonType]["Function"]
	local ClassNameExceptance = ButtonTypes[ButtonType]["ClassName"]
	
	for i, Button in pairs(ButtonsFolder:GetChildren()) do
		-- INIT
		if IsUiAdditionalElement(Button) then
			if not ClassNameExceptance then
				continue
			else
				if ClassNameExceptance ~= Button.ClassName then
					continue
				end
			end
		end
		
		-- DIRECT
		local _ButtonConnections = InitialiseFunction(nil, Button, ...)
			
		-- Connections
		for x, Connection in pairs(_ButtonConnections) do
			table.insert(ButtonConnections, Connection)
		end		
	end
	
	return ButtonConnections
end

--
function InterfaceEffectsModule.InterfaceEffectProcess(NilParam, FunctionName, ...)
	-- Functions
	-- INIT
	local Success, RequiredModule = pcall(function()
		return RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
	end)
	
	if Success then
		if RequiredModule and RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(...)
		end
	else
		--DebugModule:PrintRequiredModule, "Error")
	end
end

-- INIT
RunSubModules()

return InterfaceEffectsModule