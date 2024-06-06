
local game = LoadFacility('Game')['game']

local owner = owner or error('No owner')

local evidence = owner.map.getFirstTagged(owner.gridPosition, 'evidence')

if evidence ~= nil then
    owner.tags.removeTag("blocksMove")
end