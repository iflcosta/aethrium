-- ============================================================
-- Aethrium Instance System — Eventos de Instância
-- Registra todos os CreatureEvents relacionados a Hunt e Boss Room.
-- Separado do lib/ porque CreatureEvent só pode ser registrado
-- dentro de data/scripts/, após o engine inicializar a API.
-- ============================================================

-- ── Morte do Boss ─────────────────────────────────────────────

local bossDeathEvent = CreatureEvent("BossRoomOnDeath")
function bossDeathEvent.onDeath(creature, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
    local instanceId = creature:getInstanceId()
    if instanceId == 0 then return true end

    local data = BossRoom.activeInstances[instanceId]
    if not data or data.bossDefeated then return true end

    data.bossDefeated = true

    if data.timerId then
        stopEvent(data.timerId)
        data.timerId = nil
    end

    local boss = BossRoom.getBoss(data.bossId)
    if not boss then return true end

    local damageMap = creature:getDamageMap()

    for _, spec in ipairs(BossRoom.getInstanceSpectators(instanceId)) do
        if spec:isPlayer() and spec:getInstanceId() == instanceId then
            if damageMap[spec:getId()] then
                spec:addTaskPoints(boss.pointsReward)
                spec:sendTextMessage(MESSAGE_EVENT_ORANGE,
                    string.format("[Boss Room] Parabens! Voce derrotou %s e ganhou %d Task Points!",
                    boss.bossName, boss.pointsReward))
            end
        end
    end

    -- Encerra a instância 30s após a morte (tempo de pegar loot)
    addEvent(function(iid)
        if not BossRoom.activeInstances[iid] then return end
        BossRoom.expelAllPlayers(iid, "[Boss Room] A sala esta fechando. Ate a proxima!")
        BossRoom.cleanupInstance(iid)
    end, 30000, instanceId)

    return true
end
bossDeathEvent:type("death")
bossDeathEvent:register()

-- ── Logout dentro de instância ────────────────────────────────

local instanceLogout = CreatureEvent("InstanceLogout")
function instanceLogout.onLogout(player)
    local instanceId = player:getInstanceId()
    if instanceId == 0 then return true end

    HuntSystem.removePlayer(player)
    BossRoom.removePlayer(player)

    return true
end
instanceLogout:register()

-- ── Login: limpa instanceId residual de crash/reconexão ───────

local instanceLogin = CreatureEvent("InstanceLogin")
function instanceLogin.onLogin(player)
    player:registerEvent("InstanceLogout")

    local instanceId = player:getInstanceId()
    if instanceId ~= 0 then
        player:setInstanceIdRaw(0)
        addEvent(function()
            if player and player:isOnline() then
                player:teleportTo(player:getTown():getTemplePosition())
                player:sendTextMessage(MESSAGE_EVENT_ORANGE,
                    "[Instancia] Voce foi removido de uma instancia anterior.")
            end
        end, 100)
    end

    return true
end
instanceLogin:register()
