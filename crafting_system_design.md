# Plano de Design: Sistema de Crafting (Aethrium)

Este documento detalha o design e a arquitetura técnica para a implementação de um sistema de Crafting de itens únicos, integrado aos sistemas de Imbuement e Exaltation Forge.

## 🎯 Objetivo
Transformar o loot excedente em recursos valiosos, permitindo a criação de itens "Masterworked" que superam os limites dos itens comuns em bônus de Tier e Slots de Imbuement.

## 💎 Conceitos de Design

### 1. Itens Masterworked (Únicos)
- **Atributo Visual**: Itens craftados terão o nome em uma cor diferenciada (ex: Roxo/Lendário) no comando `Look`.
- **Sinergia com Forja**: Itens Masterworked possuem 15% de bônus na chance de sucesso da Forja e podem atingir **Classificação 6**.
- **Sinergia com Imbuement**: Desbloqueio do **"Slot de Alma"** (4º slot exclusivo para atributos únicos como Life Drain passivo ou Speed).

### 2. O Ciclo de Materiais (Gameplay Loop)
- **Salvage (Moagem)**: Sistema para destruir itens raros (ex: Golden Armor) e obter `Crafting Dust`.
- **Blueprints (Receitas)**: Itens raros obtidos via Bosses, Dungeons e o **Battle Pass**.
- **Catalisadores**: Itens da Store que aumentam a chance de sucesso ou garantem que os materiais não sejam perdidos em caso de falha.

## 🛠️ Arquitetura Técnica

### Backend (Servidor)
- **Localização**: `data/lib/crafting_core.lua` e `data/scripts/actions/crafting.lua`.
- **Persistência**: Tabela `item_recipes` no DB e novos atributos de item no C++ (`ITEM_ATTRIBUTE_CRAFTED`).
- **Comunicação**: Protocolo via OpCode Estendido **151**.

### Frontend (Cliente)
- **Módulo**: `modules/game_crafting`.
- **Interface**: Janela modal com slots para materiais, área de preview do item resultante (mostrando possíveis atributos) e barra de progresso.
- **Efeitos**: Reuso dos Shaders de forja (`forge_success.frag` / `forge_failed.frag`).

## 📋 Próximos Passos
1.  Definição do modelo de "Risco" (Sucesso/Falha).
2.  Mapeamento das primeiras 10 receitas iniciais.
3.  Desenvolvimento da UI base no OTClient.
