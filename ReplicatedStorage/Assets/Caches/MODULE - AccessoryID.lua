local AccessoryIDCacheModule = {}

-- CORE
local Cache = {}

-- SERVICES
local MarketplaceService = game:GetService("MarketplaceService")

-- Functions
-- MECHANICS
local function Get(ID)
	-- Functions
	-- INIT
	if not Cache[ID] then	
		Cache[ID] = MarketplaceService:GetProductInfo(ID, Enum.InfoType.Asset)
		Cache[ID]["Price"] = Cache[ID]["PriceInRobux"]
	end
	
	return Cache[ID]
end

-- DIRECT
function AccessoryIDCacheModule.Get(NilParam, ...)
	return Get(...)
end

return AccessoryIDCacheModule