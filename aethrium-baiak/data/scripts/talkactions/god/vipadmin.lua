-- VIP System — Admin command
-- Usage: !vipadmin PlayerName, Tier(1-3), Days
-- Example: !vipadmin Iago, 3, 30

local VIP_TIER_NAMES = { [1] = "Bronze", [2] = "Silver", [3] = "Gold" }

local talk = TalkAction("!vipadmin")

function talk.onSay(player, words, param)
    if player:getGroup():getId() < 3 then
        return true
    end

    local parts = param:split(",")
    if #parts < 3 then
        player:sendCancelMessage("Usage: !vipadmin PlayerName, Tier(1-3), Days")
        return false
    end

    local targetName = parts[1]:trim()
    local tier = tonumber(parts[2])
    local days = tonumber(parts[3])

    if not tier or tier < 1 or tier > 3 then
        player:sendCancelMessage("Tier must be 1 (Bronze), 2 (Silver) or 3 (Gold).")
        return false
    end

    if not days or days < 1 then
        player:sendCancelMessage("Days must be a positive number.")
        return false
    end

    local target = Player(targetName)
    if not target then
        player:sendCancelMessage("Player '" .. targetName .. "' is not online.")
        return false
    end

    target:setVip(tier, days)

    local tierName = VIP_TIER_NAMES[tier]
    target:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("[VIP] You received %d days of VIP %s!", days, tierName))
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
        string.format("[VIP] Granted %d days of VIP %s to %s.", days, tierName, target:getName()))

    return false
end

talk:separator(" ")
talk:register()
