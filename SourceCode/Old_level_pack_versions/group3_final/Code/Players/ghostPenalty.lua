
local owner = owner or error('No owner')

local game = LoadFacility('Game')['game']

local function penalty(message)

    local action
    local ghost = owner.map.getFirstTagged(owner.gridPosition, 'ghost')
    print("player is: ", ghost)
    if ghost ~= nil then
        print("player attacked the ghost", ghost.hasFunc('showHealthIndicator'))
        ghost.callAction('loseHealth', 1)
        ghost.callAction('showHealthIndicator')
        waitMilliSeconds(2000)
        ghost.callAction('hideHealthIndicator')
        ghost = nil
    end

end


owner.bus.subscribe('siblingAdded', penalty)

