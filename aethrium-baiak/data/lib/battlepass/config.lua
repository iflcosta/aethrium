-- ============================================================
-- Battle Pass — Configuration
-- Season 1 · 50 Tiers · Aethrium OTServ 8.6 (TFS 1.8)
-- ============================================================
-- Todos os IDs foram verificados em data/items/items.xml.
--
-- Tipos de recompensa:
--   {type="item",   id=<itemId>, count=<n>}
--   {type="coins",  amount=<pontosZnote>}  ← debita/credita znote_accounts.points
--
-- IDs de referência (items.xml confirmados):
--   3031 = gold coin          3035 = platinum coin      3043 = crystal coin
--   266  = health potion      268  = mana potion        7876 = small health potion
--   236  = strong health pot  237  = strong mana pot
--   239  = great health pot   238  = great mana pot     7642 = great spirit pot
--   7643 = ultimate health p  23373= ultimate mana pot  23374= ultimate spirit pot
--   23375= supreme health pot
--   7439 = berserk potion     7440 = mastermind potion  7443 = bullseye potion
--   3155 = sudden death rune  3161 = avalanche rune     3202 = thunderstorm rune
--   3189 = fireball rune      3160 = ultimate healing   3174 = light magic missile
--   3048 = might ring         3049 = stealth ring       3052 = life ring
--   3053 = time ring          3057 = amulet of loss     3055 = platinum amulet
--   3054 = silver amulet      3045 = strange talisman
--   19082= golden raid token  19083= silver raid token
--   22516= silver token       22722= copper token       22723= platinum token
--   22724= titanium token     22721= gold token
-- ============================================================

BattlePassConfig = {

    season    = 1,
    maxLevel  = 50,
    xpPerLevel = 1000,
    eliteCost = 500,  -- znote points (Tibia Coins)

    -- Desconto percentual por tier de VIP (0 = sem VIP, 5 = tier máximo)
    vipDiscount = {
        [0] = 0,
        [1] = 5,
        [2] = 10,
        [3] = 15,
        [4] = 20,
        [5] = 25,
    },

    -- ── Recompensas por Tier ──────────────────────────────────
    rewards = {

        -- ┌─────────────────────────────────────────────────────
        -- │ TIERS 1-10 · Início de Jornada
        -- │ Free: consumíveis básicos e moedas
        -- │ Elite: versões mais fortes e cristais
        -- └─────────────────────────────────────────────────────
        [1]  = {
            free  = { type="item", id=3035,  count=15 },   -- 15 Platinum Coins
            elite = { type="item", id=3043,  count=1  },   -- 1 Crystal Coin
        },
        [2]  = {
            free  = { type="item", id=266,   count=30 },   -- 30 Health Potions
            elite = { type="item", id=236,   count=15 },   -- 15 Strong Health Potions
        },
        [3]  = {
            free  = { type="item", id=268,   count=30 },   -- 30 Mana Potions
            elite = { type="item", id=237,   count=15 },   -- 15 Strong Mana Potions
        },
        [4]  = {
            free  = { type="coins", amount=25  },          -- 25 TC
            elite = { type="coins", amount=75  },          -- 75 TC
        },
        [5]  = {
            free  = { type="item", id=3043,  count=1  },   -- 1 Crystal Coin
            elite = { type="item", id=3043,  count=3  },   -- 3 Crystal Coins
        },
        [6]  = {
            free  = { type="item", id=3155,  count=5  },   -- 5 Sudden Death Runes
            elite = { type="item", id=3155,  count=20 },   -- 20 Sudden Death Runes
        },
        [7]  = {
            free  = { type="item", id=236,   count=20 },   -- 20 Strong Health Potions
            elite = { type="item", id=239,   count=10 },   -- 10 Great Health Potions
        },
        [8]  = {
            free  = { type="item", id=237,   count=20 },   -- 20 Strong Mana Potions
            elite = { type="item", id=238,   count=10 },   -- 10 Great Mana Potions
        },
        [9]  = {
            free  = { type="item", id=3035,  count=30 },   -- 30 Platinum Coins
            elite = { type="coins", amount=100 },          -- 100 TC
        },
        [10] = {
            free  = { type="item", id=3043,  count=2  },   -- 2 Crystal Coins
            elite = { type="item", id=3043,  count=6  },   -- 6 Crystal Coins
        },

        -- ┌─────────────────────────────────────────────────────
        -- │ TIERS 11-20 · Progressão Intermediária
        -- │ Free: runas, anéis, spirit potions
        -- │ Elite: potions upper-tier, silver tokens
        -- └─────────────────────────────────────────────────────
        [11] = {
            free  = { type="item", id=3161,  count=10 },   -- 10 Avalanche Runes
            elite = { type="item", id=3161,  count=40 },   -- 40 Avalanche Runes
        },
        [12] = {
            free  = { type="item", id=239,   count=20 },   -- 20 Great Health Potions
            elite = { type="item", id=7642,  count=10 },   -- 10 Great Spirit Potions
        },
        [13] = {
            free  = { type="coins", amount=50  },          -- 50 TC
            elite = { type="coins", amount=150 },          -- 150 TC
        },
        [14] = {
            free  = { type="item", id=238,   count=20 },   -- 20 Great Mana Potions
            elite = { type="item", id=23373, count=5  },   -- 5 Ultimate Mana Potions
        },
        [15] = {
            free  = { type="item", id=3043,  count=3  },   -- 3 Crystal Coins
            elite = { type="item", id=3043,  count=9  },   -- 9 Crystal Coins
        },
        [16] = {
            free  = { type="item", id=7642,  count=15 },   -- 15 Great Spirit Potions
            elite = { type="item", id=23374, count=5  },   -- 5 Ultimate Spirit Potions
        },
        [17] = {
            free  = { type="item", id=3048,  count=5  },   -- 5 Might Rings
            elite = { type="item", id=3048,  count=20 },   -- 20 Might Rings
        },
        [18] = {
            free  = { type="coins", amount=75  },          -- 75 TC
            elite = { type="coins", amount=200 },          -- 200 TC
        },
        [19] = {
            free  = { type="item", id=3202,  count=10 },   -- 10 Thunderstorm Runes
            elite = { type="item", id=3202,  count=40 },   -- 40 Thunderstorm Runes
        },
        [20] = {
            free  = { type="item", id=3043,  count=4  },   -- 4 Crystal Coins
            elite = { type="item", id=22516, count=5  },   -- 5 Silver Tokens
        },

        -- ┌─────────────────────────────────────────────────────
        -- │ TIERS 21-30 · Upper-Mid
        -- │ Free: stealth rings, spirit potions, runas top
        -- │ Elite: copper tokens, silver raid tokens
        -- └─────────────────────────────────────────────────────
        [21] = {
            free  = { type="item", id=3049,  count=5  },   -- 5 Stealth Rings
            elite = { type="item", id=3049,  count=20 },   -- 20 Stealth Rings
        },
        [22] = {
            free  = { type="item", id=7642,  count=30 },   -- 30 Great Spirit Potions
            elite = { type="coins", amount=250 },          -- 250 TC
        },
        [23] = {
            free  = { type="item", id=3043,  count=5  },   -- 5 Crystal Coins
            elite = { type="item", id=3043,  count=15 },   -- 15 Crystal Coins
        },
        [24] = {
            free  = { type="item", id=3155,  count=20 },   -- 20 Sudden Death Runes
            elite = { type="item", id=3155,  count=80 },   -- 80 Sudden Death Runes
        },
        [25] = {
            free  = { type="item", id=3043,  count=5  },   -- 5 Crystal Coins
            elite = { type="item", id=22722, count=5  },   -- 5 Copper Tokens
        },
        [26] = {
            free  = { type="item", id=23374, count=10 },   -- 10 Ultimate Spirit Potions
            elite = { type="item", id=23374, count=30 },   -- 30 Ultimate Spirit Potions
        },
        [27] = {
            free  = { type="coins", amount=100 },          -- 100 TC
            elite = { type="coins", amount=300 },          -- 300 TC
        },
        [28] = {
            free  = { type="item", id=3048,  count=15 },   -- 15 Might Rings
            elite = { type="item", id=3048,  count=50 },   -- 50 Might Rings
        },
        [29] = {
            free  = { type="item", id=3043,  count=6  },   -- 6 Crystal Coins
            elite = { type="item", id=3043,  count=18 },   -- 18 Crystal Coins
        },
        [30] = {
            free  = { type="item", id=7642,  count=50 },   -- 50 Great Spirit Potions
            elite = { type="item", id=19083, count=3  },   -- 3 Silver Raid Tokens
        },

        -- ┌─────────────────────────────────────────────────────
        -- │ TIERS 31-40 · Prestígio Inicial
        -- │ Free: ultimate potions, amulets, rings
        -- │ Elite: platinum tokens, golden raid tokens
        -- └─────────────────────────────────────────────────────
        [31] = {
            free  = { type="item", id=3049,  count=20 },   -- 20 Stealth Rings
            elite = { type="item", id=3049,  count=60 },   -- 60 Stealth Rings
        },
        [32] = {
            free  = { type="coins", amount=125 },          -- 125 TC
            elite = { type="coins", amount=350 },          -- 350 TC
        },
        [33] = {
            free  = { type="item", id=23373, count=10 },   -- 10 Ultimate Mana Potions
            elite = { type="item", id=23373, count=30 },   -- 30 Ultimate Mana Potions
        },
        [34] = {
            free  = { type="item", id=3043,  count=8  },   -- 8 Crystal Coins
            elite = { type="item", id=3043,  count=24 },   -- 24 Crystal Coins
        },
        [35] = {
            free  = { type="item", id=3202,  count=30 },   -- 30 Thunderstorm Runes
            elite = { type="item", id=22722, count=10 },   -- 10 Copper Tokens
        },
        [36] = {
            free  = { type="item", id=7643,  count=15 },   -- 15 Ultimate Health Potions
            elite = { type="item", id=7643,  count=40 },   -- 40 Ultimate Health Potions
        },
        [37] = {
            free  = { type="coins", amount=150 },          -- 150 TC
            elite = { type="coins", amount=400 },          -- 400 TC
        },
        [38] = {
            free  = { type="item", id=3043,  count=10 },   -- 10 Crystal Coins
            elite = { type="item", id=3043,  count=30 },   -- 30 Crystal Coins
        },
        [39] = {
            free  = { type="item", id=23374, count=20 },   -- 20 Ultimate Spirit Potions
            elite = { type="item", id=23374, count=60 },   -- 60 Ultimate Spirit Potions
        },
        [40] = {
            free  = { type="item", id=3043,  count=12 },   -- 12 Crystal Coins
            elite = { type="item", id=22723, count=3  },   -- 3 Platinum Tokens
        },

        -- ┌─────────────────────────────────────────────────────
        -- │ TIERS 41-50 · Grand Finale
        -- │ Free: supreme potions, high quantities
        -- │ Elite: titanium tokens, golden raid tokens, TC massivo
        -- └─────────────────────────────────────────────────────
        [41] = {
            free  = { type="item", id=7642,  count=100 },  -- 100 Great Spirit Potions
            elite = { type="coins", amount=500 },          -- 500 TC
        },
        [42] = {
            free  = { type="coins", amount=175 },          -- 175 TC
            elite = { type="coins", amount=450 },          -- 450 TC
        },
        [43] = {
            free  = { type="item", id=3043,  count=15 },   -- 15 Crystal Coins
            elite = { type="item", id=3043,  count=45 },   -- 45 Crystal Coins
        },
        [44] = {
            free  = { type="item", id=7643,  count=30 },   -- 30 Ultimate Health Potions
            elite = { type="item", id=7643,  count=80 },   -- 80 Ultimate Health Potions
        },
        [45] = {
            free  = { type="item", id=3048,  count=40 },   -- 40 Might Rings
            elite = { type="item", id=19082, count=3  },   -- 3 Golden Raid Tokens
        },
        [46] = {
            free  = { type="coins", amount=200 },          -- 200 TC
            elite = { type="coins", amount=600 },          -- 600 TC
        },
        [47] = {
            free  = { type="item", id=3043,  count=20 },   -- 20 Crystal Coins
            elite = { type="item", id=3043,  count=60 },   -- 60 Crystal Coins
        },
        [48] = {
            free  = { type="item", id=7642,  count=150 },  -- 150 Great Spirit Potions
            elite = { type="item", id=22724, count=3  },   -- 3 Titanium Tokens
        },
        [49] = {
            free  = { type="item", id=7643,  count=50 },   -- 50 Ultimate Health Potions
            elite = { type="coins", amount=750 },          -- 750 TC
        },
        [50] = {
            free  = { type="item", id=3043,  count=30 },   -- 30 Crystal Coins (Grand Finale Free)
            elite = { type="item", id=19082, count=10 },   -- 10 Golden Raid Tokens (Grand Finale Elite)
        },
    },

    -- ── Pool de Missões Diárias ───────────────────────────────
    -- A cada reset, 3 tarefas são sorteadas aleatoriamente.
    -- "xp" = Battle-Pass XP concedido ao completar.
    -- "weight" = peso no sorteio (maior = mais frequente).
    dailyTaskPool = {
        -- Abates genéricos
        { type="kill",      target=50,  label="Matar 50 monstros",      xp=150,  weight=5 },
        { type="kill",      target=100, label="Matar 100 monstros",     xp=250,  weight=4 },
        { type="kill",      target=200, label="Matar 200 monstros",     xp=400,  weight=2 },
        { type="kill",      target=300, label="Matar 300 monstros",     xp=600,  weight=1 },

        -- Abate de bosses
        { type="kill_boss", target=1,   label="Derrotar 1 boss",        xp=300,  weight=4 },
        { type="kill_boss", target=3,   label="Derrotar 3 bosses",      xp=700,  weight=2 },
        { type="kill_boss", target=5,   label="Derrotar 5 bosses",      xp=1000, weight=1 },

        -- Uso de poções
        { type="use_item",  target=20,  label="Usar 20 poções",         xp=100,  weight=5 },
        { type="use_item",  target=50,  label="Usar 50 poções",         xp=200,  weight=4 },
        { type="use_item",  target=100, label="Usar 100 poções",        xp=350,  weight=2 },

        -- Loot de itens
        { type="loot_item", target=25,  label="Lootar 25 itens",        xp=100,  weight=5 },
        { type="loot_item", target=75,  label="Lootar 75 itens",        xp=200,  weight=3 },
        { type="loot_item", target=150, label="Lootar 150 itens",       xp=350,  weight=1 },

        -- Viagens
        { type="travel",    target=3,   label="Viajar 3 vezes",         xp=80,   weight=5 },
        { type="travel",    target=8,   label="Viajar 8 vezes",         xp=150,  weight=3 },

        -- Depósito no banco
        { type="deposit",   target=1,   label="Depositar ouro no banco", xp=80,   weight=4 },
        { type="deposit",   target=5,   label="Depositar ouro 5 vezes", xp=200,  weight=2 },
    },
}
