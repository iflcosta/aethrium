-- Core API functions implemented in Lua
json = dofile('data/lib/json.lua')
dofile('data/lib/core/core.lua')

-- Monk Harmony System
dofile('data/lib/monk_harmony.lua')

-- Compatibility library for our old Lua API
dofile('data/lib/compat/compat.lua')

-- Debugging helper function for Lua developers
dofile('data/lib/debugging/dump.lua')
dofile('data/lib/debugging/lua_version.lua')

-- Battle Pass System
dofile('data/lib/battlepass/config.lua')
dofile('data/lib/battlepass/core.lua')

-- Task System
dofile('data/lib/core/task_system.lua')

-- Hunt Instance System (SuperUP)
dofile('data/lib/core/hunt_system.lua')

-- Boss Room System
dofile('data/lib/core/boss_room.lua')
