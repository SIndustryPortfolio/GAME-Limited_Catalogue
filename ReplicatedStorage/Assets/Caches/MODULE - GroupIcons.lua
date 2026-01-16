local GroupIDCacheModule = {}

-- CORE
local Cache = {}

-- SERVICES
local GroupService = game:GetService("GroupService")

-- Functions
-- MECHANICS
local function Get(ID)
	-- Functions
	-- INIT
	if not Cache[ID] then	
		Cache[ID] = GroupService:GetGroupInfoAsync(ID)
		Cache[ID] = Cache[ID]["EmblemUrl"]
	end

	return Cache[ID]
end

-- DIRECT
function GroupIDCacheModule.Get(NilParam, ...)
	return Get(...)
end

return GroupIDCacheModule