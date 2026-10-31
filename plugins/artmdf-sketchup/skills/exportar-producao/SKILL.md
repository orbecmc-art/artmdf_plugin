---
name: exportar-producao
description: >-
  Prepara e gera os arquivos de produção do UpMobb para a fábrica e confere cada um — verificação de
  divergências, arquivo de usinagem .scx para as máquinas, plano de corte, itens a comprar e cadastro dos
  insumos que faltam no painel web do UpMobb. Use quando o usuário pedir para exportar, mandar para a fábrica,
  gerar usinagem, plano de corte, lista de compras ou itens a comprar, cadastrar itens sem cadastro, ou comparar
  a usinagem antes e depois de uma alteração.
when_to_use: >-
  "exporta a usinagem", "manda pra fábrica", "gera o scx", "plano de corte", "itens a comprar", "lista de
  compras", "itens sem cadastro", "cadastra os insumos", "a usinagem mudou?"
---

# Exportar para produção

O arquivo que vai para a máquina não admite erro. Esta skill não altera o móvel: ela verifica, exporta e confere. Se a conferência achar problema no modelo, pare e volte para `modelar-movel` ou `personalizar-modulo`, com OK do usuário.

Depende de: `sketchup-ponte`, `upmobb`. Os botões do painel (divergências, exportações, Detalhes do projeto) são operados pela tela: `sketchup-tela`. A conferência dos arquivos (`SCX`) não precisa de ponte.

Atalhos:
- **SK** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/sk.ps1"`
- **JANELAS** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/janelas.ps1"`
- **SCX** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/scx.ps1"`

Pasta de trabalho: `${user_config.pasta_trabalho}`. Pasta de exportação do UpMobb: `${user_config.pasta_exportacao}` (usinagem em `<projeto>\usinagens\<projeto>.scx`).

## 1. Pré-requisitos

- [ ] Um móvel (ou um conjunto que vai junto para a fábrica) por arquivo. As exportações valem para o modelo inteiro.
- [ ] Arquivo salvo com nome definitivo (a pasta de exportação leva o nome do projeto). Salvar só com OK.
- [ ] Nada seu dentro dos módulos (cotas, testes). Cotas na raiz.
- [ ] Painel de ações do UpMobb aberto. Nenhuma MessageBox pendente (`JANELAS -ProcessoId <PID>`).
- [ ] Para plano de corte e itens a comprar: "Detalhes do projeto" preenchidos (Meu código, Projetista, Cliente, Descrição). **Dados do cliente: peça ao usuário, nunca invente.**

## 2. Divergências

Rode "Verificar divergências" do UpMobb (usuário clica, ou você automatiza o painel com autorização). Leia o resultado com a regra da skill `upmobb`: compare com o módulo original antes de chamar algo de defeito. Liste para o usuário: o que é esperado (com motivo) e o que precisa de ação.

Não exporte com divergência real sem o usuário decidir.

## 3. Usinagem (.scx)

1. Se já existe .scx deste projeto, guarde a versão atual: `SCX -Arquivo "<caminho>" -Guardar`.
2. Exporte pelo painel de ações.
3. Responda a MessageBox de fim ("abrir local do arquivo?") com `JANELAS -ProcessoId <PID> -Clicar "Não"` (ou como o usuário preferir).
4. Confirme que o arquivo é novo (data/hora) e leia o resumo: `SCX -Arquivo "<caminho>"`.
5. Confira:
   - nº de painéis coerente com as peças do móvel (peças sem furação, como tamponamentos e tampo, podem não entrar: isso é normal);
   - cada peça com as usinagens esperadas (dobradiças nas portas, minifix na caixa, canal de corrediça, cava/fresagem);
   - contagem de furos de minifix = minifix no modelo (no criado-mudo: 39 = 39);
   - furo, cava ou rasgo que deixa pouca espessura (alertas da `modelar-movel`).
6. Se havia versão anterior e a usinagem **não** devia mudar: `SCX -Arquivo "<novo>" -Comparar "<anterior>"`. Qualquer diferença → mostrar ao usuário antes de liberar.
7. `SK console` sem erro novo do exportador.

Detalhe de uma peça: `SCX -Arquivo "<caminho>" -Peca "Porta Esquerda"`.

## 4. Plano de corte

Exportar pelo painel de ações. Bloqueou pedindo Detalhes do projeto → pedir os dados ao usuário. Gerado → confirmar arquivo novo na pasta e informar o caminho.

## 5. Itens a comprar e cadastro de insumos

1. Gerar "Itens a comprar" (UpMobb > Exportação > Exportar listagens > Itens a comprar > Todo o projeto).
2. Se aparecer "Lista de elementos sem cadastro", obter o texto (o usuário cola, ou captura do diálogo).
3. Cadastrar os itens no painel web do UpMobb seguindo `references/cadastro-insumos.md` (navegador com o login do usuário).
4. Regerar a lista: o aviso deve sumir. Itens ainda faltando → conferir código idêntico.

## 6. Entrega

Resumo para o usuário: arquivos gerados com caminho, contagens conferidas, diferenças (se houve comparação), alertas e pendências (ex.: Detalhes do projeto, ferramenta sem código). Nada vai para a fábrica sem o usuário confirmar.

## Aprender

Registre em `${user_config.pasta_trabalho}/_claude/aprendizados.md`: erro novo de exportação e como resolveu, peça que a máquina recusou, regra de conferência que faltou aqui.
