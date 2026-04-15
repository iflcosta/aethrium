local creatureEvent = CreatureEvent("TaskKill")

function creatureEvent.onKill(player, target)
    if not target:isMonster() then
        return true
    end

    local targetName = target:getName()
    
    local taskInfo = getTaskInfos(player)
    if taskInfo then
        local isValidMonster = false
        for _, monsterName in ipairs(taskInfo.monsters_list) do
            if targetName == monsterName then
                isValidMonster = true
                break
            end
        end
        
        if isValidMonster then
            local currentKills = player:getStorageValue(task_kills)
            if currentKills < 0 then
                currentKills = 0
            end
            player:setStorageValue(task_kills, currentKills + 1)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Task: " .. (currentKills + 1) .. "/" .. taskInfo.amount .. " " .. taskInfo.name .. " killed.")
        end
    end
    
    local dailyInfo = getTaskDailyInfo(player)
    if dailyInfo then
        local isValidMonster = false
        for _, monsterName in ipairs(dailyInfo.monsters_list) do
            if targetName == monsterName then
                isValidMonster = true
                break
            end
        end
        
        if isValidMonster then
            local currentKills = player:getStorageValue(taskd_kills)
            if currentKills < 0 then
                currentKills = 0
            end
            player:setStorageValue(taskd_kills, currentKills + 1)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Daily Task: " .. (currentKills + 1) .. "/" .. dailyInfo.count .. " " .. dailyInfo.name .. " killed.")
        end
    end
    
    return true
end

registerCreatureEvent(creatureEvent, "TaskKill")