-- ============================================================
-- Aethrium Boss Room System
-- Usa o Instance System nativo do engine (C++)
-- Coordenadas: mesmo mapa do baiakthunder
-- Cada sala física no mapa é compartilhada entre instâncias
-- (isolamento real via instanceId, não salas físicas exclusivas)
-- ============================================================

BossRoom = {}

-- Contador global de instâncias (nunca reutilizado)
local bossInstanceCounter = 60000

-- Posição de saída padrão (fora de todas as salas)
BossRoom.EXIT_POSITION = Position(583, 1242, 7)

-- Kill time em minutos: o boss deve ser morto neste prazo
-- Todas as salas têm dimensão ~6x6 em torno do `center`
-- `from`/`to` são calculados como center ± halfSize

local function makeArea(center, halfX, halfY)
    halfX = halfX or 6
    halfY = halfY or 6
    return {
        from = Position(center.x - halfX, center.y - halfY, center.z),
        to   = Position(center.x + halfX, center.y + halfY, center.z),
    }
end

-- Todos os bosses disponíveis.
-- Adicionar um novo boss é só acrescentar uma entrada.
-- `center` = centro da sala (onde o boss spawna)
-- `currency` = "coins" ou "tasks"
-- `price` = custo
-- `level` = level mínimo
-- `killTime` = minutos para matar o boss antes de ser expulso
-- `minPlayers`/`maxPlayers` = tamanho de party permitido
-- `pointsReward` = Task Points ganhos ao matar o boss

BossRoom.bosses = {
    -- ── Coin Bosses (nível crescente de dificuldade) ──────────
    [1] = {
        id = 1,
        name = "Gaz'haragoth",
        bossName = "Gaz'haragoth",
        level = 250,
        currency = "coins",
        price = 100,
        killTime = 15,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 7,
        center = Position(1646, 975, 9),
        looktype = 390,
    },
    [2] = {
        id = 2,
        name = "Abyssador",
        bossName = "Abyssador",
        level = 230,
        currency = "coins",
        price = 80,
        killTime = 15,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 5,
        center = Position(1695, 977, 9),
        looktype = 616,
    },
    [3] = {
        id = 3,
        name = "Deathstrike",
        bossName = "Deathstrike",
        level = 220,
        currency = "coins",
        price = 80,
        killTime = 15,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 4,
        center = Position(1743, 978, 9),
        looktype = 239,
    },
    [4] = {
        id = 4,
        name = "Gnomevil",
        bossName = "Gnomevil",
        level = 200,
        currency = "coins",
        price = 70,
        killTime = 15,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 4,
        center = Position(1792, 980, 9),
        looktype = 645,
    },
    [5] = {
        id = 5,
        name = "Chizzoron",
        bossName = "Chizzoron The Distorter",
        level = 180,
        currency = "coins",
        price = 60,
        killTime = 15,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1646, 921, 9),
        looktype = 575,
    },
    [6] = {
        id = 6,
        name = "The Abomination",
        bossName = "The Abomination",
        level = 160,
        currency = "coins",
        price = 50,
        killTime = 12,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1695, 923, 9),
        looktype = 371,
    },
    [7] = {
        id = 7,
        name = "Jaul",
        bossName = "Jaul",
        level = 150,
        currency = "coins",
        price = 40,
        killTime = 12,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1743, 924, 9),
        looktype = 244,
    },
    [8] = {
        id = 8,
        name = "Tanjis",
        bossName = "Tanjis",
        level = 140,
        currency = "coins",
        price = 40,
        killTime = 12,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 2,
        center = Position(1792, 926, 9),
        looktype = 153,
    },
    [9] = {
        id = 9,
        name = "Obujos",
        bossName = "Obujos",
        level = 130,
        currency = "coins",
        price = 40,
        killTime = 12,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 2,
        center = Position(1646, 867, 9),
        looktype = 244,
    },
    [10] = {
        id = 10,
        name = "Zulazza",
        bossName = "Zulazza the Corruptor",
        level = 120,
        currency = "coins",
        price = 30,
        killTime = 12,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 2,
        center = Position(1695, 869, 9),
        looktype = 154,
    },

    -- ── Task Point Bosses ─────────────────────────────────────
    [11] = {
        id = 11,
        name = "Apocalypse",
        bossName = "Apocalypse",
        level = 300,
        currency = "tasks",
        price = 1000,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1743, 870, 9),
        looktype = 253,
    },
    [12] = {
        id = 12,
        name = "Bazir",
        bossName = "Bazir",
        level = 280,
        currency = "tasks",
        price = 900,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1792, 872, 9),
        looktype = 35,
    },
    [13] = {
        id = 13,
        name = "Infernatil",
        bossName = "Infernatil",
        level = 270,
        currency = "tasks",
        price = 800,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1646, 813, 9),
        looktype = 35,
    },
    [14] = {
        id = 14,
        name = "Verminor",
        bossName = "Verminor",
        level = 260,
        currency = "tasks",
        price = 700,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1695, 815, 9),
        looktype = 240,
    },
    [15] = {
        id = 15,
        name = "Ferumbras",
        bossName = "Ferumbras",
        level = 250,
        currency = "tasks",
        price = 600,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1743, 816, 9),
        looktype = 75,
    },
    [16] = {
        id = 16,
        name = "Morgaroth",
        bossName = "Morgaroth",
        level = 240,
        currency = "tasks",
        price = 500,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1792, 818, 9),
        looktype = 236,
    },
    [17] = {
        id = 17,
        name = "Ghazbaran",
        bossName = "Ghazbaran",
        level = 230,
        currency = "tasks",
        price = 500,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 3,
        center = Position(1645, 761, 9),
        looktype = 236,
    },
    [18] = {
        id = 18,
        name = "The Pale Count",
        bossName = "The Pale Count",
        level = 200,
        currency = "tasks",
        price = 400,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 2,
        center = Position(1694, 763, 9),
        looktype = 517,
    },
    [19] = {
        id = 19,
        name = "Zoralurk",
        bossName = "Zoralurk",
        level = 180,
        currency = "tasks",
        price = 300,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 2,
        center = Position(1742, 764, 9),
        looktype = 155,
    },
    [20] = {
        id = 20,
        name = "Annihilon",
        bossName = "Annihilon",
        level = 160,
        currency = "tasks",
        price = 200,
        killTime = 10,
        minPlayers = 1,
        maxPlayers = 10,
        pointsReward = 2,
        center = Position(1791, 766, 9),
        looktype = 159,
    },
}

-- Storage base para cooldown por jogador (bossId + base)
BossRoom.COOLDOWN_STORAGE_BASE = 51000
BossRoom.COOLDOWN_TIME = 30 * 60 -- 30 minutos

-- Instâncias ativas em memória: instanceId -> { bossId, timerId, players = {guid = true} }
BossRoom.activeInstances = {}

-- ── Funções auxiliares ────────────────────────────────────────

function BossRoom.getBoss(id)
    return BossRoom.bosses[id]
end

function BossRoom.getCooldownStorage(bossId)
    return BossRoom.COOLDOWN_STORAGE_BASE + bossId
end

function BossRoom.getPlayerCooldown(player, bossId)
    local val = player:getStorageValue(BossRoom.getCooldownStorage(bossId))
    if val and val > 0 then
        local remaining = val - os.time()
        if remaining > 0 then return remaining end
    end
    return 0
end

function BossRoom.getArea(boss)
    return makeArea(boss.center)
end

function BossRoom.getInstanceSpectators(instanceId)
    local area = Game.getInstanceArea(instanceId)
    if not area then return {} end
    local cx = math.floor((area.fromPos.x + area.toPos.x) / 2)
    local cy = math.floor((area.fromPos.y + area.toPos.y) / 2)
    local rx = math.ceil((area.toPos.x - area.fromPos.x) / 2)
    local ry = math.ceil((area.toPos.y - area.fromPos.y) / 2)
    return Game.getSpectators(Position(cx, cy, area.fromPos.z), false, false, rx, rx, ry, ry)
end

function BossRoom.broadcastToInstance(instanceId, msg)
    for _, spec in ipairs(BossRoom.getInstanceSpectators(instanceId)) do
        if spec:isPlayer() and spec:getInstanceId() == instanceId then
            spec:sendTextMessage(MESSAGE_EVENT_ORANGE, msg)
        end
    end
end

function BossRoom.cleanupInstance(instanceId)
    local data = BossRoom.activeInstances[instanceId]
    if data and data.timerId then
        stopEvent(data.timerId)
    end

    for _, spec in ipairs(BossRoom.getInstanceSpectators(instanceId)) do
        if spec:isMonster() and spec:getInstanceId() == instanceId then
            spec:remove()
        end
    end

    Game.unregisterInstanceArea(instanceId)
    BossRoom.activeInstances[instanceId] = nil
end

function BossRoom.expelAllPlayers(instanceId, msg)
    for _, spec in ipairs(BossRoom.getInstanceSpectators(instanceId)) do
        if spec:isPlayer() and spec:getInstanceId() == instanceId then
            if msg then spec:sendTextMessage(MESSAGE_EVENT_ORANGE, msg) end
            spec:setInstanceIdRaw(0)
            spec:teleportTo(BossRoom.EXIT_POSITION)
            BossRoom.EXIT_POSITION:sendMagicEffect(CONST_ME_TELEPORT)
        end
    end
end

function BossRoom.removePlayer(player)
    local instanceId = player:getInstanceId()
    if instanceId == 0 then return end

    local data = BossRoom.activeInstances[instanceId]
    player:setInstanceIdRaw(0)

    if not data then
        Game.unregisterInstanceArea(instanceId)
        return
    end

    data.players[player:getGuid()] = nil

    if not next(data.players) then
        BossRoom.cleanupInstance(instanceId)
    end
end

-- ── Entrada na Boss Room ──────────────────────────────────────

function BossRoom.enter(player, bossId)
    local boss = BossRoom.getBoss(bossId)
    if not boss then
        return false, "Boss não encontrado."
    end

    if player:getLevel() < boss.level then
        return false, string.format("Você precisa de level %d para enfrentar %s.", boss.level, boss.name)
    end

    if player:getInstanceId() ~= 0 then
        return false, "Você já está dentro de uma instância. Saia primeiro."
    end

    local cooldown = BossRoom.getPlayerCooldown(player, bossId)
    if cooldown > 0 then
        local m = math.ceil(cooldown / 60)
        return false, string.format("Aguarde %d minuto(s) para entrar novamente.", m)
    end

    -- Coleta participantes
    local participants = {player}
    local party = player:getParty()
    if party and party:getLeader():getId() == player:getId() then
        local added = {[player:getGuid()] = true}
        for _, m in ipairs(party:getMembers()) do
            if not added[m:getGuid()] and m:getInstanceId() == 0 then
                added[m:getGuid()] = true
                participants[#participants + 1] = m
            end
        end
    end

    if #participants < boss.minPlayers then
        return false, string.format("Você precisa de pelo menos %d jogadores na party.", boss.minPlayers)
    end

    if #participants > boss.maxPlayers then
        participants = {table.unpack(participants, 1, boss.maxPlayers)}
    end

    -- Verifica cooldown de todos
    for _, p in ipairs(participants) do
        local cd = BossRoom.getPlayerCooldown(p, bossId)
        if cd > 0 then
            return false, string.format("%s precisa aguardar %d minuto(s) para este boss.", p:getName(), math.ceil(cd / 60))
        end
    end

    -- Cobra o custo do líder
    if boss.currency == "coins" then
        if not player:removeTibiaCoins(boss.price) then
            return false, string.format("Você precisa de %d Tibia Coins para entrar.", boss.price)
        end
    elseif boss.currency == "tasks" then
        if not player:removeTaskPoints(boss.price) then
            return false, string.format("Você precisa de %d Task Points para entrar.", boss.price)
        end
    end

    -- Cria a instância
    bossInstanceCounter = bossInstanceCounter + 1
    local instanceId = bossInstanceCounter

    local area = BossRoom.getArea(boss)
    Game.registerInstanceArea(instanceId, area.from, area.to)

    -- Teleporta jogadores para posições ao redor do centro
    local playerTracking = {}
    for i, p in ipairs(participants) do
        p:setInstanceIdRaw(instanceId)
        playerTracking[p:getGuid()] = true

        -- Espalha os jogadores em volta do centro
        local offsetX = ((i - 1) % 3) - 1
        local offsetY = math.floor((i - 1) / 3) - 1
        local dest = Position(boss.center.x + offsetX, boss.center.y + offsetY + 3, boss.center.z)
        local safeDest = p:getClosestFreePosition(dest, false)
        if safeDest.x == 0 then safeDest = dest end
        p:teleportTo(safeDest)
        safeDest:sendMagicEffect(CONST_ME_TELEPORT, {p})
    end

    -- Spawna o boss após 5 segundos (tempo de os jogadores se posicionarem)
    addEvent(function()
        local inst = BossRoom.activeInstances[instanceId]
        if not inst then return end

        local monster = Game.createMonster(boss.bossName, boss.center, false, true, CONST_ME_TELEPORT, instanceId)
        if monster then
            monster:registerEvent("BossRoomOnDeath")
        end

        BossRoom.broadcastToInstance(instanceId,
            string.format("[Boss Room] %s apareceu! Você tem %d minutos para matá-lo!", boss.bossName, boss.killTime))
    end, 5000)

    -- Timer de kill time
    local timerId = addEvent(function(iid)
        local inst = BossRoom.activeInstances[iid]
        if not inst or inst.bossDefeated then return end
        BossRoom.expelAllPlayers(iid, "[Boss Room] Tempo esgotado! Você não conseguiu derrotar o boss.")
        BossRoom.cleanupInstance(iid)
    end, boss.killTime * 60 * 1000, instanceId)

    -- Define cooldown para todos os participantes
    local expireAt = os.time() + BossRoom.COOLDOWN_TIME
    for _, p in ipairs(participants) do
        p:setStorageValue(BossRoom.getCooldownStorage(bossId), expireAt)
    end

    BossRoom.activeInstances[instanceId] = {
        bossId       = bossId,
        timerId      = timerId,
        players      = playerTracking,
        bossDefeated = false,
    }

    return true, instanceId
end

-- ── Dados para a UI ───────────────────────────────────────────

function BossRoom.getUIData(player)
    local list = {}
    for _, boss in ipairs(BossRoom.bosses) do
        local cooldown = BossRoom.getPlayerCooldown(player, boss.id)
        list[#list + 1] = {
            id          = boss.id,
            name        = boss.name,
            bossName    = boss.bossName,
            level       = boss.level,
            currency    = boss.currency,
            price       = boss.price,
            killTime    = boss.killTime,
            minPlayers  = boss.minPlayers,
            maxPlayers  = boss.maxPlayers,
            pointsReward = boss.pointsReward,
            cooldown    = cooldown,
            looktype    = boss.looktype or 0,
        }
    end
    return list
end
