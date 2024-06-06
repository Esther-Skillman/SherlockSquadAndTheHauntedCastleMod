﻿--- Include a delay per turn
--- Without, actions occur as soon as longest animation complets.
LoadFacility('Game')

-- Set-up the remedy if not supplied by JSON data
delayPerTurn = delayPerTurn or 1000

local function onTurnStart(message)
	local turnNumber = message.data.turnNumber;
	print('Delay ', delayPerTurn, 'milliseconds for turn', turnNumber)
	waitMilliSeconds(delayPerTurn)
	print('Delay for turn ', turnNumber, 'done')
end

local function onViewMode(message)
	local mode = message.data.viewMode;
	if ("none" == mode) then
		print('Disabling delayPerTurn when view absent.')
		delayPerTurn = 0
	end
end

game.bus.subscribe('viewMode', onViewMode)
game.bus.subscribe('turnStart', onTurnStart)
