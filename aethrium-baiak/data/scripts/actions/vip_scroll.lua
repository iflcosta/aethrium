-- VIP System - Activation Scrolls
-- Uses item 14758 (premium scroll) with custom attribute "vip_tier" set at purchase.

local VIP_TIER_NAMES = { [1] = "Bronze", [2] = "Silver", [3] = "Gold" }
local VIP_DAYS = 30

local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local tier = tonumber(item:getCustomAttribute("vip_tier"))

    if not tier or not VIP_TIER_NAMES[tier] then
        return false
    end

    player:setVip(tier, VIP_DAYS)
    player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
        string.format("[VIP] You have activated %d days of VIP %s!", VIP_DAYS, VIP_TIER_NAMES[tier]))

    item:remove(1)
    return true
end

action:id(14758)
action:register()
