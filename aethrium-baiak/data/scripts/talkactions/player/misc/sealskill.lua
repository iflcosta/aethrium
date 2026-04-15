-- Skill Seal System
-- The player purchases a Skill Seal via the Reset modal (opcode 180, action "buy_seal")
-- This talkaction is a fallback: !sealskill <skillname>
-- Sealing costs Tibia Coins (deducted from account balance via db)

local SKILL_SEAL_PRICE = 50  -- Tibia Coins per skill sealed

local SKILL_MAP = {
    ["fist"]       = 0,
    ["club"]       = 1,
    ["sword"]      = 2,
    ["axe"]        = 3,
    ["distance"]   = 4,
    ["dist"]       = 4,
    ["shielding"]  = 5,
    ["shield"]     = 5,
    ["fishing"]    = 6,
    ["magic"]      = 12,
    ["ml"]         = 12,
    ["magiclevel"] = 12,
}

local function getAccountCoins(accountId)
    local result = db.storeQuery(
        "SELECT `points` FROM `znote_accounts` WHERE `account_id` = " .. accountId)
    if not result then return 0 end
    local coins = result.getDataInt(result, "points")
    result.free(result)
    return coins
end

local function deductCoins(accountId, amount)
    db.query(
        "UPDATE `znote_accounts` SET `points` = `points` - " .. amount ..
        " WHERE `account_id` = " .. accountId)
end

local talk = TalkAction("!sealskill")

function talk.onSay(player, words, param)
    if not configManager.getBoolean(RESET_SYSTEM_ENABLED) then
        player:sendCancelMessage("The reset system is currently disabled.")
        return false
    end

    param = param:lower():gsub("%s+", "")
    local skillId = SKILL_MAP[param]

    if skillId == nil then
        player:sendCancelMessage(
            "Invalid skill name. Use: fist, club, sword, axe, distance, shielding, fishing, magic")
        return false
    end

    if player:isSkillSealed(skillId) then
        player:sendCancelMessage("That skill is already sealed for your next reset.")
        return false
    end

    local accountId = player:getAccountId()
    local coins = getAccountCoins(accountId)

    if coins < SKILL_SEAL_PRICE then
        player:sendCancelMessage(
            "You need " .. SKILL_SEAL_PRICE .. " Tibia Coins to seal a skill. You have: " .. coins)
        return false
    end

    deductCoins(accountId, SKILL_SEAL_PRICE)
    player:sealSkill(skillId)

    -- Log to shop_history
    db.asyncQuery(
        "INSERT INTO `shop_history` VALUES (NULL, " .. accountId ..
        ", " .. player:getGuid() ..
        ", NOW(), 'Skill Seal: " .. param .. "'" ..
        ", " .. (-SKILL_SEAL_PRICE) ..
        ", 0, 1, NULL)")

    local skillName = param:gsub("^%l", string.upper)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        "Skill Seal applied to " .. skillName .. "! It will be protected during your next reset. (" ..
        SKILL_SEAL_PRICE .. " Tibia Coins deducted.)")

    return false
end

talk:register()
