# Plano de Reconstrução: Battlepass UI (Premium)

Este plano detalha a refatoração completa da interface do Battlepass para atingir o padrão de qualidade dos módulos de elite do cliente (Store e Exaltation Forge).

## 📊 Motivação da Refatoração
A análise dos sistemas atuais revelou que a versão anterior do Battlepass era tecnicamente limitada e visualmente inconsistente. 
- **Tecnologia**: Migração total para o Renderer HTML/CSS (Padrão Forja).
- **Aesthetics**: Uso de molduras de pedra (`window.png`) e painéis texturizados (`panel.png`) para substituir cores planas.

## 🚀 Arquitetura da Nova UI

### 1. Sistema de Grade (Reward Matrix)
Implementamos uma matriz de 50 níveis com rolagem horizontal.
- **Estrutura**: Cada tier possui uma coluna com slot Free (topo), indicador de nível (centro) e slot Elite (base).
- **Estados Dinâmicos**: O CSS gerencia brilhos para o nível atual e opacidade reduzida para níveis bloqueados.
- **Interatividade**: Slots de recompensa são clicáveis para acionar o resgate via Lua.

### 2. Painel de Missões (Daily Pass)
Uma sidebar dedicada exibe as 3 missões diárias.
- **Design de Card**: Cada missão é um card com bordas sutis e barras de progresso que utilizam assets do jogo.
- **Feedback**: Cores de status (Verde para Completo, Vermelho para Ativo).

## 🛠️ Implementação Técnica

### Arquivos Modificados
- `modules/game_battlepass_html/game_battlepass_html.html`: Nova estrutura baseada em flexbox e tags `<UIItem>`.
- `modules/game_battlepass_html/game_battlepass_html.css`: Definição de tokens de design premium e border-images.
- `modules/game_battlepass_html/game_battlepass_html.lua`: Lógica reativa para popular 50 colunas dinamicamente baseado no OpCode 150.

## ✅ Garantia de Qualidade
- **Consistência**: Todos os botões e janelas usam os mesmos assets da `game_store`.
- **Performance**: Renderização baseada em propriedades reativas para minimizar o re-draw da UI.
