local Log = require('Log')
---Default to normal 'log' level unless
local logLevel = --[[---@type number]] (logLevel or Log.LevelLog)
local log = Log.new(logLevel)
log:debug("Dispenser loaded")

local owner = owner or error('No owner')

local game = LoadFacility('Game')['game']

local CarryHelper = require('CarryHelper')
---@type table<number, string>
local prefabToNameMap = {}

local loader = game.loader or error('No loader')

local water
local pill

--note error when placing or throwing the water on the tary
--water still nil
local function linkWaterCupToTray()
    local addWater = 'tray_water'

    --water = owner.map.getFirstTagged(owner.gridPosition, 'water')
    print("Water:", water )
    if water ~= nil  then
        --destroy the tray when place the water
        owner.destroyObject()

        water = nil
        print("Water:", water )
        log:debug('Attempting to create ', addWater, ' at ', owner.gridPosition)
        local newInstance = --[[---@type MapMobile]] loader.instantiate(addWater, owner.gridPosition)
        prefabToNameMap[newInstance.id] = addWater
        log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', addWater, '")')
        print('Water cup linked to tray successfully.')
    else
        print("Failed to instantiate tray or water.")
    end

end

local function linkPillToTray()
    local addPill = 'tray_pill'

    print("pill:", pill )
    if pill ~= nil  then
        --destroy the tray when place the water
        owner.destroyObject()

        pill = nil
        print("pill:", pill )
        log:debug('Attempting to create ', addPill, ' at ', owner.gridPosition)
        local newInstance = --[[---@type MapMobile]] loader.instantiate(addPill, owner.gridPosition)
        prefabToNameMap[newInstance.id] = addPill
        log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', addPill, '")')
        print('pill linked to tray successfully.')
    else
        print("Failed to instantiate tray or pill.")
    end

end

local function medicineTray()
    local addMedicine = 'tray_water_pill'

    owner.destroyObject()
    log:debug('Attempting to create ', addMedicine, ' at ', owner.gridPosition)
    local newInstance = --[[---@type MapMobile]] loader.instantiate(addMedicine, owner.gridPosition)
    prefabToNameMap[newInstance.id] = addMedicine
    log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', addMedicine, '")')
    print('pill linked to tray successfully.')

end

--for placeing the object down
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')
    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        return true
    end

    -- There's no empty floor or could not put down, try administering the medicine instead
    return administer()
end

local function onSiblingAdded(message)
    local player = owner.map.getFirstTagged(owner.gridPosition, 'Player')
    print("Player details:", player)
    water = owner.map.getFirstTagged(owner.gridPosition, 'water')
    pill = owner.map.getFirstTagged(owner.gridPosition,'pill')
    print('Am I a patient:', owner.tags.hasTag('patient'))


    if  water ~= nil and owner.tags.hasTag('tray') then
        linkWaterCupToTray()
    elseif pill ~= nil and owner.tags.hasTag('tray') then
        linkPillToTray()
    elseif owner.tags.hasTag('trayW')  and pill ~= nil then
        medicineTray()
    elseif owner.tags.hasTag('trayP')  and water ~= nil then
        medicineTray()
    else
        print("Failed to instantiate tray or water.")
    end
end



owner.bus.subscribe('siblingAdded', onSiblingAdded)
