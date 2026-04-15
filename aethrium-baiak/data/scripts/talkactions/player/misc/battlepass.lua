-- Battle Pass — Comando !battlepass
-- Solicita ao cliente a abertura da interface do Battle Pass

local talk = TalkAction("!battlepass", "!bp")

function talk.onSay(player, words, param)
    -- Subcomandos opcionais via parametro
    -- !battlepass buy  → compra o Elite Pass
    -- !battlepass claim <tier> <track>  → coleta recompensa (debug/GM)
    -- (sem parametro)  → abre a interface

    local args = {}
    for word in param:gmatch("%S+") do
        table.insert(args, word)
    end

    local cmd = args[1]

    if cmd == "buy" then
        BattlePass.buyElite(player)
        return false
    end

    if cmd == "claim" then
        local tier  = tonumber(args[2])
        local track = args[3] or "free"

        if not tier then
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
                "[Battle Pass] Uso: !battlepass claim <tier> <free|elite>")
            return false
        end

        BattlePass.claimReward(player, tier, track)
        return false
    end

    -- Sem parametro: envia payload completo ao cliente para abrir a UI
    local ok, payload = pcall(BattlePass.buildPayload, player)
    if not ok then
        print("[BattlePass] Erro ao construir payload: " .. tostring(payload))
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Erro interno. Contate um administrador.")
        return false
    end

    local ok2, encoded = pcall(json.encode, payload)
    if not ok2 then
        print("[BattlePass] Erro ao codificar JSON: " .. tostring(encoded))
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
            "[Battle Pass] Erro interno. Contate um administrador.")
        return false
    end

    print(string.format("[BattlePass] Abrindo UI para %s", player:getName()))
    player:sendExtendedOpcode(150, encoded)
    return false
end

talk:separator(" ")
talk:register()
