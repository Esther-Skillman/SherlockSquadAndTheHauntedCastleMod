---@type Game
local game = LoadFacility('Game')['game']

local NarrativeSaveDataKeys = require('NarrativeSaveDataKeys')

local Log = require('Log')
local log = Log.new()

---@type MapMobile
local owner = owner or error('No owner')

local function clearRoundSpecificNarrativeSaveData()
    local keys = NarrativeSaveDataKeys.getAllKeysToClearOnNewRound()
    for key in keys do
        log:log('Deleting round-specific save data with key "' .. key .. '"')
        game.saveData.delete(key)
    end
end

local function clearLevelSpecificNarrativeSaveData()
    local keys = NarrativeSaveDataKeys.getAllKeysToClearOnNewLevel()
    for key in keys do
        log:log('Deleting level-specific save data with key "' .. key .. '"')
        game.saveData.delete(key)
    end
end

local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase
	if phase == nil then
		error('No phase data in gamePhase message!')
	end
    if phase == 'acting' then
        clearRoundSpecificNarrativeSaveData()
    end
end

-- MAIN

-- Clear any leftover narrative-related save data from a previous level
clearRoundSpecificNarrativeSaveData()
clearLevelSpecificNarrativeSaveData()

tags.addTag('NarrativeManager')
owner.tags.addTag('NarrativeManager')

log:log('NarrativeManager lua started')

game.bus.subscribe('gamePhase', onGamePhaseChanged)