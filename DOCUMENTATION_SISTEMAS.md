# Documentação dos Sistemas Implementados - Aethrium

## Visão Geral

Este documento descreve todos os sistemas implementados no servidor Aethrium, incluindo Sistema de Tasks, Hunts por Instância, Boss Rooms por Instância, NPC de Decoração e Sistema de Troca de Addons.

---

## 1. Sistema de Tasks (Melhorado)

### Arquivos Criados/Modificados

| Arquivo | Descrição |
|---------|-----------|
| `data/lib/core/task_system.lua` | Dados das tasks (monsters, recompensas, storages) |
| `data/scripts/creaturescripts/task_kill.lua` | Evento de kill que conta progresso |
| `data/lib/core/player.lua` | Adicionado getTaskPoints(), addTaskPoints(), removeTaskPoints() |
| `data/scripts/creaturescripts/player_login_logout.lua` | Registro do evento TaskKill |
| `data/lib/lib.lua` | Carregamento do sistema |

### Estrutura de Dados

```lua
-- task_monsters: Tasks normais
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
    -- ... mais 9 tasks
}

-- task_daily: Tasks diárias
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
    -- ... mais 9 tasks diárias
}
```

### Storages Utilizados

| Storage | Função |
|---------|--------|
| 200001 | Task Points do jogador |
| 30100 | Task atual (normal) |
| 30101 | Kills da task normal |
| 30102 | Tempo de punição (abandonar) |
| 30103 | Task diária atual |
| 30104 | Kills da task diária |
| 30105 | Cooldown diária |

### Funções do Player

```lua
-- Get Task Points
player:getTaskPoints()

-- Add Task Points
player:addTaskPoints(amount)

-- Remove Task Points
player:removeTaskPoints(amount)
```

### NPC Bianca

O NPC Bianca foi atualizado para o novo sistema de tasks:
- Tasks normais: "normal"
- Tasks diárias: "daily"
- Receber rewards: "receive"
- Abandonar: "abandon"
- Ver listas: "lista de task normal", "lista de task diária"

---

## 2. Sistema de Hunt por Instância (SuperUP)

Usa o **Instance System nativo do engine** (C++) — isolamento real via `instanceId`. Múltiplos jogadores podem usar a mesma sala física ao mesmo tempo sem se ver.

### Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `data/lib/core/hunt_system.lua` | Dados, lógica de entrada, spawn, re-spawn e cleanup |
| `data/scripts/creaturescripts/instances_cleanup.lua` | Cleanup de logout/login |
| `data/scripts/creaturescripts/others/extendedopcode.lua` | Opcode 151 — recebe ações da UI |

### Interface com o Jogador

Acessado via **OTUI** (`game_instances`) — janela com grid de cards, abas Hunt/Boss, filtro por moeda.  
Não há comandos de texto; toda interação é pela janela.

### Hunts Disponíveis (20 hunts)

| IDs | Categoria | Level | Moeda | Preço |
|-----|-----------|-------|-------|-------|
| 1–3 | Cobra Cave I–III | 500+ | Tibia Coins | 50 TC |
| 4–7 | Falcon Cave I–IV | 700+ | Tibia Coins | 80 TC |
| 8–10 | Golem Cave I–III | 900+ | Tibia Coins | 120 TC |
| 11–13 | Asura Cave I–III | 500+ | Task Points | 500 TP |
| 14–16 | Lost Soul Cave I–III | 700+ | Task Points | 800 TP |
| 17–20 | Sea Devil Cave I–IV | 900+ | Task Points | 1200 TP |

### API principal

```lua
-- Entrada na hunt (chamada pelo opcode handler)
HuntSystem.enter(player, huntId)
-- Retorna: success (bool), instanceId ou mensagem de erro

-- Remove jogador da instância (logout/sair)
HuntSystem.removePlayer(player)

-- Dados para a UI
HuntSystem.getUIData(player)
-- Retorna: lista com id, name, monsters, level, currency, price, time, cooldown
```

### Storages

| Storage | Função |
|---------|--------|
| 50000 + huntId | Timestamp de expiração do cooldown por jogador |

---

## 3. Sistema de Boss Room por Instância

Mesmo princípio do Hunt System — instâncias nativas do engine. A **mesma sala física** pode ser usada por múltiplos grupos simultaneamente, cada um isolado em sua própria instância.

### Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `data/lib/core/boss_room.lua` | Dados, lógica de entrada, spawn do boss, rewards e cleanup |
| `data/scripts/creaturescripts/instances_cleanup.lua` | Cleanup compartilhado com hunts |
| `data/scripts/creaturescripts/others/extendedopcode.lua` | Opcode 151 — recebe ações da UI |

### Bosses Disponíveis (20 bosses)

| IDs | Bosses | Level | Moeda | Preço | Kill Time |
|-----|--------|-------|-------|-------|-----------|
| 1 | Gaz'haragoth | 250+ | Coins | 100 TC | 15 min |
| 2 | Abyssador | 230+ | Coins | 80 TC | 15 min |
| 3 | Deathstrike | 220+ | Coins | 80 TC | 15 min |
| 4 | Gnomevil | 200+ | Coins | 70 TC | 15 min |
| 5 | Chizzoron | 180+ | Coins | 60 TC | 15 min |
| 6 | The Abomination | 160+ | Coins | 50 TC | 12 min |
| 7 | Jaul | 150+ | Coins | 40 TC | 12 min |
| 8 | Tanjis | 140+ | Coins | 40 TC | 12 min |
| 9 | Obujos | 130+ | Coins | 40 TC | 12 min |
| 10 | Zulazza | 120+ | Coins | 30 TC | 12 min |
| 11 | Apocalypse | 300+ | Tasks | 1000 TP | 10 min |
| 12 | Bazir | 280+ | Tasks | 900 TP | 10 min |
| 13 | Infernatil | 270+ | Tasks | 800 TP | 10 min |
| 14 | Verminor | 260+ | Tasks | 700 TP | 10 min |
| 15 | Ferumbras | 250+ | Tasks | 600 TP | 10 min |
| 16 | Morgaroth | 240+ | Tasks | 500 TP | 10 min |
| 17 | Ghazbaran | 230+ | Tasks | 500 TP | 10 min |
| 18 | The Pale Count | 200+ | Tasks | 400 TP | 10 min |
| 19 | Zoralurk | 180+ | Tasks | 300 TP | 10 min |
| 20 | Annihilon | 160+ | Tasks | 200 TP | 10 min |

### Coordenadas das Salas

Todas as salas usam as coordenadas exatas do mapa do baiakthunder (z=9), área `center ± 6` tiles.  
Salas de Coins: y ≈ 867–980. Salas de Tasks: y ≈ 761–872.

### API principal

```lua
-- Entrada na boss room (chamada pelo opcode handler)
BossRoom.enter(player, bossId)
-- Retorna: success (bool), instanceId ou mensagem de erro

-- Remove jogador da instância
BossRoom.removePlayer(player)

-- Dados para a UI
BossRoom.getUIData(player)
```

### Sistema de Party

- Apenas o **líder** paga e inicia a entrada
- Todos os membros elegíveis (level + sem cooldown) entram juntos
- `maxPlayers` limita a 10 (configurável por boss)

### Rewards

- Quem causou dano ao boss recebe **Task Points** (`pointsReward`, 2–7 TP por boss)
- Boss spawna 5s após a entrada para os jogadores se posicionarem
- 30s após a morte do boss a sala fecha e todos são teleportados

### Storages

| Storage | Função |
|---------|--------|
| 51000 + bossId | Timestamp de expiração do cooldown (30 min) por jogador |

---

## 4. NPC Moveleiro (Decoração de Casas)

### Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `data/npc/Moveleiro.xml` | Definição do NPC |
| `data/npc/scripts/furniture.lua` | Script de vendas |

### Posicionamento

Colocar o NPC em algum ponto de venda (suggestão: cidade principal).

### Categorias de Itens

| Categoria | Descrição | IDs de exemplo |
|-----------|-----------|----------------|
| Zaoan | Vasos, carpets, mesas | 9774-9791 |
| Serpent | Estátuas, carpets, chifres | 9796-9994 |
| Natal | Árvores, morcegos, esqueletos | 6491-6998 |
| Diversos | Kits, escudos, lanças | 11090-23473 |

### Diálogo

```
NPC: "Ola |PLAYERNAME|! Tenho varios moveis para Decoracao de casas. Vire ver minha {loja}!"
```

### Comandos do Jogador

| Comando | Ação |
|---------|------|
| `{loja}` | Mostra categorias |
| `{zanoan}` | Filtra itens Zaoan |
| `{serpent}` | Filtra itens Serpent |
| `{natal}` | Filtra itens de Natal |
| `{diversos}` | Filtra itens diversos |
| `{todos}` | Mostra todos os itens |
| `comprar [id] [qtd]` | Compra item |

---

## 5. NPC Armeiro (Troca de Addons)

### Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `data/npc/Armeiro.xml` | Definição do NPC |
| `data/npc/scripts/addon.lua` | Script de troca |

### Outfits Disponíveis

| Outfit ID | Nome | Addon 1 | Addon 2 |
|-----------|------|---------|---------|
| 128 | Citizen | 10x Spider Silk, 10x Felbat Leather | 20x Spider Silk, 20x Felbat Leather |
| 129 | Hunter | 15x Spider Silk, 1x Assassin Star | 25x Spider Silk, 1x Piece of Dead Brain |
| 130 | Mage | 5x Empty, 5x Strong | 10x Empty, 10x Strong |
| 131 | Knight | 1x Brass Armor, 1x Brass Helmet | 1x Brass Legs, 1x Brass Shield |
| 133 | Noble | 500 gp | 1000 gp |
| 134 | Summoner | 10x Mana Potion, 1x Spellbook | 20x Mana Potion, 1x Spellbook of DRAGONS |
| 137 | Ninja | 2000 gp | 3000 gp |
| 138 | Barbarian | 1000 gp | 1500 gp |
| 139 | Pirate | 800 gp | 1200 gp |
| 140 | Assassin | 1500 gp | 2000 gp |
| 141 | Beggar | 500 gp | 800 gp |
| 142 | Shaman | 1000 gp | 1500 gp |
| 143 | Norse | 800 gp | 1200 gp |
| 144 | Jester | 600 gp | 900 gp |
| 145 | Elf | 2000 gp | 3000 gp |
| 146 | Dwarf | 2000 gp | 3000 gp |
| 147 | Druid | 1500 gp | 2000 gp |
| 148 | Party Girl | 800 gp | 1200 gp |
| 149 | Merchant | 500 gp | 800 gp |
| 150 | Warrior | 2500 gp | 3500 gp |
| 155 | Old | 300 gp | 500 gp |
| 156 | Recruiter | 1000 gp | 1500 gp |

### Diálogo

```
NPC: "Ola |PLAYERNAME|! Sou o armeiro. Posso adicionar addons em suas outfits em troca de itens. Diga {addons} para ver o que eu troco!"
```

### Comandos do Jogador

| Comando | Ação |
|---------|------|
| `{addons}` | Mostra opções |
| `{lista}` | Lista completa de trocas |
| `{trocar} [outfit] [1 ou 2]` | Efetua troca |
| `{noble}` | Verifica requisitos específicos |

### Validações

1. Jogador deve ter a outfit base
2. Jogador não pode ter o addon já instalado
3. Jogador deve ter os itens necessários

---

## Resumo de Storages

| Range | Sistema |
|-------|---------|
| 200001 | Task Points |
| 30100-30105 | Task System |
| 50001-50020 | Hunt cooldown por jogador (50000 + huntId) |
| 51001-51020 | Boss Room cooldown por jogador (51000 + bossId) |

---

## Notas para Implementação

### Tasks
- O sistema usa storages para tracking de progresso
- O NPC Bianca manteve compatibilidade de diálogo com o sistema anterior
- Recompensas incluem gold (id 2160), experiência e task points

### Hunts
- Atualmente apenas a lógica de teleporte foi implementada
- O spawn de monstros dentro da área da instância ainda não foi implementado
- A duração de 3 horas é controlada via storage

### Boss Rooms
- Suporte a party (apenas o líder inicia a entrada)
- Cooldown de 30 minutos evita spam de entrada
- As salas de boss precisam ser configuradas no mapa usando doors/terreno para isolamento

### Addons
- Usa `player:addOutfitAddon()` (API padrão TFS)
- Verificar se o C++ suporta a função

---

## Custo dos Sistemas

| Sistema | Custo (Tibia Coins) | Custo (Task Points) | Custo (Outros) |
|---------|---------------------|---------------------|----------------|
| Demon Hunt | 100 | 50 | - |
| Dragon Hunt | 80 | 40 | - |
| Spider Hunt | 50 | 30 | - |
| Cyclops Hunt | 40 | 20 | - |
| Troll Hunt | 20 | 10 | - |
| Infernal Boss | 200 | 100 | - |
| Dragon Boss | 150 | 75 | - |
| Hydra Boss | 250 | 150 | - |
| Behemoth Boss | 180 | 80 | - |
| Demon Boss | 300 | 200 | - |
| Decoração | 250-2000 gp | - | - |
| Addons | 300-3500 gp | - | Various items |

---

## Pendências e Itens Não Implementados

| Sistema | Pendência | Prioridade |
|---------|-----------|------------|
| game_instances (OTUI) | Ícone próprio para o botão do painel (atualmente reutiliza ícone do Cyclopedia) | Baixa |
| NPC Moveleiro | Posicionamento no mapa (cidade principal) | Baixa |
| NPC Armeiro | Posicionamento no mapa | Baixa |
| Addons | Verificar suporte de `player:addOutfitAddon()` no C++ customizado | Média |

---

*Documento gerado em 2026-04-14*
*Projeto: Aethrium - Servidor Tibia 8.60*