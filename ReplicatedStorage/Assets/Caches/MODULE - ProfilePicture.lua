local ProfilePictureCacheModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local Cache = {}
local ProxyURL = "roproxy.com"

-- SERVICES
local HttpService = game:GetService("HttpService")

-- Functions
-- MECHANICS
local function Get(ID)
	-- Functions
	-- INIT
	if not Cache[ID] then
		local UserThumbnailRequestURL = "https://thumbnails.".. tostring(ProxyURL).. "/v1/users/avatar-headshot?userIds=".. tostring(ID).. "&size=48x48&format=Png&isCircular=false"
		
		local Success2, UserThumbnailResponse = pcall(function()
			return HttpService:GetAsync(UserThumbnailRequestURL)
		end)

		if not Success2 then
			return DebugModule:Print(script.Name.. " | Purchased | UserId: ".. tostring(ID).. " | UserThumbnailResponse | Error: ".. tostring(UserThumbnailResponse))
		end

		UserThumbnailResponse = HttpService:JSONDecode(UserThumbnailResponse)
		Cache[ID] = UserThumbnailResponse["data"][1]["imageUrl"]
	end

	return Cache[ID]
end

-- DIRECT
function ProfilePictureCacheModule.Get(NilParam, ...)
	return Get(...)
end

return ProfilePictureCacheModule