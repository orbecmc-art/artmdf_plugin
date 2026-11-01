# UpMobb · operações passo a passo

Verificado em: 31/10/2026 (UpMobb 2.18.30, SketchUp 2026) · Volatilidade: média

## Inserir módulo da biblioteca

Caminho preferido: o usuário (ou você, com computer use, se ele autorizar) insere pelo painel da biblioteca do UpMobb. Assim o módulo entra com todos os dados e observadores.

Por script, o UpMobb tem rotinas de carga (`load_definition`, `insert_el`) usadas pelo próprio painel. Use só se o usuário pedir automação completa e sempre confira depois:
1. O módulo apareceu no Configurador ao selecionar.
2. `console(40)` sem erro novo.
3. Divergências rodam sem "elemento inválido" novo.

Lembre: definição carregada sem instância é apagada pelo observador do UpMobb.

## Configurar e aplicar

1. Selecione o módulo. Leia as opções atuais (inspecao.md §4) e mostre ao usuário o que vai mudar.
2. Mudança pelo Configurador: o usuário digita e clica Aplicar, ou você opera o painel pela tela (skill `sketchup-tela`, `references/upmobb-pela-tela.md`).
3. Mudança por script (quando não há campo no Configurador ou para lote): grave na **definição**, valores numéricos (nunca Length), e dispare o redesenho do UpMobb.
   - O "Aplicar" chega ao Ruby como `apply_config_element`. Ao chamar direto, atenção à unidade: num teste o valor foi lido em mm quando se esperava cm (pega ficou 80 mm em vez de 80 cm). Passe o valor na unidade do campo e confira medindo.
4. Conferência obrigatória: `medidas` das peças afetadas, `foto`, Configurador mostrando o valor novo, `console`.
5. Teste de ida e volta quando criar opção nova: mude para outro valor, aplique, meça, volte ao valor original, aplique, meça.

Redesenho demorado é normal (o criado-mudo levou ~2,8 s).

## Verificar divergências

O painel tem 13 testes (usinagens, materiais, componentes, alertas, elementos inválidos, ocultos, colisões...). Os resultados ficam na página do painel. Caminho simples: o usuário clica "Verificar divergências" e você lê o resultado (captura do painel com `janelas.ps1 -Capturar` + Read, ou o usuário cola).

Leitura dos resultados:
- **Antes de corrigir, compare com o módulo original da biblioteca** sem alterações. No criado-mudo, os mesmos 4 "colisões" (régua da cava passando pelo recorte intencional) e "componentes pendentes" apareciam no original: não eram defeito introduzido.
- Colisão real = duas chapas ocupando o mesmo volume sem recorte previsto. Minifix, cavilhas e rebaixos sobrepõem de propósito.
- "Elemento inválido" = grupo/componente sem dados do UpMobb dentro do móvel (ex.: grupo de cotas). Tire de dentro do módulo.

## Exportar

Antes: modelo salvo (com OK do usuário), um móvel por arquivo, divergências revisadas, painel de ações aberto.

| O quê | Como | Depois |
|---|---|---|
| Usinagem (.scx) | Painel de ações > exportação de usinagem | MessageBox "abrir local?" → responder. Conferir arquivo novo pela data/hora e pelo conteúdo (skill upmobb-cadastrar-itens-faltantes) |
| Plano de corte (.json) | Painel de ações > plano de corte | Exige Detalhes do projeto. Se bloquear, peça os dados ao usuário |
| Itens a comprar | Painel UpMobb > Exportação > Exportar listagens > Itens a comprar > "Todo o projeto" | Lista "elementos sem cadastro" → cadastro em Insumos (skill exportar-producao) |

Se a exportação "não fez nada": quase sempre MessageBox pendente de uma exportação anterior, ou painel fechado. `janelas.ps1` primeiro.

## Erros conhecidos do console

| Mensagem | Causa provável | Ação |
|---|---|---|
| `undefined method 'end' for nil` em rotina de usinagem | fresagem malformada (ex.: marca de inserção fora do caminho) deixada por teste | desfazer a alteração; reexportar e confirmar que não surgem erros novos |
| `LocalJumpError` em `exports.rbe` / `request.rbe`, "Operação cancelada" | erro interno do UpMobb ao gerar listas | não é do cadastro nem do modelo; reabrir painel e repetir; persistindo, suporte UpMobb |
| `comparison of Length with nil` no redesenho | atributo de componente dinâmico gravado como Length | regravar como número (`to_f`) |
| Erros de observador ao abrir arquivo | observador do UpMobb | não afetam o arquivo; seguir |
