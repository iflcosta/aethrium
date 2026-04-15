-- VIP System — Login Handler
-- Verifies expiration, applies XP bonus, grants/revokes outfits and mounts

local VIP_TIER_NAMES = { [1] = "Bronze", [2] = "Silver", [3] = "Gold" }

-- Outfits granted per tier (male looktypes)
-- Each tier includes all tiers below it (cumulative)
local VIP_OUTFITS = {
    [1] = { 134, 143, 152, 154, 289 },         -- Bronze: Warrior, Barbarian, Assassin, Shaman, Demon Hunter
    [2] = { 268, 432, 465, 884, 899 },          -- Silver: Nightmare, Elementalist, Insectoid, Arena Champion, Lupine Warden
    [3] = { 541, 512, 665, 667, 846, 1202,      -- Gold: Demon, Crystal Warlord, Chaos Acolyte, Death Herald, Rift Warrior,
            1444, 1489, 1675, 1680, 1713,        --       Void Master, Dragon Knight, Ghost Blade, Darklight Evoker, Flamefury Mage,
            1725, 1745, 1809, 1831, 1824 },      --       Doom Knight, Celestial Avenger, Blade Dancer, Fiend Slayer, Winged Druid, Monk
}

-- Female looktypes (same order as male)
local VIP_OUTFITS_FEMALE = {
    [1] = { 142, 147, 156, 158, 288 },
    [2] = { 269, 433, 466, 885, 900 },
    [3] = { 542, 513, 664, 666, 845, 1203,
            1445, 1490, 1676, 1681, 1714,
            1726, 1746, 1808, 1832, 1825 },
}

-- Standard premium outfits that should get addons for VIP players
local PREMIUM_STANDARD_OUTFITS_MALE = { 128, 129, 130, 131, 132, 133, 134, 143, 144, 145, 146 }
local PREMIUM_STANDARD_OUTFITS_FEMALE = { 136, 137, 138, 139, 140, 141, 142, 147, 148, 149, 150 }

-- Mount IDs (server mount id from mounts.xml)
local VIP_MOUNTS = {
    [1] = { 17, 16, 5, 6, 11 },               -- Bronze: War Horse, Crystal Wolf, Midnight Panther, Draptor, Stampor
    [2] = { 40, 9, 31, 39, 106 },             -- Silver: Noble Lion, Blazebringer, Dragonling, The Hellgrip, Stone Rhino
    [3] = { 144, 184, 175, 174, 87,           -- Gold: Gryphon, Singeing Steed, Krakoloss, White Lion, Rift Runner,
            99,  179, 180, 181, 94,            --       Vortexion, Void Watcher, Rune Watcher, Rift Watcher, Sparkion,
            98,  206, 202, 167, 162 },         --       Neon Sparkid, Mutated Abomination, Ripptor, Phantasmal Jade, Haze
}

local function getAllTierOutfits(tier, isFemale)
    local result = {}
    local source = isFemale and VIP_OUTFITS_FEMALE or VIP_OUTFITS
    for t = 1, tier do
        for _, v in ipairs(source[t] or {}) do
            result[#result + 1] = v
        end
    end
    return result
end

local function getAllTierMounts(tier)
    local result = {}
    for t = 1, tier do
        for _, v in ipairs(VIP_MOUNTS[t] or {}) do
            result[#result + 1] = v
        end
    end
    return result
end

local function grantVipRewards(player, tier)
    local isFemale = player:getSex() == PLAYERSEX_FEMALE
    local outfits = getAllTierOutfits(tier, isFemale)
    local mounts  = getAllTierMounts(tier)
    
    -- Standard premium outfits that get addons
    local standardOutfits = isFemale and PREMIUM_STANDARD_OUTFITS_FEMALE or PREMIUM_STANDARD_OUTFITS_MALE
    for _, looktype in ipairs(standardOutfits) do
        player:addOutfitAddon(looktype, 3)
    end

    -- VIP-specific outfits (also with addons)
    for _, looktype in ipairs(outfits) do
        player:addOutfitAddon(looktype, 3)
    end

    for _, mountId in ipairs(mounts) do
        player:addMount(mountId)
    end
end

local function revokeAllVipRewards(player)
    for tier = 1, 3 do
        local isFemale = player:getSex() == PLAYERSEX_FEMALE
        local outfits = getAllTierOutfits(tier, isFemale)
        local mounts  = getAllTierMounts(tier)
        for _, looktype in ipairs(outfits) do
            player:removeOutfit(looktype)
        end
        for _, mountId in ipairs(mounts) do
            player:removeMount(mountId)
        end
    end
end

local loginEvent = CreatureEvent("VipLogin")

function loginEvent.onLogin(player)
    local tier = player:getVipTier()

    -- Check expiration
    if tier > 0 and not player:isVip() then
        revokeAllVipRewards(player)
        player:setVip(0, 0)
        player:sendTextMessage(MESSAGE_STATUS_WARNING, "[VIP] Your VIP has expired.")
        return true
    end

    if tier > 0 then
        -- Grant outfits/mounts in case they were missing
        grantVipRewards(player, tier)

        -- Apply XP bonus
        local xpBonus = player:getVipXpBonus()
        if xpBonus > 0 then
            player:setExperienceRate(ExperienceRateType.BONUS, 100 + xpBonus)
        end

        -- Warn if expiring soon
        local days = player:getVipDaysRemaining()
        if days <= 3 then
            player:sendTextMessage(MESSAGE_STATUS_WARNING,
                string.format("[VIP] Your VIP %s expires in %d day(s)!",
                    VIP_TIER_NAMES[tier] or "", days))
        else
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE,
                string.format("[VIP] Welcome! VIP %s active — %d days remaining.",
                    VIP_TIER_NAMES[tier] or "", days))
        end
    end

    return true
end

loginEvent:register()
