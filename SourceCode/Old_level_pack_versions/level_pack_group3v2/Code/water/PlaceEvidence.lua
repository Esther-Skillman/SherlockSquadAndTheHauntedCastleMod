--@type MapMobile
local owner = owner or error('No owner')

local Log = require('Log')
---Default to normal 'log' level unless
local logLevel = --[[---@type number]] (logLevel or Log.LevelLog)
local log = Log.new(logLevel)
log:debug("Dispenser loaded")

local game = LoadFacility('Game')['game']

---@type table<number, string>
local prefabToNameMap = {}

local loader = game.loader or error('No loader')

local CarryHelper = require('CarryHelper')
local Neighbour

--finds object with ghost tag, in this case 'ghost-original' to run releaseGhost function in Ghost.lua
local function findGhost()
    ghost = game.map.getFirstObjectTagged('ghost_original')
    print("ghost: ",ghost )
    
    if ghost.hasFunc('releaseGhost') then
        log:log('Calling releaseGhost on ghost object')
        success = ghost.callFunc('releaseGhost')
        print("success is ", success)
    else
        log:log("No 'releaseGhost' function on ", ghost)
        success = false
    end
    return true
end

local function evidenceTable(name)

    owner.destroyObject()

    log:debug('Attempting to create ', name, ' at ', Neighbour.gridPosition)
    local newInstance = --[[---@type MapMobile]] loader.instantiate(name, Neighbour.gridPosition)
    prefabToNameMap[newInstance.id] = name
    log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', name, '")')
    print('evidence placed on the table successfully.')
    Neighbour.destroyObject()
    
end

local function placeEvidence()

    if owner.tags.hasTag('evidence') and owner.tags.hasTag('doll') then
        if Neighbour.tags.hasTag('ball') and Neighbour.tags.hasTag('picture') then
            evidenceTable("table_all_evidence")
            findGhost()

        elseif Neighbour.tags.hasTag('picture') then
            evidenceTable("table_picture_doll")
            return true

        elseif Neighbour.tags.hasTag('ball') then
            evidenceTable("table_doll_ball")
            return true

        elseif Neighbour.tags.hasTag('empty') then
            evidenceTable("table_doll")
            return true

        else
            return false
        end

    elseif owner.tags.hasTag('evidence') and owner.tags.hasTag('ball') then
        if Neighbour.tags.hasTag('doll') and Neighbour.tags.hasTag('picture') then
            evidenceTable("table_all_evidence")
            findGhost()

        elseif Neighbour.tags.hasTag('picture') then
            evidenceTable("table_ball_picture")
            return true

        elseif Neighbour.tags.hasTag('doll') then
            evidenceTable("table_doll_ball")
            return true

        elseif Neighbour.tags.hasTag('empty') then
            evidenceTable("table_ball")
            return true

        else
            return false
        end

    elseif owner.tags.hasTag('evidence') and owner.tags.hasTag('picture') then
        if Neighbour.tags.hasTag('doll') and Neighbour.tags.hasTag('ball')  then
            evidenceTable("table_all_evidence")
            findGhost()

        elseif Neighbour.tags.hasTag('ball') then
            evidenceTable("table_ball_picture")
            return true

        elseif Neighbour.tags.hasTag('doll') then
            evidenceTable("table_picture_doll")
            return true

        elseif Neighbour.tags.hasTag('empty') then
            evidenceTable("table_picture")
            return true

        else
            return false
        end

    else
        print("not recognised type of evidence")
        return false
    end

end

--for placeing the object down
function actWhenCarried(carrierOwner, carrier, actDirection)
    assert(nil ~= carrierOwner, 'No carrierOwner')
    assert(nil ~= carrier, 'No carrier')
    assert(nil ~= actDirection, 'No actDirection')

    Neighbour = owner.getFirstNeighbouringObjectTagged("evidenceTable")
    print("Neighbour", Neighbour)

    -- If there is empty floor with nothing blocking us, drop the tray
    if CarryHelper.placeDownIfClearInFront(carrierOwner, carrier, actDirection) then
        return true
    end
    print("it is ",owner.getFirstNeighbouringObjectTagged("evidenceTable"))

    if Neighbour ~= nil and Neighbour.tags.hasTag('evidenceTable') then
        if Neighbour.tags.hasTag('doll') and owner.tags.hasTag('doll') then
            return false
        elseif Neighbour.tags.hasTag('ball') and owner.tags.hasTag('ball') then
            return false
        elseif Neighbour.tags.hasTag('picture') and owner.tags.hasTag('picture') then
            return false
        end

        return placeEvidence()
    end
    -- There's no empty floor or could not put down
    return false
end






