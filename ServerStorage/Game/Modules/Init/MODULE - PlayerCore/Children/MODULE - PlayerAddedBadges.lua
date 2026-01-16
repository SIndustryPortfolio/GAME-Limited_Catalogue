local PlayerAddedBadgesModule = {}

-- CORE
local BadgesToAward = {1164474647969187}

-- Services
local BadgeService = game:GetService("BadgeService")

-- Functions
-- MECHANICS
local function PlayerAdded(Player)
	-- Functions
	-- INIT
	for i, BadgeId in pairs(BadgesToAward) do
		if not BadgeService:UserHasBadge(Player.UserId, BadgeId) then
			BadgeService:AwardBadge(Player.UserId, BadgeId)
		end
	end	
end

local function PlayerRemoved(Player)
	-- Functions
	-- INIT
	
end

-- DIRECT
function PlayerAddedBadgesModule.PlayerAdded(NilParam, ...)
	return PlayerAdded(...)
end

function PlayerAddedBadgesModule.PlayerRemoved(NilParam, ...)
	return PlayerRemoved(...)
end

return PlayerAddedBadgesModule