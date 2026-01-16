local AppearanceIDCacheModule = {}

-- CORE
local Cache = {}

-- SERVICES


-- Functions
-- MECHANICS
local function Get(ID)
	-- Functions
	-- INIT
	if not Cache[ID] then	
		local Success, Appearance = pcall(function()
			return game.Players:GetHumanoidDescriptionFromUserId(ID)
		end)

		if Success then
			Cache[ID] = Appearance
		end
	end

	return Cache[ID]
end

-- DIRECT
function AppearanceIDCacheModule.Get(NilParam, ...)
	return Get(...)
end

return AppearanceIDCacheModule