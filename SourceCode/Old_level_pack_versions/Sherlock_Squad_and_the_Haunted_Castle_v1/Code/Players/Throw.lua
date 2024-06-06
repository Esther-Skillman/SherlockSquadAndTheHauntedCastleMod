-- Throw

-- Action called by the "throw" action from the 'phone' controller
function throw(direction)
    print('Acting getting actor from owner', owner)
    coOpActor = owner.getFirstComponentTagged("CoOpActor", SearchType.SelfOnly)
    print('Modding throwing', direction, 'for owner', owner, 'with actor', coOpActor)

    local result = coOpActor.throwInDirection(direction)
    -- only return a value if we succeeded (so other things can be tried otherwise)
    if result then
        return true
    end
end

print('Throw mod ready for', owner)
