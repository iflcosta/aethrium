--[[
    Aethrium Aetherite & Crafting System
    Phase 1-4: Core Library & Crafting Engine
    Developer: Antigravity (Senior AI Coding Assistant)

    FIX: Using Global GUID cache instead of Metadata
]]--

-- Load Recipes
dofile("data/lib/core/aetherite_recipes.lua")

AetheriteSystem = {}
AetheriteSystem.SKILL_COLETA = 1
AetheriteSystem.SKILL_REFINO = 2
AetheriteSystem.SKILL_CRAFTING = 3

-- Global Cache for Session Data
AetheriteSystem.playerData = {}

-- XP Constants
AetheriteSystem.RATE_P1 = 1.8
AetheriteSystem.RATE_P2 = 1.2
AetheriteSystem.RATE_P3 = 0.6

AetheriteSystem.CAP_P1 = 999
AetheriteSystem.CAP_P2 = 60
AetheriteSystem.CAP_P3 = 30

-- DB Schema Helpers
function AetheriteSystem.loadPlayer(player)
    local guid = player:getGuid()
    local resultId = db.storeQuery(string.format("SELECT * FROM `player_aetherite_mastery` WHERE `player_id` = %d", guid))
    
    local data = {
        [AetheriteSystem.SKILL_COLETA] = { xp = 0, lvl = 1, priority = 1 },
        [AetheriteSystem.SKILL_REFINO] = { xp = 0, lvl = 1, priority = 2 },
        [AetheriteSystem.SKILL_CRAFTING] = { xp = 0, lvl = 1, priority = 3 },
        dust = 0
    }

    if resultId ~= false then
        data[1].xp = result.getNumber(resultId, "coleta_xp")
        data[2].xp = result.getNumber(resultId, "refino_xp")
        data[3].xp = result.getNumber(resultId, "craft_xp")
        
        data[1].priority = result.getNumber(resultId, "p1")
        data[2].priority = result.getNumber(resultId, "p2")
        data[3].priority = result.getNumber(resultId, "p3")
        
        data.dust = result.getNumber(resultId, "aetherite_dust")
        result.free(resultId)
    else
        -- Initialize new player in DB
        db.query(string.format("INSERT INTO `player_aetherite_mastery` (`player_id`, `p1`, `p2`, `p3`) VALUES (%d, 1, 2, 3)", guid))
    end

    -- Calculate levels from XP
    for i = 1, 3 do
        data[i].id = i
        data[i].lvl = AetheriteSystem.xpToLevel(data[i].xp)
    end

    AetheriteSystem.playerData[guid] = data
end

function AetheriteSystem.savePlayer(player)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if not data then return end

    local query = string.format([[
        UPDATE `player_aetherite_mastery` SET 
        `coleta_xp` = %d, `refino_xp` = %d, `craft_xp` = %d,
        `p1` = %d, `p2` = %d, `p3` = %d,
        `aetherite_dust` = %d
        WHERE `player_id` = %d]],
        data[1].xp, data[2].xp, data[3].xp,
        data[1].priority, data[2].priority, data[3].priority,
        data.dust, guid
    )
    db.query(query)
end

-- XP & LEVEL FORMULAS
function AetheriteSystem.xpToLevel(xp)
    if xp < 100 then return 1 end
    return math.floor(math.sqrt(xp / 100) + 1)
end

function AetheriteSystem.levelToXp(level)
    if level <= 1 then return 0 end
    return ((level - 1) ^ 2) * 100
end

-- GETTERS / SETTERS
function AetheriteSystem.getLevel(player, skillId)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if not data then 
        AetheriteSystem.loadPlayer(player)
        data = AetheriteSystem.playerData[guid]
    end
    return data and data[skillId].lvl or 1
end

function AetheriteSystem.getDust(player)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if not data then 
        AetheriteSystem.loadPlayer(player)
        data = AetheriteSystem.playerData[guid]
    end
    return data and data.dust or 0
end

function AetheriteSystem.addDust(player, amount)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if data then
        data.dust = math.max(0, data.dust + amount)
        AetheriteSystem.savePlayer(player)
    end
end

-- XP LOGIC
function AetheriteSystem.addXP(player, skillId, amount)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if not data then 
        AetheriteSystem.loadPlayer(player)
        data = AetheriteSystem.playerData[guid]
    end

    local skill = data[skillId]
    local priority = skill.priority
    
    local multiplier = AetheriteSystem.RATE_P1
    local cap = AetheriteSystem.CAP_P1
    
    if priority == 2 then
        multiplier = AetheriteSystem.RATE_P2
        cap = AetheriteSystem.CAP_P2
    elseif priority == 3 then
        multiplier = AetheriteSystem.RATE_P3
        cap = AetheriteSystem.CAP_P3
    end

    if skill.lvl >= cap then return end

    local oldLvl = skill.lvl
    skill.xp = skill.xp + math.floor(amount * multiplier)
    skill.lvl = AetheriteSystem.xpToLevel(skill.xp)

    if skill.lvl > oldLvl then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("Voc avanou no nvel de Mestria de Aetherita (%d)! Nvel atual: %d", skillId, skill.lvl))
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end
    
    AetheriteSystem.savePlayer(player)
end

-- PRIORITY SYSTEM
function AetheriteSystem.setPriority(player, skillId, newPriority)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if not data then return end

    -- Swap logic
    local currentSkillAtPriority = nil
    for i = 1, 3 do
        if data[i].priority == newPriority then
            currentSkillAtPriority = i
            break
        end
    end

    if currentSkillAtPriority then
        local oldPriority = data[skillId].priority
        
        -- Penalty: 30% XP if upgrading to 1st Focus
        if newPriority == 1 then
            data[skillId].xp = math.floor(data[skillId].xp * 0.7)
            data[skillId].lvl = AetheriteSystem.xpToLevel(data[skillId].xp)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Prioridade mxima alterada! Penalidade de 30% XP aplicada.")
        end

        data[currentSkillAtPriority].priority = oldPriority
        data[skillId].priority = newPriority
        
        AetheriteSystem.savePlayer(player)
    end
end

-- CRAFTING ENGINE
function AetheriteSystem.craftItem(player, recipeId)
    local recipe = AetheriteRecipes.items[recipeId]
    if not recipe then return false, "Receita não encontrada." end

    -- Cost Check (Gold)
    if not player:removeMoney(recipe.gold) then
        return false, "Você não tem ouro suficiente (Necessário: " .. recipe.gold .. ")."
    end

    -- Material Check
    for _, ing in ipairs(recipe.ingredients) do
        if player:getItemCount(ing.id) < ing.count then
            return false, "Você não tem todos os materiais necessários."
        end
    end

    -- Base Item Check
    local baseItem = nil
    if recipe.baseItemId and recipe.baseItemId > 0 then
        baseItem = player:getItemById(recipe.baseItemId, true)
        if not baseItem then
            return false, "Você precisa do item base para este upgrade."
        end
    end

    -- CONSUMPTION
    for _, ing in ipairs(recipe.ingredients) do
        player:removeItem(ing.id, ing.count)
    end
    if baseItem then baseItem:remove(1) end

    -- CALCULATION
    local craftingLvl = AetheriteSystem.getLevel(player, AetheriteSystem.SKILL_CRAFTING)
    local successChance = recipe.chance + (craftingLvl * 0.2)
    
    if math.random(1, 100) <= successChance then
        local newItem = player:addItem(recipe.resultId, 1)
        if newItem then
            local mwChance = recipe.mwChance + (craftingLvl * 0.1)
            if math.random(1, 100) <= mwChance then
                newItem:setAttribute(ITEM_ATTRIBUTE_MASTERWORKED, 1)
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "CRAFT SUCESSO! Voc criou um item MASTERWORKED!")
                player:getPosition():sendMagicEffect(CONST_ME_MAGIC_PURPLE)
            else
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "CRAFT SUCESSO! Voc criou: " .. recipe.name)
                player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
            end
            
            newItem:setAttribute(ITEM_ATTRIBUTE_CRAFTED, 1)
            newItem:setAttribute(ITEM_ATTRIBUTE_WRITER, player:getName())
            AetheriteSystem.addXP(player, AetheriteSystem.SKILL_CRAFTING, 500 * recipe.tier)
            return true
        end
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "CRAFT FALHOU! Os materiais foram consumidos.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        AetheriteSystem.addXP(player, AetheriteSystem.SKILL_CRAFTING, 100 * recipe.tier)
    end
    return true
end

-- UI DATA EXPORTER
function AetheriteSystem.getSkillData(player, skillId)
    local guid = player:getGuid()
    local data = AetheriteSystem.playerData[guid]
    if not data then 
        AetheriteSystem.loadPlayer(player)
        data = AetheriteSystem.playerData[guid]
    end
    
    local skill = data[skillId]
    return {
        id = skillId,
        lvl = skill.lvl,
        xp = skill.xp,
        nextXp = AetheriteSystem.levelToXp(skill.lvl + 1),
        priority = skill.priority
    }
end
