-- GameManagerLua
-- Monitors for `ghost.released`, counts patients remaining and finishes the level once all done.
-- Finishes the level by sending the `level.won` message.

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

---@type string
local currentGamePhase

local numGhostsAtStart = 0
local numGhostsReleased = 0
local numGhostsDied = 0

local function onGamePhaseChanged(message)
	local phase = message.data.gamePhase
	if phase == nil then
		print('No phase data in gamePhase message!')
	end
	print('currentGamePhase:(', currentGamePhase, '->', phase, ')')
	currentGamePhase = phase
end

local function getNumGhostsRemaining()
	local iterator = game.map.getAllObjectsTagged('ghost')
	-- This gives an iterator so we iterate it and count how many there are
	local count = 0
	for _ in iterator do
		count = count + 1
	end
	return count
end

local function checkEnding()
	local numGhostsRemaining = getNumGhostsRemaining()
	print('Found '.. numGhostsRemaining ..' ghosts remaining')
	if 0 >= numGhostsRemaining then
		-- You win if you cured more (since you can still cure patients who have passed-out)
		local didWin = numGhostsReleased > numGhostsDied;
		local endingMessage = didWin and {'level.won'} or {'level.lost'}
		print('All ghosts done: '.. numGhostsReleased ..' released, '.. numGhostsDied ..' died = Finishing the level with', endingMessage)
		game.bus.send(endingMessage)
	else
		print('Level still in-progress')
	end
end

local function onGhostReleased()
	numGhostsReleased = numGhostsReleased + 1
	print("game recognises ghost released")
	checkEnding()
end

local function onGhostDied()
	numGhostsDied = numGhostsDied + 1
	checkEnding()
end

local function onGameManagerEventReceived(message)
	-- No longer used at 2022/10/24
	if message.data.gameManager == 'ghost.released' then
		onGhostReleased()
	else
		error('GameManager needs updating to handle:'.. tostring(message))
	end
end

numGhostsAtStart = getNumGhostsRemaining()
print('Found ' .. numGhostsAtStart ..' ghosts at start')

-- subscribe to get informed when sent messages (not used as of 2022/10/24)
game.bus.subscribe('gameManager', onGameManagerEventReceived)

-- subscribe to know when a ghost is released
game.bus.subscribe('ghost.released', onGhostReleased)
game.bus.subscribe('ghost.died', onGhostDied)
game.bus.subscribe('gamePhase', onGamePhaseChanged)