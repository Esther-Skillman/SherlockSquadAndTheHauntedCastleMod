-- GameManagerLua
-- Monitors for `ghost.released`, counts patients remaining and finishes the level once all done.
-- Finishes the level by sending the `level.won` message.

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

---@type Game
local game = LoadFacility('Game')['game']

local subscriptionHelper = require('SubscriptionHelper').new(game.bus)

local Log = require('Log')
local log = Log.new()

---@type string
local currentGamePhase

local numGhostsAtStart = 0
local numGhostsReleased = 0
local numGhostsDied = 0

local function removeNotification()
	game.bus.send({'textNotificationUI.destroyAll'}, nil, false)
end

-- Start music
game.bus.send({ metadata = { 'playMusic' }, data = { soundName = 'BackgroundMusic' } }, false)
game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'throw' } }, false)
game.bus.send({ metadata = { 'playSound' }, data = { soundName = 'Walk' } }, false)

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

		subscriptionHelper:unsubscribeAll()
		-- You win if you cured more (since you can still cure patients who have passed-out)
		local wonMessage = { metadata = { 'level.won' }, data = { patientsCured = numGhostsReleased, patientsTotal = numGhostsAtStart } }
		local lostMessage = { metadata = { 'level.lost' }, data = { patientsCured = numGhostsReleased, patientsTotal = numGhostsAtStart } }
		local didWin = numGhostsReleased > numGhostsDied;
		local endingMessage = didWin and wonMessage or lostMessage
		--print('All ghosts done: '.. numGhostsReleased ..' released, '.. numGhostsDied ..' died = Finishing the level with', endingMessage)
		log:log('All ghosts done: '.. numGhostsReleased ..' released, '.. numGhostsDied ..' died = Finishing the level with', endingMessage)
		game.bus.send(endingMessage)


		if numGhostsReleased > numGhostsDied then
			game.bus.send({'level.next'})
		else
			game.bus.send({'level.reload'})
	    end
		--log:log('GameManager.lua sending `level.results`!')
		--game.bus.send({'level.results'})
	else
		--print('Level still in-progress')
		log:log('Level still in-progress')
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

local function onGamePhaseChanged(message)
	local phase = message.data.gamePhase
	if phase == nil then
		print('No phase data in gamePhase message!')
	end
	print('currentGamePhase:(', currentGamePhase, '->', phase, ')')
	currentGamePhase = phase
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
game.bus.send({
	metadata = { 'textNotificationUI.configureDisplay' },
	data = {
		onScreenLimit = 2,
		replaceIfMaxExceeded = true,
		reversDisplayOrder = false,
		scrollDelay = 3
	}
}, nil, false)
game.bus.send({
	metadata = { 'textNotificationUI.createOrUpdate' },
	data = {
		id = "test1",
		titleTextKey = "mod",
		mainTextKey = "welcome to the ghost mod",
	}
}, nil, false)

game.bus.subscribe('gameManager', onGameManagerEventReceived)

-- subscribe to know when a ghost is released
game.bus.subscribe('ghost.released', onGhostReleased)
game.bus.subscribe('ghost.died', onGhostDied)
game.bus.subscribe('gamePhase', onGamePhaseChanged)
game.bus.subscribe('newNotification', removeNotification)

--Do all the subscriptions
--subscriptionHelper:subscribeAll()
