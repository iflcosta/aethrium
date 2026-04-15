local RESET_OPCODE = 180

-- Milestones at specific reset counts
local MILESTONES = {
    [3]  = "Slot extra de Imbuimento",
    [5]  = "Slot extra de Prey",
    [8]  = "Outfit exclusivo",
    [10] = "Título especial + Aura",
}

local SKILL_NAMES = {
    [SKILL_FIST]      = "Fist",
    [SKILL_CLUB]      = "Club",
    [SKILL_SWORD]     = "Sword",
    [SKILL_AXE]       = "Axe",
    [SKILL_DISTANCE]  = "Distance",
    [SKILL_SHIELD]    = "Shielding",
    [SKILL_FISHING]   = "Fishing",
    [12]              = "Magic Level",
}

local function buildOpenData(player)
    local resetNum     = player:getResetCount() + 1
    local requiredLvl  = player:getResetRequiredLevel()
    local xpCap        = player:getResetXPCap()
    local reduxPct     = (resetNum >= 10) and 50 or 30
    local bonusHP, bonusMana, bonusCap = player:getResetBonusStats()

    -- Vocation bonus for THIS reset (not yet accumulated)
    -- We replicate the same table from player.cpp for display purposes
    local vocId   = player:getVocation():getId()
    local baseVoc = vocId % 4
    local isMonk  = (vocId == 9 or vocId == 10)
    local tier    = (resetNum <= 2) and 1 or (resetNum <= 4 and 2 or 3)

    local VOC_BONUS = {
        knight  = {{200,50,1000},{250,75,1250},{300,100,1500}},
        paladin = {{150,150,750},{175,175,875},{200,200,1000}},
        sorc    = {{50,300,500},{75,350,600},{100,400,750}},
        druid   = {{75,250,500},{100,300,600},{125,350,750}},
        monk    = {{150,150,750},{175,175,875},{200,200,1000}},
    }

    local t
    if isMonk then
        t = VOC_BONUS.monk[tier]
    elseif baseVoc == 0 then
        t = VOC_BONUS.knight[tier]
    elseif baseVoc == 1 then
        t = VOC_BONUS.sorc[tier]
    elseif baseVoc == 2 then
        t = VOC_BONUS.druid[tier]
    else
        t = VOC_BONUS.paladin[tier]
    end

    local nextBonusHP, nextBonusMana, nextBonusCap = t[1], t[2], t[3]
    local accHP   = bonusHP   + nextBonusHP
    local accMana = bonusMana + nextBonusMana
    local accCap  = bonusCap  + nextBonusCap

    -- Skills preview (base value after redux, respecting seals)
    local skills = {}
    local redux = (resetNum >= 10) and 0.50 or 0.30
    local sealMask = player:getSealedSkillsMask()

    for skillId, skillName in pairs(SKILL_NAMES) do
        local current
        if skillId == 12 then
            current = player:getMagicLevel()
        else
            current = player:getSkillLevel(skillId)
        end

        local sealed = (sealMask & (1 << skillId)) ~= 0
        local after
        if sealed then
            after = current
        elseif skillId == 12 then
            after = math.max(0, math.floor(current * (1 - redux)))
        else
            after = math.max(10, math.floor(current * (1 - redux)))
        end

        table.insert(skills, {
            id      = skillId,
            name    = skillName,
            current = current,
            after   = after,
            sealed  = sealed,
        })
    end

    return {
        action        = "open",
        resetNum      = resetNum,
        requiredLevel = requiredLvl,
        xpCap         = xpCap,
        reduxPct      = reduxPct,
        bonusHP       = nextBonusHP,
        bonusMana     = nextBonusMana,
        bonusCap      = nextBonusCap,
        accHP         = accHP,
        accMana       = accMana,
        accCap        = accCap,
        milestone     = MILESTONES[resetNum],
        skills        = skills,
    }
end

-- Extended opcode handler (client → server)
local function onExtendedOpcode(player, opcode, buffer)
    if opcode ~= RESET_OPCODE then return end

    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= "table" then return end

    if data.action == "request" then
        player:sendExtendedOpcode(RESET_OPCODE, json.encode(buildOpenData(player)))

    elseif data.action == "confirm" then
        print("[Debug] Reset confirmation received for " .. player:getName())

        local enabled = configManager.getBoolean("resetSystemEnabled")
        if not enabled then
            print("[Debug] Reset system is DISABLED in config.")
            player:sendExtendedOpcode(RESET_OPCODE, json.encode({
                action  = "error",
                message = "The reset system is currently disabled.",
            }))
            return
        end

        local requiredLvl = player:getResetRequiredLevel()
        print("[Debug] Player Level: " .. player:getLevel() .. " | Required: " .. requiredLvl)

        if player:getLevel() < requiredLvl then
            print("[Debug] Level insufficient. Sending error packet.")
            player:sendExtendedOpcode(RESET_OPCODE, json.encode({
                action  = "error",
                message = "You need level " .. requiredLvl .. " to perform this reset.",
            }))
            return
        end

        player:doReset()

        local town = player:getTown()
        if town then
            player:teleportTo(town:getTemplePosition())
        end
        player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

        -- Update XP reduction rate
        local reduction = player:getResetExpReduction()
        player:setExperienceRate(ExperienceRateType.STAMINA, reduction * 100)

        player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
            "You have performed a reset! Total resets: " .. player:getResetCount() .. ".")

        player:sendExtendedOpcode(RESET_OPCODE, json.encode({
            action   = "done",
            resetNum = player:getResetCount(),
        }))
    end
end

-- Register extended opcode listener
local creatureEvent = CreatureEvent("ResetOpcodeHandler")
creatureEvent.onExtendedOpcode = onExtendedOpcode
creatureEvent:register()

-- Talkaction: opens the reset modal (or shows info if level insufficient)
local talk = TalkAction("!reset")

function talk.onSay(player, words, param)
    print("[Debug] !reset command triggered for " .. player:getName())

    if not json then
        print("[Error] JSON library not found!")
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error: JSON library not found.")
        return false
    end

    -- Fix: Use string key if constant is not defined
    local enabled = configManager.getBoolean("resetSystemEnabled")
    if not enabled then
        player:sendCancelMessage("The reset system is currently disabled.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

    local status, data = pcall(buildOpenData, player)
    if not status then
        print("[Error] Failed to build reset data: " .. tostring(data))
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error: Internal script error.")
        return false
    end

    local ok, encoded = pcall(json.encode, data)
    if not ok then
        print("[Error] JSON encoding failed: " .. tostring(encoded))
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Error: JSON encoding failed.")
        return false
    end

    print("[Debug] Sending Reset Opcode 180: " .. encoded)
    player:sendExtendedOpcode(RESET_OPCODE, encoded)
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Reset menu request sent.")
    return false
end

talk:register()
