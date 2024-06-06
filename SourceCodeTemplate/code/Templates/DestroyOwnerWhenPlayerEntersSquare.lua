--- Destroys its owner when a player enters the square
local DirectionUtils =require('DirectionUtils')
local owner = owner or error('No owner')

local function onSiblingAdded(message)
	
	-- check whether there's a player in the same square as our owner
	local player = owner.map.getFirstTagged(owner.gridPosition, 'Player')
	if nil == player then
		return -- early out = not a player
	end

	local Direction = DirectionUtils.North
	print("Player details:", player)
	
	-- Wake up, it's time to die
	owner.destroyObject()
	--move on space when the player on the same floor as the object
	--owner.move1SpaceIfPossible(Direction)
	
end

-- MAIN
-- Subscribe to be told when something enters the same square we're on
owner.bus.subscribe('siblingAdded', onSiblingAdded)
