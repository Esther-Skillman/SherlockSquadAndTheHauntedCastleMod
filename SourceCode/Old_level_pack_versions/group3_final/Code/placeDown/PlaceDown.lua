
local CarryHelper = require('CarryHelper')
local owner = owner or error('No owner')

--for placeing the object down
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')
    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then

        return true
    end

    -- There's no empty floor or could not put down
    return false
end

owner.tags.removeTag("carryable")

