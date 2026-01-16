local AssetThumbnailCacheModule = {}

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
		local AssetThumbnailRequestURL = "https://thumbnails.".. tostring(ProxyURL).. "/v1/assets?assetIds=".. tostring(ID).. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"

		local Success1, AssetThumbnailResponse = pcall(function()
			return HttpService:GetAsync(AssetThumbnailRequestURL)
		end)

		if not Success1 then
			return DebugModule:Print(script.Name.. " | Purchased | AssetId: ".. tostring(ID).. " | AssetThumbnailResponse | Error: ".. tostring(AssetThumbnailResponse))
		end

		AssetThumbnailResponse = HttpService:JSONDecode(AssetThumbnailResponse)
		Cache[ID] = AssetThumbnailResponse["data"][1]["imageUrl"]
	end

	return Cache[ID]
end

-- DIRECT
function AssetThumbnailCacheModule.Get(NilParam, ...)
	return Get(...)
end

return AssetThumbnailCacheModule