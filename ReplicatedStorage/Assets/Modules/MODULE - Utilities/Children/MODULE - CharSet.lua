local CharSet = {}

-- CORE
local CharacterBounds = {{48, 57}, {65, 90}, {97, 122}}

-- Functions
-- INIT
for i, BoundaryPair in pairs(CharacterBounds) do
	for c = BoundaryPair[1], BoundaryPair[2] do
		table.insert(CharSet, string.char(c))
	end
end

return CharSet