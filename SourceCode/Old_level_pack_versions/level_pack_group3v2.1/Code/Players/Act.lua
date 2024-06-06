-- Act

-- Action called by the "act" action from the 'phone' controller
-- If not handled by this function, might be handled by something else (carried item)
function act(actDirection)
    print('Acting getting actor from owner', owner)
    local coOpActor = owner.getFirstComponentTagged("CoOpActor", SearchType.SelfOnly)
    print('Acting with actor', coOpActor, 'in direction', actDirection)
    -- return success at either carrying or applying to neighbour (placing patient in bed)
    local result = coOpActor.carryOrApplyToNeighbour(actDirection)
    print('Result of acting with actor', result)
    -- only return a value if we succeeded (so other things can be tried otherwise)
    if result then
        return true
    end
end

print('Act mod ready for', owner)
