---
name: upmobb-curso
description: >-
  Processo completo do UpMobb na interface, do jeito ensinado no curso "Execução Completa Upmobb" (Rafael Grossl,
  aulas 02 a 14) e no vídeo "Cozinha em 20 minutos": preparar o SketchUp, construtor de paredes, esboço de caixa
  e substituição, Construir, Agregados, Trocas, Aplicação de cores, Orçamento, Render IA, painel web (usuários,
  módulos, cores), Verificador de divergências, exportações, etiquetas, arquivos de usinagem e plano de corte no
  Otimizador. Use quando precisar saber ONDE fica um botão ou QUAL a sequência de cliques no UpMobb, para ensinar
  um projetista novo, para planejar um ambiente do zero até a fábrica, ou quando o usuário perguntar "como faz
  no UpMobb", "onde fica", "o que o curso ensina", "passo a passo". Complementa a skill upmobb
  (que trata do funcionamento interno e de scripts).
when_to_use: >-
  "como faz no upmobb", "onde fica o botão", "passo a passo", "curso do upmobb", "aula do upmobb", "ensina o projetista",
  "esboço de caixa", "substituir módulo", "agregados", "trocas", "aplicar cores", "render ia", "plano de corte",
  "otimizador", "etiqueta", "verificador de divergência", "como faz no openmob", "aula do openmob"
---

# UpMobb: o processo inteiro (resumo do curso)

Fonte: playlist "Curso de Upmobb" de Rafael Grossl (13 aulas, ~4h30) + vídeo "57 - Cozinha em 20 Minutos". Verificado em: 07/11/2026 · resumo feito a partir das legendas automáticas do YouTube. O curso é de 2025: nomes de botões podem ter mudado. Se a tela não bater com o que está aqui, confie na tela e registre a diferença.

Detalhe aula por aula, com medidas e opções: `references/aulas.md`.

## A ordem certa de um projeto

1. **Preparar o SketchUp** (uma vez por máquina) — modelo em milímetros, unidades decimais em mm, salvamento automático a cada 2 min, perfil de arestas desligado (pesa). Instalar o `.rbz` em Extensões > Gerenciador > Instalar extensão.
2. **Detalhes do projeto** (Menu do projeto) — código da OS + número do ambiente, projetista, cliente, descrição. Esses campos vão para etiqueta, lista e orçamento.
3. **Minhas preferências** — espessura padrão (15 / 18,5 / 25) com "alterar módulos da cena"; unidade mm; pasta de exportação; logo da etiqueta. Se módulo não carrega: **Limpar cache de módulos e de texturas** (não usar "resetar configurações").
4. **Ambiente** — Construtor de paredes (altura, espessura, alinhamento esquerda = desenhar no sentido horário). Depois portas e janelas (Construir > Decorações; já recortam a parede) e **pontos de água, esgoto, gás e tomadas antes dos móveis** (soltos no canto da parede, centralizam no meio dela).
5. **Esboço de caixa** — ferramenta ao lado da seta; **TAB** abre altura, profundidade e alinhamento (inferior = balcão, superior = aéreo). Clica no canto e vai digitando as larguras + Enter. Planeja a cozinha inteira em blocos.
6. **Substituir** — seleciona um ou vários esboços, escolhe o módulo em Construir (ou pesquisa pelo nome no topo) e clica no botão de substituir: o módulo real entra com as medidas do esboço.
7. **Ajustar no Configurador** — "Selecionar componente" (mira amarela) abre o Configurador; "Selecionar peça" (verde) mexe numa peça. Medidas aceitam conta: `+` soma, `-` diminui, `*` substitui pelo que a trena medir, e expressões (`1200/2`).
8. **Agregados** — o que vai dentro ou sobre o módulo: prateleiras, divisórias, gavetas, portas, tamponamentos, LED, acessórios. Clica no agregado e depois no **vão** (contêiner). As setas laterais sobem o nível da seleção (peça > conjunto > armário); Ctrl junta vários vãos e Enter aplica.
9. **Trocas** — troca o que o item selecionado permite: modelo de frente, fixação de gaveta (minifix ↔ parafuso), fixação de prateleira, dobradiça (marca e amortecedor), corrediça, LED, tampo/lateral duplado ou engrossado. Selecione tudo para trocar no projeto inteiro. Salve antes de trocas grandes (pode travar).
10. **Aplicação de cores** — MDF por Corpo (módulo todo), por Frente, por Portas ou **por Peça** (clicando uma a uma); fitas de borda (clicar a aresta pinta só ela, Shift pinta o conjunto); perfis e tampas. "Pescar cor" (conta-gotas) e "Substituir cor" (troca uma cor pelo projeto todo).
11. **Orçamento** — Selecionado ou Todo o projeto; Resumido, Módulo, Detalhado, Analítico, Custo. Item **em vermelho = sem cadastro** (cadastrar insumo). Salvar orçamento e "Solicitar à central" manda para o painel web.
12. **Render IA** (opcional, para o cliente) — a IA melhora a *imagem* da cena: quanto melhor a cena no SketchUp, melhor o render.
13. **Verificador de divergências** — rodar até ficar verde (ver checklist abaixo).
14. **Exportar** — listagem de peças (Excel), etiquetas, itens a comprar, perfis lineares, arquivos de usinagem (lado A/B), JSON para o Otimizador.
15. **Plano de corte** — no Otimizador web: cadastrar chapas no Armazém, criar lote, importar o JSON, vincular materiais, otimizar, imprimir diagramas e etiquetas.

## Checklist do Verificador de divergências

| Aba | O que acusa | O que fazer |
|---|---|---|
| Usinagens | Usinagem em sobreposição (furo sobre furo); usinagem não aplicada (VB/cavilha que não pega em peça nenhuma, comum em divisória); peça além do limite | Ver resultado > selecionar > Exibir com raio X; excluir a usinagem órfã ou reduzir margem/quantidade do VB/cavilha; rodar de novo |
| Materiais | Materiais, espessuras e bordas usadas | Caçar espessura errada (ex. 18,5 no meio de 15) e cor trocada |
| Componentes | Peças em colisão; elementos ocultos; inválidos; sobrepostos; para atualizar | Colisão é para corrigir (ex. porta batendo em divisória: dobradiça alta). Paredes aparecem como "inválidos" e módulos editados como "para atualizar": normal |
| Alertas | Avisos construtivos dos módulos (limites de medida, corrediça indisponível) | Ajustar a medida ou o modelo (ex. gaveta de 600 sem corrediça: padronizar 500) |

## Medidas e valores que aparecem no curso

- Folga entre portas 3,5 mm; transpasse padrão 12; dobradiça reta, reta total, alta (porta encostando em divisória) ou super alta.
- Espaço entre corpos de gaveta 30; folga de frente 3.
- Prateleira com recuo de 5 atrás da porta; 15–16 quando tem frente/fechamento na frente.
- Bancada: espessura 40, profundidade 550–630, elevação 800 (balcão), rodapia 20.
- Chapa no Otimizador: 2750 × 1850, refilo 10 (5 de cada lado).
- Render: campo de visão ~34°, exposição ~0,9, LED = PNG degradê a ~5 mm da peça.

São valores de exemplo do instrutor. Na Art MDF valem os padrões da casa (skill `modelar-movel`, `${user_config.pasta_trabalho}/_claude/padrao-da-casa.md` e a biblioteca MDF ARTE DESIGN).

## Armadilhas que o curso aponta

- **Escala (S):** pegue no meio da face, não na borda (senão escala o objeto inteiro ou a parede). Nunca use escala ou "inverter" para espelhar módulo do UpMobb.
- **Ctrl+C / Ctrl+V de projeto repete os códigos de peça.** Para duplicar, use Exportação > **Cópia do projeto** (gera códigos novos).
- **Usinagem só aparece em Modo revisar** ("estou revisando").
- A primeira aplicação do dia às vezes falha (esboço inverte o alinhamento, agregado não entra): repita.
- Biblioteca "crua" vem sem itens ativados ou cadastrados: o orçamento só fica certo depois de cadastrar insumos e ativar itens.
- Ajuste que acontece uma vez: faça na mão. Ajuste que se repete em todo projeto: deixe paramétrico na biblioteca (configurador global ou desenvolvedor).
- Ferragem com 3D detalhado (dobradiça Blum) e sombras pesam: desligue sombras enquanto modela.
- Cor nova no painel: o **nome vinculado** tem que ser idêntico ao nome do material/.skm, senão a cor não aparece.

## Painel web (gestor)

- **Usuários:** convidar por e-mail; grupo (interno = projetista da empresa, externo = arquiteto, administrador, PCP, operador de máquina); nível dos módulos (Básico < Iniciante < Intermediário < Avançado < Premium < Desenvolvedor); tipo de orçamento permitido; desconto; resetar vínculo (troca de computador). Excluir: congela por 15 dias e depois apaga.
- **Orçamentos:** Novos > Processados > Orçados > Efetivados; baixar XML, anexar PDF, reverter, efetivar.
- **Módulos:** nível mínimo por módulo, ocultar para todos, montar a Biblioteca fácil (ambiente + tipo + descrição abreviada); Agregados e Trocas por "favorito". Para liberar módulo novo na Art MDF, use a skill `upmobb-liberar-modulo`.
- **Cores:** cadastrar textura (descrição, nome vinculado, imagem, .skm) e marcar em quais grupos ela vale (corpo, portas, frentes, fitas, tamponamentos…).

## Onde o curso para

- Configuração da máquina (deslocamentos, giro de peça, Z seguro, chapa de sacrifício, saída do arquivo) o instrutor faz junto com o cliente por videochamada; o curso só mostra onde fica (Desenvolvedor > Usinagens > Configurações globais e Otimizador > Configurações gerais).
- Editor de etiquetas do Otimizador, sobras e importação de lista de materiais estavam "em desenvolvimento" na época.
- Menu Desenvolvedor (criar e editar módulos dinâmicos) foi anunciado para aulas futuras.

## Skills relacionadas

- `upmobb` — por dentro do UpMobb, scripts e regras de convivência.
- `modelar-movel` — padrão de construção da Art MDF.
- `exportar-producao` e `upmobb-exportar-otimizador` — exportação e plano de corte passo a passo.
- `upmobb-criar-ambiente-paredes-janelas-portas` — ambiente pelo construtor.
- `upmobb-cadastrar-itens-faltantes` — itens em vermelho no orçamento ou sem cadastro.

## Aprender

Achou botão com outro nome, passo que mudou ou valor da casa diferente do curso? Registre em `${user_config.pasta_trabalho}/_claude/aprendizados.md` (formato da skill `evoluir-plugin`, `skill: upmobb-curso`). Correção do usuário vale mais que o curso.
