--[[
    Aethrium Aetherite & Crafting System
    Phase 4: Recipe Database
    Developer: Antigravity (Senior AI Coding Assistant)

    INSTRUÇÕES: 
    1. Ajuste os IDs dos itens nos campos 'resultId' e 'baseItemId' conforme sua itens.xml.
    2. 'ingredients' suporta múltiplos itens.
]]--

AetheriteRecipes = {
    -- SKILL IDs
    SKILL_COLETA = 1,
    SKILL_REFINO = 2,
    SKILL_CRAFTING = 3,

    -- CONSTANTS
    SOLID_ID = 2154,
    STORE_ESSENCE_ID = 25555, -- Placeholder para Item da Store

    -- RECIPE LIST
    -- Estrutura: { name, vocation, tier, ingredients, gold, resultId, chance, masterworkChance }
    items = {
        -- KNIGHT EXAMPLES
        [1] = {
            name = "Aetherite Platemail (T1)",
            vocation = "knight",
            tier = 1,
            baseItemId = 28719, -- Falcon Plate
            ingredients = { {id = 2154, count = 25} },
            gold = 1000000,
            resultId = 25000, -- Placeholder New Item
            chance = 70,
            mwChance = 5
        },
        [2] = {
            name = "Soverign Aetherite Platemail (T2)",
            vocation = "knight",
            tier = 2,
            baseItemId = 25000, 
            ingredients = { {id = 2154, count = 50} },
            gold = 5000000,
            resultId = 25001,
            chance = 50,
            mwChance = 8
        },
        [3] = {
            name = "Eternal Aetherite Platemail (T3)",
            vocation = "knight",
            tier = 3,
            baseItemId = 25001, 
            ingredients = { {id = 2154, count = 100}, {id = 25555, count = 1} },
            gold = 10000000,
            resultId = 25002,
            chance = 40,
            mwChance = 15
        },

        -- PALADIN EXAMPLES
        [10] = {
            name = "Aetherite Bow (T1)",
            vocation = "paladin",
            tier = 1,
            baseItemId = 28718, -- Falcon Bow
            ingredients = { {id = 2154, count = 25} },
            gold = 1000000,
            resultId = 25100,
            chance = 70,
            mwChance = 5
        },

        -- MAGE EXAMPLES
        [20] = {
            name = "Aetherite Wand (T1)",
            vocation = "mage",
            tier = 1,
            baseItemId = 30399, -- Cobra Wand
            ingredients = { {id = 2154, count = 25} },
            gold = 1000000,
            resultId = 25200,
            chance = 70,
            mwChance = 5
        }
    }
}

-- Helper function to get all recipes (Universal Crafting)
function AetheriteRecipes.getAll()
    local result = {}
    for id, recipe in pairs(AetheriteRecipes.items) do
        local copy = {}
        for k, v in pairs(recipe) do copy[k] = v end
        copy.id = id -- Store original ID
        table.insert(result, copy)
    end
    return result
end
