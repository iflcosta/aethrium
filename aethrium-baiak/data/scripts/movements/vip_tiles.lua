-- VIP Area — Movement restriction
-- Place tiles in RME with the Action IDs below to restrict access by tier
--
-- Action IDs:
--   50010 = requires any VIP (tier >= 1)
--   50011 = requires VIP Silver or Gold (tier >= 2)
--   50012 = requires VIP Gold only (tier == 3)

local VIP_TILES = {
    [50010] = { minTier = 1, name = "VIP" },
    [50011] = { minTier = 2, name = "VIP Silver" },
    [50012] = { minTier = 3, name = "VIP Gold" },
}

local movement = MoveEvent()

function movement.onStepIn(creature, item, position, fromPosition)
    local player = creature:getPlayer()
    if not player then return true end

    local config = VIP_TILES[item:getActionId()]
    if not config then return true end

    if not player:isVip() or player:getVipTier() < config.minTier then
        player:sendTextMessage(MESSAGE_STATUS_SMALL,
            string.format("You need %s to access this area.", config.name))
        player:teleportTo(fromPosition, true)
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    return true
end

for actionId, _ in pairs(VIP_TILES) do
    movement:aid(actionId)
end
movement:register()
