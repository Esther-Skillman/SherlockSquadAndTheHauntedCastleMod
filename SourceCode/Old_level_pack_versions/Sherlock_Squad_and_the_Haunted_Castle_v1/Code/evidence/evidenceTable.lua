
local game = LoadFacility('Game')['game']

local owner = owner or error('No owner')

local linkGhost = linkGhost
print("table special num is: ", linkGhost, "postion: ", owner.gridPosition)

function created(link)
    linkGhost = link
    return link
end

function getLink()
    print("table special num is: ", linkGhost)
    return linkGhost
end