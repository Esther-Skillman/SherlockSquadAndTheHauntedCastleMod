-- GameManagerLua
-- Monitors for `patient.cured`, counts patients remaining and finishes the level once all done.
-- Finishes the level by sending the `level.won` message.

-- Bring in the ability to subscribe to the GameManager's message bus for game phase changes
LoadFacility('Game')

local numPatientsAtStart = 0
local numPatientsCured = 0
local numPatientsDied = 0

local function getNumPatientsRemaining()
	local iterator = game.map.getAllObjectsTagged('patient')
	-- This gives an iterator so we iterate it and count how many there are
	local count = 0
	for _ in iterator do
		count = count + 1
	end
	return count
end

local function checkEnding()
	local numPatientsRemaining = getNumPatientsRemaining()
	print('Found '.. numPatientsRemaining ..' patients remaining')
	if 0 >= numPatientsRemaining then
		-- You win if you cured more (since you can still cure patients who have passed-out)
		local didWin = numPatientsCured > numPatientsDied;
		local endingMessage = didWin and {'level.won'} or {'level.lost'}
		print('All patients done: '.. numPatientsCured ..' cured, '.. numPatientsDied ..' died = Finishing the level with', endingMessage)
		game.bus.send(endingMessage)
	else
		print('Level still in-progress')
	end
end

local function onPatientCured()
	numPatientsCured = numPatientsCured + 1
	checkEnding()
end

local function onPatientDied()
	numPatientsDied = numPatientsDied + 1
	checkEnding()
end

local function onGameManagerEventReceived(message)
	print('GameManager received:', message)
	-- No longer used at 2022/10/24
	if message.data.gameManager == 'patient.cured' then
		onPatientCured()
	else
		error('GameManager needs updating to handle:'.. tostring(message))
	end
end

numPatientsAtStart = getNumPatientsRemaining()
print('Found ' .. numPatientsAtStart ..' patients at start')

-- subscribe to get informed when sent messages (not used as of 2022/10/24)
game.bus.subscribe('gameManager', onGameManagerEventReceived)

-- subscribe to know when a patient is cured
game.bus.subscribe('patient.cured', onPatientCured)
game.bus.subscribe('patient.died', onPatientDied)
