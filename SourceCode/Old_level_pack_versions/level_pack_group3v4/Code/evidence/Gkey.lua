local owner = owner or error('No owner')
local CarryHelper = require('CarryHelper')
---@type Game
local game = LoadFacility('Game')['game']
---@type Loader
local loader = game.loader or error('No loader')

local keyLocalVariable
local fake

local function keyCarryable()
    print("Hello world!")
    -- Assuming the message contains information about the added sibling
    if owner.tags.hasTag('MagGlasses') then
        -- bed.destroyObject()
        if fake ~= nil then
            fake.destroyObject()
        end
        if keyLocalVariable ~= nil then
            keyLocalVariable.tags.addTag("carryable")
        end
        if fake ~= nil and keyLocalVariable ~= nil then
            print("you got an evidence to be narrative")
            game.bus.send({'textNotificationUI.destroyAll'}, nil, false)
            game.bus.send({
                metadata = { 'textNotificationUI.createOrUpdate' },
                data = {
                    id = "test",
                    titleTextKey = "Ghost",
                    mainTextKey = "you got an evidence to be narrative",
                }
            }, nil, false)
        else
            print("fake evidence to be narrative")
        end
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
    fake = owner.getFirstNeighbouringObjectTagged("EvidenceBox" )
    if keyLocalVariable == nil  then
        keyLocalVariable = owner.getFirstNeighbouringObjectTagged("key" )
    end
    print("key", keyLocalVariable)
    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then

        owner.destroyObject()
        return true

    -- Checking if we are interacting with the key, which later will be evidence
    elseif keyLocalVariable ~= nil or fake ~= nil then
        print("keyLocalVar Method")
        keyCarryable()
        return true
    end
    -- There's no empty floor or could not put down
    return false
end



