-- ============================================================
-- Aethrium Hunt System (SuperUP)
-- Usa o Instance System nativo do engine (C++)
-- Coordenadas: mesmo mapa do baiakthunder
-- ============================================================

HuntSystem = {}

-- Contador global de instâncias (nunca reutilizado)
local huntInstanceCounter = 50000

-- Todas as hunts disponíveis.
-- Adicionar mais hunts é só acrescentar entradas nesta tabela.
-- `from`/`to` definem a boundary box da sala (usada para criar a instância).
-- `destination` é onde o jogador aparece dentro da sala.
-- `monsters` é a lista de monstros spawnados aleatoriamente na área.
-- `monsterCount` é quantos monstros são spawnados ao entrar.
-- `respawnInterval` (ms) é o intervalo de re-spawn quando um monstro morre.
-- `currency` = "coins" ou "tasks"
-- `price` = custo na moeda escolhida
-- `level` = level mínimo
-- `time` = duração em segundos (padrão 3h = 10800)

-- Looktypes por grupo de monstro (representacao visual no UI)
-- Cobra Assassin=1016, Falcon Knight=1161, Mould Phantom/Rotten Golem=1117
-- True Asura=1054, Lost Soul=1068, Bony Sea Devil=1083
HuntSystem.hunts = {
    -- ── LEVEL 500+ (Tibia Coins) ──────────────────────────────
    [1] = {
        id = 1,
        name = "Cobra Cave I",
        monsters = {"Cobra Assassin", "Cobra Scout", "Cobra Vizier"},
        looktype = 1016,
        monsterCount = 20,
        respawnInterval = 60000,
        level = 500,
        currency = "coins",
        price = 50,
        time = 10800,
        destination = Position(1930, 1741, 7),
        from = Position(1831, 1708, 7),
        to   = Position(1930, 1741, 7),
    },
    [2] = {
        id = 2,
        name = "Cobra Cave II",
        monsters = {"Cobra Assassin", "Cobra Scout", "Cobra Vizier"},
        looktype = 1016,
        monsterCount = 20,
        respawnInterval = 60000,
        level = 500,
        currency = "coins",
        price = 50,
        time = 10800,
        destination = Position(1537, 2081, 7),
        from = Position(1496, 2047, 7),
        to   = Position(1573, 2115, 7),
    },
    [3] = {
        id = 3,
        name = "Cobra Cave III",
        monsters = {"Cobra Assassin", "Cobra Scout", "Cobra Vizier"},
        looktype = 1016,
        monsterCount = 20,
        respawnInterval = 60000,
        level = 500,
        currency = "coins",
        price = 50,
        time = 10800,
        destination = Position(1682, 1932, 7),
        from = Position(1600, 1925, 7),
        to   = Position(1714, 2012, 7),
    },

    -- ── LEVEL 700+ (Tibia Coins) ──────────────────────────────
    [4] = {
        id = 4,
        name = "Falcon Cave I",
        monsters = {"Falcon Knight", "Falcon Paladin"},
        looktype = 1161,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "coins",
        price = 80,
        time = 10800,
        destination = Position(1641, 1877, 7),
        from = Position(1614, 1801, 7),
        to   = Position(1724, 1899, 7),
    },
    [5] = {
        id = 5,
        name = "Falcon Cave II",
        monsters = {"Falcon Knight", "Falcon Paladin"},
        looktype = 1161,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "coins",
        price = 80,
        time = 10800,
        destination = Position(1812, 1915, 7),
        from = Position(1736, 1852, 7),
        to   = Position(1861, 1980, 7),
    },
    [6] = {
        id = 6,
        name = "Falcon Cave III",
        monsters = {"Falcon Knight", "Falcon Paladin"},
        looktype = 1161,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "coins",
        price = 80,
        time = 10800,
        destination = Position(2088, 1871, 7),
        from = Position(2023, 1860, 7),
        to   = Position(2132, 1930, 7),
    },
    [7] = {
        id = 7,
        name = "Falcon Cave IV",
        monsters = {"Falcon Knight", "Falcon Paladin"},
        looktype = 1161,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "coins",
        price = 80,
        time = 10800,
        destination = Position(2192, 1919, 7),
        from = Position(2151, 1847, 7),
        to   = Position(2254, 1934, 7),
    },

    -- ── LEVEL 900+ (Tibia Coins) ──────────────────────────────
    [8] = {
        id = 8,
        name = "Golem Cave I",
        monsters = {"Mould Phantom", "Rotten Golem", "Brachiodemon"},
        looktype = 1117,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "coins",
        price = 120,
        time = 10800,
        destination = Position(2178, 1831, 7),
        from = Position(2149, 1752, 7),
        to   = Position(2260, 1837, 7),
    },
    [9] = {
        id = 9,
        name = "Golem Cave II",
        monsters = {"Mould Phantom", "Rotten Golem", "Brachiodemon"},
        looktype = 1117,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "coins",
        price = 120,
        time = 10800,
        destination = Position(2083, 1675, 7),
        from = Position(2068, 1617, 7),
        to   = Position(2169, 1696, 7),
    },
    [10] = {
        id = 10,
        name = "Golem Cave III",
        monsters = {"Mould Phantom", "Rotten Golem", "Brachiodemon"},
        looktype = 1117,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "coins",
        price = 120,
        time = 10800,
        destination = Position(1740, 1805, 7),
        from = Position(1729, 1761, 7),
        to   = Position(1826, 1847, 7),
    },

    -- ── LEVEL 500+ (Task Points) ──────────────────────────────
    [11] = {
        id = 11,
        name = "Asura Cave I",
        monsters = {"True Dawnfire Asura", "True Frost Flower Asura", "True Midnight Asura"},
        looktype = 1054,
        monsterCount = 18,
        respawnInterval = 60000,
        level = 500,
        currency = "tasks",
        price = 500,
        time = 10800,
        destination = Position(198, 1446, 8),
        from = Position(184, 1434, 8),
        to   = Position(313, 1533, 8),
    },
    [12] = {
        id = 12,
        name = "Asura Cave II",
        monsters = {"True Dawnfire Asura", "True Frost Flower Asura", "True Midnight Asura"},
        looktype = 1054,
        monsterCount = 18,
        respawnInterval = 60000,
        level = 500,
        currency = "tasks",
        price = 500,
        time = 10800,
        destination = Position(845, 1545, 7),
        from = Position(790, 1529, 7),
        to   = Position(885, 1671, 8),
    },
    [13] = {
        id = 13,
        name = "Asura Cave III",
        monsters = {"True Dawnfire Asura", "True Frost Flower Asura", "True Midnight Asura"},
        looktype = 1054,
        monsterCount = 18,
        respawnInterval = 60000,
        level = 500,
        currency = "tasks",
        price = 500,
        time = 10800,
        destination = Position(864, 1692, 7),
        from = Position(850, 1667, 7),
        to   = Position(934, 1768, 7),
    },

    -- ── LEVEL 700+ (Task Points) ──────────────────────────────
    [14] = {
        id = 14,
        name = "Lost Soul Cave I",
        monsters = {"Flimsy Lost Soul", "Freakish Lost Soul", "Mean Lost Soul"},
        looktype = 1068,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "tasks",
        price = 800,
        time = 10800,
        destination = Position(315, 647, 7),
        from = Position(291, 615, 7),
        to   = Position(395, 705, 7),
    },
    [15] = {
        id = 15,
        name = "Lost Soul Cave II",
        monsters = {"Flimsy Lost Soul", "Freakish Lost Soul", "Mean Lost Soul"},
        looktype = 1068,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "tasks",
        price = 800,
        time = 10800,
        destination = Position(313, 757, 7),
        from = Position(250, 725, 7),
        to   = Position(373, 809, 7),
    },
    [16] = {
        id = 16,
        name = "Lost Soul Cave III",
        monsters = {"Flimsy Lost Soul", "Freakish Lost Soul", "Mean Lost Soul"},
        looktype = 1068,
        monsterCount = 15,
        respawnInterval = 90000,
        level = 700,
        currency = "tasks",
        price = 800,
        time = 10800,
        destination = Position(782, 943, 7),
        from = Position(727, 903, 7),
        to   = Position(835, 966, 7),
    },

    -- ── LEVEL 900+ (Task Points) ──────────────────────────────
    [17] = {
        id = 17,
        name = "Sea Devil Cave I",
        monsters = {"Bony Sea Devil", "Cloak of Terror", "Courage Leech"},
        looktype = 1083,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "tasks",
        price = 1200,
        time = 10800,
        destination = Position(911, 932, 7),
        from = Position(863, 902, 7),
        to   = Position(954, 967, 7),
    },
    [18] = {
        id = 18,
        name = "Sea Devil Cave II",
        monsters = {"Bony Sea Devil", "Cloak of Terror", "Courage Leech"},
        looktype = 1083,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "tasks",
        price = 1200,
        time = 10800,
        destination = Position(956, 1596, 7),
        from = Position(923, 1576, 7),
        to   = Position(996, 1636, 7),
    },
    [19] = {
        id = 19,
        name = "Sea Devil Cave III",
        monsters = {"Bony Sea Devil", "Cloak of Terror", "Courage Leech"},
        looktype = 1083,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "tasks",
        price = 1200,
        time = 10800,
        destination = Position(204, 638, 7),
        from = Position(189, 607, 7),
        to   = Position(281, 687, 7),
    },
    [20] = {
        id = 20,
        name = "Sea Devil Cave IV",
        monsters = {"Bony Sea Devil", "Cloak of Terror", "Courage Leech"},
        looktype = 1083,
        monsterCount = 12,
        respawnInterval = 120000,
        level = 900,
        currency = "tasks",
        price = 1200,
        time = 10800,
        destination = Position(1275, 1703, 8),
        from = Position(1220, 1694, 8),
        to   = Position(1311, 1811, 8),
    },
}

-- Storage base para cooldown de hunt por jogador (huntId * 1 + base)
HuntSystem.COOLDOWN_STORAGE_BASE = 50000

-- Instâncias ativas em memória: instanceId -> { huntId, timerId, players = {guid = true} }
HuntSystem.activeInstances = {}

-- ── Funções auxiliares ────────────────────────────────────────

function HuntSystem.getHunt(id)
    return HuntSystem.hunts[id]
end

function HuntSystem.getCooldownStorage(huntId)
    return HuntSystem.COOLDOWN_STORAGE_BASE + huntId
end

function HuntSystem.getPlayerCooldown(player, huntId)
    local val = player:getStorageValue(HuntSystem.getCooldownStorage(huntId))
    if val and val > 0 then
        local remaining = val - os.time()
        if remaining > 0 then
            return remaining
        end
    end
    return 0
end

-- Retorna posição aleatória dentro da boundary box da hunt
function HuntSystem.randomPosInArea(hunt)
    return Position(
        math.random(hunt.from.x, hunt.to.x),
        math.random(hunt.from.y, hunt.to.y),
        hunt.from.z
    )
end

-- Coleta espectadores de uma instância pelo instanceId
function HuntSystem.getInstanceSpectators(instanceId)
    local area = Game.getInstanceArea(instanceId)
    if not area then return {} end
    local cx = math.floor((area.fromPos.x + area.toPos.x) / 2)
    local cy = math.floor((area.fromPos.y + area.toPos.y) / 2)
    local rx = math.ceil((area.toPos.x - area.fromPos.x) / 2)
    local ry = math.ceil((area.toPos.y - area.fromPos.y) / 2)
    return Game.getSpectators(Position(cx, cy, area.fromPos.z), false, false, rx, rx, ry, ry)
end

-- Envia mensagem para todos os jogadores na instância
function HuntSystem.broadcastToInstance(instanceId, msg)
    for _, spec in ipairs(HuntSystem.getInstanceSpectators(instanceId)) do
        if spec:isPlayer() and spec:getInstanceId() == instanceId then
            spec:sendTextMessage(MESSAGE_EVENT_ORANGE, msg)
        end
    end
end

-- Remove monstros e desregistra a instância
function HuntSystem.cleanupInstance(instanceId)
    local data = HuntSystem.activeInstances[instanceId]
    if data then
        if data.timerId then stopEvent(data.timerId) end
        if data.respawnTimerId then stopEvent(data.respawnTimerId) end
    end

    for _, spec in ipairs(HuntSystem.getInstanceSpectators(instanceId)) do
        if spec:isMonster() and spec:getInstanceId() == instanceId then
            spec:remove()
        end
    end

    Game.unregisterInstanceArea(instanceId)
    HuntSystem.activeInstances[instanceId] = nil
end

-- Expulsa todos os jogadores da instância para o templo
function HuntSystem.expelAllPlayers(instanceId, msg)
    for _, spec in ipairs(HuntSystem.getInstanceSpectators(instanceId)) do
        if spec:isPlayer() and spec:getInstanceId() == instanceId then
            if msg then spec:sendTextMessage(MESSAGE_EVENT_ORANGE, msg) end
            spec:setInstanceIdRaw(0)
            spec:teleportTo(spec:getTown():getTemplePosition())
        end
    end
end

-- Remove um jogador da instância (saiu/deslogou)
function HuntSystem.removePlayer(player)
    local instanceId = player:getInstanceId()
    if instanceId == 0 then return end

    local data = HuntSystem.activeInstances[instanceId]
    player:setInstanceIdRaw(0)

    if not data then
        Game.unregisterInstanceArea(instanceId)
        return
    end

    data.players[player:getGuid()] = nil

    -- Se não há mais jogadores, encerra a instância
    if not next(data.players) then
        HuntSystem.cleanupInstance(instanceId)
    end
end

-- ── Entrada na Hunt ───────────────────────────────────────────

function HuntSystem.enter(player, huntId)
    local hunt = HuntSystem.getHunt(huntId)
    if not hunt then
        return false, "Hunt não encontrada."
    end

    if player:getLevel() < hunt.level then
        return false, string.format("Você precisa de level %d para entrar nesta hunt.", hunt.level)
    end

    if player:getInstanceId() ~= 0 then
        return false, "Você já está dentro de uma instância. Saia primeiro."
    end

    local cooldown = HuntSystem.getPlayerCooldown(player, huntId)
    if cooldown > 0 then
        local h = math.floor(cooldown / 3600)
        local m = math.floor((cooldown % 3600) / 60)
        return false, string.format("Aguarde %dh %dm para entrar nesta hunt novamente.", h, m)
    end

    -- Cobra o custo
    if hunt.currency == "coins" then
        if not player:removeTibiaCoins(hunt.price) then
            return false, string.format("Você precisa de %d Tibia Coins para entrar.", hunt.price)
        end
    elseif hunt.currency == "tasks" then
        if not player:removeTaskPoints(hunt.price) then
            return false, string.format("Você precisa de %d Task Points para entrar.", hunt.price)
        end
    end

    -- Cria a instância
    huntInstanceCounter = huntInstanceCounter + 1
    local instanceId = huntInstanceCounter

    Game.registerInstanceArea(instanceId, hunt.from, hunt.to)

    -- Coleta participantes (jogador solo ou party)
    local participants = {}
    local party = player:getParty()
    if party then
        local all = {party:getLeader()}
        for _, m in ipairs(party:getMembers()) do
            all[#all + 1] = m
        end
        for _, p in ipairs(all) do
            if p:getInstanceId() == 0 and p:getLevel() >= hunt.level then
                participants[#participants + 1] = p
            end
        end
    else
        participants[1] = player
    end

    local playerTracking = {}
    for _, p in ipairs(participants) do
        p:setInstanceIdRaw(instanceId)
        playerTracking[p:getGuid()] = true
        local dest = p:getClosestFreePosition(hunt.destination, false)
        if dest.x == 0 then dest = hunt.destination end
        p:teleportTo(dest)
        dest:sendMagicEffect(CONST_ME_TELEPORT, {p})
    end

    -- Spawna monstros iniciais
    local spawned = 0
    for _ = 1, hunt.monsterCount * 5 do
        if spawned >= hunt.monsterCount then break end
        local pos = HuntSystem.randomPosInArea(hunt)
        local m = Game.createMonster(hunt.monsters[math.random(#hunt.monsters)], pos, true, false, 0, instanceId)
        if m then
            spawned = spawned + 1
        end
    end

    -- Timer de duração
    local timerId = addEvent(function(iid)
        HuntSystem.broadcastToInstance(iid, "[Hunt] Seu tempo acabou! Você será teleportado.")
        HuntSystem.expelAllPlayers(iid)
        HuntSystem.cleanupInstance(iid)
    end, hunt.time * 1000, instanceId)

    -- Timer de re-spawn
    local function scheduleRespawn(iid, huntData)
        return addEvent(function()
            local inst = HuntSystem.activeInstances[iid]
            if not inst then return end

            -- Conta monstros vivos na instância
            local alive = 0
            for _, spec in ipairs(HuntSystem.getInstanceSpectators(iid)) do
                if spec:isMonster() and spec:getInstanceId() == iid then
                    alive = alive + 1
                end
            end

            -- Re-spawna até atingir monsterCount
            local toSpawn = huntData.monsterCount - alive
            for _ = 1, toSpawn * 3 do
                if toSpawn <= 0 then break end
                local pos = HuntSystem.randomPosInArea(huntData)
                local m = Game.createMonster(huntData.monsters[math.random(#huntData.monsters)], pos, true, false, 0, iid)
                if m then toSpawn = toSpawn - 1 end
            end

            inst.respawnTimerId = scheduleRespawn(iid, huntData)
        end, huntData.respawnInterval)
    end

    HuntSystem.activeInstances[instanceId] = {
        huntId          = huntId,
        timerId         = timerId,
        respawnTimerId  = scheduleRespawn(instanceId, hunt),
        players         = playerTracking,
    }

    -- Define cooldown (o tempo da hunt)
    local expireAt = os.time() + hunt.time
    player:setStorageValue(HuntSystem.getCooldownStorage(huntId), expireAt)

    HuntSystem.broadcastToInstance(instanceId,
        string.format("[Hunt] Bem-vindo à %s! Você tem %dh. Boa caçada!", hunt.name, hunt.time / 3600))

    return true, instanceId
end

-- ── Dados para a UI ───────────────────────────────────────────

-- Retorna a lista de hunts serializada para o cliente
function HuntSystem.getUIData(player)
    local list = {}
    for _, hunt in ipairs(HuntSystem.hunts) do
        local cooldown = HuntSystem.getPlayerCooldown(player, hunt.id)
        list[#list + 1] = {
            id        = hunt.id,
            name      = hunt.name,
            monsters  = hunt.monsters,
            level     = hunt.level,
            currency  = hunt.currency,
            price     = hunt.price,
            time      = hunt.time,
            cooldown  = cooldown,
            looktype  = hunt.looktype or 0,
        }
    end
    return list
end
