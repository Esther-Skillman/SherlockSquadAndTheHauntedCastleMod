-- Build the function here for magGlass / evidence interaction

-- the following 4 lines might not be needed
---@type Game
local game = LoadFacility('Game')['game']
---@type Loader
local loader = game.loader or error('No loader')

-- when you define magGlass in LevelShared.yaml I will need to add the end tag 'mods: [{name: MagGlass}]'
-- magGlass being the name of this folder for the object in LevelShared file to call the function
-- from this file
local owner = owner or error('No owner')


--local function onSiblingAdded(message)
-- code the function here
-- using a print statement to test and debug
--    print('Test')
--end

local function onSiblingAdded(message)
            print("Hello world!")
    -- Assuming the message contains information about the added sibling
    local addedObject = message.object
            print("Hello world!2", addedObject)
    -- Check if the added object is the key and has the "bed" tag
    local bed = owner.map.getFirstTagged(owner.gridPosition, 'MagGlasses')
            print("Hello world!3", bed)
            print("The owner is ", owner)            
    if bed ~= nil then

        owner.tags.addTag("carryable")
        print("Is owner carryable", owner.tags.hasTag("carryable"))
        print("Key is carryable")

    else
        print("Object is null!")

    end

end


-- this line should be at the very end
-- when 2 objects occupy the same position, the first object (i.e. magGlass) is destroyed
owner.tags.removeTag("carryable")
owner.bus.subscribe('siblingAdded', onSiblingAdded)