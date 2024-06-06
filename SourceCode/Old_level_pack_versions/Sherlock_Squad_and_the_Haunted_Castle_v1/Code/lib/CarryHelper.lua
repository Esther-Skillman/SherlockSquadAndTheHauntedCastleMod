---Utilities for carrying
---
local Vector = require('Vector')

local CarryHelper = {}

---Place down the currently carried item in the direction and return whether succeeded.
---@param carryingOwner MapMobile
---@param carrier Carrier
---@param direction DirectionName
---@return boolean
function CarryHelper.placeDownIfClearInFront(carryingOwner, carrier, direction)
	-- If there is empty floor with nothing blocking us, place carried item down
	local noMoveBlocker = carryingOwner.getFirstFacingObjectTagged('blocksMove') == nil
	-- (Shrunk things don't block movement, but do not allow things to be placed on top of them, to prevent e.g. multiple beds/cabinets in a single tile)
	local noShrunkObject = carryingOwner.getFirstFacingObjectTagged('shrunk') == nil
	local hasFloor = carryingOwner.getFirstFacingObjectTagged('floor') ~= nil
	if noMoveBlocker and noShrunkObject and hasFloor then
		local dropPos = Vector.new(carryingOwner.gridPosition) + Vector.directionNameToVector(direction)
		return carrier.endCarry(dropPos) -- success or not
	end

	return false
end

---Place down the currently carried item on carrier's position and return whether succeeded.
---@param carrier Carrier
---@return boolean
function CarryHelper.endCarryWithoutPlacing(carrier)
	return carrier.endCarry()
end

---Attempt to get the carrier at the given position (or nil).
---@param position Pos
---@return Carrier|nil
function CarryHelper.getCarrierAtPosition(position)
	local carrierObjs = owner.map.getAllTagged(position, 'carrier')
	for carrierObj in carrierObjs do
		local carrierComp = carrierObj.getFirstComponentTagged('carrier')
		if carrierComp ~= nil then
			return carrierComp
		end
	end
	return nil
end

---Cease carrying by passing it to the supplied 'acceptor'.
---@param carrier Carrier
---@param acceptorMapObject MapObject @ Should have an acceptor component which accepts the item currently carried.
---@return boolean
function CarryHelper.endIntoAcceptorMapObject(carrier, acceptorMapObject)
	local acceptor = acceptorMapObject.getFirstComponentTagged('acceptor')
	assert(nil ~= acceptor, "No acceptor on " .. tostring(acceptorMapObject))
	return carrier.endCarryInto(acceptor)
end

return CarryHelper
