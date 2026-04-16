--[[
    Aethrium Aetherite & Crafting System
    Phase 2: Economy & Refining
    Developer: Antigravity (Senior AI Coding Assistant)
]]--

local RAW_AETHERITE_ID = 2150
local SOLID_AETHERITE_ID = 2154
local FORGE_ID = 8636

local BASE_DUST_PER_RAW = 50
local BASE_DUST_FOR_SOLID = 500

local refiningAction = Action()

function refiningAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- If using Raw Aetherite ON the Forge
    if item:getId() == RAW_AETHERITE_ID then
        if target:getId() ~= FORGE_ID then
            return false
        end

        local count = item:getCount()
        local level = AetheriteSystem.getLevel(player, AetheriteSystem.SKILL_REFINO)
        
        -- Scaling: +1% dust per level (up to +100% at lvl 100)
        local bonusMult = 1.0 + (level / 100)
        local totalDust = math.floor(count * BASE_DUST_PER_RAW * bonusMult)

        AetheriteSystem.addDust(player, totalDust)
        AetheriteSystem.addXP(player, AetheriteSystem.SKILL_REFINO, 20 * count)
        
        item:remove()
        toPosition:sendMagicEffect(CONST_ME_FIREAREA)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Voc refinou %d Aetherita Bruta em %d Poeira de Aetherita.", count, totalDust))
        return true
    end

    -- If using the FORGE itself (Consolidate Dust into Solid)
    if item:getId() == FORGE_ID then
        local currentDust = AetheriteSystem.getDust(player)
        local level = AetheriteSystem.getLevel(player, AetheriteSystem.SKILL_REFINO)
        
        -- Discount logic: 0% at level 0, 50% at level 100
        local discountMult = 1.0 - (level / 200) -- max 0.5
        local cost = math.floor(BASE_DUST_FOR_SOLID * discountMult)

        if currentDust < cost then
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Voc precisa de pelo menos %d Dust para consolidar 1 Aetherita Slida (Saldo: %d).", cost, currentDust))
            return true
        end

        -- Consolidate as much as possible OR just 1 (Senior preference: max available)
        local amountToCreate = math.floor(currentDust / cost)
        local totalCost = amountToCreate * cost

        AetheriteSystem.addDust(player, -totalCost)
        player:addItem(SOLID_AETHERITE_ID, amountToCreate)
        
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Voc consolidou %d Dust em %d Aetherita Slida refinada.", totalCost, amountToCreate))
        toPosition:sendMagicEffect(CONST_ME_MAGIC_PURPLE)
        return true
    end

    return false
end

refiningAction:id(RAW_AETHERITE_ID)
refiningAction:id(FORGE_ID)
refiningAction:register()
