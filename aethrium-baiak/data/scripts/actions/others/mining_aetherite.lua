--[[
    Aethrium Aetherite & Crafting System
    Phase 2: Active gathering (Mining)
    Developer: Antigravity (Senior AI Coding Assistant)
]]--

local CRYSTAL_ID = 13537
local DEPLETED_ID = 13539
local RAW_AETHERITE_ID = 2150
local COOLDOWN_MINUTES = 5

local miningAction = Action()

function miningAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Verify if player has a pick/tool
    local hasTool = player:getItemCount(2553) > 0 or player:getItemCount(10515) > 0
    if not hasTool then
        player:sendCancelMessage("Voc precisa de uma picareta para minerar este cristal.")
        return true
    end

    -- Visual Effect
    toPosition:sendMagicEffect(CONST_ME_BLOCKHIT)
    
    -- Luck & Level Logic
    local level = AetheriteSystem.getLevel(player, AetheriteSystem.SKILL_COLETA)
    local yieldCount = math.random(1, 2)
    
    -- Bonus based on level (every 20 levels = +1 potential stone)
    if level >= 20 then
        yieldCount = yieldCount + math.floor(level / 20)
    end

    -- Give Item
    local rawItem = player:addItem(RAW_AETHERITE_ID, yieldCount)
    if rawItem then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Voc minerou %d Aetherita Bruta.", yieldCount))
        
        -- Give XP (Base 50 * yield)
        AetheriteSystem.addXP(player, AetheriteSystem.SKILL_COLETA, 50 * yieldCount)

        -- Deplete Crystal
        target:transform(DEPLETED_ID)
        addEvent(function(pos)
            local tile = Tile(pos)
            if tile then
                local item = tile:getItemById(DEPLETED_ID)
                if item then
                    item:transform(CRYSTAL_ID)
                end
            end
        end, COOLDOWN_MINUTES * 60 * 1000, toPosition)
    end

    return true
end

miningAction:id(CRYSTAL_ID)
miningAction:register()
