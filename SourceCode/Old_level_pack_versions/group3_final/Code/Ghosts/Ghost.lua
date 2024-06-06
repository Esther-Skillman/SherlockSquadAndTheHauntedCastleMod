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

local linkTable = linkTable

---@type number
local posYOffset = 0.6
---@type number
local posXOffset = 0.25
---@type boolean
local destroyed = false
---@type number @ Turn to appear on (counted from 1)
---
local SpawnsInGrid = require('SpawnsInGrid')

local appearOnTurn = appearOnTurn or 0
--log:log('appearOnTurn:', appearOnTurn)

local healthLostOnNewRound = healthLostOnNewRound or 1

function releaseGhost( table)

    if table == linkTable then
        if owner.tags.hasTag('ghost_original') then
            --sound here for original ghost


            --Animation here for original ghost

        elseif owner.tags.hasTag('ghost_cowboy') then
            --sound here for cowboy ghost


            --Animation here for cowboy ghost

        elseif owner.tags.hasTag('ghost_party') then
            --sound here for party ghost


            --Animation here for party ghost

        elseif owner.tags.hasTag('ghost_sherlock') then
            --sound here for sherlock ghost


            --Animation here for sherlock ghost

        else
            print("error not recognised ghost type")
        end

        owner.destroyObject()
        destroyed = true
        health = 0
        -- Notify any interested listener (GameManager.lua) that a patient was cured so it can check whether the level has been won.
        game.bus.send({ 'ghost.released' })
        print("i am ghost ", linkTable, "and my table is ", table )
        return true
    else
        print("i am ghost ", linkTable, "and my table is ", table )
        return false
    end
    --game.bus.send({
        --metadata = { 'textNotificationUI.createOrUpdate' },
        --data = {
            --id = "test",
            --titleTextKey = "Ghost",
            --mainTextKey = "Oh, i can remember who i was. now i can pass to the next life. thanks",
        --}
    --}, nil, false)

end

---@param withDelay boolean
 function showHealthIndicator()
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

function hideHealthIndicator()
    if destroyed then
        return
    end
    owner.bus.send({ 'objectCountdown.hide' }, nil, false)
end

function loseHealth(delta)
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

-- If `appearOnTurn` is 0, we are active at start (else we go inactive)
--if (0 >= appearOnTurn) then
    -- active at start
  --  SpawnsInGrid.trySetActive(patientCanBecomeActive, onActive, onVisibleFromActive)
    -- 1 extra health so initial reduction doesn't start us one too few!
    --health = health + 1
--else
    -- Disabled at start
  --  log:log('Disabled at start since '.. appearOnTurn ..' turns until active')
    --SpawnsInGrid.setInactive(onInactive, nil, true)
--end

local function penalty(message)

    local player = owner.map.getFirstTagged(owner.gridPosition, 'Player')
    print("player is: ", player)
    if player ~= nil then
        print("player attacked the ghost")
        loseHealth(healthLostOnNewRound)
        showHealthIndicator()
        waitMilliSeconds(2000)
        hideHealthIndicator()
        player = nil
    end

end

local function onGamePhaseChanged(message)
    if message.data.gamePhase == 'planning' then
        print('about to decrease ghost health for new round...')
        if health > 0 then
            loseHealth(healthLostOnNewRound)
            showHealthIndicator()
        end
    end
    if  message.data.gamePhase == 'acting' then
        print('hiding health indicator...')
        hideHealthIndicator()
    end
end




owner.bus.subscribe('siblingAdded', penalty)
game.bus.subscribe('gamePhase', onGamePhaseChanged)