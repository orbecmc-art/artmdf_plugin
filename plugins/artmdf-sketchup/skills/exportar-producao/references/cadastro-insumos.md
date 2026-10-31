# Cadastro de itens sem cadastro no UpMobb (painel web)

Verificado em: 31/10/2026 · Origem: skill "upmobb-cadastrar-itens-faltantes" da Orbe, incorporada aqui.

Objetivo: zerar o aviso "Lista de elementos sem cadastro" que aparece ao gerar "Itens a comprar".

## 1. Separar código e descrição

Cada linha vem como `CODIGO - Descrição` (ex.: `PONT416FECCHAMPAGNE_ALTE - Ponteira RM146 Fechada`). Separe no **primeiro** " - ". Copie o código exatamente (maiúsculas, underscores). Copie a descrição exatamente, mesmo com erro aparente; não corrija sem perguntar.

## 2. Classificar

| Tipo de item | Unidade | Categoria |
|---|---|---|
| Ponteiras, puxadores, dobradiças, corrediças, fechos, parafusos e demais ferragens | Unidade | Ferragem |
| Chapas de MDF | Metro² | Mdf |
| Fita de borda | Metro | Fita Borda |
| Kits | (conforme item) | Kit |
| Itens já montados | (conforme item) | Montado |
| Industrializados | (conforme item) | Industrializado |

Unidades disponíveis: Unidade, Metro, Metro², Metro³, Milheiro, Cento, Pacote, Dúzia, Par, Hora trabalho, Cartela.

Se existir `_claude/regras-insumos.md` na pasta de trabalho (caminho na skill exportar-producao) (regras da casa sobre unidade e categoria), ele prevalece. Não deu para classificar com segurança: "Indefinido" e liste no fim. Dúvidas: uma pergunta só, agrupando todos os itens. **Preço: deixar 0,00** (não inventar).

## 3. Cadastrar no painel

Site: `https://upmobb.com.br/mdfart/products.html` (menu Insumos), com o login do usuário no navegador. Use o navegador do Claude (Claude in Chrome), não cliques de tela do desktop.

Para cada item:
1. Rolar até o fim da tabela e clicar em "Adicionar +" (canto inferior direito). Surge uma linha editável no final.
2. Colunas da linha nova: ID (vazio), Código, Descrição, Unidade (lista), 3 valores (deixar 0.00), tipo (padrão "Padrão"), 3 Sim/Não (deixar "Não"), Categoria (lista), "Salvar".
3. Preencher Código e Descrição, escolher Unidade e Categoria.
4. Salvar e conferir que a linha ficou gravada (aparece com Editar/Apagar e data).

Cadastrar insumo é ação no sistema da empresa: confirme a lista completa com o usuário antes de começar (código, descrição, unidade, categoria).

## 4. Verificação

Regerar "Itens a comprar" no SketchUp. A lista de elementos sem cadastro deve vir vazia. Se ainda aparecer item: código idêntico? espaço sobrando? Repetir só para ele.

Se o UpMobb mostrar "Operação cancelada" ou `LocalJumpError` em exports.rbe/request.rbe: é erro do plugin, não do cadastro. Reabrir o painel e repetir; persistindo, suporte UpMobb.

## 5. Resumo

Tabela curta: código | descrição | unidade | categoria. Confirmação de que a lista regerada ficou zerada. Itens que ficaram "Indefinido".
