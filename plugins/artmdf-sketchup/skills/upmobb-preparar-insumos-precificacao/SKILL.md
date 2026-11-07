---
name: upmobb-preparar-insumos-precificacao
description: >-
  Use sempre que o usuário falar de precificação na UpMobb (MDF Arte Design): insumos, custos, venda, markup, ativar/inativar insumos na aba Insumos > Lista Insumos.
when_to_use: >-
  "precificação", "preço dos módulos", "markup", "custo e venda dos insumos", "ativa ou inativa insumos"
---

# Precificação UpMobb (MDF Arte Design)

**Regra central:** sempre que o usuário falar em *precificação* (dos módulos, insumos, custos, preço de venda, markup), o trabalho acontece na aba **Insumos** do painel `upmobb.com.br/mdfart` (`products.html`), começando pela **Lista Insumos**. Este skill é o ponto de partida de toda a precificação e será ampliado pelo usuário ao longo do tempo.

## Etapa 1 — Preparar os insumos (ativos x inativos)
Objetivo: a Lista de Insumos deve refletir exatamente o que a biblioteca da MDF Arte Design usa. Usados = **Ativo**; não usados = **Inativo**. Só depois disso se segue para os preços.

### Onde as coisas ficam
- Biblioteca de módulos: `upmobb.com.br/mdfart/module.html` (menu "Modulos" > aba "Base" > sub-aba "MDF ARTE DESIGN"; categorias à esquerda: AEREO BANHEIRO, ALTOS, CAMAS, CANTO CURVO, CRIADOS MUDO, DORMITÓRIO CANTO, INFERIOR BANHEIRO etc.).
- Insumos: `upmobb.com.br/mdfart/products.html` (menu "Insumos"; abas: Lista Insumos, Tipos, Unidades, Grupos Markup, Outros; sub-botões Markup / Dedução).
- Colunas da tabela: ID, Cod., Cod.3D, Descrição, Und., Quebra %, R$ Custo, R$ Venda, Gr.Markup, Linear, M², Conferência, Tipo, Status (Ativo verde / Inativo vermelho), Última Alteração, Ações (Editar / Apagar). Campo "Pesquise aqui"; botões flutuantes Importar lista, Baixar Tabela, Adicionar +, Topo. A tabela rola na horizontal (Status e Ações ficam à direita).

### Passos
1. **Analisar o que é usado**: percorrer a biblioteca MDF ARTE DESIGN (todas as categorias/módulos) e levantar os insumos realmente utilizados (ferragens, fitas, serviços, embalagens, materiais). Usar o Chrome (read_page / get_page_text) no navegador do usuário, já logado; preferir leitura de texto a cliques.
2. **Abrir Insumos > Lista Insumos** e extrair a tabela completa (ID, descrição, Tipo, Status atual).
3. **Cruzar**: marcar cada insumo como usado ou não usado.
4. **Ajustar o Status** pelo botão **Editar** da linha (usados = Ativo; não usados = Inativo). Nunca usar "Apagar".
5. **Conferir** relendo a tabela e reportar resumo (ativados, desativados, casos duvidosos).

## Etapa 2 — Precificação dos módulos
A ser detalhada pelo usuário (custos, venda, Gr.Markup, Dedução). Até lá, após a Etapa 1, perguntar ao usuário como seguir. Este skill será atualizado.

## Cuidados
- Em dúvida se um insumo é usado, não desativar: listar para o usuário decidir.
- Serviços (ex.: "$ Colagem de Borda", "$ Corte") também são insumos; confirmar antes de inativar.
- Na Etapa 1 não alterar custos/preços; só Status.
- Antes de mudanças em lote, informar o plano (quantidade a ativar/desativar).