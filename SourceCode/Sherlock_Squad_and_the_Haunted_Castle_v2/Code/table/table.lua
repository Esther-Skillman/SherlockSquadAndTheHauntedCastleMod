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

local evidence


local function evidenceTable(name)

    owner.destroyObject()

    log:debug('Attempting to create ', name, ' at ', owner.gridPosition)
    local newInstance = --[[---@type MapMobile]] loader.instantiate(name, owner.gridPosition)
    prefabToNameMap[newInstance.id] = name
    log:debug('Created ', newInstance, ' (mapped "', newInstance.id, '" to "', name, '")')
    print('evidence placed on the table successfully.')

end

local function onSiblingAdded(message)

    evidence = owner.map.getFirstTagged(owner.gridPosition, 'evidence')

    if evidence ~= nil and owner.tags.hasTag('evidenceTable') and owner.tags.hasTag('table_all_evidence') == false then
        if  evidence.tags.hasTag('doll') then

            if owner.tags.hasTag('table_ball') then
                evidenceTable("table_doll_ball")

            elseif owner.tags.hasTag('table_picture') then
                evidenceTable("table_picture_doll")

            elseif owner.tags.hasTag('table_ball_picture') then
                evidenceTable("table_all_evidence")

            elseif owner.tags.hasTag('table_doll_ball') == false and owner.tags.hasTag('table_picture_doll') == false then
                evidenceTable("table_doll")
            end

        elseif evidence.tags.hasTag('ball') then

            if owner.tags.hasTag('table_doll') then
                evidenceTable("table_doll_ball")

            elseif owner.tags.hasTag('table_picture') then
                evidenceTable("table_ball_picture")

            elseif owner.tags.hasTag('table_picture_doll') then
                evidenceTable("table_all_evidence")

            elseif owner.tags.hasTag('table_doll_ball') == false and owner.tags.hasTag('table_ball_picture') == false then
                evidenceTable("table_ball")
            end

        elseif evidence.tags.hasTag('picture') then

            if owner.tags.hasTag('table_doll') then
                evidenceTable("table_picture_doll")

            elseif owner.tags.hasTag('table_ball') then
                evidenceTable("table_ball_picture")

            elseif owner.tags.hasTag('table_doll_ball') then
                evidenceTable("table_all_evidence")

            elseif owner.tags.hasTag('table_picture_doll') == false and owner.tags.hasTag('table_ball_picture') == false then
                evidenceTable("table_picture")
            end


        else
            print("not recognised type of evidence")
        end
    end
end



owner.bus.subscribe('siblingAdded', onSiblingAdded)
