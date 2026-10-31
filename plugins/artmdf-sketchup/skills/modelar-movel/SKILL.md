---
name: modelar-movel
description: >-
  Conduz a modelagem 3D de um móvel planejado no SketchUp com UpMobb, do pedido ao modelo conferido e pronto
  para produção. Use quando o usuário pedir para criar, projetar, montar ou ajustar um móvel ou ambiente
  (cozinha, armário, roupeiro, guarda-roupa, criado-mudo, balcão, gabinete de banheiro, painel de TV, home
  office, aéreo, torre, nicho), ou para encaixar módulos em medidas de obra. Aplica o padrão de construção da
  Art MDF e confere medidas, folgas e visual antes de entregar.
when_to_use: >-
  "faz um armário", "cria um criado-mudo", "modela a cozinha", "monta o roupeiro", "encaixa nesse vão", "medidas
  da obra", "projeta um balcão"
---

# Modelar um móvel

Objetivo: modelo correto para a fábrica (o UpMobb gera usinagem, corte e orçamento a partir dele) e bonito para o cliente. Correto vem antes de bonito.

Depende de: `sketchup-ponte` (executar e conferir; sem ponte, `sketchup-tela`) e `upmobb` (como os módulos funcionam). Carregue as duas se ainda não estiverem no contexto.

**SK** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/sk.ps1"` (cliente da ponte; detalhes na skill `sketchup-ponte`).

## 0. Contexto da casa

Leia, se existirem:
- `${user_config.pasta_trabalho}/_claude/padrao-da-casa.md`: espessuras, folgas, ferragens, materiais e regras da Art MDF. **Prevalece** sobre `references/padroes-construcao.md`.
- `${user_config.pasta_trabalho}/_claude/conhecimento-local.md`: regras curtas aprendidas recentemente.

## 1. Entender o pedido

Monte esta ficha antes de tocar no SketchUp. Preencha o que veio; complete o resto com o padrão da casa e **marque como suposição**:

| Item | Exemplo |
|---|---|
| Móvel e ambiente | roupeiro 2 portas, dormitório casal |
| Vão ou medidas externas (L × A × P) | 1200 × 2400 × 600 mm |
| Interferências | rodapé 10 cm, tomada a 30 cm, janela, viga, piso desnivelado |
| Composição interna | cabideiro, prateleiras, 3 gavetas |
| Frentes e puxador | portas de giro, puxador cava RM416 |
| Acabamento | BRANCO_TX externo, interno MDF branco |
| Ferragens | dobradiça com amortecedor, corrediça oculta |

Quando o móvel é para um cliente final novo (não um ajuste técnico), complete também a **ficha do cliente**, que orienta acabamento, puxador e apresentação: `references/briefing-cliente.md`.

Pergunte só o que muda o projeto e não dá para supor com segurança (ex.: medida do vão, tipo de porta). No máximo uma rodada de perguntas, agrupadas. O usuário fala por voz: interprete termos parecidos ("OpenMob" = UpMobb).

## 2. Preparar o arquivo

1. `SK status` e `SK eval "info_modelo"`. Veja título, se há alterações pendentes e o que já existe.
2. Um móvel por arquivo quando for para produção (as exportações valem para o modelo inteiro). Ambiente completo com vários móveis é estudo de apresentação; produção sai de arquivos separados.
3. Se for trabalhar sobre um modelo que o usuário deixou aberto e sem salvar, **não feche nem substitua**: pergunte. Se precisar abrir outro, salve o atual como backup primeiro (com OK).
4. Ambiente, quando pedido: paredes com `parede(...)` na camada "Ambiente", piso como referência Z = 0. O móvel encosta nas faces internas das paredes.

## 3. Montar a partir da biblioteca

1. Ache o módulo mais próximo na biblioteca do UpMobb (Ambientes / Construir / Personalizado). Na dúvida entre dois, mostre ao usuário as diferenças em uma linha cada.
2. Se já existe um projeto parecido em `${user_config.pasta_trabalho}`, estude como foi feito (abra só com OK, sem fechar o atual sem salvar).
3. Insira e configure as medidas pelo Configurador (`${CLAUDE_PLUGIN_ROOT}/skills/upmobb/references/operacoes.md`). Medidas externas = vão menos folgas de instalação (`references/padroes-construcao.md`, seção Instalação).
4. Composição interna, frentes, puxadores, ferragens e cores pelo próprio UpMobb.
5. Não existe módulo que sirva? Escolha o mais próximo e adapte com a skill `personalizar-modulo`. Geometria crua só para estudo, nunca para produção sem avisar que ela não entra em listas e usinagem.

Trabalhe em etapas pequenas, conferindo entre elas. Cada alteração por script dentro de `operacao('...')`.

## 4. Conferir (obrigatório)

Siga `references/checklist.md`. Resumo:

1. **Medidas:** externas batem com o vão menos folgas; nenhuma peça com medida estranha (0, negativa, maior que a chapa).
2. **Construção:** espessuras certas por peça, frentes com folga, gavetas cabendo com a corrediça, fundo encaixado, prateleiras com folga.
3. **Usabilidade:** portas abrem sem bater em parede, puxador, outro móvel; gavetas abrem; alturas ergonômicas (`references/ergonomia.md`).
4. **UpMobb:** Configurador mostra os valores reais; console sem erro novo; divergências sem item novo em relação ao módulo original.
5. **Visual:** fotos em `iso`, `frente`, `direita`, `topo` e de detalhe onde mudou. Olhe cada uma. Frente sumida, peça flutuando, face invertida (cinza-azulado), linha sobrando: corrija antes de entregar.
6. **Alertas técnicos:** cavilha/furo profundo em frente fina, cava que deixa pouca espessura, peça maior que a chapa, vão de prateleira acima do recomendado sem reforço.

## 5. Entregar

Resposta curta e organizada:
- O que foi feito (móvel, medidas externas, materiais, puxador, ferragens principais, nº de peças).
- Suposições feitas e alertas técnicos.
- Imagens geradas (caminhos) e onde o arquivo está.
- O que falta (ex.: salvar, exportar, Detalhes do projeto).
- Pergunta direta: salvar agora? (nunca salve sem OK).

Depois do OK para salvar: fluxo de salvar da `sketchup-ponte`. Exportação para a fábrica: skill `exportar-producao`. Apresentação ao cliente: `documentar-projeto`.

## 6. Aprender

No fim, registre em `${user_config.pasta_trabalho}/_claude/aprendizados.md` (formato na skill `evoluir-plugin`):
- correções que o usuário fez no seu trabalho (são a fonte mais valiosa);
- comportamento novo do UpMobb ou do SketchUp;
- medida ou regra da casa que não estava escrita.

## Referências

- `references/padroes-construcao.md`: chapas, construção de caixas, portas, gavetas, ferragens, instalação.
- `references/ergonomia.md`: alturas e profundidades de referência por ambiente.
- `references/checklist.md`: conferência completa antes de entregar.
- `references/nomenclatura.md`: nomes das peças e módulos em pt-BR.
- `references/briefing-cliente.md`: ficha do cliente final (uso, estilo, referências, prioridades).
