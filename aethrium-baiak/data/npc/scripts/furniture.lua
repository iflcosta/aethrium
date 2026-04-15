local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local shopItems = {
    -- Zaoan Decorations
    {id = 9774, name = "zaoan vase", price = 500},
    {id = 9775, name = "zaoan vase", price = 500},
    {id = 9776, name = "zaoan vase", price = 500},
    {id = 9777, name = "zaoan vase", price = 500},
    {id = 9778, name = "zaoan carpet", price = 800},
    {id = 9779, name = "zaoan carpet", price = 800},
    {id = 9780, name = "zaoan carpet", price = 800},
    {id = 9781, name = "zaoan carpet", price = 800},
    {id = 9782, name = "zaoan carpet", price = 800},
    {id = 9783, name = "zaoan carpet", price = 800},
    {id = 9784, name = "zaoan carpet", price = 800},
    {id = 9785, name = "zaoan carpet", price = 800},
    {id = 9786, name = "zaoan table", price = 1200},
    {id = 9787, name = "zaoan table", price = 1200},
    {id = 9788, name = "zaoan table", price = 1200},
    {id = 9789, name = "zaoan table", price = 1200},
    {id = 9790, name = "zaoan table", price = 1200},
    {id = 9791, name = "zaoan table", price = 1200},
    
    -- Serpent Decorations
    {id = 9796, name = "serpent statue", price = 1500},
    {id = 9797, name = "serpent statue", price = 1500},
    {id = 9798, name = "serpent statue", price = 1500},
    {id = 9799, name = "serpent statue", price = 1500},
    {id = 9800, name = "serpent statue", price = 1500},
    {id = 9801, name = "serpent statue", price = 1500},
    {id = 9980, name = "serpent carpet", price = 800},
    {id = 9981, name = "serpent carpet", price = 800},
    {id = 9982, name = "serpent carpet", price = 800},
    {id = 9983, name = "serpent carpet", price = 800},
    {id = 9984, name = "serpent carpet", price = 800},
    {id = 9985, name = "serpent carpet", price = 800},
    {id = 9986, name = "serpent carpet", price = 800},
    {id = 9987, name = "serpent carpet", price = 800},
    {id = 9988, name = "serpent carpet", price = 800},
    {id = 9989, name = "serpent carpet", price = 800},
    {id = 9990, name = "serpent carpet", price = 800},
    {id = 9991, name = "serpent carpet", price = 800},
    {id = 9992, name = "horn", price = 300},
    {id = 9993, name = "horn", price = 300},
    {id = 9994, name = "horn", price = 300},
    
    -- Wooden Decorations
    {id = 6993, name = "christmas tree", price = 2000},
    {id = 6994, name = "christmas tree", price = 2000},
    {id = 6995, name = "christmas tree", price = 2000},
    {id = 6996, name = "christmas tree", price = 2000},
    {id = 6997, name = "christmas tree", price = 2000},
    {id = 6998, name = "christmas tree", price = 2000},
    
    -- Bat Decorations
    {id = 6491, name = "bat decoration", price = 400},
    {id = 6492, name = "bat decoration", price = 400},
    {id = 6495, name = "bat decoration", price = 400},
    
    -- Skeleton Decoration
    {id = 6525, name = "skeleton decoration", price = 500},
    
    -- Decoration Kits
    {id = 23398, name = "decoration kit", price = 1000},
    
    -- Furniture Kit
    {id = 23473, name = "furniture kit", price = 1500},
    
    -- Large Decorative Mushroom
    {id = 15156, name = "large decorative mushroom", price = 250},
    {id = 15157, name = "large decorative mushroom", price = 250},
    
    -- Decorative Axe
    {id = 11090, name = "decorative axe", price = 600},
    {id = 11095, name = "decorative axe", price = 600},
    
    -- Decorative Shield
    {id = 11091, name = "decorative shield", price = 800},
    {id = 11092, name = "decorative shield", price = 800},
    
    -- Decorative Spear
    {id = 11182, name = "decorative spear", price = 500},
    {id = 11183, name = "decorative spear", price = 500},
    {id = 11184, name = "decorative spear", price = 500},
    {id = 11185, name = "decorative spear", price = 500},
    
    -- Knightly Decorative Shield
    {id = 39502, name = "knightly decorative shield", price = 1200},
    
    -- Decorative Ribbon
    {id = 16155, name = "decorative ribbon", price = 200},
}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

npcHandler:addModule(FocusModule:new())

local function setTopic(cid, topic)
    npcHandler.topic[cid] = topic
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
    local player = Player(cid)
    local msg = msg:lower()
    
    if msg == "loja" or msg == "shop" or msg == "items" then
        local text = "--- Moveleiro - Decoracao de Casas ---\n\n"
        text = text .. "{zanoan} - Moveis Zaoan\n"
        text = text .. "{serpent} - Decoracao Serpent\n"
        text = text .. "{natal} - Decoracoes de Natal\n"
        text = text .. "{diversos} - Itens Diversos\n"
        text = text .. "{todos} - Ver todos os itens\n"
        
        npcHandler:say(text, cid)
        npcHandler.topic[cid] = 1
        
    elseif npcHandler.topic[cid] == 1 then
        local itemsToShow = {}
        
        if msg == "zanoan" then
            for _, item in ipairs(shopItems) do
                if string.find(ItemType(item.id):getName(), "zaoan") then
                    table.insert(itemsToShow, item)
                end
            end
        elseif msg == "serpent" then
            for _, item in ipairs(shopItems) do
                if string.find(ItemType(item.id):getName(), "serpent") or string.find(ItemType(item.id):getName(), "horn") then
                    table.insert(itemsToShow, item)
                end
            end
        elseif msg == "natal" then
            for _, item in ipairs(shopItems) do
                if string.find(ItemType(item.id):getName(), "christmas") or string.find(ItemType(item.id):getName(), "bat") or string.find(ItemType(item.id):getName(), "skeleton") then
                    table.insert(itemsToShow, item)
                end
            end
        elseif msg == "diversos" or msg == "diverse" then
            for _, item in ipairs(shopItems) do
                local name = ItemType(item.id):getName()
                if not string.find(name, "zaoan") and not string.find(name, "serpent") and not string.find(name, "horn") 
                   and not string.find(name, "christmas") and not string.find(name, "bat") and not string.find(name, "skeleton") then
                    table.insert(itemsToShow, item)
                end
            end
        elseif msg == "todos" or msg == "all" then
            itemsToShow = shopItems
        end
        
        if #itemsToShow > 0 then
            local text = "--- Itens Disponiveis ---\n\n"
            for i = 1, math.min(#itemsToShow, 20) do
                local item = itemsToShow[i]
                local itemName = ItemType(item.id):getName()
                text = text .. "[" .. item.id .. "] " .. itemName .. " - " .. item.price .. " gp\n"
            end
            if #itemsToShow > 20 then
                text = text .. "\n... e mais " .. (#itemsToShow - 20) .. " itens."
            end
            text = text .. "\n\nPara comprar, diga: {comprar} [id] [quantidade]"
            player:showTextDialog(1949, text)
            npcHandler:say("Aqui esta a lista de itens!", cid)
        else
            npcHandler:say("Nenhum item encontrado nessa categoria.", cid)
        end
        
        npcHandler.topic[cid] = 0
        
    elseif msg == "comprar" or msg == "buy" then
        npcHandler:say("Por favor, me diga o ID do item e a quantidade. Exemplo: comprar 9774 1", cid)
        npcHandler.topic[cid] = 2
        
    elseif npcHandler.topic[cid] == 2 then
        local id, count = msg:match("(%d+)%s+(%d+)")
        id = tonumber(id)
        count = tonumber(count) or 1
        
        if not id then
            npcHandler:say("Formato invalido. Use: comprar [id] [quantidade]", cid)
            return true
        end
        
        local itemFound = false
        local price = 0
        
        for _, item in ipairs(shopItems) do
            if item.id == id then
                itemFound = true
                price = item.price
                break
            end
        end
        
        if not itemFound then
            npcHandler:say("Item nao encontrado na minha loja.", cid)
            npcHandler.topic[cid] = 0
            return true
        end
        
        local totalPrice = price * count
        
        if player:getMoney() >= totalPrice then
            player:removeMoney(totalPrice)
            local item = player:addItem(id, count)
            if item then
                npcHandler:say("Voce comprou " .. count .. "x " .. ItemType(id):getName() .. " por " .. totalPrice .. " gp!", cid)
            else
                player:addMoney(totalPrice)
                npcHandler:say("Nao foi possivel adicionar o item ao seu inventario.", cid)
            end
        else
            npcHandler:say("Voce precisa de " .. totalPrice .. " gp para comprar este item.", cid)
        end
        
        npcHandler.topic[cid] = 0
    end
    
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)