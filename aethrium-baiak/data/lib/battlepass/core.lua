-- Battle Pass — Logica central
-- Carregado por data/lib/lib.lua (apos config.lua)

BattlePass = {}

local BATTLEPASS_OPCODE = 150

-- ============================================================
-- Helpers internos
-- ============================================================

-- Retorna o bit N de um inteiro (1-indexed para combinar com tier)
local function getBit(value, n)
    return math.floor(value / (2 ^ (n - 1))) % 2 == 1
end

-- Define o bit N de um inteiro
local function setBit(value, n)
    if getBit(value, n) then return value end
    return value + (2 ^ (n - 1))
end

-- Entrega a recompensa fisica ao jogador
local function grantReward(player, reward)
    if not reward then return end

    if reward.type == "item" then
        local item = player:addItem(reward.id, reward.count or 1)
        if not item then
            -- depot como fallback se inventario cheio
            player:addItemEx(Item.create(reward.id, reward.count or 1))
        end

    elseif reward.type == "coins" then
        player:getAccount():addCoins(reward.amount or 0)

    elseif reward.type == "outfit" then
        player:addOutfit(reward.id)
        if reward.addons and reward.addons > 0 then
            player:addOutfitAddon(reward.id, reward.addons)
        end

    elseif reward.type == "mount" then
        player:addMount(reward.id)

    elseif reward.type == "xp" then
        -- XP boost: adiciona via storage temporaria (implementar conforme sistema do servidor)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            "[Battle Pass] XP Boost ativado!")
    end
end

-- ============================================================
-- Acesso ao banco de dados
-- ============================================================

function BattlePass.getData(player)
    local guid = player:getGuid()
    local resultId = db.storeQuery(string.format(
        "SELECT `xp`, `level`, `elite`, `claimed_free`, `claimed_elite`, `season`" ..
        " FROM `player_battlepass` WHERE `player_id` = %d", guid))

    if not resultId then
        -- Jogador ainda nao tem registro: inserir linha padrao e retornar defaults
        db.query(string.format(
            "INSERT INTO `player_battlepass` (`player_id`, `season`) VALUES (%d, %d)",
            guid, BattlePassConfig.season))
        return {
            xp           = 0,
            level        = 1,
            elite        = false,
            claimed_free = 0,
            claimed_elite = 0,
            season       = BattlePassConfig.season,
        }
    end

    local data = {
        xp            = result.getNumber(resultId, "xp"),
        level         = result.getNumber(resultId, "level"),
        elite         = result.getNumber(resultId, "elite") == 1,
        claimed_free  = result.getNumber(resultId, "claimed_free"),
        claimed_elite = result.getNumber(resultId, "claimed_elite"),
        season        = result.getNumber(resultId, "season"),
    }
    result.free(resultId)
    return data
end

function BattlePass.saveData(player, data)
    local guid = player:getGuid()
    db.query(string.format(
        "UPDATE `player_battlepass`" ..
        " SET `xp` = %d, `level` = %d, `elite` = %d," ..
        " `claimed_free` = %d, `claimed_elite` = %d, `season` = %d" ..
        " WHERE `player_id` = %d",
        data.xp, data.level, data.elite and 1 or 0,
        data.claimed_free, data.claimed_elite, data.season, guid))
end

-- ============================================================
-- XP e progressao de nivel
-- ============================================================

function BattlePass.addXP(player, amount)
    local data = BattlePass.getData(player)
    local cfg  = BattlePassConfig

    -- Season desatualizada: nao conceder XP
    if data.season ~= cfg.season then return end

    data.xp = data.xp + amount

    -- Level up em loop (pode subir mais de 1 tier de uma vez)
    while data.level < cfg.maxLevel and data.xp >= cfg.xpPerLevel do
        data.xp    = data.xp - cfg.xpPerLevel
        data.level = data.level + 1
    end

    -- Cap no nivel maximo
    if data.level >= cfg.maxLevel then
        data.xp    = math.min(data.xp, cfg.xpPerLevel - 1)
        data.level = cfg.maxLevel
    end

    BattlePass.saveData(player, data)

    -- Notifica o cliente com o payload atualizado
    BattlePass.sendUpdate(player)
end

-- ============================================================
-- Coleta de recompensas
-- ============================================================

-- track: "free" | "elite"
function BattlePass.claimReward(player, tier, track)
    local cfg = BattlePassConfig

    if tier < 1 or tier > cfg.maxLevel then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Tier invalido.")
        return false
    end

    local data = BattlePass.getData(player)

    -- Tier ainda nao desbloqueado
    if data.level < tier then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Voce ainda nao desbloqueou este tier.")
        return false
    end

    -- Elite sem o passe
    if track == "elite" and not data.elite then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Voce precisa do Elite Pass para esta recompensa.")
        return false
    end

    -- Verificar bitmask
    local field = (track == "elite") and "claimed_elite" or "claimed_free"
    if getBit(data[field], tier) then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Recompensa ja coletada.")
        return false
    end

    -- Recompensa definida?
    local rewardRow = cfg.rewards[tier]
    if not rewardRow or not rewardRow[track] then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Sem recompensa definida para este tier.")
        return false
    end

    -- Entregar e marcar como coletado
    grantReward(player, rewardRow[track])
    data[field] = setBit(data[field], tier)
    BattlePass.saveData(player, data)

    player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("[Battle Pass] Recompensa do Tier %d (%s) coletada!", tier, track))

    BattlePass.sendUpdate(player)
    return true
end

-- ============================================================
-- Helpers de Tibia Coins (znote_accounts.points)
-- ============================================================

local function getZnoteCoins(accountId)
    local resultId = db.storeQuery(
        "SELECT `points` FROM `znote_accounts` WHERE `account_id` = " .. accountId)
    if not resultId then return 0 end
    local coins = result.getDataInt(resultId, "points")
    result.free(resultId)
    return coins
end

local function deductZnoteCoins(accountId, amount)
    db.query(
        "UPDATE `znote_accounts` SET `points` = `points` - " .. amount ..
        " WHERE `account_id` = " .. accountId)
end

-- ============================================================
-- Compra do Elite Pass
-- ============================================================

function BattlePass.buyElite(player)
    local data = BattlePass.getData(player)

    if data.elite then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Voce ja possui o Elite Pass.")
        return false
    end

    local cfg  = BattlePassConfig
    local cost = cfg.eliteCost

    -- Desconto VIP
    local vipTier  = player:getVipTier()
    local discount = cfg.vipDiscount[vipTier] or 0
    if discount > 0 then
        cost = math.floor(cost * (100 - discount) / 100)
    end

    local balance = player:getTibiaCoins()

    if balance < cost then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            string.format("[Battle Pass] Tibia Coins insuficientes. Necessario: %d TC.", cost))
        return false
    end

    player:removeTibiaCoins(cost)
    data.elite = true
    BattlePass.saveData(player, data)

    player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        "[Battle Pass] Elite Pass ativado! Aproveite as recompensas exclusivas!")

    BattlePass.sendUpdate(player)
    return true
end

-- ============================================================
-- Daily Tasks
-- ============================================================

function BattlePass.generateDailyTasks(player)
    local guid = player:getGuid()
    local today = os.date("%Y-%m-%d")

    -- Verificar se ja foram geradas hoje
    local check = db.storeQuery(string.format(
        "SELECT COUNT(*) AS cnt FROM `player_battlepass_daily`" ..
        " WHERE `player_id` = %d AND `date` = '%s'", guid, today))
    if check then
        local cnt = result.getNumber(check, "cnt")
        result.free(check)
        if cnt >= 3 then return end
    end

    -- Sortear 3 tarefas distintas do pool
    local pool = {}
    for i, t in ipairs(BattlePassConfig.dailyTaskPool) do
        pool[i] = t
    end

    -- Embaralhar
    for i = #pool, 2, -1 do
        local j = math.random(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    -- Inserir as 3 primeiras
    for taskId = 1, 3 do
        local task = pool[taskId]
        if task then
            db.query(string.format(
                "INSERT IGNORE INTO `player_battlepass_daily`" ..
                " (`player_id`, `task_id`, `type`, `target`, `current`, `completed`, `date`)" ..
                " VALUES (%d, %d, %s, %d, 0, 0, '%s')",
                guid, taskId,
                db.escapeString(task.type),
                task.target, today))
        end
    end
end

function BattlePass.getDailyTasks(player)
    local guid  = player:getGuid()
    local today = os.date("%Y-%m-%d")
    local tasks = {}

    local resultId = db.storeQuery(string.format(
        "SELECT `task_id`, `type`, `target`, `current`, `completed`" ..
        " FROM `player_battlepass_daily`" ..
        " WHERE `player_id` = %d AND `date` = '%s'" ..
        " ORDER BY `task_id`", guid, today))

    if resultId then
        repeat
            local taskType = result.getString(resultId, "type")
            local target   = result.getNumber(resultId, "target")

            -- Buscar label do pool
            local label = taskType
            for _, poolTask in ipairs(BattlePassConfig.dailyTaskPool) do
                if poolTask.type == taskType and poolTask.target == target then
                    label = poolTask.label
                    break
                end
            end

            table.insert(tasks, {
                id        = result.getNumber(resultId, "task_id"),
                type      = taskType,
                label     = label,
                target    = target,
                current   = result.getNumber(resultId, "current"),
                completed = result.getNumber(resultId, "completed") == 1,
            })
        until not result.next(resultId)
        result.free(resultId)
    end

    return tasks
end

function BattlePass.updateDailyTask(player, taskType, increment)
    local guid  = player:getGuid()
    local today = os.date("%Y-%m-%d")

    -- Buscar tarefa ativa deste tipo
    local resultId = db.storeQuery(string.format(
        "SELECT `task_id`, `target`, `current`" ..
        " FROM `player_battlepass_daily`" ..
        " WHERE `player_id` = %d AND `date` = '%s'" ..
        " AND `type` = %s AND `completed` = 0" ..
        " LIMIT 1",
        guid, today, db.escapeString(taskType)))

    if not resultId then return end

    local taskId  = result.getNumber(resultId, "task_id")
    local target  = result.getNumber(resultId, "target")
    local current = result.getNumber(resultId, "current")
    result.free(resultId)

    local newCurrent  = math.min(current + increment, target)
    local isCompleted = (newCurrent >= target)

    db.query(string.format(
        "UPDATE `player_battlepass_daily`" ..
        " SET `current` = %d, `completed` = %d" ..
        " WHERE `player_id` = %d AND `date` = '%s' AND `task_id` = %d",
        newCurrent, isCompleted and 1 or 0,
        guid, today, taskId))

    if isCompleted then
        -- Buscar o XP da tarefa no pool
        local xpGrant = 200
        for _, poolTask in ipairs(BattlePassConfig.dailyTaskPool) do
            if poolTask.type == taskType and poolTask.target == target then
                xpGrant = poolTask.xp
                break
            end
        end

        BattlePass.addXP(player, xpGrant)

        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            string.format("[Battle Pass] Tarefa diaria concluida! +%d BP XP", xpGrant))
    end
end

-- ============================================================
-- Payload para o cliente
-- ============================================================

function BattlePass.buildPayload(player)
    local cfg  = BattlePassConfig
    local data = BattlePass.getData(player)

    -- Calcular dias restantes da season
    local expires  = Game.getStorageValue(GlobalStorageKeys.battlepassExpires)
    local daysLeft = 0
    if expires and expires > 0 then
        daysLeft = math.max(0, math.floor((expires - os.time()) / 86400))
    end

    -- Custo com desconto VIP
    local vipTier  = player:getVipTier()
    local discount = cfg.vipDiscount[vipTier] or 0
    local finalCost = math.floor(cfg.eliteCost * (100 - discount) / 100)

    -- Montar lista de recompensas
    local rewardsList = {}
    for tier = 1, cfg.maxLevel do
        local row = cfg.rewards[tier] or {}
        table.insert(rewardsList, {
            tier          = tier,
            free          = row.free  or {},
            elite         = row.elite or {},
            claimedFree   = getBit(data.claimed_free,  tier),
            claimedElite  = getBit(data.claimed_elite, tier),
        })
    end

    -- Daily tasks (gera se ainda nao existirem hoje)
    BattlePass.generateDailyTasks(player)
    local tasks = BattlePass.getDailyTasks(player)

    return {
        action      = "open",
        season      = data.season,
        level       = data.level,
        xp          = data.xp,
        xpNext      = cfg.xpPerLevel,
        elite       = data.elite,
        eliteCost   = finalCost,
        vipDiscount = discount,
        daysLeft    = daysLeft,
        rewards     = rewardsList,
        dailyTasks  = tasks,
    }
end

-- Envia o payload atualizado ao cliente via opcode 150
function BattlePass.sendUpdate(player)
    local ok, payload = pcall(BattlePass.buildPayload, player)
    if not ok then
        print("[BattlePass] Erro ao construir payload: " .. tostring(payload))
        return
    end

    local ok2, encoded = pcall(json.encode, payload)
    if not ok2 then
        print("[BattlePass] Erro ao codificar JSON: " .. tostring(encoded))
        return
    end

    player:sendExtendedOpcode(BATTLEPASS_OPCODE, encoded)
end
