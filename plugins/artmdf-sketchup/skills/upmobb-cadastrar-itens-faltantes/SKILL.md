---
name: upmobb-cadastrar-itens-faltantes
description: >-
  Cadastra no painel web do UpMobb (tela Insumos) os itens que aparecem na "Lista de elementos sem cadastro"
  ao gerar Itens a comprar no SketchUp, com código, descrição, unidade e categoria certos, e confere regerando
  a lista até o aviso sumir. Use quando o usuário pedir para cadastrar itens sem cadastro, cadastrar insumos
  faltantes, zerar a lista de elementos sem cadastro, ou colar uma lista no formato CODIGO - Descrição.
when_to_use: >-
  "cadastra os itens que faltam", "itens sem cadastro", "elementos sem cadastro", "cadastra os insumos",
  "a lista de compras deu item sem cadastro", "zera a lista sem cadastro", lista colada com linhas
  "CODIGO - Descrição"
---

# Cadastrar itens faltantes no UpMobb

Objetivo: zerar o aviso "Lista de elementos sem cadastro" que o UpMobb mostra ao gerar "Itens a comprar", cadastrando cada item em Insumos no painel web. Pronto é quando a lista regerada vem vazia, e não quando os itens foram salvos.

Esta skill não altera o modelo. Cadastro de insumo mexe no sistema da empresa: nada é gravado sem o usuário aprovar a lista completa.

Comandos:
- **JANELAS** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/janelas.ps1"`
- **SK** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/sk.ps1"`

Regras da casa: `${user_config.pasta_trabalho}/_claude/regras-insumos.md`. Prevalecem sobre a tabela padrão de `references/cadastro-insumos.md`.

## 1. Obter a lista

No SketchUp: painel UpMobb > Exportação > Exportar listagens > Itens a comprar > "Todo o projeto" > Exportar. Se houver item sem cadastro, abre o diálogo "Lista de elementos sem cadastro", com uma linha por item: `CODIGO - Descrição`.

Pegue o texto pelo caminho mais confiável disponível, nesta ordem:
1. **O usuário colou a lista no chat**: use a lista colada. É o caminho mais rápido.
2. **`JANELAS -ProcessoId <PID>`**: lê o texto do diálogo sem tocar no mouse. `SK status` mostra o PID.
3. **Captura**: `JANELAS -ProcessoId <PID> -Capturar "<pasta>\sem-cadastro.png" -Janela "sem cadastro"` e leia a imagem (se o título do diálogo for outro, rode `JANELAS -ProcessoId <PID>` sem filtro para ver os títulos). Pode também ler pela tela (skill `sketchup-tela`). Amplie para não errar caractere de código.
4. Se nada disso funcionar, peça ao usuário que gere a lista e cole o texto.

Os botões do painel (gerar a lista) são operados pela tela, pela skill `sketchup-tela`, ou o usuário clica. Não apareceu o diálogo: não há pendência, então informe e termine.

## 2. Separar e classificar

1. Separe cada linha no **primeiro** " - ". O código fica à esquerda, copiado exato (maiúsculas, underscores, sem espaço sobrando). A descrição fica à direita, também exata, mesmo com erro de digitação aparente: não corrija sem perguntar.
2. Classifique a unidade e a categoria: primeiro por `regras-insumos.md`, depois pela tabela de `references/cadastro-insumos.md`.
3. Se não der para classificar com segurança, use "Indefinido". Preço fica 0,00: nunca invente.

## 3. Aprovar antes de gravar

Mostre uma tabela com código, descrição, unidade e categoria, destacando os itens duvidosos. Faça uma única pergunta, agrupando todas as dúvidas. Só comece a gravar depois do OK.

## 4. Cadastrar no painel web

Site: `https://upmobb.com.br/mdfart/products.html` (menu Insumos), com o login do usuário no navegador.
- Use o navegador do Claude (Claude in Chrome), e não cliques de tela do desktop.
- Se houver uma skill do navegador, carregue-a antes.
- Trabalhe numa aba nova.

Para cada item:
1. **Já existe?** Procure o código na tabela (busca da página ou leitura da tabela). Se já existir, não duplique: anote o item e compare unidade e categoria. Se o código cadastrado for parecido mas não idêntico (espaço, letra), a causa provável do "sem cadastro" é essa. Mostre a diferença ao usuário.
2. Role até o fim e clique em **"Adicionar +"** (canto inferior direito). Surge uma linha editável no final.
3. Preencha a linha com o código, a descrição, a unidade e a categoria. Os demais campos ficam no padrão (valores 0.00, tipo "Padrão", Sim/Não em "Não"), salvo regra da casa. A ordem das colunas está em `references/cadastro-insumos.md`.
4. Clique em **"Salvar"** e confira que a linha ficou gravada, com Editar/Apagar e data. Releia o código gravado.

Se surgir uma caixa de confirmação ou erro da página, leia antes de responder. Para "Apagar" ou para substituir um item existente, só com OK.

## 5. Verificar (obrigatório)

Regere "Itens a comprar" no SketchUp (passo 1). A lista de elementos sem cadastro deve vir vazia ou não aparecer.
- **Sobrou item:** confira se o código é idêntico ao da lista (espaço, maiúscula, underscore) e repita só para ele.
- **"Operação cancelada" ou `LocalJumpError` em exports.rbe/request.rbe** (no Console Ruby: `SK console`): é erro do UpMobb, não do cadastro. Reabra o painel e repita; se persistir, fale com o suporte do UpMobb.

## 6. Resumo

Tabela curta com código, descrição, unidade e categoria. Acrescente:
- a confirmação de que a lista regerada ficou zerada;
- os itens que já existiam;
- os itens que ficaram "Indefinido", para o usuário decidir.

## Aprender

Quando o usuário decidir a classificação de um tipo novo de item (ex.: "perfil de alumínio é por metro"), proponha incluir a regra em `${user_config.pasta_trabalho}/_claude/regras-insumos.md` e grave com o OK dele. Assim, na próxima vez, a pergunta não se repete. Erro novo do painel e como foi resolvido vai para `_claude/aprendizados.md`.
