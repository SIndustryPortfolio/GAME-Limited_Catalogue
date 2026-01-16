local UtilitiesModule = {}

-- Dirs
--local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
--local FpsInfoModule = require(InfoModulesFolder["Fps"])

-- Modules
local CharSetModule = require(script["CharSet"])
local BrickColorsModule = require(script["BrickColors"])

-- CORE
local RequiredModules = {}

-- Services
local HttpService = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local SocialService = game:GetService("SocialService")

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
		end
	end
end

local function FormatToDoubleDigit(Time)
	-- Functions
	-- INIT
	if string.len(Time) < 2 then
		return "0".. tostring(Time)
	end
	
	return tostring(Time)
end

-- DIRECT

local function Color3FromRGB(RGBValue)
	return Color3.fromRGB(RGBValue.R, RGBValue.G, RGBValue.B)
end

local function Color3ToRGB(Color3Value)
	return {R = Color3Value.r * 255, G = Color3Value.g * 255, B = Color3Value.b * 255}
end

function UtilitiesModule.GetInitials(NilParam, String)
	-- Functions
	-- INIT
	local FinalString = ""
	
	for i, Word in pairs(string.split(String, " ")) do
		FinalString = FinalString.. string.upper(string.sub(Word, 1, 1))
	end
	
	return FinalString
end

function UtilitiesModule.AddToColor3(NilParam, RGBValue, Amplifier, DontClamp)
	RGBValue = Color3ToRGB(RGBValue)
	
	local NewR = nil
	local NewG = nil
	local NewB = nil
	
	if not DontClamp then
		NewR = RGBValue.R + Amplifier
		NewG = RGBValue.G + Amplifier
		NewB = RGBValue.B + Amplifier
	else
		NewR = math.clamp(RGBValue.R + Amplifier, 0, 255)
		NewG = math.clamp(RGBValue.G + Amplifier, 0, 255)
		NewB = math.clamp(RGBValue.B + Amplifier, 0, 255)
	end

	return Color3FromRGB({R = NewR, G = NewG, B = NewB})

	--return {R = RGBValue.R + Amplifier, G = RGBValue.G + Amplifier, B = RGBValue.B + Amplifier}
end

function UtilitiesModule.RunSubModulesCoroutine(NilParam, Parent, IgnoreInitialise, ...)
	-- CORE
	local Dict = {}
	local Args = {...}	
	
	local Goal = #Parent:GetChildren()
	local Current = 0
	
	-- Functions
	-- INIT
	for i, Module in pairs(Parent:GetChildren()) do
		if not Parent or not Module then
			continue
		end
		
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				local RequiredModule = require(Module)

				if not IgnoreInitialise then
					if RequiredModule and RequiredModule.Initialise ~= nil then
						RequiredModule:Initialise(unpack(Args))
					end
				end

				return RequiredModule
			end)

			if not Success then
				print(script.Name.. " | RunSubModules | Parent: ".. tostring(Parent).. " | Module: ".. tostring(Module).. " | Error: ".. tostring(Error))
			else
				Dict[Module.Name] = Error
			end
			
			Current += 1
		end)()
	end
	
	repeat
		task.wait()
	until Current >= Goal
	
	return Dict
end

function UtilitiesModule.RunSubModules(NilParam, Parent, IgnoreInitialise, ...)
	-- CORE
	local Dict = {}
	local Args = {...}	
	
	-- Functions
	-- INIT
	for i, Module in pairs(Parent:GetChildren()) do
		local Success, Error = pcall(function()
			local RequiredModule = require(Module)
			
			if not IgnoreInitialise then
				if RequiredModule and RequiredModule.Initialise ~= nil then
					RequiredModule:Initialise(unpack(Args))
				end
			end

			return RequiredModule
		end)

		if not Success then
			print(script.Name.. " | RunSubModules | Parent: ".. tostring(Parent).. " | Module: ".. tostring(Module).. " | Error: ".. tostring(Error))
		else
			Dict[Module.Name] = Error
		end
	end
	
	return Dict
end

function UtilitiesModule.DestroyAllSounds(NilParam, Sounds)
	-- Fuunctions
	-- INIT
	for i, Sound in pairs(Sounds) do
		if not Sound then
			continue
		end
		
		if Sound.IsPlaying then
			Sound:Stop()
		end
		
		Sound:Destroy()
	end
end

function UtilitiesModule.GetRootModel(NilParam, Model)
	-- Functions
	-- INIT
	local Root = Model
	local CurrentRoot = Root

	while CurrentRoot --[[and task.wait()]] do
		CurrentRoot = CurrentRoot:FindFirstAncestorOfClass("Model")

		if CurrentRoot then
			Root = CurrentRoot
		else
			break
		end
	end

	return Root
end

function UtilitiesModule.GetTotalMass(NilParam, _Instance)
	-- CORE
	local RunningTotal = 0
	
	-- Functions
	-- INIT
	if _Instance:IsA("Model") then
		for i, Part in pairs(_Instance:GetDescendants()) do
			if not Part:IsA("BasePart") then
				continue
			end
			
			RunningTotal += Part:GetMass()
		end
	else
		RunningTotal = _Instance:GetMass()
	end
	
	return RunningTotal
end

function UtilitiesModule.RoundVector3(NilParam, _Vector3, Decimals)
	-- Functions
	-- INIT
	local Order = {"X", "Y", "Z"}
	local Components = {}
	
	for _, PropertyName in pairs(Order) do
		local StringNumber = tostring(_Vector3[PropertyName])
		
		local FoundDecimal = string.find(StringNumber, ".") or string.len(StringNumber)
		
		table.insert(Components, tonumber(string.sub(StringNumber, 1, FoundDecimal + Decimals)))
	end
	
	return Vector3.new(unpack(Components))
end

function UtilitiesModule.FlipVector3(NilParam, _Vector3)
	-- CORE
	local newTable = {}
	
	-- Functions
	-- INIT
	local Order = {"X", "Y", "Z"}
	
	for i, PropertyName in pairs(Order) do
		if _Vector3[PropertyName] == 1 then
			newTable[PropertyName] = 0
		else
			newTable[PropertyName] = 1
		end
	end
	
	return Vector3.new(unpack(newTable))
end

function UtilitiesModule.SetCollisionGroup(NilParam, Model, Name)
	-- Functions
	-- INIT
	local Descendants = Model:GetDescendants()
	
	if Model:IsA("BasePart") then
		Model.CollisionGroup = Name
	end
	
	for i, Part in pairs(Descendants) do
		if Part:IsA("BasePart") then
			Part.CollisionGroup = Name
		end
	end
end

function UtilitiesModule.MapValue(NilParam, n, start, stop, newStart, newStop)
	return ((n - start) / (stop - start)) * (newStop - newStart) + newStart
end

function UtilitiesModule.Colour3ToRGB(NilParam, Color3Value)
	return {R = Color3Value.r * 255, G = Color3Value.g * 255, B = Color3Value.b * 255}
end

function UtilitiesModule.TypeToColor3(NilParam, _Value)
	-- CORE
	local TypeToColor3 = 
	{
		["string"] = function(Value)
			return BrickColor.new(Value).Color
		end,
		["BrickColor"] = function(Value)
			return Value.Color
		end,
		["Color3"] = function(Value)
			return Value
		end,
	}

	-- Functions
	-- INIT
	return TypeToColor3[typeof(_Value)](_Value)
end

function UtilitiesModule.GetAllPartsIncludingParent(NilParam, Part)
	-- Core
	local Parts = {}
	
	-- Functions
	-- INIT
	for i, _Part in pairs(Part:GetDescendants()) do
		if not _Part:IsA("BasePart") then
			continue
		end
		
		table.insert(Parts, _Part)
	end
	
	if Part:IsA("BasePart") then
		table.insert(Parts, Part)
	end
	
	return Parts
end

function UtilitiesModule.SecondsToMinutes(NilParam, Seconds, Round)
	-- Functions
	-- INIT
	if not Round then
		return (Seconds / 60)
	else
		return math.floor(Seconds / 60)
	end
end

function UtilitiesModule.GetServerRegion()
	-- Functions
	-- INIT
	local Success, Response = pcall(function()
		return HttpService:GetAsync("http://ip-api.com/json/")
	end)

	if Success then
		Response = HttpService:JSONDecode(Response)
		return Response["country"]
	end
end

function UtilitiesModule.ClearTable(NilParam, Table, Destroy)
	-- Functions
	-- INIT
	for key, val in pairs(Table) do
		if val and typeof(val) == "Instance" then
			val:Destroy()
		end
		
		Table[key] = nil
	end
	
	return Table
end

function UtilitiesModule.CombineTables(NilParam, ...)
	-- Functions
	-- INIT
	local JointTable = {}
	
	for i, Table in pairs({...}) do
		for x, Element in pairs(Table) do
			table.insert(JointTable, Element)
		end
	end
	
	return JointTable
end

function UtilitiesModule.UnpackConnectionsToLargeTable(NilParam, ...)
	-- Functions
	-- INIT
	local LargeTable = {}
	
	for i, ConnectionTable in pairs({...}) do
		for x, Connection in pairs(ConnectionTable) do
			table.insert(LargeTable, Connection)
		end
	end
	
	return LargeTable
end

function UtilitiesModule.ChooseRandomFromArray(NilParam, Array)
	-- Functions
	-- INIT
	return Array[math.random(1, #Array)]
end

function UtilitiesModule.HasProperty(NilParam, _Instance, PropertyName)
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		local Result = _Instance[PropertyName]
	end)
	
	return Success
end

function UtilitiesModule.FormatNumber(NilParam, Number)
	-- Functions
	-- INIT
	
	if Number == 0 then
		return Number
	end
	
	local n = Number
	
	local suffixes = {"K", "M", "B", "T", "Q"} -- numbers don't go higher than 'Q' in Lua.

	--local function toSuffixString(n)
		local i = math.floor(math.log(n, 1e3))
		local v = math.pow(10, i * 3)
		return ("%.1f"):format(n / v):gsub("%.?0+$", "") .. (suffixes[i] or "")
	--end
	
	--[[if Number >= 1000000 then
		local Whole = math.floor(Number / 1000000)
		local NumberRemainder = Number % 1000000
		return tostring(Whole).. ".".. tostring(string.sub(NumberRemainder, 1, 2)).. "M"
	elseif Number >= 1000 then
		local Whole = math.floor(Number / 1000)
		local NumberRemainder = Number % 1000
		return tostring(Whole).. ".".. tostring(string.sub(NumberRemainder, 1, 2)).. "K"
	else
		return Number
	end]]
end

function UtilitiesModule.FormatTime(NilParam, Seconds)
	-- Functions
	-- INIT
	local TimeInHours = math.floor(Seconds / 3600)
	Seconds = Seconds - (TimeInHours * 3600)	
	local TimeInMinutes = math.floor(Seconds / 60)
	Seconds = math.floor(Seconds - (TimeInMinutes * 60))
	
	return FormatToDoubleDigit(TimeInHours).. " : ".. FormatToDoubleDigit(TimeInMinutes).. " : ".. FormatToDoubleDigit(Seconds)
end

function UtilitiesModule.CanSendGameInvite(NilParam, TargetPlayer)
	local Success, CanInvite = pcall(SocialService.PromptGameInvite, SocialService, TargetPlayer)
	
	return Success and CanInvite
end

function UtilitiesModule.PackSavableValue(NilParam, Value)
	-- Functions
	-- INIT
	if typeof(Value) == "Color3" then
		return UtilitiesModule:Color3ToTable(Value)
	elseif typeof(Value) == "BrickColor" then
		return Value.Name
	else
		return Value
	end
end

function UtilitiesModule.UnPackSavableValue(NilParam, Value)
	-- Functions
	-- INIT
	if typeof(Value) == "table" and Value.Type ~= nil and Value.Type == "Color3" then
		return Color3.fromRGB(Value.R, Value.G, Value.B)
	elseif typeof(Value) == "string" and UtilitiesModule:DoesBrickColourExist(Value) then
		return BrickColor.new(Value)
	else
		return Value
	end
end

function UtilitiesModule.DoesBrickColourExist(NilParam, ColourName)
	-- Functions
	-- INIT
	if table.find(BrickColorsModule:GetBrickColourNames(), ColourName) then
		return true
	else
		local Success, Error = pcall(function()
			return BrickColor.new(ColourName)
		end)
		
		if Success then
			return true
		end
		
		print("Utilities | BrickColour: ".. tostring(ColourName).. " doesn't exist!")
		return false
	end
end

function UtilitiesModule.IsPlayerDead(NilParam, Player)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	-- Functions
	-- INIT
	if not Character then
		return nil
	end
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	if Humanoid.Health <= 0 then
		return true
	end
end

function UtilitiesModule.IsPrivateServer()
	-- Functions
	-- INIT
	if game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0 then
		return nil
	end
end

function UtilitiesModule.GetNumberFromSequence(NilParam, _NumberSequence, Time)
	-- Functions
	-- INIT
	if not _NumberSequence or typeof(NumberSequence) == "number" then
		return _NumberSequence
	end

	if Time == 0 then
		return _NumberSequence.Keypoints[1].Value
	elseif Time == 1 then
		return _NumberSequence.Keypoints[#_NumberSequence.Keypoints].Value
	end

	if not _NumberSequence.Keypoints then
		return _NumberSequence
	end

	for i = 1, #_NumberSequence.Keypoints - 1 do
		local ThisNumber = _NumberSequence.Keypoints[i]
		local NextNumber = _NumberSequence.Keypoints[i + 1]

		if Time > ThisNumber.Time and Time < NextNumber.Time then
			local Alpha = (Time - ThisNumber.Time) / (NextNumber.Time - ThisNumber.Time)

			return (NextNumber.Value - ThisNumber.Value) * Alpha + ThisNumber.Value
		end
	end
end

function UtilitiesModule.GetColourFromSequence(NilParam, ColourSequence, Time)
	-- Functions
	-- INIT
	if not ColourSequence or typeof(ColorSequence) == "Color3" then
		return ColourSequence
	end
	
	if Time == 0 then
		return ColourSequence.Keypoints[1].Value
	elseif Time == 1 then
		return ColourSequence.Keypoints[#ColourSequence.Keypoints].Value
	end
	
	if not ColourSequence.Keypoints then
		return ColourSequence.Color
	end
	
	for i = 1, #ColourSequence.Keypoints - 1 do
		local ThisColour = ColourSequence.Keypoints[i]
		local NextColour = ColourSequence.Keypoints[i + 1]
		
		if Time > ThisColour.Time and Time < NextColour.Time then
			local Alpha = (Time - ThisColour.Time) / (NextColour.Time - ThisColour.Time)
			
			return Color3.new(
				(NextColour.Value.R - ThisColour.Value.R) * Alpha + ThisColour.Value.R,
				(NextColour.Value.G - ThisColour.Value.G) * Alpha + ThisColour.Value.G,
				(NextColour.Value.B - ThisColour.Value.B) * Alpha + ThisColour.Value.B
			)
		end
	end
end

function UtilitiesModule.GetChildrenNames(NilParam, Parent)
	-- CORE
	local ChildrenNames = {}
	
	-- Functions
	-- INIT
	for i, Child in pairs(Parent:GetChildren()) do
		table.insert(ChildrenNames, Child.Name)
	end
	
	return ChildrenNames
end

function UtilitiesModule.GetFPS()
	return RequiredModules["FPS"]:GetFPS()
end

function UtilitiesModule.LoadAnimations(NilParam, Animations, AnimationInstancesTable, AnimationToLoadDict, Animator, WaitTilFinished, AttributesToSet)
	-- CORE
	AttributesToSet = AttributesToSet or {}
	
	-- Functions
	-- INIT
	local NeedToLoad = UtilitiesModule:GetSizeOfDict(Animations)
	local Loaded = 0
	local MaxAttempts = 20
	
	if not Animator then
		print(script.Name.. " | LoadAnimations | No animator given!")
		return nil
	end
	
	for InstanceName, AnimationInfo in pairs(Animations) do
		-- Instancing		
		coroutine.wrap(function()
			local Attempts = 0
			local Success, Error = false, nil

			local Animation = Instance.new("Animation")
			Animation.AnimationId = AnimationInfo.Id
			
			if AnimationInstancesTable then
				table.insert(AnimationInstancesTable, Animation)
			end
			
			repeat
				Success, Error = pcall(function()
					AnimationToLoadDict[InstanceName] = Animator:LoadAnimation(Animation)
					--AnimationToLoadDict[InstanceName]:AdjustWeight(1)
					
					--[[if FpsInfoModule:GetFpsInfo("AnimationPriorities")[InstanceName] then
						AnimationToLoadDict[InstanceName].Priority = FpsInfoModule:GetFpsInfo("AnimationPriorities")[InstanceName] --Enum.AnimationPriority.Action4
					end]]
				end)
				
				if not Success then
					warn("Retrying to load animation: '".. tostring(InstanceName).. "'")
					task.wait(.05)
					Attempts += 1
				else
					for AttributeName, AttributeValue in pairs(AttributesToSet) do
						AnimationToLoadDict[InstanceName]:SetAttribute(AttributeName, AttributeValue)
					end
				end
			until Success or not Animator or Attempts >= MaxAttempts
			
			if Success and Animator then
				repeat
					task.wait()
				until AnimationToLoadDict[InstanceName].Length > 0
			end
			
			Loaded += 1
		end)()
	end
	
	if WaitTilFinished then
		repeat
			task.wait()
		until Loaded >= NeedToLoad
	end
end

function UtilitiesModule.GetHumanoidFromHit(NilParam, HitPart)
	-- Functions
	-- INIT
	if not HitPart then
		return nil
	end
	
	local LastParent = HitPart
	
	local Humanoid = LastParent:FindFirstChildOfClass("Humanoid")	

	--pcall(function()		
			
	--[[if not Humanoid then
		for i = 1, 5 do
			if Humanoid then
				break --return Humanoid
			end
		
			LastParent = LastParent:FindFirstAncestorOfClass("Model")
				
			if not LastParent then
				break --return Humanoid
			end
			
			Humanoid = LastParent:FindFirstChildOfClass("Humanoid")
		end
	end
	--end)[[]]
	
	local RootModel = UtilitiesModule:GetRootModel(HitPart)
	
	if RootModel then
		Humanoid = RootModel:FindFirstChildOfClass("Humanoid")
	else
		Humanoid = HitPart:FindFirstChildofClass("Humanoid")
	end
	
	return Humanoid
end

function UtilitiesModule.WaitUntilLoaded(NilParam, Model)
	-- Functions
	-- INIT
	for i, _Model in pairs({Model, unpack(Model:GetChildren())}) do
		repeat
			task.wait()
		until _Model
	end
	
	task.wait()
end

function UtilitiesModule.GetPartToShift(NilParam, Model)
	-- Functions
	-- INIT
	if not Model or typeof(Model) ~= "Instance" then
		return nil
	end
	
	if Model:IsA("Model") then
		if Model.PrimaryPart then
			return Model.PrimaryPart
		else
			return Model:FindFirstChild("Base")
		end
	else
		return Model
	end
end

function UtilitiesModule.GetPlayerCharacterModule(NilParam, Player, ModuleType, ModuleName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)

	-- Functions
	-- INIT
	return UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Modules"), ModuleType), ModuleName)
end

function UtilitiesModule.GetPlayerCharacterClientRemote(NilParam, Player, RemoteName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	
	-- Elements
	-- FOLDERS
	local CharacterClientRemotesFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Remotes"), "Client"), "Remotes")
	
	-- Functions
	-- INIT
	return UtilitiesModule:WaitForChildTimed(CharacterClientRemotesFolder, RemoteName)
end

function UtilitiesModule.GetPlayerCharacterRemote(NilParam, Player, RemoteName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)

	-- Elements
	-- FOLDERS
	local CharacterClientServerSignalsFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Remotes"), "ClientServer"), "Remotes")

	-- Functions
	-- INIT
	return UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, RemoteName)
end

function UtilitiesModule.GetPlayerCharacterSignal(NilParam, Player, SignalName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)

	-- Elements
	-- FOLDERS
	local CharacterClientServerSignalsFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Remotes"), "ClientServer"), "Signals")

	-- Functions
	-- INIT
	return UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, SignalName)
end

function UtilitiesModule.RemoveElementCache(NilParam, Child, Properties, Cache)
	-- Functions
	-- INIT
	if not Cache[Child] then
		return nil
	end
	
	for i, Property in pairs(Properties) do
		Cache[Child][Property] = nil
	end
	
	if UtilitiesModule:GetSizeOfDict(Cache[Child]) <= 0 then
		Cache[Child] = nil
	end
end

function UtilitiesModule.CreateCustomConnection(NilParam, CustomConnections)
	-- Functions
	-- INSTANCING
	local CustomConnection = Instance.new("BoolValue")
	CustomConnection.Value = true
	
	if CustomConnections then
		table.insert(CustomConnections, CustomConnection)	
	end

	return CustomConnection 
end

function UtilitiesModule.WeldParts(NilParam, Part1, Part2, IgnoreCs)
	-- Functions
	-- INIT
	local WeldConstraint = Instance.new("ManualWeld")
	WeldConstraint.Part0 = Part1
	WeldConstraint.Part1 = Part2
	
	if not IgnoreCs then
		local ConstraintJoint = CFrame.new(Part1.Position)
		
		local C0 = Part1.CFrame:Inverse() * ConstraintJoint
		local C1 = Part2.CFrame:Inverse() * ConstraintJoint

		WeldConstraint.C0 = C0
		WeldConstraint.C1 = C1
	end

	WeldConstraint.Parent = Part1
	Part1.Anchored = false
	
	return WeldConstraint
end

function UtilitiesModule.WeightedRandom(NilParam, ChanceTable)
	-- Functions
	-- INIT
	local SumOfWeights = 0
	
	for Name, Weight in pairs(ChanceTable) do
		SumOfWeights += Weight
	end
	
	local randomNumber = math.random(0, SumOfWeights * 100) / 100
	
	for Name, Weight in pairs(ChanceTable) do
		if randomNumber < Weight then
			return Name
		end
		
		randomNumber -= Weight
	end
end

function UtilitiesModule.UnloadAnimations(NilParam, AnimationLoads)
	-- Functions
	-- INIT
	for i, AnimationLoad in pairs(AnimationLoads) do
		AnimationLoad:Stop()
		AnimationLoad:Destroy()
	end
end

function UtilitiesModule.GenerateRandomString(NilParam, Length)
	-- CORE
	local String = ""
	
	-- Functions
	-- INIT
	for i = 1, Length do
		String = String.. CharSetModule[math.random(1, #CharSetModule)]
	end
	
	return String
end

function UtilitiesModule.TableToVector3(NilParam, _Dict)
	-- Functions
	-- INIT
	return Vector3.new(_Dict["X"], _Dict["Y"], _Dict["Z"])
end

function UtilitiesModule.Color3ToTable(NilParam, _Color3)
	-- Functions
	-- INIT
	return {R = _Color3.R * 255, G = _Color3.G * 255, B = _Color3.B *  255, Type = "Color3"}
end

function UtilitiesModule.Color3ToVector3(NilParma, _Color3)
	-- Functions
	-- INIT
	return Vector3.new(_Color3.R * 255, _Color3.G * 255, _Color3.B * 255)
end

function UtilitiesModule.GetCharacters(NilParam, Loaded)
	-- Functions
	-- INIT
	local Characters = {}
	
	for i, Player in pairs(game.Players:GetPlayers()) do
		local Character = UtilitiesModule:GetCharacter(Player, true)
		
		if not Character or not Character.Parent then
			continue
		end
		
		if not Loaded then
			table.insert(Characters, Character)
		else
			if Character:GetAttributes()["ServerLoaded"] then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				
				if Humanoid and Humanoid.Health > 0 then
					table.insert(Characters, Character)
				end
			end
		end
	end
	
	return Characters
end

function UtilitiesModule.GetCharacter(NilParam, Player, StopWait)
	-- Functions
	-- INIT
	if Player then		
		if not StopWait then
			return Player.Character or Player:GetPropertyChangedSignal("Character"):Wait() --Player.CharacterAdded:Wait()
		else
			return Player.Character
		end	
	end
end

function UtilitiesModule.ApplyProperties(NilParam, Element, Properties)
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(Properties) do
		if UtilitiesModule:HasProperty(Element, PropertyName) then
			Element[PropertyName] = PropertyValue
		else
			Element:SetAttribute(PropertyName, PropertyValue)
		end
	end
end

function UtilitiesModule.CreateElementCache(NilParam, Element, Properties, Cache)
	-- Functions
	-- INIT
	if Cache[Element] == nil then
		Cache[Element] = {}
	end
	
	for i, PropertyName in pairs(Properties) do
		if Cache[Element][PropertyName] == nil then
			if UtilitiesModule:HasProperty(Element, PropertyName) then
				Cache[Element][PropertyName] = Element[PropertyName]
			else
				Cache[Element][PropertyName] = Element:GetAttributes()[PropertyName]
			end
		end
	end
	
	return Cache[Element]
end

function UtilitiesModule.MinutesToSeconds(NilParam, Minutes)
	-- Functions
	-- INIT
	return Minutes * 60
end

function UtilitiesModule.BetterCountdown(NilParam, From, CustomConnection, Replication)
	-- CORE
	local Difference = 0
	local TimeNow = tick()
	local LocalCustomConnection = false
	
	if not CustomConnection then
		LocalCustomConnection = true
		CustomConnection = UtilitiesModule:CreateCustomConnection()
	end
		
	-- Functions
	-- INIT
	repeat
		Difference = tick() - TimeNow
		
		if Replication then
			if Replication.Attribute ~= nil then
				Replication.Attribute.Instance:SetAttribute(Replication.Attribute.Name, math.floor(From - Difference))
			end
		end
		
		task.wait()
	until Difference >= From or not CustomConnection or not CustomConnection.Value
	
	if LocalCustomConnection then
		UtilitiesModule:DisconnectCustomConnections({CustomConnection})
	end
end

function UtilitiesModule.DisconnectCustomConnections(NilParam, CustomConnections)
	-- Functions
	-- INIT
	if typeof(CustomConnections) == "table" then
		for i, CustomConnection in pairs(CustomConnections) do
			CustomConnection.Value = false
			CustomConnection:Destroy()
			CustomConnection = nil
		end
	elseif typeof(CustomConnections) == "Instance" then
		CustomConnections.Value = false
		CustomConnections:Destroy()
		CustomConnections = nil
	end
end

function UtilitiesModule.DisconnectConnections(NilParam, Connections)
	-- Functions
	-- INIT
	if not Connections then
		return nil
	end
	
	for i, Connection in pairs(Connections) do
		if Connection and Connection.Connected then
			Connection:Disconnect()
		end
	end
	
	Connections = {}
end

function UtilitiesModule.CancelTween(NilParam, TweenElement, TweenDict)
	-- Functions
	-- INIT
	if TweenElement and TweenDict and TweenDict[TweenElement] ~= nil then
		TweenDict[TweenElement]:Cancel()
		TweenDict[TweenElement]:Destroy()
		TweenDict[TweenElement] = nil
	end
end

function UtilitiesModule.CompleteTween(NilParam, TweenElement, TweenDict)
	-- Functions
	-- INIT
	if TweenElement and TweenDict and TweenDict[TweenElement] ~= nil then
		local Connection1 = nil

		Connection1 = TweenDict[TweenElement].Completed:Connect(function(PlaybackStatus)
			if PlaybackStatus == Enum.PlaybackState.Completed then
				TweenDict[TweenElement]:Destroy()
				TweenDict[TweenElement] = nil
			end

			Connection1:Disconnect()
		end)
	end
end

function UtilitiesModule.DecimalToPercentage(NilParam, Decimal)
	return Decimal * 100
end

function UtilitiesModule.GetGroupsFromUserId(NilParam, UserId)
	-- Functions
	-- INIT
	local Groups = GroupService:GetGroupsAsync(UserId)

	return Groups
end

function UtilitiesModule.HoursToSeconds(NilParam, Hours)
	return Hours * 3600
end

function UtilitiesModule.SecondsToHours(NilParam, Seconds)
	return math.floor(Seconds / 3600)
end

function UtilitiesModule.GetDictKeys(NilParam, Dict)
	-- CORE
	local Array = {}

	-- Functions
	-- INIT
	for i, v in pairs(Dict) do
		table.insert(Array, i)
	end

	return Array
end

function UtilitiesModule.DictToArray(NilParam, Dict)
	-- CORE
	local Array = {}
	
	-- Functions
	-- INIT
	for i, v in pairs(Dict) do
		table.insert(Array, v)
	end
	
	return Array
end

function UtilitiesModule.CloneDict(NilParam, Dict)
	-- CORE
	local NewDict = {}
	
	-- Functions
	-- INIT
	for i, v in pairs(Dict) do
		if typeof(v) == "table" then
			NewDict[i] = UtilitiesModule:CloneDict(v)
		else
			NewDict[i] = v
		end
	end
	
	return NewDict
end

function UtilitiesModule.WaitForChildTimed(NilParam, Parent, Child, Tries, Infinite, _CustomConnection)
	if not Parent then
		return nil
	end
	
	-- Core
	local IsCustomConnection = false
	
	if _CustomConnection ~= nil then
		IsCustomConnection = true
	end
	
	Tries = Tries or 100
	local FoundChild = nil
	
	if Parent then
		FoundChild = Parent:FindFirstChild(Child)
	end
	
	-- Functions
	-- INIT
	if not FoundChild then
		if not Infinite then
			for i = 1, Tries do				
				if FoundChild then
					break
				end

				FoundChild = Parent:FindFirstChild(Child)
				task.wait()
				
				if IsCustomConnection and (not _CustomConnection or not _CustomConnection.Value) then
					break
				end
			end
		else
			while not FoundChild do
				FoundChild = Parent:FindFirstChild(Child)
				
				if not FoundChild then
					task.wait()
				end
				
				if IsCustomConnection and (not _CustomConnection or not _CustomConnection.Value) then
					break
				end
			end
		end
	end
	
	return FoundChild
end

function UtilitiesModule.WaitForChildOfClass(NilParam, Parent, ClassName)
	if not Parent then
		return nil
	end
	
	-- CORE
	local FoundElement = Parent:FindFirstChildOfClass(ClassName)
	
	-- Functions
	-- INIT
	if not FoundElement then
		repeat
			task.wait(.1)
			FoundElement = Parent:FindFirstChildOfClass(ClassName)
		until FoundElement
	end
	
	return FoundElement
end

function UtilitiesModule.ArrayToString(NilParam, Array)
	-- CORE
	local String = ""
	
	-- Functions
	-- INIT
	for i, Element in pairs(Array) do
		String = String.. tostring(Element)
		
		if i ~= #Array then
			String = String.. ", "
		end
	end
	
	return String
end

function UtilitiesModule.GetElementFromPath(NilParam, Root, Path)
	-- Functions
	-- INIT
	local LastItem = nil
	
	for i, ElementName in pairs(Path) do
		if LastItem then
			LastItem = LastItem[ElementName]
		else
			LastItem = Root[ElementName]
		end
	end
	
	return LastItem
end

function UtilitiesModule.Map(NilParam, Dir, Function, ClassName, ArgsBefore, ...)
	-- Functions
	-- INIT
	for i, v in pairs(Dir:GetChildren()) do
		if v:IsA(ClassName) then
			if not ArgsBefore then
				Function(v, ...)
			else
				Function(..., v)
			end
		end
	end
end

function UtilitiesModule.FindCharacterInString(NilParam, String, Sub)
	-- Functions
	-- INIT
	for i = 1, string.len(String) do
		if string.sub(String, i, i) == Sub then
			return i
		end
	end
end

function UtilitiesModule.CropNumberToDecimalPlaces(NilParam, Number, PlaceValueNumber)
	-- Functions
	-- INIT
	local NumberString = tostring(Number)
	
	local DecimalPointIndex = UtilitiesModule:FindCharacterInString(NumberString, ".") --string.find(NumberString, '.')
	--local FinalNumber = string.sub(NumberString, DecimalPointIndex + Number, DecimalPointIndex + PlaceValueNumber)
	
	if DecimalPointIndex ~= nil then
		return string.sub(NumberString, 1, DecimalPointIndex + PlaceValueNumber)
	else
		return tostring(Number)
	end
end

function UtilitiesModule.GetSizeOfDict(NilParam, Dict)
	-- CORE
	local Size = 0
	
	-- Functions
	-- INIT
	if Dict and typeof(Dict) == "table" then
		for i, v in pairs(Dict) do
			if v == nil then
				continue
			end
			
			Size += 1
		end
	else
		print("Utilities | Table doesn't exist: ".. tostring(Dict))
	end
	
	return Size
end

function UtilitiesModule.CreateRegion3FromPart(NilParam, obj)
	local abs = math.abs

	local cf = obj.CFrame -- this causes a LuaBridge invocation + heap allocation to create CFrame object - expensive! - but no way around it. we need the cframe
	local size = obj.Size -- this causes a LuaBridge invocation + heap allocation to create Vector3 object - expensive! - but no way around it
	local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no allocations

	-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
	local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
	local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
	local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same

	-- just a bunch of local ops
	local minx = x - wsx
	local miny = y - wsy
	local minz = z - wsz

	local maxx = x + wsx
	local maxy = y + wsy
	local maxz = z + wsz

	local minv, maxv = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return Region3.new(minv, maxv)
end

-- INIT
RunSubModules()

return UtilitiesModule