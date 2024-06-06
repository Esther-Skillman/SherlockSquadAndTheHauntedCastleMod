--@type MapMobile
local owner = owner or error('No owner')

local CarryHelper = require('CarryHelper')

--for placeing the object down
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')
    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        return true
    end
    print("it is ",owner.getFirstNeighbouringObjectTagged("evidenceTable"))
    if owner.getFirstNeighbouringObjectTagged("evidenceTable") ~= nil then
        return true
    end
    --a dd if statument to know if the object in the player direction is the table
    -- There's no empty floor or could not put down
    return false
end




