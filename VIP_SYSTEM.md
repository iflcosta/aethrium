# VIP System — Aethrium

## Visão Geral

O VIP System oferece 3 tiers de assinatura com benefícios progressivos. Todos os jogadores têm acesso ao Premium Account gratuitamente (`freePremium = true`), e o VIP adiciona benefícios exclusivos em cima disso.

---

## Tiers e Preços

| Tier | Preço (R$) | Tibia Coins |
|------|-----------|-------------|
| Bronze | R$ 12 | 120 TC |
| Silver | R$ 20 | 200 TC |
| Gold | R$ 30 | 300 TC |

---

## Benefícios por Tier

| Benefício | Bronze | Silver | Gold |
|-----------|:------:|:------:|:----:|
| XP Bonus | +10% | +20% | +30% |
| Loot Bonus | +10% | +15% | +25% |
| Depot | 25.000 | 35.000 | 50.000 |
| Autoloot Slots | 15 | 20 | 30 |
| Área VIP exclusiva | sim | sim | sim |
| Desconto Bless | — | — | 50% |
| Outfits exclusivos | 5 | +5 (10 total) | +15 (25 total) |
| Mounts exclusivos | 5 | +5 (10 total) | +15 (25 total) |

---

## Bless com Desconto Gold

- Preço base do bless: `level × 1500` gold por bless
- 5 bless no total
- VIP Gold: 50% de desconto → `level × 750` gold por bless

| Level | Preço normal (5 bless) | Preço Gold (5 bless) |
|-------|----------------------|---------------------|
| 100 | 750.000 | 375.000 |
| 300 | 2.250.000 | 1.125.000 |
| 500 | 3.750.000 | 1.875.000 |
| 800 | 6.000.000 | 3.000.000 |
| 1000 | 7.500.000 | 3.750.000 |

> O sistema de bless será revisado junto com XP/loss e interação com o Reset System.

---

## Premium Account (freePremium = true)

Todos os jogadores recebem gratuitamente os benefícios nativos de premium:

- Stamina +50% XP (acima de 2400 minutos)
- Uso de camas (regeneração offline)
- Spells marcadas como premium
- Canal privado próprio
- Depot 15.000
- Autoloot 10 slots
- Gold Pouch ilimitado
- Compra de casas
- Outfits e mounts premium desbloqueados por padrão

---

## Outfits VIP

### Bronze (5 outfits)
| Outfit |
|--------|
| Barbarian |
| Warrior |
| Assassin |
| Shaman |
| Demon Hunter |

### Silver (+5 outfits, 10 total)
| Outfit |
|--------|
| Nightmare |
| Elementalist |
| Insectoid |
| Arena Champion |
| Lupine Warden |

### Gold (+15 outfits, 25 total)
| Outfit |
|--------|
| Demon |
| Crystal Warlord |
| Rift Warrior |
| Dragon Knight |
| Doom Knight |
| Celestial Avenger |
| Darklight Evoker |
| Flamefury Mage |
| Void Master |
| Fiend Slayer |
| Ghost Blade |
| Winged Druid |
| Blade Dancer |
| Chaos Acolyte |
| Death Herald |

---

## Mounts VIP

### Bronze (5 mounts)
| Mount |
|-------|
| War Horse |
| Crystal Wolf |
| Midnight Panther |
| Draptor |
| Stampor |

### Silver (+5 mounts, 10 total)
| Mount |
|-------|
| Noble Lion |
| Blazebringer |
| Dragonling |
| The Hellgrip |
| Stone Rhino |

### Gold (+15 mounts, 25 total)
| Mount |
|-------|
| Gryphon |
| Singeing Steed |
| Krakoloss |
| White Lion |
| Rift Runner |
| Vortexion |
| Void Watcher |
| Rune Watcher |
| Rift Watcher |
| Sparkion |
| Neon Sparkid |
| Mutated Abomination |
| Ripptor |
| Phantasmal Jade |
| Haze |

---

## Distribuição Geral de Outfits

| Origem | Descrição |
|--------|-----------|
| Padrão | Desbloqueados para todos por padrão (Citizen, Hunter, Mage, Knight, etc.) |
| VIP Bronze/Silver/Gold | Concedidos automaticamente ao ativar o tier |
| Store | Comprados com Tibia Coins (Formal Dress, Nordic Chieftain, Fencer, Golden, Pharaoh, Royal Costume, etc.) |
| Eventos / Edição Limitada | Distribuídos em ocasiões especiais, sazonais ou edições limitadas |
| Quest / Addon (futuro) | Desbloqueados via quest ou sistema de addons por itens |

---

## Ativação

- **Item consumível** — VIP Scroll (Bronze/Silver/Gold) comprado com Tibia Coins
- **Comando admin** — `!vipadmin Nome, Tier, Dias`
- Duração: **30 dias** por scroll
- Acúmulo: se o jogador já tem VIP ativo do mesmo tier, os dias são somados

---

## Armazenamento (Source)

Colunas na tabela `players` (não storage values):

```sql
ALTER TABLE `players`
  ADD COLUMN `vip_tier`    TINYINT  NOT NULL DEFAULT 0,
  ADD COLUMN `vip_expires` BIGINT   NOT NULL DEFAULT 0;
```

- `vip_tier` — 0 = sem VIP, 1 = Bronze, 2 = Silver, 3 = Gold
- `vip_expires` — timestamp Unix da expiração

Métodos expostos ao Lua via `luaplayer.cpp`:
- `player:getVipTier()` — retorna 0–3
- `player:isVip()` — true se tier > 0 e não expirado
- `player:setVip(tier, days)` — define tier e soma dias
- `player:getVipDaysRemaining()` — dias restantes

---

## Expiração

- Verificada no login e ao matar monstro (para XP/loot bonus)
- Ao expirar: tier volta a 0, outfits/mounts VIP são revogados, mensagem enviada ao jogador
- Aviso automático com 3 dias de antecedência

---

## Arquivos do Sistema

### Servidor (`aethrium-baiak`)
| Arquivo | Função |
|---------|--------|
| `src/player.h` | Campos `vipTier`, `vipExpires` e declarações |
| `src/player.cpp` | `isVip()`, `getVipTier()`, `setVip()`, XP/loot bonus hooks |
| `src/luaplayer.cpp` | Exposição ao Lua |
| `src/iologindata.cpp` | Load/save dos campos no DB |
| `data/migrations/vip_system.sql` | Migration SQL |
| `data/scripts/talkactions/player/misc/vip.lua` | Talkaction `!vip` (status) e `!gohome` |
| `data/scripts/talkactions/god/vipadmin.lua` | Comando admin |
| `data/scripts/actions/vip_scroll.lua` | Ativação por item |
| `data/scripts/creaturescripts/vip_login.lua` | Login: verificar expiração, registrar outfits/mounts |
| `data/scripts/movements/vip_tiles.lua` | Tiles de área VIP restrita |
| `data/npc/scripts/bless.lua` | NPC bless com desconto Gold |

### Cliente (`aethrium-client`)
| Arquivo | Função |
|---------|--------|
| `modules/game_vip/game_vip.otmod` | Definição do módulo |
| `modules/game_vip/game_vip.lua` | Controller: opcode 181, data binding |
| `modules/game_vip/game_vip.html` | Layout HTML do modal |
| `modules/game_vip/game_vip.css` | Estilos no padrão Forge |

---

## Protocolo de Comunicação

- **Opcode:** 181 (Extended Opcode)
- **Formato:** JSON

### Servidor → Cliente

| action | Quando | Dados |
|--------|--------|-------|
| `open` | Jogador digita `!vip` | tier, daysRemaining, benefits, outfits, mounts |
| `expired` | VIP expirou | message |

---

## Pendências

- [ ] Definir outfit exclusivo adicional para Gold (a confirmar)
- [ ] Revisar sistema de bless completo (XP/loss × reset)
- [ ] Definir localização da área VIP no mapa
- [ ] Definir sistema de addons por itens (futuro)
- [ ] Definir outfits para eventos/edição limitada (futuro)
