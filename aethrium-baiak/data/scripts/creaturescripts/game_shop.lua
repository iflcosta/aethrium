local DONATION_URL = "https://aethrium.com.br"
local GAME_SHOP = nil
local SECOND_CURRENCY_ENABLED = true  -- Task Points como segunda moeda

local ExtendedOPCodes = {
    CODE_GAMESHOP = 201
}

local shopInitialized = false

-- Garante que a tabela existe (caso a migration ainda não tenha rodado)
db.query([[
    CREATE TABLE IF NOT EXISTS `shop_history` (
        `id`         INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `account`    INT NOT NULL,
        `player_id`  INT NOT NULL,
        `date`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `title`      VARCHAR(255) NOT NULL,
        `price`      INT NOT NULL,
        `costSecond` TINYINT(1) NOT NULL DEFAULT 0,
        `count`      INT NOT NULL DEFAULT 0,
        `extra`      VARCHAR(255) NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
]])

-- ============================================================
-- Helpers de moeda (usa funções nativas do servidor)
-- ============================================================
local function getPoints(player)
    return player:getTibiaCoins()
end

local function getSecondCurrency(player)
    return player:getTaskPoints()
end

local function removePoints(player, amount)
    player:removeTibiaCoins(amount)
end

local function sanitizeStoreText(text)
    if type(text) ~= "string" then
        return ""
    end

    -- Keep only alphanumeric characters, common punctuation and spaces
    local cleaned = text:gsub("[^%w%s%p]", "")
    
    -- Normalize spacing
    cleaned = cleaned:gsub("%s+", " ")
    cleaned = cleaned:gsub("^%s+", "")
    cleaned = cleaned:gsub("%s+$", "")

    if cleaned == "" then
        return text
    end
    return cleaned
end

-- ============================================================
-- Mensagens helper
-- ============================================================
local function errorMsg(player, msg)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({action = "error", data = {message = msg}}))
end

local function infoMsg(player, msg, updatePoints)
    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({action = "info", data = {message = msg}}))
    if updatePoints then
        gameShopUpdatePoints(player)
        gameShopUpdateHistory(player)
    end
end

-- ============================================================
-- Atualiza saldo no cliente
-- ============================================================
function gameShopUpdatePoints(player)
    if type(player) == "number" then
        player = Player(player)
    end
    if not player then return end

    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({
        action = "points",
        data = {
            points = getPoints(player),
            secondPoints = getSecondCurrency(player)
        }
    }))
end

-- ============================================================
-- Histórico de compras
-- ============================================================
function gameShopUpdateHistory(player)
    if type(player) == "number" then
        player = Player(player)
    end
    if not player then return end

    local history = {}
    local accountId = player:getAccountId()

    local resultId = db.storeQuery("SELECT * FROM `shop_history` WHERE `account` = " .. accountId .. " ORDER BY `id` DESC LIMIT 50")
    if resultId ~= false then
        repeat
            table.insert(history, {
                date  = result.getDataString(resultId, "date"),
                price = result.getDataInt(resultId, "price"),
                isSecondPrice = result.getDataInt(resultId, "costSecond") == 1,
                name  = result.getDataString(resultId, "title"),
                count = result.getDataInt(resultId, "count")
            })
        until not result.next(resultId)
        result.free(resultId)
    end

    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({action = "history", data = history}))
end

-- ============================================================
-- Categorias e constantes
-- ============================================================
local CATEGORY_NONE     = -1
local CATEGORY_PREMIUM  =  0
local CATEGORY_ITEM     =  1
local CATEGORY_BLESSING =  2
local CATEGORY_OUTFIT   =  3
local CATEGORY_MOUNT    =  4
local CATEGORY_EXTRAS   =  5

local VIP_BRONZE_DESCRIPTION = "Activate 30 days of VIP Bronze:\n\n* exclusive Bronze outfits and mounts\n* XP bonus\n* access to VIP areas\n\n- grants a scroll sent to your backpack\n- use the scroll to activate"
local VIP_SILVER_DESCRIPTION = "Activate 30 days of VIP Silver:\n\n* all Bronze benefits\n* exclusive Silver outfits and mounts\n* higher XP bonus\n\n- grants a scroll sent to your backpack\n- use the scroll to activate"
local VIP_GOLD_DESCRIPTION   = "Activate 30 days of VIP Gold:\n\n* all Bronze and Silver benefits\n* exclusive Gold outfits and mounts\n* maximum XP bonus\n\n- grants a scroll sent to your backpack\n- use the scroll to activate"
local BLESSING_DESCRIPTION = "Reduces your character's chance to lose items and experience upon death.\n\n- only usable by purchasing character\n- maximum 5 blessings per character"
local HEALTH_POTION_DESCRIPTION = "Restores hit points.\n\n- will be sent to your backpack\n- requires Protection Zone"
local MANA_POTION_DESCRIPTION = "Refills mana.\n\n- will be sent to your backpack\n- requires Protection Zone"

-- ============================================================
-- Inicialização da loja (categorias e itens)
-- ============================================================
function gameShopInitialize()
    if shopInitialized then return end

    GAME_SHOP = {
        categories   = {},
        categoriesId = {},
        offers       = {}
    }

    -- VIP Account (todos usam o item 14758 com atributo vip_tier)
    addCategory(nil, "VIP Account", 20, CATEGORY_ITEM)
    addItem("VIP Account", "VIP Bronze (30 days)", 14758, 500,  false, 1, VIP_BRONZE_DESCRIPTION)
    addItem("VIP Account", "VIP Silver (30 days)", 14758, 1000, false, 1, VIP_SILVER_DESCRIPTION)
    addItem("VIP Account", "VIP Gold (30 days)",   14758, 2000, false, 1, VIP_GOLD_DESCRIPTION)

    -- Blessings
    addCategory(nil, "Blessings", 8, CATEGORY_BLESSING)
    addItem("Blessings", "All Blessings",           "All_regular_Blessings",    130, false, -1, BLESSING_DESCRIPTION)
    addItem("Blessings", "The Spiritual Shielding",  "The_Spiritual_Shielding",   25, false,  1, BLESSING_DESCRIPTION)
    addItem("Blessings", "The Embrace of Tibia",     "The_Embrace_of_Tibia",      25, false,  2, BLESSING_DESCRIPTION)
    addItem("Blessings", "The Fire of the Suns",     "The_Fire_of_the_Suns",      25, false,  3, BLESSING_DESCRIPTION)
    addItem("Blessings", "The Wisdom of Solitude",   "The_Wisdom_of_Solitude",    25, false,  4, BLESSING_DESCRIPTION)
    addItem("Blessings", "The Spark of the Phoenix", "The_Spark_of_the_Phoenix",  25, false,  5, BLESSING_DESCRIPTION)

    -- Potions
    addCategory(nil, "Potions", 10, CATEGORY_ITEM)
    addItem("Potions", "Health Potion",        266,  6,  false, 125, HEALTH_POTION_DESCRIPTION)
    addItem("Potions", "Health Potion",        266,  11, false, 300, HEALTH_POTION_DESCRIPTION)
    addItem("Potions", "Strong Health Potion", 236,  10, false, 100, HEALTH_POTION_DESCRIPTION)
    addItem("Potions", "Strong Health Potion", 236,  21, false, 250, HEALTH_POTION_DESCRIPTION)
    addItem("Potions", "Great Health Potion",  239,  18, false, 100, HEALTH_POTION_DESCRIPTION)
    addItem("Potions", "Mana Potion",          268,  6,  false, 125, MANA_POTION_DESCRIPTION)
    addItem("Potions", "Mana Potion",          268,  12, false, 300, MANA_POTION_DESCRIPTION)
    addItem("Potions", "Strong Mana Potion",   237,  7,  false, 100, MANA_POTION_DESCRIPTION)
    addItem("Potions", "Strong Mana Potion",   237,  17, false, 250, MANA_POTION_DESCRIPTION)
    addItem("Potions", "Great Mana Potion",    238,  11, false, 100, MANA_POTION_DESCRIPTION)

    -- Extra Services
    addCategory(nil, "Extra Services", 7, CATEGORY_EXTRAS)
    addItem("Extra Services", "Temple Teleport", "Temple_Teleport", 15, false, 1, "Teleports you instantly to your home temple.\n\n- cannot be used while in combat or PZ locked")
    addItem("Extra Services", "XP Boost",        "XP_Boost",        30, false, 1, "Increases experience gained by 50% for 1 hour of hunting time.")

    shopInitialized = true
end

-- ============================================================
-- Helpers para adicionar categorias/itens
-- ============================================================
function addCategory(parent, title, iconId, categoryId, description)
    title = sanitizeStoreText(title)
    if parent then parent = sanitizeStoreText(parent) end
    if description then description = sanitizeStoreText(description) end

    GAME_SHOP.categoriesId[title] = categoryId
    table.insert(GAME_SHOP.categories, {
        title      = title,
        parent     = parent,
        iconId     = iconId,
        categoryId = categoryId,
        description = description
    })
end

function addItem(parent, name, id, price, isSecondPrice, count, description)
    parent = sanitizeStoreText(parent)
    name = sanitizeStoreText(name)
    if description then description = sanitizeStoreText(description) end

    if not GAME_SHOP.offers[parent] then
        GAME_SHOP.offers[parent] = {}
    end

    local serverId = id
    if type(id) == "number" then
        if GAME_SHOP.categoriesId[parent] == CATEGORY_ITEM or GAME_SHOP.categoriesId[parent] == CATEGORY_EXTRAS then
            id = ItemType(id):getClientId()
        end
    end

    table.insert(GAME_SHOP.offers[parent], {
        parent       = parent,
        name         = name,
        serverId     = serverId,
        id           = id,
        price        = price,
        isSecondPrice = isSecondPrice,
        count        = count,
        description  = description,
        categoryId   = GAME_SHOP.categoriesId[parent]
    })
end

-- ============================================================
-- Fetch: envia categorias + ofertas + saldo ao cliente
-- ============================================================
function gameShopFetch(player)
    gameShopUpdatePoints(player)
    gameShopUpdateHistory(player)

    local filteredCategories = {}
    for _, category in ipairs(GAME_SHOP.categories) do
        table.insert(filteredCategories, category)
    end

    player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({
        action = "fetchBase",
        data   = {categories = filteredCategories, url = DONATION_URL}
    }))

    for category, offersTable in pairs(GAME_SHOP.offers) do
        local offersWithoutDesc = {}
        for _, offer in ipairs(offersTable) do
            local offerCopy = {}
            for k, v in pairs(offer) do
                if k ~= "description" then
                    offerCopy[k] = v
                end
            end
            table.insert(offersWithoutDesc, offerCopy)
        end
        player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({
            action = "fetchOffers",
            data   = {category = category, offers = offersWithoutDesc}
        }))
    end
end

-- ============================================================
-- Descrição de item
-- ============================================================
function gameShopGetDescription(player, data)
    local category = data.category
    local name = data.name

    if GAME_SHOP.offers[category] then
        for _, offer in ipairs(GAME_SHOP.offers[category]) do
            if offer.name == name then
                player:sendExtendedOpcode(ExtendedOPCodes.CODE_GAMESHOP, json.encode({
                    action = "fetchDescription",
                    data   = {category = category, name = name, description = offer.description}
                }))
                return
            end
        end
    end
end

-- ============================================================
-- Callbacks de compra
-- ============================================================
local VIP_SCROLL_ID = 14758
local VIP_TIER_BY_NAME = {
    ["VIP Bronze (30 days)"] = 1,
    ["VIP Silver (30 days)"] = 2,
    ["VIP Gold (30 days)"]   = 3,
}

local function defaultVipCallback(player, offer)
    local bp = player:getSlotItem(CONST_SLOT_BACKPACK)
    if not bp then
        return "You don't have a backpack."
    end
    if bp:getEmptySlots(true) <= 0 then
        return "You don't have enough space in your backpack."
    end

    local tier = VIP_TIER_BY_NAME[offer.name]
    if not tier then
        return "Something went wrong with this VIP offer."
    end

    local item = player:addItem(VIP_SCROLL_ID, 1, false)
    if not item then
        return "Could not create the scroll. Contact an admin."
    end

    item:setCustomAttribute("vip_tier", tostring(tier))
    return false
end

local function defaultPremiumCallback(player, offer)
    player:addPremiumDays(offer.count)
    return false
end

local function defaultItemCallback(player, offer)
    local inPz    = player:getTile():hasFlag(TILESTATE_PROTECTIONZONE)
    local inFight = player:isPzLocked() or player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT)

    if not inPz then
        return "You must be in a Protection Zone to buy items."
    end
    if inFight then
        return "Cannot be used while having a battle sign."
    end

    local weight = ItemType(offer.serverId):getWeight(offer.count)
    if player:getFreeCapacity() < weight then
        return "This item is too heavy for you!"
    end

    local bp = player:getSlotItem(CONST_SLOT_BACKPACK)
    if not bp then
        return "You don't have a backpack."
    end
    if bp:getEmptySlots(true) <= 0 then
        return "You don't have enough space in your backpack."
    end

    player:addItem(offer.serverId, offer.count, false)
    return false
end

local function defaultBlessingCallback(player, offer)
    if offer.count == -1 then
        local hasAll = true
        for i = 1, 5 do
            if not player:hasBlessing(i) then hasAll = false break end
        end
        if hasAll then return "You already have all blessings." end
        for i = 1, 5 do player:addBlessing(i) end
        return false
    end
    if player:hasBlessing(offer.count) then
        return "You already have this blessing."
    end
    player:addBlessing(offer.count)
    return false
end

local function defaultOutfitCallback(player, offer)
    local id = offer.id
    if offer.ids then
        id = player:getSex() == PLAYERSEX_MALE and offer.ids.male or offer.ids.female
    end
    if player:hasOutfit(id, offer.count) then
        return "You already have this outfit."
    end
    player:addOutfitAddon(id, offer.count)
    return false
end

local function defaultMountCallback(player, offer)
    local mountId = Game.getMountIdByClientId(offer.id)
    if player:hasMount(mountId) then
        return "You already have this mount."
    end
    if not player:addMount(mountId) then
        return "Something went wrong, mount cannot be added."
    end
    return false
end

local function defaultExtrasCallback(player, offer)
    if offer.name == "Temple Teleport" then
        local inFight = player:isPzLocked() or player:getCondition(CONDITION_INFIGHT, CONDITIONID_DEFAULT)
        if inFight then return "Cannot be used while in combat." end
        player:teleportTo(player:getTown():getTemplePosition())
        player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
        return false
    elseif offer.name == "XP Boost" then
        local boostStorage = 693690
        local boostDuration = 3600
        local currentBoostEnd = player:getStorageValue(boostStorage) or 0
        if currentBoostEnd >= os.time() then
            return "You already have an XP boost active!"
        end
        player:setStorageValue(boostStorage, os.time() + boostDuration)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Your one hour XP boost has started! +50% experience.")
        return false
    end
    return defaultItemCallback(player, offer)
end

local function finalizePurchase(player, offer)
    if offer.parent == "VIP Account" then return defaultVipCallback(player, offer) end
    local categoryId = GAME_SHOP.categoriesId[offer.parent]
    if categoryId == CATEGORY_PREMIUM  then return defaultPremiumCallback(player, offer)
    elseif categoryId == CATEGORY_ITEM then return defaultItemCallback(player, offer)
    elseif categoryId == CATEGORY_BLESSING then return defaultBlessingCallback(player, offer)
    elseif categoryId == CATEGORY_OUTFIT then return defaultOutfitCallback(player, offer)
    elseif categoryId == CATEGORY_MOUNT  then return defaultMountCallback(player, offer)
    elseif categoryId == CATEGORY_EXTRAS then return defaultExtrasCallback(player, offer)
    end
    return "Something went wrong, try again or contact an admin."
end

-- ============================================================
-- Compra
-- ============================================================
function gameShopPurchase(player, offer)
    local offers = GAME_SHOP.offers[offer.parent]
    if not offers then
        return errorMsg(player, "Something went wrong [#1]!")
    end

    for i = 1, #offers do
        local o = offers[i]
        if o.name == offer.name and o.price == offer.price and o.count == offer.count then
            local points = o.isSecondPrice and getSecondCurrency(player) or getPoints(player)

            if o.price > points then
                return errorMsg(player, "You don't have enough points!")
            end

            offer.serverId = o.serverId
            local status = finalizePurchase(player, offer)
            if status then
                return errorMsg(player, status)
            end

            -- Debita moeda
            if o.isSecondPrice then
                removeSecondCurrency(player, o.price)
            else
                removePoints(player, o.price)
            end

            -- Histórico
            local accountId = player:getAccountId()
            db.asyncQuery(string.format(
                "INSERT INTO `shop_history` VALUES (NULL, %d, %d, NOW(), %s, %d, %d, %d, NULL)",
                accountId,
                player:getGuid(),
                db.escapeString(o.name),
                -o.price,
                o.isSecondPrice and 1 or 0,
                o.count or 0
            ))

            return infoMsg(player, "You've bought " .. o.name .. "!", true)
        end
    end

    return errorMsg(player, "Something went wrong [#3]!")
end

-- ============================================================
-- Registro dos eventos
-- ============================================================
local LoginEvent = CreatureEvent("GameShopLogin")
function LoginEvent.onLogin(player)
    player:registerEvent("GameShopExtended")
    return true
end
LoginEvent:register()

local ExtendedEvent = CreatureEvent("GameShopExtended")
function ExtendedEvent.onExtendedOpcode(player, opcode, buffer)
    if opcode ~= ExtendedOPCodes.CODE_GAMESHOP then
        return true
    end

    if not shopInitialized then
        gameShopInitialize()
    end

    local ok, json_data = pcall(function() return json.decode(buffer) end)
    if not ok or type(json_data) ~= "table" then
        return true
    end

    local action = json_data.action
    local data   = json_data.data
    if not action or not data then return true end

    if action == "fetch" then
        gameShopFetch(player)
    elseif action == "getDescription" then
        gameShopGetDescription(player, data)
    elseif action == "purchase" then
        gameShopPurchase(player, data)
    end

    return true
end
ExtendedEvent:register()
