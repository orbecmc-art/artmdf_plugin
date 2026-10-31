---
name: evoluir-plugin
description: >-
  Mantém o plugin vivo e cada vez melhor. Consolida o que a equipe e o Claude aprenderam nos projetos (correções
  do projetista, comportamentos do UpMobb e do SketchUp, receitas que funcionaram), revisa fontes externas
  (SketchUp, UpMobb, Claude Code, fabricantes de chapas e ferragens, normas) e transforma tudo em atualização do
  conhecimento local na hora e em nova versão do plugin, com diff aprovado. Use quando o usuário pedir para
  atualizar, melhorar ou evoluir o plugin, revisar fontes, registrar um aprendizado, criar uma skill nova a
  partir de um processo, ou quando o início da sessão avisar aprendizados pendentes ou fontes vencidas.
when_to_use: >-
  "atualiza o plugin", "evolui o plugin", "revisa as fontes", "anota isso", "aprende isso", "registra esse
  aprendizado", "vira uma skill", "o que mudou no sketchup", "tem atualização do upmobb"
---

# Evoluir o plugin

O plugin aprende em duas camadas:

| Camada | Onde | Quando vale | Quem usa |
|---|---|---|---|
| **Conhecimento vivo** | `${user_config.pasta_trabalho}/_claude/` | na hora, nesta máquina | todas as skills leem antes de trabalhar |
| **Versão do plugin** | repositório do plugin (`${user_config.repo_plugin}`) | depois de publicar; outras máquinas recebem pela atualização automática | todos que têm o plugin |

Regra de ouro: **nada muda sem diff aprovado pelo usuário.** Você propõe; ele aprova; você aplica e registra.

## Arquivos do conhecimento vivo (`_claude/`)

| Arquivo | Conteúdo |
|---|---|
| `aprendizados.md` | Diário: tudo que foi aprendido, com status (novo, consolidado, descartado) |
| `conhecimento-local.md` | Regras curtas e validadas que as skills leem antes de trabalhar |
| `padrao-da-casa.md` | Padrão técnico da Art MDF (espessuras, folgas, ferragens, materiais, preferências) |
| `upmobb-mapa.md` | Atributos e comportamentos do UpMobb descobertos nesta instalação |
| `regras-insumos.md` | Regras de unidade e categoria para cadastro de insumos |
| `fontes-estado.json` | Data da última revisão de cada fonte externa |
| `historico-evolucao.md` | O que foi aplicado, quando, de onde veio, versão publicada |
| `scripts/` | Scripts que rodaram no SketchUp, por data (matéria-prima de receitas e skills novas) |

Primeira vez (pasta não existe): crie a pasta e a subpasta `scripts/`, copie os modelos de `${CLAUDE_SKILL_DIR}/assets/` e troque `{{DATA}}` pela data de hoje no formato AAAA-MM-DD (o aviso de início de sessão lê essa data). Nunca sobrescreva um arquivo que já existe. Avise o usuário que `padrao-da-casa.md` precisa ser revisado com ele: é a decisão de padrão que mais pesa (ex.: caixa 15 ou 18 mm).

## A. Registrar um aprendizado (a qualquer momento)

Toda skill do plugin termina registrando o que aprendeu. Formato (acrescente no fim de `aprendizados.md`):

```markdown
## AAAA-MM-DD · título curto
- status: novo
- skill: sketchup-ponte | upmobb | modelar-movel | personalizar-modulo | exportar-producao | documentar-projeto | evoluir-plugin
- tipo: correção do usuário | comportamento do UpMobb | comportamento do SketchUp | regra da casa | receita | erro e solução
- aconteceu: o que estava sendo feito e o que ocorreu (2-3 linhas)
- aprendi: a regra acionável, escrita como instrução ("Ao X, fazer Y porque Z")
- evidência: script em _claude/scripts/..., foto, arquivo, número medido, ou "o usuário disse"
- confiança: testado | visto uma vez | hipótese
```

Correção feita pelo usuário vale mais que qualquer fonte: registre sempre, com as palavras dele quando forem decisivas.

## B. Consolidar o que foi aprendido

Disparo: o usuário pede, ou o início da sessão avisa 5+ aprendizados novos.

1. Leia os aprendizados com `status: novo`. Agrupe os que falam da mesma coisa.
2. Para cada grupo, decida o destino:
   - regra curta de uso geral → `conhecimento-local.md`;
   - medida ou preferência da casa → `padrao-da-casa.md`;
   - atributo ou comportamento do UpMobb → `upmobb-mapa.md`;
   - procedimento testado de ponta a ponta → candidato a receita (vai para o plugin, passo D);
   - instrução de skill errada ou faltando → candidato a mudança de skill (passo D);
   - hipótese não testada → fica como novo até ter evidência; descartado se for contradito.
3. Mostre ao usuário uma tabela: aprendizado → destino → texto exato que vai entrar. Peça OK (pode aprovar em bloco).
4. Aplique o aprovado nos arquivos do `_claude/` e marque os itens como `status: consolidado (AAAA-MM-DD → destino)`. Esses já valem a partir da próxima tarefa.
5. Conflito com o que o plugin diz: evidência testada aqui vence texto genérico. Registre o conflito para o passo D corrigir a skill.

## C. Revisar fontes externas

Disparo: o usuário pede, ou fontes revisadas há 30+ dias. Lista, cadência e o que observar em cada uma: `references/fontes.md`.

1. Para cada fonte vencida, busque o que mudou desde a última revisão (WebSearch/WebFetch). Leia a fonte primária, não resumo de terceiros.
2. Compare com o que o plugin afirma. Três categorias: **confirmado** (nada muda), **mudou** (reescrever trecho), **novo** (acrescentar com fonte e data).
3. Atenção especial a **quebras**: versão nova do SketchUp ou do Ruby embutido, versão nova do UpMobb, mudança no formato de plugins/skills/hooks do Claude Code, fim de suporte de Windows. Quebra provável vira aviso destacado ao usuário, com o que fazer (ex.: "não atualizar o SketchUp para 2027 até o UpMobb confirmar compatibilidade").
4. Proponha diffs (trecho atual → trecho novo → fonte com data). Só fato com fonte primária. Vídeo sem conteúdo verificável, post de fórum isolado e texto gerado por IA não são fonte.
5. Atualize `fontes-estado.json` com a data de cada fonte revisada, mesmo se nada mudou.

## D. Publicar nova versão do plugin

Disparo: há mudanças aprovadas para skills, referências, receitas ou scripts. Procedimento completo em `references/publicar.md`. Resumo:

1. Repositório desta máquina: `${user_config.repo_plugin}` (é o `<REPO>` de `references/publicar.md`). Vazio, inexistente ou sem git: entregue as mudanças como arquivo de patch na pasta `_claude/para-publicar/` e diga que a publicação é feita na máquina da Orbe.
2. Aplique os diffs aprovados no repositório. Mantenha o padrão: cabeçalho "Verificado em" atualizado, conhecimento novo no arquivo de referência certo, SKILL.md enxuto.
3. Suba a versão em `.claude-plugin/plugin.json` (correção = 1.0.x, conhecimento novo = 1.x.0, mudança que quebra = x.0.0) e escreva a entrada no `CHANGELOG.md`.
4. Se mudou algo em `sketchup/`, suba também `VERSAO` em `sketchup/claude_ponte.rb`: o início de sessão avisa as máquinas que a ponte precisa ser reinstalada.
5. Valide (`claude plugin validate`), mostre o resumo das mudanças e, com OK, faça commit e push.
6. Registre em `historico-evolucao.md`.

## E. Processo que se repete vira skill

Em `_claude/scripts/` e nos aprendizados, procure procedimentos que já foram feitos 3 vezes ou mais com o mesmo formato (ex.: "montar torre quente", "cadastrar itens de um fornecedor"). Proponha ao usuário uma skill nova (nome, quando usar, passos) seguindo as boas práticas de `references/publicar.md` (seção Skills novas). Com OK, crie no repositório e publique como versão nova.

## Automático

- O início de cada sessão do Claude Code informa aprendizados pendentes e fontes vencidas. Quando aparecer, ofereça rodar esta skill no fim da tarefa atual (não interrompa o trabalho do usuário).
- Rotina semanal no Windows: quando o usuário pedir ("cria a rotina semanal do plugin"), rode
  `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/agendar-rotina.ps1" -Pasta "${user_config.pasta_trabalho}" -Dia Monday -Hora 08:00`
  e depois `... agendar-rotina.ps1 -Testar`. A rotina roda sem interação e **só propõe**: grava `_claude/relatorios/revisao-AAAA-MM-DD.md`. Quando o usuário pedir "revisa o relatório da semana", leia o relatório mais recente e siga os passos B a D com aprovação item a item. Remover: `-Remover`.
- **Modo revisão** (pedido vindo da rotina, sem ninguém na conversa): faça B e C só até a proposta; não altere `_claude/` além do relatório e de `fontes-estado.json`, não publique, não rode git.
- As outras máquinas recebem versões novas pela atualização automática do marketplace (configurada na instalação).

## Entrega

Resumo: quantos aprendizados consolidados e para onde, fontes revisadas e o que mudou, avisos de quebra, versão publicada (ou patch pendente), próxima revisão sugerida.
