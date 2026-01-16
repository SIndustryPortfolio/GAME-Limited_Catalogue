local ChatMessageModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local SoundsModule = require(ModulesFolder["Sounds"])

-- Services
local StarterGuiService = game:GetService("StarterGui")

-- Functions
-- MECHANICS
local function Add(Message, Colour, SoundName)
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Add | Message: ".. tostring(Message).. " | Colour: ".. tostring(Colour))

	Colour = {R = math.floor(Colour.r * 255), G = math.floor(Colour.g * 255), B = math.floor(Colour.b * 255)}

	--game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage("<font color='rgb(1,1,1)'>{Message}</font>")
	game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage(`<font color='rgb(`.. Colour.R.. `, `.. Colour.G.. `, `.. Colour.B.. `)'>`.. Message.. `</font>`)

	if SoundName ~= nil then
		SoundsModule:PlaySoundEffectByName("Misc", SoundName)
	end

	--game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage(`<font color="rgb(`.. Colour.r.. `, `.. Colour.g.. `, `.. Colour.b.. `)">{Message}</font>`)


	--game.StarterGui:SetCore("ChatMakeSystemMessage", {Text = Message, Color = Colour, font = Enum.Font.SourceSansBold})


	--[[StarterGuiService:SetCore("ChatMakeSystemMessage", {
		Text = Message;
		Color = Colour;
		Font = Enum.Font.SourceSansBold;
		TextSize = 18
	})]]

	--[[if not Success then
		DebugModule:Print(script.Name.. " | Add | Message: ".. tostring(Message).. " | Colour: ".. tostring(Colour).. " | Error: ".. tostring(Error))
	end]]
end

-- CORE FUNCTIONS
local ServerRequests = 
{
	["Add"] = Add		
}

-- MECHANICS
local function ServerRequest(FunctionName, ...)
	-- Functions
	-- INIT
	return ServerRequests[FunctionName](...)
end

-- DIRECT
function ChatMessageModule.ServerRequest(NilParam, ...)
	return ServerRequest(...)
end


return ChatMessageModule