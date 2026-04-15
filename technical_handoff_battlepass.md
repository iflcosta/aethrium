# Technical Handoff - Sistema de Battle Pass (Aethrium)

Este documento contém o contexto arquitetural completo para o desenvolvimento do sistema de Battle Pass e Daily Pass no ecossistema Aethrium. Atualizado após revisão completa da base de código do servidor e cliente.

---

## 📁 Estrutura de Diretórios

- **Servidor**: `c:\Users\Iago Lopes\.gemini\antigravity\scratch\aethrium\aethrium-baiak\`
- **Cliente**: `c:\Users\Iago Lopes\.gemini\antigravity\scratch\aethrium\aethrium-client\`
- **Repositórios GitHub**:
  - `iflcosta/aethrium-baiak`
  - `iflcosta/aethrium-client`

---

## ⚙️ Especificações Técnicas (Servidor)

- **Engine**: The Forgotten Server (TFS) 1.8
- **Linguagem**: C++17 / Lua 5.1
- **Sistema de Scripts**: RevScripts (`data/scripts/`) e EventCallbacks (`data/scripts/eventcallbacks/`)
- **Banco de Dados**: MySQL via sistema de migrações numeradas (`data/migrations/*.lua`)
- **Build System**: CMake com `vcpkg`. Executável principal: `tfs.exe`

---

## 🖥️ Especificações Técnicas (Cliente)

- **Engine**: OTClient (versão otimizada para Aethrium)
- **Linguagem**: Lua / OTUI / HTML+CSS (módulos modernos)
- **Estrutura**: 72 módulos em `modules/`. Módulos carregados por prioridade (0–9999) via `init.lua`
- **Referências de UI**:
  - `modules/game_vip` — padrão moderno: HTML/CSS + Extended Opcode JSON
  - `modules/game_store` — padrão cipsoft: OTUI widgets + protocolo direto

---

## 📡 Protocolo de Comunicação

A comunicação entre servidor e cliente para sistemas customizados utiliza **Extended Opcodes**.

- **OpCode Reservado**: `150`
  - ⚠️ **Verificar antes de implementar**: fazer grep por `150` em `data/scripts/network/` (servidor) e em todos os `registerExtendedOpcode` do cliente para confirmar que não há colisão.
- **Padrão de envio (Servidor)**:
  ```lua
  player:sendExtendedOpcode(150, json.encode(table))
  ```
- **Padrão de recebimento (Cliente)**:
  ```lua
  ProtocolGame.registerExtendedOpcode(150, function(protocol, opcode, buffer)
      local ok, data = pcall(json.decode, buffer)
      -- processar data
  end)
  ```
- **Alternativa suportada** (JSON fragmentado):
  ```lua
  ProtocolGame.registerExtendedJSONOpcode(150, function(protocol, opcode, data)
      -- data já vem como table decodificada, suporta mensagens grandes
  end)
  ```
- **Referência de opcodes em uso**: VIP = `181`

---

## 📜 Regras de Negócio do Battle Pass

1. **Duração**: Bimestral (60 dias). Reset automático ou via comando GM.
2. **Progressão**: 50 Níveis (Tiers).
3. **Trilhas**:
   - **Free**: Disponível para todos os jogadores.
   - **Elite**: Comprada via Store (Tibia Coins).
4. **Sistema de Desconto VIP**: Jogadores com VIP ativo recebem desconto progressivo na compra do passe Elite:
   - VIP Bronze (tier 1): 5% de desconto
   - VIP Silver (tier 2): 10% de desconto
   - VIP Gold (tier 3): 15% de desconto
5. **Daily Pass**: 3 tarefas aleatórias geradas por dia que concedem **Battle Points (BP XP)**.
6. **Season**: Controlada por `GlobalStorageKeys.battlepassSeason` e `battlepassExpires`.

---

## 🗄️ Banco de Dados

### Regra crítica
O padrão do projeto são **arquivos `.lua` numerados** em `data/migrations/`. Os arquivos `.sql` avulsos existentes (`vip_system.sql`, `reset_system_v2.sql`) são exceções fora do padrão — **não os siga**.

### Migração: `data/migrations/36.lua`
> Verificar qual é o número seguinte ao último arquivo existente em `data/migrations/`.

```lua
function onUpdateDatabase()
    logMigration("> Updating database to version 37 (battle pass system)")

    -- Tabela principal do battle pass por jogador
    db.query([[
        CREATE TABLE IF NOT EXISTS `player_battlepass` (
            `player_id`        INT NOT NULL PRIMARY KEY,
            `xp`               INT UNSIGNED NOT NULL DEFAULT 0,
            `level`            TINYINT UNSIGNED NOT NULL DEFAULT 1,
            `elite`            TINYINT(1) NOT NULL DEFAULT 0,
            `claimed_free`     BIGINT UNSIGNED NOT NULL DEFAULT 0,
            `claimed_elite`    BIGINT UNSIGNED NOT NULL DEFAULT 0,
            `season`           SMALLINT UNSIGNED NOT NULL DEFAULT 1,
            FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
        )
    ]])

    -- Tabela de tarefas diárias (Daily Pass)
    db.query([[
        CREATE TABLE IF NOT EXISTS `player_battlepass_daily` (
            `player_id`   INT NOT NULL,
            `task_id`     TINYINT UNSIGNED NOT NULL,
            `type`        VARCHAR(32) NOT NULL,
            `target`      INT NOT NULL,
            `current`     INT NOT NULL DEFAULT 0,
            `completed`   TINYINT(1) NOT NULL DEFAULT 0,
            `date`        DATE NOT NULL,
            PRIMARY KEY (`player_id`, `date`, `task_id`),
            FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
        )
    ]])

    return true
end
```

### Decisão de design: `claimed_rewards` como bitmask

Em vez de JSON/Blob, as recompensas coletadas são armazenadas como **dois `BIGINT UNSIGNED`** (bitmask):
- `claimed_free`: bit N = tier N+1 da trilha Free foi coletado
- `claimed_elite`: bit N = tier N+1 da trilha Elite foi coletado
- 50 tiers cabe em 50 bits → dentro do range de `BIGINT UNSIGNED` (64 bits)
- Mais eficiente: sem deserialização JSON a cada verificação

### Decisão de design: Daily Tasks em tabela separada

Três tarefas por dia com progresso individual ficam em `player_battlepass_daily`:
- Evita deserialização de JSON a cada `onKill`
- Permite queries diretas por data e tipo de tarefa
- Fácil limpeza de registros antigos via cron

---

## 🛠️ Estrutura de Arquivos do Servidor

### Lib Lua — dividida em dois arquivos

#### `data/lib/battlepass/config.lua`
Responsável por: tabelas de recompensas (50 tiers × Free/Elite), custo do passe, descontos VIP, pool de tarefas diárias.

```lua
BattlePassConfig = {
    season = 1,
    duration = 60,          -- dias
    maxLevel = 50,
    eliteCost = 500,        -- Tibia Coins
    xpPerLevel = 1000,      -- BP XP necessário por tier

    vipDiscount = {
        [1] = 5,            -- Bronze: 5%
        [2] = 10,           -- Silver: 10%
        [3] = 15,           -- Gold:   15%
    },

    -- Pool de tipos de tarefas disponíveis para sorteio diário
    dailyTaskPool = {
        { type = "kill",      target = 50,  xp = 200, label = "Kill 50 monsters" },
        { type = "kill",      target = 100, xp = 350, label = "Kill 100 monsters" },
        { type = "loot_gold", target = 5000,xp = 200, label = "Loot 5000 gold" },
        { type = "travel",    target = 1,   xp = 150, label = "Use a depot" },
        -- ... expandir conforme necessário
    },

    -- Recompensas por tier [nivel] = { free = {...}, elite = {...} }
    rewards = {
        [1]  = { free = { type = "item",     id = 3031, count = 100 },
                 elite = { type = "item",    id = 9058, count = 50  } },
        [5]  = { free = { type = "item",     id = 3031, count = 500 },
                 elite = { type = "outfit",  id = 1337           } },
        [10] = { free = { type = "coins",    amount = 50         },
                 elite = { type = "mount",   id = 200            } },
        -- ... todos os 50 tiers
    },
}
```

#### `data/lib/battlepass/core.lua`
Responsável por: funções de XP, level up, claim reward, geração de daily tasks, acesso ao BD.

```lua
-- Carregar em data/lib/lib.lua:
-- dofile('data/lib/battlepass/config.lua')
-- dofile('data/lib/battlepass/core.lua')

BattlePass = {}

function BattlePass.getData(player)
    local resultId = db.storeQuery(string.format(
        "SELECT * FROM `player_battlepass` WHERE `player_id` = %d",
        player:getGuid()
    ))
    if not resultId then return nil end
    local data = {
        xp           = result.getNumber(resultId, "xp"),
        level        = result.getNumber(resultId, "level"),
        elite        = result.getNumber(resultId, "elite") == 1,
        claimed_free = result.getNumber(resultId, "claimed_free"),
        claimed_elite= result.getNumber(resultId, "claimed_elite"),
        season       = result.getNumber(resultId, "season"),
    }
    result.free(resultId)
    return data
end

function BattlePass.addXP(player, amount)
    -- Busca dados atuais, faz level up se necessário, salva no BD
end

function BattlePass.claimReward(player, tier, track)
    -- Valida tier, verifica bitmask, entrega recompensa, atualiza bitmask
end

function BattlePass.generateDailyTasks(player)
    -- Sorteia 3 tarefas do pool, insere em player_battlepass_daily para hoje
end

function BattlePass.getDailyTasks(player)
    -- Retorna tarefas do dia atual do jogador
end

function BattlePass.updateDailyTask(player, taskType, increment)
    -- Incrementa progresso de tarefa ativa do tipo especificado
end

function BattlePass.buildPayload(player)
    -- Monta a table completa para json.encode e envio via opcode
end
```

---

### Scripts de Rastreamento

#### `data/scripts/eventcallbacks/player/battlepass_onKill.lua`
> ⚠️ **Usar EventCallback, não CreatureEvent.**
> O padrão moderno do projeto para hooks de combate/progressão é `data/scripts/eventcallbacks/player/` (ver `default_onGainExperience.lua`). O EventCallback não requer registro via `registerCreatureEvent` no login.

```lua
local event = Event()

function event.onKill(player, target, lastHit)
    if not target:isMonster() then return end
    BattlePass.updateDailyTask(player, "kill", 1)
end

event:register()
```

#### `data/scripts/globalevents/battlepass_daily_reset.lua`

```lua
local globalevent = GlobalEvent("battlepass_daily_reset")

function globalevent.onTime(interval)
    -- Executado à meia-noite: limpa registros de daily tasks do dia anterior
    db.asyncQuery("DELETE FROM `player_battlepass_daily` WHERE `date` < CURDATE()")
    return true
end

globalevent:time("00:00:00")
globalevent:register()
```

#### `data/scripts/talkactions/player/misc/battlepass.lua`
Comando `!battlepass` para abrir a interface no cliente.

---

### Storage Keys

Adicionar em `data/lib/core/storages.lua`:

```lua
GlobalStorageKeys = {
    -- existentes...
    battlepassSeason  = 90010,
    battlepassExpires = 90011,
}
```

---

## 🖥️ UI do Cliente — Duas Implementações

O Battle Pass terá **duas implementações de UI** desenvolvidas em paralelo para avaliação comparativa ao final. Ambas usam o mesmo Extended Opcode (`150`) e o mesmo payload JSON.

---

### Payload JSON (comum às duas UIs)

```json
{
    "action": "open",
    "season": 1,
    "level": 12,
    "xp": 450,
    "xpNext": 1000,
    "elite": false,
    "eliteCost": 500,
    "vipDiscount": 10,
    "daysLeft": 43,
    "rewards": [
        { "tier": 1,  "free": { "type": "item", "id": 3031, "count": 100 }, "elite": { "type": "item", "id": 9058, "count": 50 }, "claimedFree": true, "claimedElite": false },
        { "tier": 2,  "free": { "type": "item", "id": 3031, "count": 200 }, "elite": { "type": "coins", "amount": 50 },           "claimedFree": false, "claimedElite": false }
    ],
    "dailyTasks": [
        { "id": 1, "label": "Kill 50 monsters", "current": 30, "target": 50, "completed": false },
        { "id": 2, "label": "Loot 5000 gold",   "current": 5000, "target": 5000, "completed": true  },
        { "id": 3, "label": "Use a depot",       "current": 0,  "target": 1,  "completed": false }
    ]
}
```

---

### Implementação A — HTML/CSS (estilo `game_vip`)

**Módulo**: `modules/game_battlepass_html/`

**Características**:
- Template HTML com property binding (`{{self.property}}`)
- CSS para layout e animações da barra de progresso
- Desenvolvimento mais rápido, mais expressivo para listas e grids
- Referência direta: `modules/game_vip/`

**Estrutura de arquivos**:
```
modules/game_battlepass_html/
├── game_battlepass_html.otmod
├── game_battlepass_html.lua      # Controller + registro do opcode
├── game_battlepass_html.html     # Template da janela principal
└── game_battlepass_html.css      # Estilos
```

**game_battlepass_html.otmod**:
```otml
Module
  name: game_battlepass_html
  description: Battle Pass System - HTML/CSS variant
  scripts: [ game_battlepass_html ]
  sandboxed: true
  @onLoad: BattlePassHtmlController:init()
  @onUnload: BattlePassHtmlController:terminate()
```

**game_battlepass_html.lua** (esqueleto):
```lua
BattlePassHtmlController = Controller:new()

local BATTLEPASS_OPCODE = 150
local window = nil

function BattlePassHtmlController:onInit()
    self:registerExtendedOpcode(BATTLEPASS_OPCODE, function(protocol, opcode, buffer)
        local ok, data = pcall(json.decode, buffer)
        if not ok or type(data) ~= "table" then return end
        if data.action == "open" then
            self:show(data)
        end
    end)
end

function BattlePassHtmlController:show(data)
    if window then window:destroy() end
    -- Criar janela HTML com data binding
    -- Renderizar barra de progresso, tiers, daily tasks via template
end

function BattlePassHtmlController:onTerminate()
    if window then window:destroy() end
end
```

**Elementos da UI** (via HTML/CSS):
- Cabeçalho: Season, dias restantes, botão comprar Elite (com desconto VIP aplicado)
- Barra de progresso XP: `<div class="xp-bar"><div class="xp-fill" style="width: {{self.xpPercent}}%"></div></div>`
- Tier atual e XP: `Tier {{self.level}} — {{self.xp}} / {{self.xpNext}} BP`
- Grid de tiers (50 itens) com trilha Free (topo) e Elite (baixo), ícone de recompensa, estado: bloqueado / disponível / coletado
- Seção Daily Tasks: lista de 3 tarefas com barra de progresso individual e ícone de check

---

### Implementação B — OTUI Widgets (estilo `game_store`)

**Módulo**: `modules/game_battlepass_otui/`

**Características**:
- Widgets OTUI nativos (Panel, Label, ProgressBar, ScrollArea)
- Layout com anchors e verticalBox/horizontalBox/grid
- Criação dinâmica de widgets via `g_ui.createWidget()`
- Mais verboso, mas integra melhor com o sistema de estilos nativo do OTClient
- Referência direta: `modules/game_store/`

**Estrutura de arquivos**:
```
modules/game_battlepass_otui/
├── game_battlepass_otui.otmod
├── game_battlepass_otui.lua        # Controller + lógica de UI
├── game_battlepass_otui.otui       # Definição dos widgets
└── style/
    └── ui.otui                     # Estilos customizados dos widgets
```

**game_battlepass_otui.otmod**:
```otml
Module
  name: game_battlepass_otui
  description: Battle Pass System - OTUI Widgets variant
  scripts: [ game_battlepass_otui ]
  @onLoad: BattlePassOtuiController:init()
  @onUnload: BattlePassOtuiController:terminate()
```

**game_battlepass_otui.otui** (estrutura principal):
```otui
BattlePassWindow < MainWindow
  size: 820 560
  !text: tr('Battle Pass')
  visible: false
  @onEscape: modules.game_battlepass_otui.toggle()

  -- Cabeçalho
  Panel
    id: header
    height: 60
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    Label
      id: lblSeason
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      margin-left: 10
      font: verdana-11px-bold

    Label
      id: lblDaysLeft
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 10

    Button
      id: btnBuyElite
      width: 140
      height: 30
      anchors.right: lblDaysLeft.left
      anchors.verticalCenter: parent.verticalCenter
      margin-right: 8
      !text: tr('Buy Elite Pass')

  -- Barra de XP
  Panel
    id: xpBar
    height: 28
    anchors.top: header.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin: 5 10 5 10

    ProgressBar
      id: xpProgress
      anchors.fill: parent

    Label
      id: lblXp
      anchors.centerIn: parent
      text-align: center

  -- Grid de Tiers (scroll horizontal)
  ScrollArea
    id: tierScroll
    anchors.top: xpBar.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: dailyPanel.top
    margin: 5 10 5 10
    layout:
      type: horizontalBox
      cell-spacing: 4
      fit-children: true

  -- Painel Daily Tasks
  Panel
    id: dailyPanel
    height: 120
    anchors.bottom: btnClose.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin: 0 10 5 10

    Label
      id: lblDaily
      !text: tr('Daily Tasks')
      anchors.top: parent.top
      anchors.left: parent.left
      margin: 4 0 0 6
      font: verdana-11px-bold

    Panel
      id: dailyList
      anchors.top: lblDaily.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      layout:
        type: verticalBox
        cell-spacing: 2

  Button
    id: btnClose
    width: 80
    height: 24
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    margin: 0 10 8 0
    !text: tr('Close')
    @onClick: modules.game_battlepass_otui.toggle()
```

**Widgets customizados** (em `style/ui.otui`):
```otui
-- Célula de tier na grade
TierCell < Panel
  size: 72 140
  focusable: true
  border: 1 #555555

  $focus:
    border: 2 #FFD700

  $checked:
    background-color: #2a4a2a

  Box
    id: icon
    size: 48 48
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    margin-top: 6

  Label
    id: lblTier
    height: 16
    anchors.top: icon.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    font: verdana-11px-bold

  -- Recompensa Free
  Box
    id: freeReward
    size: 30 30
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: lblTier.bottom
    margin-top: 4

  -- Recompensa Elite
  Box
    id: eliteReward
    size: 30 30
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: freeReward.bottom
    margin-top: 2

  Label
    id: lblLocked
    !text: tr('Locked')
    height: 14
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    color: #888888

-- Linha de tarefa diária
DailyTaskRow < Panel
  height: 28
  layout:
    type: horizontalBox

  Label
    id: lblLabel
    width: 200
    text-align: left
    margin-left: 6
    anchors.verticalCenter: parent.verticalCenter

  ProgressBar
    id: taskProgress
    anchors.verticalCenter: parent.verticalCenter
    margin: 0 6

  Label
    id: lblProgress
    width: 60
    text-align: right
    margin-right: 6
    anchors.verticalCenter: parent.verticalCenter

  CheckBox
    id: chkDone
    width: 20
    height: 20
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 4
    enabled: false
```

**game_battlepass_otui.lua** (esqueleto):
```lua
local BATTLEPASS_OPCODE = 150
local window = nil

function init()
    ProtocolGame.registerExtendedOpcode(BATTLEPASS_OPCODE, onExtendedOpcode)
    g_keyboard.bindKeyDown('Ctrl+B', toggle)
end

function terminate()
    if window then
        window:destroy()
        window = nil
    end
    g_keyboard.unbindKeyDown('Ctrl+B')
end

function onExtendedOpcode(protocol, opcode, buffer)
    local ok, data = pcall(json.decode, buffer)
    if not ok or type(data) ~= "table" then return end
    if data.action == "open" then
        open(data)
    end
end

function open(data)
    if not window then
        window = g_ui.loadUI('game_battlepass_otui', gameRootPanel)
        window:setId('battlePassWindow')
        window:find('btnClose').onClick = toggle
    end

    -- Preencher cabeçalho
    window:find('lblSeason'):setText('Season ' .. data.season .. ' — ' .. data.daysLeft .. ' days left')
    
    -- Atualizar barra de XP
    local xpPct = math.floor((data.xp / data.xpNext) * 100)
    window:find('xpProgress'):setPercent(xpPct)
    window:find('lblXp'):setText('Tier ' .. data.level .. '   ' .. data.xp .. ' / ' .. data.xpNext .. ' BP')

    -- Botão Elite
    local btn = window:find('btnBuyElite')
    if data.elite then
        btn:setText('Elite Active')
        btn:setEnabled(false)
    else
        local cost = data.eliteCost
        local disc = data.vipDiscount or 0
        local final = math.floor(cost * (100 - disc) / 100)
        btn:setText('Buy Elite (' .. final .. ' TC)')
        btn:setEnabled(true)
    end

    -- Popular grid de tiers
    local tierScroll = window:find('tierScroll')
    tierScroll:destroyChildren()
    for _, r in ipairs(data.rewards) do
        local cell = g_ui.createWidget('TierCell', tierScroll)
        cell:find('lblTier'):setText('Tier ' .. r.tier)
        -- configurar ícones, estado locked/claimed
        if r.claimedFree then cell:setChecked(true) end
    end

    -- Popular daily tasks
    local dailyList = window:find('dailyList')
    dailyList:destroyChildren()
    for _, task in ipairs(data.dailyTasks) do
        local row = g_ui.createWidget('DailyTaskRow', dailyList)
        row:find('lblLabel'):setText(task.label)
        local pct = math.floor((task.current / task.target) * 100)
        row:find('taskProgress'):setPercent(pct)
        row:find('lblProgress'):setText(task.current .. '/' .. task.target)
        row:find('chkDone'):setChecked(task.completed)
    end

    window:show()
    window:raise()
    window:focus()
end

function toggle()
    if window and window:isVisible() then
        window:hide()
    else
        -- Solicitar dados ao servidor
        local protocol = g_game.getProtocolGame()
        if protocol then
            protocol:sendExtendedOpcode(BATTLEPASS_OPCODE, json.encode({ action = "request" }))
        end
    end
end
```

---

## 🔢 Ordem de Implementação Recomendada

1. **Verificar opcode 150** — grep no servidor e cliente para confirmar ausência de colisão
2. **Migração BD** — `data/migrations/36.lua` (verificar número correto)
3. **Storage keys** — adicionar em `data/lib/core/storages.lua`
4. **`data/lib/battlepass/config.lua`** — tabelas de recompensas e configuração
5. **`data/lib/battlepass/core.lua`** — lógica de XP, level up, claim, daily tasks
6. **`data/scripts/eventcallbacks/player/battlepass_onKill.lua`** — rastreamento
7. **`data/scripts/globalevents/battlepass_daily_reset.lua`** — reset meia-noite
8. **`data/scripts/talkactions/player/misc/battlepass.lua`** — comando `!battlepass`
9. **UI — Implementação A** (`modules/game_battlepass_html/`) — HTML/CSS
10. **UI — Implementação B** (`modules/game_battlepass_otui/`) — OTUI widgets
11. **Avaliação comparativa** das duas UIs → escolher ou mesclar o melhor de cada

---

## 📋 Checklist de Entrega

### Servidor
- [ ] Migração BD: `player_battlepass` + `player_battlepass_daily`
- [ ] `data/lib/battlepass/config.lua` (config + recompensas)
- [ ] `data/lib/battlepass/core.lua` (lógica completa)
- [ ] `data/lib/lib.lua` atualizado com os dois dofiles
- [ ] `data/lib/core/storages.lua` com GlobalStorageKeys do battle pass
- [ ] EventCallback `onKill` para daily tasks
- [ ] GlobalEvent de reset diário
- [ ] TalkAction `!battlepass`

### Cliente — Implementação A (HTML/CSS)
- [ ] `modules/game_battlepass_html/game_battlepass_html.otmod`
- [ ] `modules/game_battlepass_html/game_battlepass_html.lua`
- [ ] `modules/game_battlepass_html/game_battlepass_html.html`
- [ ] `modules/game_battlepass_html/game_battlepass_html.css`

### Cliente — Implementação B (OTUI)
- [ ] `modules/game_battlepass_otui/game_battlepass_otui.otmod`
- [ ] `modules/game_battlepass_otui/game_battlepass_otui.lua`
- [ ] `modules/game_battlepass_otui/game_battlepass_otui.otui`
- [ ] `modules/game_battlepass_otui/style/ui.otui`

### Integração
- [ ] Opcode 150 confirmado sem colisão
- [ ] Payload JSON documentado e consistente entre servidor e ambos os clientes
- [ ] Teste de fluxo completo: login → daily tasks → kill monstro → progresso atualizado → opcode enviado → UI atualiza
