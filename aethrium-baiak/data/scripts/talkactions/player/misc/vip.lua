-- VIP System — !vip status talkaction
-- Opens the client modal via opcode 181

local VIP_OPCODE = 181

local VIP_TIER_NAMES = { [0] = "None", [1] = "Bronze", [2] = "Silver", [3] = "Gold" }

local VIP_BENEFITS = {
    [1] = { xp = 10, loot = 10, depot = 25000, autoloot = 15 },
    [2] = { xp = 20, loot = 15, depot = 35000, autoloot = 20 },
    [3] = { xp = 30, loot = 25, depot = 50000, autoloot = 30 },
}

local function buildStatusData(player)
    local tier = player:getVipTier()
    local active = player:isVip()
    local days = player:getVipDaysRemaining()
    local benefits = VIP_BENEFITS[tier] or {}

    return {
        action        = "open",
        tier          = tier,
        tierName      = VIP_TIER_NAMES[tier] or "None",
        active        = active,
        daysRemaining = days,
        expiresAt     = active and os.date("%d/%m/%Y", player:getVipExpires()) or nil,
        xpBonus       = benefits.xp or 0,
        lootBonus     = benefits.loot or 0,
        depot         = benefits.depot or 0,
        autoloot      = benefits.autoloot or 0,
        blessDiscount = (tier == 3) and 50 or 0,
    }
end

local talk = TalkAction("!vip")

function talk.onSay(player, words, param)
    print("[Debug] !vip command triggered for " .. player:getName())

    if not json then
        print("[Error] JSON library not found!")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error: JSON library not found.")
        return false
    end

    local status, data = pcall(buildStatusData, player)
    if not status then
        print("[Error] Failed to build status data: " .. tostring(data))
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error: Internal script error.")
        return false
    end

    local ok, encoded = pcall(json.encode, data)
    if not ok then
        print("[Error] JSON encoding failed: " .. tostring(encoded))
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error: JSON encoding failed.")
        return false
    end

    print("[Debug] Sending Opcode 181: " .. encoded)
    player:sendExtendedOpcode(VIP_OPCODE, encoded)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "VIP Status request sent.")
    return false
end

talk:register()
