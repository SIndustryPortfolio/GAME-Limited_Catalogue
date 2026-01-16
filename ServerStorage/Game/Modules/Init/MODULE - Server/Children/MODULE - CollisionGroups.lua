local InitModule = {}

-- Services
local PhysicsService = game:GetService("PhysicsService")

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	PhysicsService:RegisterCollisionGroup("Characters")
	PhysicsService:CollisionGroupSetCollidable("Characters", "Characters", false)
end

local function End()
	
end

-- DIRECT
function InitModule.Initialise()
	return Initialise()
end

function InitModule.End()
	return End()
end

return InitModule