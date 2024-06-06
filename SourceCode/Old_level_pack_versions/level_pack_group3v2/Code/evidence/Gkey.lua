local owner = owner or error('No owner')
local CarryHelper = require('CarryHelper')
---@type Game
local game = LoadFacility('Game')['game']
---@type Loader
local loader = game.loader or error('No loader')

local keyLocalVariable

local function keyCarryable()
    print("Hello world!")
    -- Assuming the message contains information about the added sibling

    if owner.tags.hasTag('MagGlasses') then
        -- bed.destroyObject()
        keyLocalVariable.tags.addTag("carryable")
        owner.destroyObject()
        print("Is owner carryable", owner.tags.hasTag("carryable"))
        print("Key is carryable")
        return true
    else
        print("Object is null!")
        return false
    end
end
--for placeing the object down
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')
    keyLocalVariable = owner.getFirstNeighbouringObjectTagged("evidence" )
    if keyLocalVariable == nil then
        keyLocalVariable = owner.getFirstNeighbouringObjectTagged("key" )
    end
    print("key", keyLocalVariable)
    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then

        owner.destroyObject()
        return true
    -- Checking if we are interacting with the key, which later will be evidence
    elseif keyLocalVariable ~= nil then
        print("keyLocalVar Method")
        keyCarryable()
        return true
    end
    -- There's no empty floor or could not put down
    return false
end



