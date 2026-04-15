task_monsters = {
    [1] = {
        name = "Green Djinn",
        level = 1,
        amount = 50,
        monsters_list = {"Green Djinn", "Djinn"},
        items = {},
        exp = 1000,
        points = 1,
        reward = {{id = 2160, count = 100}}
    },
    [2] = {
        name = "Marid",
        level = 30,
        amount = 100,
        monsters_list = {"Marid", "Efreet"},
        items = {},
        exp = 5000,
        points = 3,
        reward = {{id = 2160, count = 300}}
    },
    [3] = {
        name = "AshDRa",
        level = 60,
        amount = 150,
        monsters_list = {"Ash DRa"},
        items = {{id = 2148, count = 10}},
        exp = 15000,
        points = 5,
        reward = {{id = 2160, count = 500}}
    },
    [4] = {
        name = "Hero",
        level = 80,
        amount = 200,
        monsters_list = {"Hero"},
        items = {{id = 2148, count = 20}},
        exp = 25000,
        points = 7,
        reward = {{id = 2160, count = 1000}}
    },
    [5] = {
        name = "Demon",
        level = 100,
        amount = 300,
        monsters_list = {"Demon"},
        items = {{id = 2148, count = 50}},
        exp = 50000,
        points = 10,
        reward = {{id = 2160, count = 2000}, {id = 6529, count = 1}}
    },
    [6] = {
        name = "Dragon Lord",
        level = 70,
        amount = 250,
        monsters_list = {"Dragon Lord"},
        items = {{id = 2148, count = 30}},
        exp = 20000,
        points = 8,
        reward = {{id = 2160, count = 1500}}
    },
    [7] = {
        name = "Warlock",
        level = 90,
        amount = 200,
        monsters_list = {"Warlock"},
        items = {{id = 2148, count = 40}},
        exp = 30000,
        points = 9,
        reward = {{id = 2160, count = 1800}}
    },
    [8] = {
        name = "Behemoth",
        level = 110,
        amount = 350,
        monsters_list = {"Behemoth"},
        items = {{id = 2148, count = 60}},
        exp = 60000,
        points = 12,
        reward = {{id = 2160, count = 2500}}
    },
    [9] = {
        name = "Hydra",
        level = 120,
        amount = 400,
        monsters_list = {"Hydra"},
        items = {{id = 2148, count = 80}},
        exp = 80000,
        points = 15,
        reward = {{id = 2160, count = 3000}, {id = 12789, count = 1}}
    },
    [10] = {
        name = "Leviathan",
        level = 150,
        amount = 500,
        monsters_list = {"Leviathan"},
        items = {{id = 2148, count = 100}},
        exp = 120000,
        points = 20,
        reward = {{id = 2160, count = 5000}, {id = 12790, count = 1}}
    },
    start = 3000000,
}

task_daily = {
    [1] = {
        name = "Cave Rat",
        level = 1,
        count = 30,
        monsters_list = {"Cave Rat", "Rat"},
        exp = 500,
        points = 1,
        reward = {{id = 2160, count = 50}}
    },
    [2] = {
        name = "Goblin",
        level = 10,
        count = 50,
        monsters_list = {"Goblin"},
        exp = 1000,
        points = 2,
        reward = {{id = 2160, count = 100}}
    },
    [3] = {
        name = "Troll",
        level = 20,
        count = 60,
        monsters_list = {"Troll"},
        exp = 1500,
        points = 2,
        reward = {{id = 2160, count = 150}}
    },
    [4] = {
        name = "Orc",
        level = 30,
        count = 70,
        monsters_list = {"Orc", "Orc Warrior", "Orc Berserker", "Orc Shaman"},
        exp = 2500,
        points = 3,
        reward = {{id = 2160, count = 200}}
    },
    [5] = {
        name = "Cyclops",
        level = 50,
        count = 80,
        monsters_list = {"Cyclops", "Cyclops Drone", "Cyclops Smith"},
        exp = 5000,
        points = 4,
        reward = {{id = 2160, count = 300}}
    },
    [6] = {
        name = "Mammoth",
        level = 70,
        count = 100,
        monsters_list = {"Mammoth", "Frozen Man"},
        exp = 10000,
        points = 6,
        reward = {{id = 2160, count = 500}}
    },
    [7] = {
        name = "Giant Spider",
        level = 80,
        count = 120,
        monsters_list = {"Giant Spider", "Spider"},
        exp = 15000,
        points = 8,
        reward = {{id = 2160, count = 700}}
    },
    [8] = {
        name = "Ancient Scar",
        level = 100,
        count = 150,
        monsters_list = {"Ancient Scar"},
        exp = 25000,
        points = 10,
        reward = {{id = 2160, count = 1000}}
    },
    [9] = {
        name = "Demon",
        level = 120,
        count = 180,
        monsters_list = {"Demon"},
        exp = 40000,
        points = 15,
        reward = {{id = 2160, count = 1500}}
    },
    [10] = {
        name = "Dragon",
        level = 90,
        count = 150,
        monsters_list = {"Dragon"},
        exp = 20000,
        points = 12,
        reward = {{id = 2160, count = 1200}}
    },
}

task_storage = 30100
task_kills = 30101
task_sto_time = 30102
taskd_storage = 30103
taskd_kills = 30104
time_daySto = 30105

task_time = 2

function getTaskInfos(player)
    local tsk = player:getStorageValue(task_storage)
    if tsk > 0 and tsk <= #task_monsters then
        return task_monsters[tsk]
    end
    return nil
end

function getTaskDailyInfo(player)
    local tsk = player:getStorageValue(taskd_storage)
    if tsk > 0 and tsk <= #task_daily then
        return task_daily[tsk]
    end
    return nil
end

function taskPoints_add(player, amount)
    player:setStorageValue(200001, (player:getStorageValue(200001) + amount))
end

function taskRank_add(player, amount)
    player:setStorageValue(200002, (player:getStorageValue(200002) + amount))
end

function getItemsFromTable(items)
    local text = ""
    for i = 1, #items do
        local item = items[i]
        local itemType = ItemType(item.id)
        text = text .. (i == 1 and "" or ", ") .. itemType:getName() .. " x" .. item.count
    end
    return text
end

function getMonsterFromList(monsters)
    return table.concat(monsters, ", ")
end