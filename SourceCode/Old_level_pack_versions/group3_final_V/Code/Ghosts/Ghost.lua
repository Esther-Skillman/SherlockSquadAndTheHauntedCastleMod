---
--- Generated by Luanalysis
--- Created by msalt.
--- DateTime: 2/6/2024 4:16 PM
---
---
local owner = owner or error('No owner')

local game = LoadFacility('Game')['game']

local Log = require('Log')
---Default to normal 'log' level unless
local logLevel = --[[---@type number]] (logLevel or Log.LevelLog)
local log = Log.new(logLevel)
log:debug("Dispenser loaded")

---@type table<number, string>
local prefabToNameMap = {}

local loader = game.loader or error('No loader')
---Health of ghost.  Explicitly *NOT* a local so tests can retrieve the value!
local health = health or 10

local linkTable = linkTable

local  penalise = false

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

local function create(name)

    log:debug('ghostToBeReleased:', owner)
    log:debug('Attempting to create ', name, ' at ', owner.gridPosition)
    local newInstance = loader.instantiate(name, owner.gridPosition)
    prefabToNameMap[newInstance.id] = "release_original"
    log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', name, '")')
    prefabToNameMap[newInstance.id] = name
    log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', name, '")')

    ghostReleasing = owner.map.getFirstTagged(owner.gridPosition, "ghostReleasing")
    --portal = owner.map.getFirstTagged(owner.gridPosition, "release_portal")
    owner.destroyObject()
    waitMilliSeconds(2500)
    ghostReleasing.destroyObject()
    --portal.destroyObject()

end

function releaseGhost( table)
    game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'releaseGhost' } }, false)
    if table == linkTable then
        if owner.tags.hasTag('ghost_original') then

            game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'originalReleased' } }, false)
            print("originalReleased sound")
            create("original_disappear")

        elseif owner.tags.hasTag('ghost_cowboy') then

            game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'cowboyReleased' } }, false)
            create("cowboy_disappear")

        elseif owner.tags.hasTag('ghost_party') then

            game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'partyReleased' } }, false)
            create("party_disappear")

        elseif owner.tags.hasTag('ghost_sherlock') then

            game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'sherlockReleased' } }, false)
            create("sherlock_disappear")

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

    local evidence = owner.map.getFirstTagged(owner.gridPosition, 'evidence')
    local player = owner.map.getFirstTagged(owner.gridPosition, 'Player')
    print("player is: ", player)
    if player ~= nil and  penalise == true and evidence == nil then
        penalise = false
        print("player attacked the ghost")
        loseHealth(healthLostOnNewRound)
        showHealthIndicator()
        game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'ghostHurt' } }, false)
        waitMilliSeconds(2000)
        hideHealthIndicator()
        player = nil
        evidence = nil
    end

end

local function onGamePhaseChanged(message)
    if message.data.gamePhase == 'planning' then
        print('about to decrease ghost health for new round...')
        penalise = true
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