# Sistema Unificado de Mestria e Crafting de Aetherita (Aethrium) - Versão Final (V1)

Este documento é a fonte única de verdade para a implementação do sistema de Crafting End-Game do Aethrium. Ele consolida a economia de materiais, a progressão de mestrias e a hierarquia de equipamentos por vocação.

---

## 1. O Ciclo de Materiais e Economia

O sistema é desenhado para ser um "Sink" (escoamento) sustentável de recursos, valorizando tanto jogadores novos quanto veteranos.

### Fluxo de Produção
1.  **Aetherita Bruta** (ID 2150): Obtida via **Coleta Ativa** (Mineração no mapa ou Loot de Bosses). É um item físico e negociável.
2.  **Poeira de Aetherita (Dust)**: Recurso **VIRTUAL** obtido ao refinar a Bruta na **Forja Física**. Fica vinculado ao saldo do personagem.
3.  **Aetherita Sólida Refinada** (ID 2154): Criada ao consolidar **Poeira Virtual** na Forja. É um item físico necessário para o Crafting final.

### Rendimento e Mestria de Refino
| Nível de Mestria | Rendimento (Bruta ➔ Dust) | Custo de Consolidação (Dust ➔ Sólida) |
| :--- | :--- | :--- |
| **Nível 0** | 1 Bruta = 50 Dust | 500 Dust = 1 Sólida |
| **Nível 100** | 1 Bruta = 100 Dust (Média) | 250 Dust = 1 Sólida (**50% de Desconto**) |

---

## 2. As Três Mestrias (Habilidades Ativas)

O progresso é 100% ativo. Não há ganho passivo de XP.

1.  **Coleta (Gathering)**: Evolui ao minerar cristais e saquear Aetherita Bruta. Aumenta a quantidade de pedras extraídas.
2.  **Refino (Refining)**: Evolui ao usar a **Forja Física** para transformar Bruta em Dust ou Sólida. Aumenta o rendimento e a eficiência.
3.  **Crafting (Blacksmithing)**: Evolui ao criar equipamentos via UI. Aumenta a chance de sucesso e a chance de item **Masterworked**.

### Sistema de Prioridade
Os jogadores escolhem a ordem de aprendizado (1ª, 2ª e 3ª Prioridade).
- **Primária**: 1.8x XP (Sem limite).
- **Secundária**: 1.2x XP (Cap Nível 60).
- **Terciária**: 0.6x XP (Cap Nível 30).
- *Penalidade*: Trocar a 1ª Prioridade custa **30% do XP total** da skill promovida.

---

## 3. Catálogo de Equipamentos e Tiers

O Crafting é focado exclusivamente em itens End-Game, divididos por vocação.

### Regras de Progressão
- **Tier 1 (Épico)**: Requer um item **Super Raro Padrão** (ex: MPA, Golden Helmet) + Aetherita Sólida.
- **Tier 2 (Lendário)**: Requer o **Item Tier 1** da mesma categoria + Aetherita Sólida.
- **Tier 3 (Eterno)**: Requer o **Item Tier 2** + Aetherita Sólida + **Catalisador da Store** (Item Pago).

### Distribuição por Especialidade
- **Knight**: Set Completo (Helm, Armor, Legs, Boots, Shield) + 3 Armas 1-Mão + 3 Armas 2-Mão.
- **Paladin**: Set Completo + Bow + Crossbow.
- **Mage**: Set Completo + Wand + Rod.

---

## 4. Diferenciais Masterworked (Lendários)

Ao craftar um item, existe uma chance (Base 5% + Skill/10) de ele se tornar **Masterworked**.

- **Identificação**: Nome exibido em **Roxo (Purple)** no Look.
- **Bônus Passivo**: +15% de chance de sucesso na **Forja Exaltada**.
- **Soul Slot**: Desbloqueio nativo do **4º Slot de Imbuement**.

---

## 5. Arquitetura Técnica

- **Backend**: C++ (Source) para atributos e cores; Lua para lógica de receitas e XP.
- **Banco de Dados**: Tabela `player_aetherite_mastery` no XAMPP (DB `aethrium`).
- **Interface**: Módulo OTClient dedicado (OpCode 152).

---
*Documento Final - Aprovado em 15/04/2026*
