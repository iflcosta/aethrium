local OPCODE_LANGUAGE    = 1
local OPCODE_BATTLEPASS  = 150
local OPCODE_INSTANCES   = 151
local OPCODE_CRAFTING    = 152

-- Load Aetherite System
dofile("data/lib/core/aetherite_lib.lua")

local extendedOpcode = CreatureEvent("ExtendedOpcode")
function extendedOpcode.onExtendedOpcode(player, opcode, buffer)
    if opcode == OPCODE_LANGUAGE then
        -- language opcode received

    elseif opcode == OPCODE_BATTLEPASS then
        local ok, data = pcall(json.decode, buffer)
        if not ok or type(data) ~= "table" then
            print(string.format("[BattlePass] Bad JSON from %s: %s", player:getName(), tostring(buffer)))
            return true
        end

        local action = data.action
        if action == "open_request" then
            BattlePass.sendUpdate(player)
        elseif action == "buy_elite" then
            BattlePass.buyElite(player)
        elseif action == "claim" then
            local tier  = tonumber(data.tier)
            local track = data.track
            if tier and (track == "free" or track == "elite") then
                BattlePass.claimReward(player, tier, track)
            end
        end

    elseif opcode == OPCODE_CRAFTING then
        local ok, data = pcall(json.decode, buffer)
        if not ok or type(data) ~= "table" then
            print(string.format("[Crafting] Bad JSON from %s: %s", player:getName(), tostring(buffer)))
            return true
        end

        local action = data.action
        if action == "open_request" then
            local payload = {
                action = "open",
                dust = AetheriteSystem.getDust(player),
                skills = {
                    coleta = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_COLETA),
                    refino = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_REFINO),
                    crafting = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_CRAFTING)
                },
                recipes = AetheriteRecipes.getAll()
            }
            player:sendExtendedOpcode(OPCODE_CRAFTING, json.encode(payload))

        elseif action == "change_focus" then
            local skillId = tonumber(data.skillId)
            local priority = tonumber(data.priority)
            if skillId and priority then
                AetheriteSystem.setPriority(player, skillId, priority)
                -- Send update back
                player:sendExtendedOpcode(OPCODE_CRAFTING, json.encode({ 
                    action = "update_skills", 
                    skills = {
                        coleta = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_COLETA),
                        refino = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_REFINO),
                        crafting = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_CRAFTING)
                    }
                }))
            end

        elseif action == "craft" then
            local recipeId = tonumber(data.recipeId)
            if recipeId then
                local success, message = AetheriteSystem.craftItem(player, recipeId)
                if not success then
                    player:sendExtendedOpcode(OPCODE_CRAFTING, json.encode({ action = "error", message = message }))
                else
                    -- Send full update back
                    local payload = {
                        action = "open",
                        dust = AetheriteSystem.getDust(player),
                        skills = {
                            coleta = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_COLETA),
                            refino = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_REFINO),
                            crafting = AetheriteSystem.getSkillData(player, AetheriteSystem.SKILL_CRAFTING)
                        }
                    }
                    player:sendExtendedOpcode(OPCODE_CRAFTING, json.encode(payload))
                end
            end
        end

    elseif opcode == OPCODE_INSTANCES then
        local ok, data = pcall(json.decode, buffer)
        if not ok or type(data) ~= "table" then
            print(string.format("[Instances] Bad JSON from %s: %s", player:getName(), tostring(buffer)))
            return true
        end

        local action = data.action
        if action == "open_request" then
            local payload = {
                action     = "open",
                hunts      = HuntSystem.getUIData(player),
                bosses     = BossRoom.getUIData(player),
                taskPoints = player:getTaskPoints(),
                coins      = player:getTibiaCoins()
            }
            player:sendExtendedOpcode(OPCODE_INSTANCES, json.encode(payload))

        elseif action == "enter_hunt" then
            local huntId = tonumber(data.id)
            if huntId then
                local success, result = HuntSystem.enter(player, huntId)
                if not success then
                    player:sendExtendedOpcode(OPCODE_INSTANCES, json.encode({ action = "error", message = result }))
                end
            end

        elseif action == "enter_boss" then
            local bossId = tonumber(data.id)
            if bossId then
                local success, result = BossRoom.enter(player, bossId)
                if not success then
                    player:sendExtendedOpcode(OPCODE_INSTANCES, json.encode({ action = "error", message = result }))
                end
            end

        elseif action == "leave" then
            if player:getInstanceId() ~= 0 then
                HuntSystem.removePlayer(player)
                BossRoom.removePlayer(player)
                player:teleportTo(player:getTown():getTemplePosition())
                player:sendTextMessage(MESSAGE_EVENT_ORANGE, "Voce saiu da instancia.")
            end
        end
    end
    return true
end
extendedOpcode:register()

local login = CreatureEvent("ExtendedOpcodeLogin")
function login.onLogin(player)
    AetheriteSystem.loadPlayer(player)
    player:registerEvent("ExtendedOpcode")
    return true
end
login:register()
