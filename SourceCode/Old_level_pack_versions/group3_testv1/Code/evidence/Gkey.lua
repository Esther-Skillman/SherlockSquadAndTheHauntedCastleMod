local owner = owner or error('No owner')
local CarryHelper = require('CarryHelper')

local Log = require('Log')
---Default to normal 'log' level unless
local logLevel = --[[---@type number]] (logLevel or Log.LevelLog)
local log = Log.new(logLevel)
log:debug("Dispenser loaded")

---@type Game
local game = LoadFacility('Game')['game']

---@type table<number, string>
local prefabToNameMap = {}

---@type Loader
local loader = game.loader or error('No loader')

--local keyLocalVariable
local hiddenEvidence
local foundEvidence
local fake
local prompt
local narrative = ""

local Deriction
local Player



local function create(name)

    owner.destroyObject()

    log:debug('Attempting to create ', name, ' at ', hiddenEvidence.gridPosition)
    local newInstance = loader.instantiate(name, hiddenEvidence.gridPosition)
    prefabToNameMap[newInstance.id] = name
    log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', name, '")')
    print('evidence found successfully')
    hiddenEvidence.destroyObject()


    waitMilliSeconds(1000)
    --game.bus.send({ 'pick_up' }, C3)

    print("acted done")

end

local function keyCarryable()
    print("Hello world!")
    -- Assuming the message contains information about the added sibling
    if fake ~= nil or hiddenEvidence ~= nil then
        -- bed.destroyObject()
        --print("fake P:", fake.gridPosition, " e p ",hiddenEvidence.gridPosition )
        --if fake ~= nil then
            --fake.destroyObject()
        --end

        if  fake ~= nil and hiddenEvidence ~= nil  then

            fake.destroyObject()
            narrative = narrative .. "\nOh great, you found evidence."
            --game.bus.send({ 'newNotification' })
            game.bus.send({
                metadata = { 'textNotificationUI.createOrUpdate' },
                data = {
                    id = "test",
                    titleTextKey = "Ghost",
                    mainTextKey = narrative,
                }
            }, nil, false)
            game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'FE' } }, false)
            waitMilliSeconds(2000)
        elseif  hiddenEvidence ~= nil  then

            if hiddenEvidence.tags.hasTag('ball') then
                print("Item name:", hiddenEvidence)
                create("A_ball")
            elseif hiddenEvidence.tags.hasTag('doll') then
                print("Item name:", hiddenEvidence)
                create("A_Doll")
            elseif hiddenEvidence.tags.hasTag('picture') then
                print("Item name:", hiddenEvidence)
                create("A_Cat_P")
            else
                print("Evidence is not recognised")
                --hiddenEvidence.destroyObject()
            end
        else
            fake.destroyObject()
            owner.destroyObject()
            narrative = narrative .. "\nOh no, the evidence box was empty."
            game.bus.send({ 'newNotification' })
            print("fake evidence to be narrative")
            game.bus.send({
                metadata = { 'textNotificationUI.createOrUpdate' },
                data = {
                    id = "test",
                    titleTextKey = "Ghost",
                    mainTextKey = narrative,
                }
            }, nil, false)
            waitMilliSeconds(2000)
        end


        foundEvidence = owner.getFirstNeighbouringObjectTagged("animatedEvidence")
        if foundEvidence ~= nil then
            foundEvidence.tags.addTag("carryable")
        end

        prompt = owner.getFirstNeighbouringObjectTagged("prompt")
        if prompt ~= nil then
            prompt.destroyObject()
        end
        Player.callFunc('act', Deriction)

        --owner.destroyObject()
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

    Deriction = actDirection
    Player = carrierOwner

    print("player", Player,"direction", Deriction)

    hiddenEvidence = owner.getFirstNeighbouringObjectTagged("evidence")
    fake = owner.getFirstNeighbouringObjectTagged("EvidenceBox")
    if hiddenEvidence == nil  then
        hiddenEvidence = owner.getFirstNeighbouringObjectTagged("key" )
    end
    print("key", hiddenEvidence)
    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then

        owner.destroyObject()
        return true

    -- Checking if we are interacting with the key, which later will be evidence
    elseif hiddenEvidence ~= nil or fake ~= nil then
        print("keyLocalVar Method")
        keyCarryable()
        return true
    end
    -- There's no empty floor or could not put down
    return false
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase

    if phase == 'acting' then
        narrative = ""
        game.bus.send({ 'newNotification' })
    end

end

game.bus.subscribe('gamePhase', onGamePhaseChanged)


