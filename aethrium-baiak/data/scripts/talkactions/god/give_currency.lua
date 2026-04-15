-- /givetaskpoints <jogador>, <quantidade>
-- /givecoins <jogador>, <quantidade>

local giveTaskPoints = TalkAction("/givetaskpoints")

function giveTaskPoints.onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end

    if param == "" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /givetaskpoints <jogador>, <quantidade>")
        return false
    end

    local split = param:split(",")
    local name   = split[1]:trim()
    local amount = tonumber(split[2])

    if not amount or amount <= 0 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Quantidade invalida.")
        return false
    end

    local target = Player(name)
    if not target then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Jogador '" .. name .. "' nao encontrado ou offline.")
        return false
    end

    target:addTaskPoints(amount)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
        string.format("+%d Task Points para %s. Total: %d", amount, target:getName(), target:getTaskPoints()))
    target:sendTextMessage(MESSAGE_EVENT_ORANGE,
        string.format("[GM] Voce recebeu %d Task Points. Total: %d", amount, target:getTaskPoints()))

    return false
end

giveTaskPoints:separator(" ")
giveTaskPoints:register()

-- ────────────────────────────────────────────────────────────

local giveCoins = TalkAction("/givecoins")

function giveCoins.onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end

    if param == "" then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Uso: /givecoins <jogador>, <quantidade>")
        return false
    end

    local split = param:split(",")
    local name   = split[1]:trim()
    local amount = tonumber(split[2])

    if not amount or amount <= 0 then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Quantidade invalida.")
        return false
    end

    local target = Player(name)
    if not target then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Jogador '" .. name .. "' nao encontrado ou offline.")
        return false
    end

    target:addTibiaCoins(amount)
    target:sendCoinBalance()
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
        string.format("+%d Tibia Coins para %s. Total: %d", amount, target:getName(), target:getTibiaCoins()))
    target:sendTextMessage(MESSAGE_EVENT_ORANGE,
        string.format("[GM] Voce recebeu %d Tibia Coins. Total: %d", amount, target:getTibiaCoins()))

    return false
end

giveCoins:separator(" ")
giveCoins:register()
