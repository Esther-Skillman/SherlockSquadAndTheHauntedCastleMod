
local owner = owner or error('No owner')

local game = LoadFacility('Game')['game']
local  penalise = false

local function penalty(message)

    local ghost = owner.map.getFirstTagged(owner.gridPosition, 'ghost')
    print("player is: ", ghost)
    if ghost ~= nil and  penalise == true then
        print("penalise", penalise)
        penalise = false
        ghost.callAction('loseHealth', 1)
        ghost.callAction('showHealthIndicator')
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'ghostHurt' } }, false)
        waitMilliSeconds(2000)
        ghost.callAction('hideHealthIndicator')
        ghost = nil
    end

end

local function onGamePhaseChanged(message)
    if message.data.gamePhase == 'planning' then
        penalise = true
    end


end

game.bus.subscribe('gamePhase', onGamePhaseChanged)
owner.bus.subscribe('siblingAdded', penalty)

