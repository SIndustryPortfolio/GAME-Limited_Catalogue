local UsernamesIDCacheModule = {}

-- CORE
local Cache = {}

-- SERVICES


-- Functions
-- MECHANICS
local function Get(ID)
	-- Functions
	-- INIT
	if not Cache[ID] then	
		Cache[ID] = game.Players:GetNameFromUserIdAsync(ID)
	end

	return Cache[ID]
end

-- DIRECT
function UsernamesIDCacheModule.Get(NilParam, ...)
	return Get(...)
end

return UsernamesIDCacheModule