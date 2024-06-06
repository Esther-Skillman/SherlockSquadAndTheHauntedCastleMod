-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
---@type Game
local game = LoadFacility('Game')['game']
---@type MapMobile
local owner = owner or error('No owner')

print('Scoreboard lua script started')

local ghostIterator = game.map.getAllObjectsTagged('ghost')
-- This gives an iterator so we iterate it and count how many there are
local ghostsAtStart = 0
for _ in ghostIterator do
	ghostsAtStart = ghostsAtStart + 1
end

-- Counters
-- The number of ghosts who lost all health
local ghostsDied = 0
-- The number of ghosts waiting to be cured/yet to appear
local ghostsWaiting = ghostsAtStart
-- The number of ghosts who were cured
local ghostsReleased = 0

print('Scoreboard - ghosts waiting at start: ' .. ghostsWaiting)

local addDiedCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "died", value = ghostsDied } }
local addWaitingCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "waiting", value = ghostsWaiting } }
local addCuredCounterMsg = { metadata = { 'addCounter' }, data = { counterName = "cured", value = ghostsReleased } }
owner.bus.send(addDiedCounterMsg, nil, false)
owner.bus.send(addWaitingCounterMsg, nil, false)
owner.bus.send(addCuredCounterMsg, nil, false)

local function onGhostReleased(message)
	local ghostPos = message.data.position;

	print('Scoreboard onGhostReleased')

	ghostsReleased = ghostsReleased + 1
	ghostsWaiting = ghostsWaiting - 1

	local setCuredCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'cured', value = ghostsReleased, originPos = ghostPos } }
	owner.bus.send(setCuredCounterMsg, nil, false)

	local setWaitingCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'waiting', value = ghostsWaiting } }
	owner.bus.send(setWaitingCounterMsg, nil, false)
end

local function onGhostDied(message)
	local ghostPos = message.data.position;

	print('Scoreboard onGhostDied with pos ' .. tostring(ghostPos))

	ghostsDied = ghostsDied + 1
	ghostsWaiting = ghostsWaiting - 1

	local setDiedCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'died', value = ghostsDied, originPos = ghostPos } }
	owner.bus.send(setDiedCounterMsg, nil, false)

	local setWaitingCounterMsg = { metadata = { 'setCounter' }, data = { counterName = 'waiting', value = ghostsWaiting } }
	owner.bus.send(setWaitingCounterMsg, nil, false)
end

local function onGamePhaseChanged(message)
	local phase = message.data.gamePhase
	if phase == 'finished' then
		return
	end

	-- Hide scoreboard in management results phase
	if phase == 'managementResults' then
		owner.bus.send({ visible = false }, nil, false)
	else
		owner.bus.send({ visible = true }, nil, false)
	end
end

-- subscribe to know when a ghost is cured/loses all health

game.bus.subscribe('ghost.released', onGhostReleased)
game.bus.subscribe('ghost.died', onGhostDied)
game.bus.subscribe('gamePhase', onGamePhaseChanged)
