---
name: upmobb-atualizar-componente-biblioteca
description: >-
  Atualiza na biblioteca UpMobb um componente ou peça dinâmica que já foi gravada e depois corrigida no
  SketchUp (por exemplo, Puxador Cava Quadrado), por UpMobb > Recarregar componente ou Componentes dinâmicos >
  Redesenhar. Use quando o usuário pedir para recarregar, regravar, salvar de novo ou atualizar na biblioteca uma
  peça existente. Para gravar um componente novo, use upmobb-gravar-agregado.
when_to_use: >-
  "recarrega o componente", "regrava a peça", "salva de novo na biblioteca", "atualiza na biblioteca",
  "redesenha o componente"
---

# Atualizar componente já gravado na biblioteca UpMobb

Une `upmobb-recarregar-componente-biblioteca` e `upmobb-regravar-peca-biblioteca` (04/11/2026, peça de referência: Puxador Cava Quadrado no arquivo "puchador CAVA QUADADO").

Só vale para peça que **já está** na biblioteca. Componente novo: `upmobb-gravar-agregado` (e depois `upmobb-liberar-modulo`). Antes de agir, confirme com o usuário qual componente é e que ele já está na biblioteca — a gravação sobrescreve a versão da empresa inteira.

É um fluxo da interface (sem API): use a tela (skill `sketchup-tela`), com screenshot a cada nível. A ponte (`sketchup-ponte`) serve para ler e conferir atributos antes e depois.

## Qual comando usar

| Situação | Comando |
|---|---|
| O usuário pediu "recarregar", ou a peça mudou só de geometria/valor e precisa puxar a versão gravada | **UpMobb > Recarregar componente** |
| Atributos ou estrutura da peça foram corrigidos e é preciso gravar por cima na biblioteca | **Componentes dinâmicos > Redesenhar** (grava automaticamente no arquivo da biblioteca de origem) |

Se não estiver claro, pergunte ao usuário qual dos dois ele usa para essa peça. Não use "Salvar como..." nem sobrescreva outros arquivos sem pedido.

## Passos

1. Trazer o SketchUp para frente com o arquivo da peça aberto. Screenshot para confirmar o estado.
2. Ferramenta Selecionar → duplo clique para entrar na peça e nos subcomponentes até o componente alvo (ex.: Puxador Cava Quadrado dentro da porta / Peça Avulsa). Caixa tracejada ou contorno azul = componente em edição.
3. Abrir *Atributos de componente* (Janela) e conferir/corrigir os atributos (ex.: `cava_a`, `cava_l`, `cava_aba`, `cava_x`, `cava_z`, `cq_dist_h`, `cq_dist_v`, `lenx/leny/lenz`). Valores com `#=` (px, py, pz, rx, ry, rz) são fórmulas: não altere. Se for mudar fórmula, mostre ao usuário e pergunte antes.
4. Botão direito sobre o componente alvo:
   - **Recarregar:** UpMobb → **Recarregar componente** (não o "Recarregar" nativo do SketchUp) → na caixa "recarregar componentes selecionados?" clicar **Sim**.
   - **Redesenhar:** Componentes dinâmicos (entre "Adicionar encaixes" e "UpMobb Ambientes") → **Redesenhar**.
5. Conferir que a geometria atualizou (ex.: usinagem da cava no lugar) e que não apareceu erro.
6. Sair dos componentes (Esc ou clique fora) e avisar o usuário qual peça foi atualizada. Sugerir testar inserindo de novo a partir da biblioteca.

Se o erro persistir depois de Redesenhar, mostre os atributos ao usuário e pergunte antes de mexer em fórmulas.
