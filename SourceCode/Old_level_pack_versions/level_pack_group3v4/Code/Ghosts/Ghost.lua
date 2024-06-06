---
--- Generated by Luanalysis
--- Created by msalt.
--- DateTime: 2/6/2024 4:16 PM
---
---
local owner = owner or error('No owner')

local game = LoadFacility('Game')['game']
---Health of ghost.  Explicitly *NOT* a local so tests can retrieve the value!
local health = health or 10
---@type number
local posYOffset = 0.6
---@type number
local posXOffset = 0.25
---@type boolean
local destroyed = false

local healthLostOnNewRound = healthLostOnNewRound or 1

function releaseGhost()
    owner.destroyObject()
    destroyed = true
    -- Notify any interested listener (GameManager.lua) that a patient was cured so it can check whether the level has been won.
    game.bus.send({ 'ghost.released' })
end

---@param withDelay boolean
local function showHealthIndicator()
    if destroyed or health <= 0 then
        return
    end
    owner.bus.send({
        metadata = { 'objectCountdown.show' },
        data = {
            displayType = "health",
            value = health,
            positionOffset = { y = posYOffset, x = posXOffset},
        }
    }, nil, false)
end

local function hideHealthIndicator()
    if destroyed then
        return
    end
    owner.bus.send({ 'objectCountdown.hide' }, nil, false)
end

local function loseHealth(delta)
    if 0 < health then
        print('Active so reducing health by '.. delta .. ' from ' .. health .. ' to ' .. health - delta)
        health = health - delta
        local alertHealthLossMsg = { metadata = { 'patient.alertHealthLoss' }, data = { healthLost = delta, position = owner.gridPosition } }
        game.bus.send(alertHealthLossMsg, nil, false)
        if 0 >= health then
            owner.destroyObject()
            destroyed = true
            print('ghost died')

            -- Notify GameManager lua that a ghost died
            game.bus.send({ 'ghost.died' })
        end
    else
        print('Health 0 = the ghost cannot be released but keep playing')
    end
end



local function onGamePhaseChanged(message)
    if message.data.gamePhase == 'planning' then
        print('about to decrease ghost health for new round...')
        loseHealth(healthLostOnNewRound)
        showHealthIndicator()
    end
    if  message.data.gamePhase == 'acting' then
        print('hiding health indicator...')
        hideHealthIndicator()
    end
end

game.bus.subscribe('gamePhase', onGamePhaseChanged)