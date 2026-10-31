---
name: personalizar-modulo
description: >-
  Adapta ou corrige um módulo paramétrico do UpMobb no SketchUp quando a biblioteca não atende — criar opção
  nova no Configurador (ex.: espessura do tamponamento), ligar medidas por fórmula, fazer recorte visual no 3D
  (rasgo de puxador, encaixe de perfil), corrigir módulo que não acompanha medida, acabamento que não muda de
  cor, ocultar linhas de fresa — e, com autorização, levar a correção para a biblioteca. Use quando o usuário
  pedir algo que o Configurador não oferece, apontar defeito visual com print, ou quando um módulo não
  redimensiona ou não redesenha direito.
when_to_use: >-
  "cria uma opção no configurador", "deixa dinâmico", "o recorte não acompanha", "tira essa face", "fica um vão
  aqui", "a gaveta não acompanha", "salva na biblioteca", "a fita tem que mudar de cor"
---

# Personalizar módulo do UpMobb

Mexer por dentro de um componente paramétrico é a tarefa mais delicada do plugin: um atributo errado quebra o redesenho, a furação ou a usinagem sem aviso. Siga a ordem abaixo sem pular etapas.

Depende de: `sketchup-ponte`, `upmobb`. Personalizar exige a ponte (instalada ou carregada pelo Console Ruby): sem ela, faça só o que o Configurador permite pela tela (`sketchup-tela`) e diga ao usuário o que ficou de fora. Leia também `${CLAUDE_PLUGIN_ROOT}/skills/sketchup-ponte/references/componentes-dinamicos.md`.

**SK** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/sk.ps1"` (cliente da ponte; detalhes na skill `sketchup-ponte`).

## Regras fixas

1. **Usinagem não muda** sem pedido explícito. Recorte visual ≠ usinagem. Depois de qualquer mexida perto de cava, rasgo, furo ou fresa: reexporte o .scx e compare com o anterior (skill `exportar-producao`, comparação de .scx).
2. **Biblioteca não muda** sem OK. Corrija no projeto; ofereça levar para a biblioteca; com OK, backup do arquivo da biblioteca antes.
3. **Desfazer pronto:** toda alteração em `operacao('...')`. Antes de mudanças grandes num arquivo salvo, `backup_disco`.
4. **Copie o padrão do UpMobb.** Para qualquer coisa nova (opção, cortador, peça que redimensiona), ache no mesmo modelo um elemento do UpMobb que já faz isso e copie os atributos dele, trocando só nomes e valores. Inventar atributos do zero é o caminho mais longo (custou horas no RM416).

## Processo

### 1. Entender o pedido em termos de peça

Traduza o pedido para: qual peça, qual medida, de que valor depende, o que deve acontecer quando esse valor mudar. Se o usuário mandou print com marcação, reproduza o mesmo ângulo com `foto` (vista e `alvo`) e confirme que está olhando o mesmo ponto.

### 2. Inspecionar

Roteiro de `${CLAUDE_PLUGIN_ROOT}/skills/upmobb/references/inspecao.md`: árvore do módulo, atributos da peça, opções do Configurador, diferenças instância × definição. Anote quem é pai de quem; o redesenho dinâmico desce do pai para os filhos.

### 3. Testar isolado primeiro

Para mecanismo que você não testou ainda neste UpMobb (cortador, opção nova, fórmula entre níveis), monte um teste num bloco separado, longe do móvel, prove que funciona, depois aplique no módulo e apague o teste. Cada teste temporário vai para a lista de limpeza do fim.

### 4. Aplicar no módulo

Receitas testadas em `references/receitas.md`:
- opção nova no Configurador que passa valor para peças internas;
- recorte visual que acompanha uma medida (cortador com "cortar abertura");
- filho que precisa redesenhar o pai ao Aplicar (`parentrefresh`);
- ligar acabamento de uma peça ao de outra por fórmula (muda de cor junto);
- ocultar linhas de fresa e emendas sem apagar geometria;
- corrigir atributo que a fórmula procura e não existe (caso corrediça HARDT).

### 5. Provar que acompanha

Todo "dinâmico" precisa de teste de ida e volta pelo **Aplicar**: valor A → medir e fotografar → valor B → medir e fotografar → voltar ao original → medir. Reporte os números das três situações.

### 6. Limpar e conferir

- Apague blocos de teste e atributos temporários.
- `console(60)`: nenhum erro novo.
- Divergências: nada novo em relação ao antes.
- .scx igual ao anterior se a usinagem não devia mudar.
- Fotos dos mesmos ângulos que o usuário apontou, de perto. Defeito visual pequeno (linha branca, lasca, vão de décimos de mm) conta: o padrão do usuário é "100%".

### 7. Entregar e oferecer a biblioteca

Diga o que mudou, os limites (ex.: "funciona com a cava na posição inferior; o deslocamento lateral não acompanha na fita"), o que foi testado e com quais valores. Pergunte se quer salvar o projeto e se quer levar a correção para o módulo da biblioteca.

## Quando travar

Se depois de 3 hipóteses testadas o mecanismo ainda não funciona, pare e informe o usuário: o que foi tentado, o que se descobriu, duas opções de caminho (ex.: solução manual mais simples, ou consultar o suporte UpMobb). Não continue "às cegas" por horas, e nunca tente abrir ou decifrar o código criptografado do UpMobb (proibido pelos termos e improdutivo).

## Aprender

Toda receita nova que funcionou vai para `${user_config.pasta_trabalho}/_claude/aprendizados.md`, com o passo a passo mínimo e o teste que provou. A skill `evoluir-plugin` a promove para `references/receitas.md`.
