# Reset System — Aethrium

## Visão Geral

O Reset System permite que jogadores que atingirem um nível mínimo reiniciem seu personagem ao level 8, mantendo bônus permanentes acumulados a cada reset. O sistema incentiva múltiplos ciclos de progressão com recompensas crescentes por vocação.

---

## Níveis Necessários por Reset

| Reset | Nível Mínimo | XP Limit (para de ganhar XP) |
|-------|-------------|-------------------------------|
| 1º    | 500         | 650 (×1.3)                    |
| 2º    | 600         | 780 (×1.3)                    |
| 3º    | 700         | 910 (×1.3)                    |
| 4º    | 800         | 1040 (×1.3)                   |
| 5º    | 900         | 1170 (×1.3)                   |
| 6º+   | 1000        | 1300 (×1.3)                   |
| 10º+  | 1000        | 1500 (×1.5)                   |

> A partir do 10º reset, o multiplicador do XP Limit sobe para 1.5.

---

## Overshoot de Skills

Enquanto o jogador está acima do nível necessário para o reset atual, ele recebe um **bônus temporário** nas suas skills e Magic Level:

- A cada **10% acima** do nível necessário → **+10% nas skills/ML atuais**
- Máximo: **+30%** (resets 1–9) ou **+50%** (reset 10+)
- O bônus é temporário e removido ao resetar

### Exemplo (1º reset, nível necessário 500):

| Nível atual | Overshoot | Bônus de skill |
|-------------|-----------|----------------|
| 500–549     | 0–9%      | +0%            |
| 550–599     | 10–19%    | +10%           |
| 600–649     | 20–29%    | +20%           |
| 650 (cap)   | 30%       | +30%           |

> Knight com Sword 100, level 550 → Sword temporariamente **110**.

---

## Redux de Skills ao Resetar

Ao executar `!reset`, o jogador perde o bônus de overshoot e sofre penalidade permanente nas skills:

| Resets        | Penalidade         |
|---------------|--------------------|
| 1º ao 9º      | −30% da skill base |
| 10º em diante | −50% da skill base |

### Fórmula:
```
skill_após_reset = floor(skill_base × (1 − redux))
mínimo: 10 para skills de combate, 0 para Magic Level
```

### Exemplo:
- Knight, Sword 100, 1º reset → `floor(100 × 0.7)` = **70**
- Knight, Sword 100, 10º reset → `floor(100 × 0.5)` = **50**

> O redux pode ser desativado globalmente com `resetSkills = false` no `config.lua`.

---

## Stats Base ao Resetar

Ao resetar, o personagem volta ao nível 8 com os stats base de criação do servidor:

| Stat | Valor Base |
|------|------------|
| HP   | 185        |
| Mana | 90         |
| Cap  | 470        |

Esses valores são somados aos bônus acumulados de todos os resets realizados.

---

## Bônus Permanentes por Vocação

A cada reset, o jogador ganha bônus permanentes de HP, Mana e Capacidade que se acumulam permanentemente.

### Knight / Elite Knight

| Reset | +HP  | +Mana | +Cap  |
|-------|------|-------|-------|
| 1º–2º | +200 | +50   | +1000 |
| 3º–4º | +250 | +75   | +1250 |
| 5º+   | +300 | +100  | +1500 |

### Paladin / Royal Paladin

| Reset | +HP  | +Mana | +Cap  |
|-------|------|-------|-------|
| 1º–2º | +150 | +150  | +750  |
| 3º–4º | +175 | +175  | +875  |
| 5º+   | +200 | +200  | +1000 |

### Sorcerer / Master Sorcerer

| Reset | +HP  | +Mana | +Cap  |
|-------|------|-------|-------|
| 1º–2º | +50  | +300  | +500  |
| 3º–4º | +75  | +350  | +600  |
| 5º+   | +100 | +400  | +750  |

### Druid / Elder Druid

| Reset | +HP  | +Mana | +Cap  |
|-------|------|-------|-------|
| 1º–2º | +75  | +250  | +500  |
| 3º–4º | +100 | +300  | +600  |
| 5º+   | +125 | +350  | +750  |

### Monk / Exalted Monk

| Reset | +HP  | +Mana | +Cap  |
|-------|------|-------|-------|
| 1º–2º | +150 | +150  | +750  |
| 3º–4º | +175 | +175  | +875  |
| 5º+   | +200 | +200  | +1000 |

---

## Marcos Especiais

| Reset | Bônus Único              |
|-------|--------------------------|
| 3º    | Slot extra de Imbuimento |
| 5º    | Slot extra de Prey       |
| 8º    | Outfit exclusivo         |
| 10º   | Título especial + Aura   |

---

## Skill Seal

Protege uma skill do redux no próximo reset.

- **Preço:** 50 Tibia Coins por skill
- **Comando:** `!sealskill <nome_da_skill>`
- **Duração:** Consumido no reset (uso único)
- **Skills protegíveis:** fist, club, sword, axe, distance, shielding, fishing, magic
- **Quantidade:** Ilimitada por reset

---

## Modal de Reset (`!reset`)

O modal abre ao digitar `!reset` independente do nível — o jogador pode se informar mesmo sem o nível necessário. Ao clicar "Confirmar Reset" sem nível suficiente, o servidor rejeita.

### Painel Esquerdo — Voce Perde:
- Level → 8
- Redux de Skills e Magic Level
- Preview de cada skill com valor antes e depois do redux

### Painel Direito — Voce Ganha:
- +HP, +Mana, +Cap do reset atual
- HP/Mana/Cap total após o reset (base + todos os bônus acumulados)
- Milestone especial (se houver)

---

## Configuração (config.lua)

```lua
resetSystemEnabled = true   -- habilita/desabilita o sistema
resetSkills = true          -- true = aplica redux nas skills, false = mantém skills intactas
```

---

## Banco de Dados

### Colunas adicionadas à tabela `players`:

```sql
ALTER TABLE `players`
  ADD COLUMN `reset_bonus_hp`   INT NOT NULL DEFAULT 0,
  ADD COLUMN `reset_bonus_mana` INT NOT NULL DEFAULT 0,
  ADD COLUMN `reset_bonus_cap`  INT NOT NULL DEFAULT 0,
  ADD COLUMN `sealed_skills`    INT UNSIGNED NOT NULL DEFAULT 0;
```

- `reset_bonus_hp/mana/cap` — total acumulado de bônus de todos os resets
- `sealed_skills` — bitmask: bit N = skill N protegida no próximo reset

---

## Arquivos do Sistema

### Servidor (`aethrium-baiak`)
| Arquivo | Função |
|---------|--------|
| `src/player.h` | Campos e declarações do reset system |
| `src/player.cpp` | `doReset()`, `getResetRequiredLevel()`, `getResetXPCap()`, `getOvershootBonus()`, `getResetVocationBonus()` |
| `src/luaplayer.cpp` | Exposição ao Lua via registerMethod |
| `src/iologindata.cpp` | Load/save dos campos no DB |
| `src/luascript.cpp` | Carrega `json.lua` como global para todos os scripts |
| `data/scripts/talkactions/player/misc/reset.lua` | Talkaction `!reset` e handler do opcode 180 |
| `data/scripts/talkactions/player/misc/sealskill.lua` | Talkaction `!sealskill <skill>` |
| `data/migrations/reset_system_v2.sql` | Migration SQL |

### Cliente (`aethrium-client`)
| Arquivo | Função |
|---------|--------|
| `modules/game_reset/game_reset.otmod` | Definição do módulo |
| `modules/game_reset/game_reset.lua` | Controller: opcode 180, data binding |
| `modules/game_reset/game_reset.html` | Layout HTML do modal |
| `modules/game_reset/game_reset.css` | Estilos no padrão Forge |
| `modules/game_interface/interface.otmod` | Referencia game_reset no load-later |

---

## Protocolo de Comunicação

- **Opcode:** 180 (Extended Opcode)
- **Formato:** JSON

### Servidor → Cliente (`action`):

| action  | Quando                        | Dados principais |
|---------|-------------------------------|------------------|
| `open`  | Jogador digita `!reset`       | resetNum, requiredLevel, xpCap, reduxPct, bonusHP/Mana/Cap, accHP/Mana/Cap, skills[] |
| `done`  | Reset executado com sucesso   | resetNum |
| `error` | Nível insuficiente            | message |

### Cliente → Servidor (`action`):

| action    | Quando |
|-----------|--------|
| `confirm` | Clica "Confirmar Reset" |
| `request` | Pede dados atualizados (ex: após Skill Seal) |

---

## Hunts por Reset (Futuro)

Hunts exclusivas acessíveis apenas para jogadores com mínimo X resets. Detalhes a definir.
