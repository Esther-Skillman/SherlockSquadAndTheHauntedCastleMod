

local game = LoadFacility('Game')['game']

local owner = owner or error('No owner')

local Log = require('Log')
local log = Log.new()

---@type Loader
local loader = game.loader or error('No loader')
local MessageHelpers = require('MessageHelpers')

local block
local block2

local move4 =  {"4", "south","2","east","4","north","2","west"} --test case basic move ghost move reset when reach the start floor at the start of the new phase
local move1 =  {"3", "south","2","east","3","north","2","west"} --test case reset when reach the start floor during the current phase
local move2 =  {"9", "east","2","south","9","west","2","north"} --test case Icunter bigger then array length
local move3 =  {}--test case empty array
local move = moves or {}--test case get the move array from the level itself

local count = 1
local nextMove = 1
local Icounter = 1

local function ghostMove()
    --local direction = DirectionUtils.move[count+1]
    --print("dirction is ", DirectionUtils.move[count+1])
    owner.setFacing(move[count+1])
    block = owner.getFirstNeighbouringObjectTagged("blocksMove")
    --if block.tags.hasTag("evidence")  then
        --block2 = owner.getFirstNeighbouringObjectTagged("EvidenceBox")
        --if block2 then
            --block2.tags.removeTag("blocksMove")
        --end
    --elseif block.tags.hasTag("EvidenceBox") then
        --block2 = owner.getFirstNeighbouringObjectTagged("evidence")
        --if block2 then
            --block2.tags.removeTag("blocksMove")
        --end
    --end

    if block ~= nil then
        block.tags.removeTag("blocksMove")
    end
    if  #move ~= 0 then
        print("dirction is ",move[count+1])
        if move[count+1] ~= #move and move[count+1] ~= nil then
            owner.move1SpaceIfPossible(move[count+1])
        else
            print("max of the array")
        end
    end
end

local function reset()
    Icounter = 1
    count = 1
    print("count rest", count, "icounter reast", Icounter)
end

local function loopMax()
    local max = 0
    for _, value in ipairs(move) do
        local number = tonumber(value)
        if number then
            max = max + number
        end
    end
    return max
end


local function RoundMove()
    local limit = loopMax()
    print("limit ", limit)
    if #move ~= 0 and limit ~= 0 then
        for i = Icounter, limit do
            if nextMove ~= 5 and tonumber(move[count])  < Icounter and count < #move - 1  then

                count = count + 2
                print("phase count is ",count , "Icounter", Icounter," i ", i)
                Icounter = 1
                i = Icounter
                print("phase count is ",count , "Icounter", Icounter," i ", i)
            end
            print("compare ",tonumber(move[count]) + 1 )
            if count == #move - 1 and Icounter == tonumber(move[count]) + 1 then
                print("reset")
                reset()
            end
            if nextMove == 5 then
                break
            end
            ghostMove()
            Icounter = Icounter + 1
            i = Icounter
            nextMove = nextMove + 1
            if block ~= nil then
                block.tags.addTag("blocksMove")
                block = nil
            end
            --if block2 ~= nil then
               -- block2.tags.addTag("blocksMove")
                --block2 = nil
            --end
        end
    end

end



local function onGamePhaseChanged(message)
    local phase = message.data.gamePhase;
    log:debug('Game phase: "', phase, '"')
    print("move max is  ",#move)
    print("phase is ",phase)
    --print("phase count is ",count, "move", #move - 1)
    --print("Icounter", Icounter ,"move ",tonumber(move[count])  + 1 )
    if phase == 'acting' then
        if move ~= nil and #move ~= 0 then
            if Icounter == tonumber(move[count]) + 1 and count < #move - 1 then

                count = count + 2
                print("phase count is ",count, "Icounter", Icounter)
                Icounter = 1
            end
            if count == #move - 1 and Icounter == tonumber(move[count]) + 1 then
                print("reset")
                reset()
            end
            nextMove = 1
            RoundMove()
        end
        return
    end
end

game.bus.subscribe('gamePhase', onGamePhaseChanged)

