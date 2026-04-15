-- Battle Pass — Rastreador de abates para Daily Tasks
-- Usa CreatureEvent tipo "kill" (padrao do projeto)
-- Requer player:registerEvent("BattlePassOnKill") no onLogin

local creatureEvent = CreatureEvent("BattlePassOnKill")

function creatureEvent.onKill(player, target, lastHit)
    -- Ignorar se o alvo nao e monstro ou se nao foi o ultimo golpe
    if not target or not target:isMonster() then return true end
    if not lastHit then return true end

    -- Tarefa generica de abate
    BattlePass.updateDailyTask(player, "kill", 1)

    -- Tarefa especifica de boss
    local monsterType = target:getMonster():getType()
    if monsterType and monsterType:isBoss() then
        BattlePass.updateDailyTask(player, "kill_boss", 1)
    end

    return true
end

creatureEvent:type("kill")
creatureEvent:register()
