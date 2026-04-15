-- Battle Pass — Loot tracker
-- Detects when a player moves an item from a ground container (corpse, chest)
-- into their own inventory hierarchy.
--
-- Detection logic:
--   fromPosition.x != 65535  → source is at a real world position (ground container)
--   toPosition.x   == 65535  → destination is inside the player's inventory tree
--
-- Registration: EventCallback fires globally; no onLogin hook needed.

local INVENTORY_X = 65535  -- TFS container-position sentinel value

local ec = Event()

function ec.onMoveItem(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
    if not player or not player:isPlayer() then return true end

    -- Source must be a real-world tile (ground container / corpse).
    if fromPosition.x == INVENTORY_X then return true end

    -- Destination must be inside the player's inventory (backpack/slot).
    if toPosition.x ~= INVENTORY_X then return true end

    BattlePass.updateDailyTask(player, "loot_item", count)
    return true
end

ec:register()
