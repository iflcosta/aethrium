local protectionMessage = CreatureEvent("protectionMessage")
function protectionMessage.onLogin(player)
    -- hide message for staff/groups
    if player:getGroup():getAccess() then
        return true
    end
    local protectionTime = 0
    if player.getProtectionTime then
        protectionTime = player:getProtectionTime()
    elseif player.getProtectionTicks then
        protectionTime = math.floor(player:getProtectionTicks() / 1000)
    end

    if protectionTime > 0 then
        local spectators = Game.getSpectators(player:getPosition(), false, false, 5, 5, 5, 5)
        local monsterCount = 0

        for _, creature in ipairs(spectators) do
            if creature:isMonster() then
                monsterCount = monsterCount + 1
            end
        end

        if monsterCount > 0 then
            local monsterText
            if monsterCount >= 5 then
                monsterText = "several monsters, be careful"
            elseif monsterCount >= 3 then
                monsterText = "various monsters nearby"
            else
                monsterText = "a monster nearby"
            end

            player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
                string.format("You are protected for %d seconds because there are %s. If you move or attack, your protection will end.", 
                    protectionTime, monsterText))
        end
    end

    return true
end
protectionMessage:register()

