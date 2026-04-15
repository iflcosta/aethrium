-- Bless System — !buybless
-- Price: level * 1500 gold per bless (5 total)
-- VIP Gold: 50% discount (level * 750 per bless)

local BLESS_COUNT = 5
local BLESS_PRICE_PER_LEVEL = 1500
local BLESS_PRICE_VIP_GOLD  = 750

local talk = TalkAction("!buybless")

function talk.onSay(player, words, param)
    local level = player:getLevel()
    local isGold = player:isVip() and player:getVipTier() == 3

    local priceEach = level * (isGold and BLESS_PRICE_VIP_GOLD or BLESS_PRICE_PER_LEVEL)
    local totalPrice = priceEach * BLESS_COUNT

    -- Count missing blessings
    local missing = {}
    for i = 1, BLESS_COUNT do
        if not player:hasBlessing(i) then
            missing[#missing + 1] = i
        end
    end

    if #missing == 0 then
        player:sendCancelMessage("You already have all blessings.")
        return false
    end

    local costForMissing = priceEach * #missing

    if not player:removeTotalMoney(costForMissing) then
        player:sendCancelMessage(string.format(
            "You need %d gold for %d blessing(s) at %d gold each%s.",
            costForMissing, #missing, priceEach,
            isGold and " (VIP Gold 50%% off)" or ""))
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    for _, i in ipairs(missing) do
        player:addBlessing(i)
    end

    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("You received %d blessing(s) for %d gold%s. Total for all 5: %d gold.",
            #missing, costForMissing,
            isGold and " (VIP Gold 50% off)" or "",
            totalPrice))

    return false
end

talk:separator(" ")
talk:register()
