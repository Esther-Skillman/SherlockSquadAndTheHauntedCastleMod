-- Move mod

-- Action called by the "move" action from the 'phone' controller
function move(direction)
	print('Modding moving', direction, 'with owner', owner)

	-- Cannot do own movement by checking target space because resolution is more complex
	local result = owner.move1SpaceIfPossible(direction)
	-- only return a value if we succeeded (so other things can be tried otherwise)
	if result then
		print('Modding moved', direction, 'with owner', owner, 'SUCCEEDED')
		return true
	else
		print('Modding moved', direction, 'with owner', owner, 'FAILED')
		return false
	end
end

print('Move mod ready for', owner)
