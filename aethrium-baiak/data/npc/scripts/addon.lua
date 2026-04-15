local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local addonTrades = {
    {
        outfit = 128,
        name = "Citizen",
        addon = 1,
        items = {
            {id = 5878, count = 10, name = "Spider Silk"},
            {id = 5890, count = 10, name = "Felbat Leather"}
        },
        price = 0
    },
    {
        outfit = 128,
        name = "Citizen",
        addon = 2,
        items = {
            {id = 5878, count = 20, name = "Spider Silk"},
            {id = 5890, count = 20, name = "Felbat Leather"}
        },
        price = 0
    },
    {
        outfit = 129,
        name = "Hunter",
        addon = 1,
        items = {
            {id = 5878, count = 15, name = "Spider Silk"},
            {id = 5944, count = 1, name = "Assassin Star"}
        },
        price = 0
    },
    {
        outfit = 129,
        name = "Hunter",
        addon = 2,
        items = {
            {id = 5878, count = 25, name = "Spider Silk"},
            {id = 5902, count = 1, name = "Piece of Dead Brain"}
        },
        price = 0
    },
    {
        outfit = 130,
        name = "Mage",
        addon = 1,
        items = {
            {id = 2181, count = 5, name = "Empty"},
            {id = 2185, count = 5, name = "Strong"}
        },
        price = 0
    },
    {
        outfit = 130,
        name = "Mage",
        addon = 2,
        items = {
            {id = 2181, count = 10, name = "Empty"},
            {id = 2185, count = 10, name = "Strong"}
        },
        price = 0
    },
    {
        outfit = 131,
        name = "Knight",
        addon = 1,
        items = {
            {id = 2456, count = 1, name = "Brass Armor"},
            {id = 2460, count = 1, name = "Brass Helmet"}
        },
        price = 0
    },
    {
        outfit = 131,
        name = "Knight",
        addon = 2,
        items = {
            {id = 2476, count = 1, name = "Brass Legs"},
            {id = 2643, count = 1, name = "Brass Shield"}
        },
        price = 0
    },
    {
        outfit = 133,
        name = "Noble",
        addon = 1,
        items = {
            {id = 2148, count = 500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 133,
        name = "Noble",
        addon = 2,
        items = {
            {id = 2148, count = 1000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 134,
        name = "Summoner",
        addon = 1,
        items = {
            {id = 2260, count = 10, name = "Mana Potion"},
            {id = 2173, count = 1, name = "Spellbook of Enlightenment"}
        },
        price = 0
    },
    {
        outfit = 134,
        name = "Summoner",
        addon = 2,
        items = {
            {id = 2260, count = 20, name = "Mana Potion"},
            {id = 2173, count = 1, name = "Spellbook of DRAGONS"}
        },
        price = 0
    },
    {
        outfit = 137,
        name = "Ninja",
        addon = 1,
        items = {
            {id = 2148, count = 2000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 137,
        name = "Ninja",
        addon = 2,
        items = {
            {id = 2148, count = 3000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 138,
        name = "Barbarian",
        addon = 1,
        items = {
            {id = 2148, count = 1000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 138,
        name = "Barbarian",
        addon = 2,
        items = {
            {id = 2148, count = 1500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 139,
        name = "Pirate",
        addon = 1,
        items = {
            {id = 2148, count = 800, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 139,
        name = "Pirate",
        addon = 2,
        items = {
            {id = 2148, count = 1200, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 140,
        name = "Assassin",
        addon = 1,
        items = {
            {id = 2148, count = 1500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 140,
        name = "Assassin",
        addon = 2,
        items = {
            {id = 2148, count = 2000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 141,
        name = "Beggar",
        addon = 1,
        items = {
            {id = 2148, count = 500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 141,
        name = "Beggar",
        addon = 2,
        items = {
            {id = 2148, count = 800, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 142,
        name = "Shaman",
        addon = 1,
        items = {
            {id = 2148, count = 1000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 142,
        name = "Shaman",
        addon = 2,
        items = {
            {id = 2148, count = 1500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 143,
        name = "Norse",
        addon = 1,
        items = {
            {id = 2148, count = 800, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 143,
        name = "Norse",
        addon = 2,
        items = {
            {id = 2148, count = 1200, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 144,
        name = "Jester",
        addon = 1,
        items = {
            {id = 2148, count = 600, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 144,
        name = "Jester",
        addon = 2,
        items = {
            {id = 2148, count = 900, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 145,
        name = "Elf",
        addon = 1,
        items = {
            {id = 2148, count = 2000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 145,
        name = "Elf",
        addon = 2,
        items = {
            {id = 2148, count = 3000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 146,
        name = "Dwarf",
        addon = 1,
        items = {
            {id = 2148, count = 2000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 146,
        name = "Dwarf",
        addon = 2,
        items = {
            {id = 2148, count = 3000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 147,
        name = "Druid",
        addon = 1,
        items = {
            {id = 2148, count = 1500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 147,
        name = "Druid",
        addon = 2,
        items = {
            {id = 2148, count = 2000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 148,
        name = "Party Girl",
        addon = 1,
        items = {
            {id = 2148, count = 800, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 148,
        name = "Party Girl",
        addon = 2,
        items = {
            {id = 2148, count = 1200, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 149,
        name = "Merchant",
        addon = 1,
        items = {
            {id = 2148, count = 500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 149,
        name = "Merchant",
        addon = 2,
        items = {
            {id = 2148, count = 800, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 150,
        name = "Warrior",
        addon = 1,
        items = {
            {id = 2148, count = 2500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 150,
        name = "Warrior",
        addon = 2,
        items = {
            {id = 2148, count = 3500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 155,
        name = "Old",
        addon = 1,
        items = {
            {id = 2148, count = 300, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 155,
        name = "Old",
        addon = 2,
        items = {
            {id = 2148, count = 500, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 156,
        name = "Recruiter",
        addon = 1,
        items = {
            {id = 2148, count = 1000, name = "Gold Coin"}
        },
        price = 0
    },
    {
        outfit = 156,
        name = "Recruiter",
        addon = 2,
        items = {
            {id = 2148, count = 1500, name = "Gold Coin"}
        },
        price = 0
    }
}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end

npcHandler:addModule(FocusModule:new())

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
    local player = Player(cid)
    local msg = msg:lower()
    
    if msg == "addons" or msg == "addon" or msg == "addons?" then
        local text = "--- Armeiro - Troca de Addons ---\n\n"
        text = text .. "Voce pode trocar itens por addons de outfits. Diga {lista} para ver todas as opcoes.\n"
        text = text .. "Ou me diga o nome da outfit que voce quer o addon. Exemplo: {noble}\n\n"
        text = text .. "Para trocar, diga: {trocar} [nome da outfit] [addon 1 ou 2]"
        
        npcHandler:say(text, cid)
        npcHandler.topic[cid] = 1
        
    elseif msg == "lista" or msg == "list" then
        local text = "--- Addons Disponiveis ---\n\n"
        
        local grouped = {}
        for _, trade in ipairs(addonTrades) do
            if not grouped[trade.outfit] then
                grouped[trade.outfit] = {
                    name = trade.name,
                    addon1 = trade,
                    addon2 = nil
                }
            end
            if trade.addon == 2 then
                grouped[trade.outfit].addon2 = trade
            end
        end
        
        for outfitId, data in pairs(grouped) do
            text = text .. "[" .. outfitId .. "] " .. data.name .. "\n"
            
            if data.addon1 then
                text = text .. "   Addon 1: "
                for i, item in ipairs(data.addon1.items) do
                    text = text .. item.count .. "x " .. item.name .. (i < #data.addon1.items and ", " or "")
                end
                text = text .. "\n"
            end
            
            if data.addon2 then
                text = text .. "   Addon 2: "
                for i, item in ipairs(data.addon2.items) do
                    text = text .. item.count .. "x " .. item.name .. (i < #data.addon2.items and ", " or "")
                end
                text = text .. "\n"
            end
            text = text .. "\n"
        end
        
        text = text .. "Para trocar, use: {trocar} [outfit] [addon]"
        player:showTextDialog(1949, text)
        npcHandler:say("Aqui esta a lista completa de addons!", cid)
        
    elseif msg == "trocar" or msg == "exchange" then
        npcHandler:say("Me diga o nome da outfit e o numero do addon que deseja trocar. Exemplo: trocar noble 1", cid)
        npcHandler.topic[cid] = 2
        
    elseif npcHandler.topic[cid] == 2 then
        local outfitName, addonNum = msg:match("(%w+)%s+(%d+)")
        addonNum = tonumber(addonNum)
        
        if not outfitName or not addonNum or addonNum < 1 or addonNum > 2 then
            npcHandler:say("Formato invalido. Use: trocar [nome da outfit] [1 ou 2]", cid)
            return true
        end
        
        local trade = nil
        for _, t in ipairs(addonTrades) do
            if t.name:lower() == outfitName and t.addon == addonNum then
                trade = t
                break
            end
        end
        
        if not trade then
            npcHandler:say("Outfit ou addon invalido. Use {lista} para ver as opcoes.", cid)
            npcHandler.topic[cid] = 0
            return true
        end
        
        local hasOutfit = player:hasOutfit(trade.outfit)
        if not hasOutfit then
            npcHandler:say("Voce precisa ter a outfit " .. trade.name .. " para receber o addon.", cid)
            npcHandler.topic[cid] = 0
            return true
        end
        
        local hasAddon = player:hasOutfit(trade.outfit, addonNum)
        if hasAddon then
            npcHandler:say("Voce ja possui o addon " .. addonNum .. " da outfit " .. trade.name .. ".", cid)
            npcHandler.topic[cid] = 0
            return true
        end
        
        local hasItems = true
        local missingItems = {}
        
        for _, item in ipairs(trade.items) do
            if not player:removeItem(item.id, item.count) then
                hasItems = false
                table.insert(missingItems, item.name .. " x" .. item.count)
            end
        end
        
        if not hasItems then
            npcHandler:say("Voce precisa dos seguintes itens: " .. table.concat(missingItems, ", "), cid)
            npcHandler.topic[cid] = 0
            return true
        end
        
        player:addOutfitAddon(trade.outfit, addonNum)
        npcHandler:say("Parabens! Voce agora tem o addon " .. addonNum .. " da outfit " .. trade.name .. "!", cid)
        
        npcHandler.topic[cid] = 0
    else
        for _, trade in ipairs(addonTrades) do
            if trade.name:lower() == msg then
                local text = "--- Addon " .. trade.addon .. " da outfit " .. trade.name .. " ---\n\n"
                text = text .. "Itens necessarios:\n"
                
                for i, item in ipairs(trade.items) do
                    text = text .. "- " .. item.count .. "x " .. item.name .. "\n"
                end
                
                text = text .. "\nPara trocar, diga: {trocar} " .. trade.name:lower() .. " " .. trade.addon
                
                player:showTextDialog(1949, text)
                npcHandler:say("Aqui estao os itens necessarios!", cid)
                return true
            end
        end
    end
    
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)