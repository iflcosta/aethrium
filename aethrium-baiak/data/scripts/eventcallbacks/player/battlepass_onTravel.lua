-- Battle Pass — Travel & Deposit tracker
-- Exposes two module-level functions that NPC scripts can call:
--
--   BattlePass.trackTravel(player)   — call from boat/carpet NPC travel keyword
--   BattlePass.trackDeposit(player)  — call from bank/depot NPC deposit keyword
--
-- HOW TO INTEGRATE:
--   In your NPC travel script (e.g. data/npc/scripts/travel.lua), after a
--   successful travel purchase, add:
--       BattlePass.trackTravel(player)
--
--   In your NPC bank/depot script, after a successful deposit action, add:
--       BattlePass.trackDeposit(player)
--
-- These functions are defined here rather than in core.lua so that this file
-- can be omitted cleanly if the task types are not used.

function BattlePass.trackTravel(player)
    if not player or not player:isPlayer() then return end
    BattlePass.updateDailyTask(player, "travel", 1)
end

function BattlePass.trackDeposit(player)
    if not player or not player:isPlayer() then return end
    BattlePass.updateDailyTask(player, "deposit", 1)
end
