# Fontes para revisão do plugin

Verificado em: 31/10/2026 · Atualize esta lista quando uma fonte morrer ou surgir outra melhor.

Cadência: **mensal** = checar a cada revisão; **trimestral** = a cada 3 meses; **evento** = quando houver lançamento.
Cada fonte indica o que observar e quais arquivos do plugin podem mudar.

## Interno (sempre primeiro: vale mais que qualquer fonte externa)

| Fonte | O que observar | Afeta |
|---|---|---|
| `_claude/aprendizados.md` | correções do projetista, erros e soluções, receitas | todas as skills |
| `_claude/scripts/` | procedimentos repetidos (candidatos a skill), scripts que falharam | personalizar-modulo, skills novas |
| `%LOCALAPPDATA%\ClaudePonte\historico\*.log` | erros de Ruby recorrentes, scripts que mais rodam | sketchup-ponte (ruby-sketchup.md) |
| Arquivos exportados (.scx, plano de corte .json) | formato mudou depois de atualização do UpMobb? | upmobb (modelo-de-dados.md), exportar-producao |

## SketchUp e Ruby API

| Fonte | Cadência | O que observar | Afeta |
|---|---|---|---|
| Release notes da Ruby API · https://ruby.sketchup.com/file.ReleaseNotes.html | evento | métodos novos/depreciados, mudança de comportamento (ex.: 2026 tornou câmera de cena "desfazível") | ruby-sketchup.md, ajuda.rb |
| Release notes do SketchUp desktop · https://help.sketchup.com/en/release-notes | evento | versão nova, Ruby embutido (2027 = Ruby 3.4.9), fim de suporte de SO | instalacao.md, aviso de compatibilidade |
| Repositório oficial com regras para Claude Code · https://github.com/SketchUp/sketchup-extension-vscode-project (`.claude/rules`, `CLAUDE.md`) | trimestral | boas práticas oficiais da Trimble para gerar Ruby | ruby-sketchup.md |
| Stubs da API · https://github.com/SketchUp/ruby-api-stubs | evento | `pages/ReleaseNotes.md` | ruby-sketchup.md |
| Fórum de desenvolvedores · https://forums.sketchup.com/c/developers/ruby-api | trimestral | anúncios oficiais (tópicos da equipe SketchUp), não opiniões | ruby-sketchup.md |
| Política de carregamento de extensões · https://help.sketchup.com/en/extensions-loading-policy | evento | mudança que impeça a ponte de carregar | instalacao.md |

## UpMobb

| Fonte | Cadência | O que observar | Afeta |
|---|---|---|---|
| Site · https://upmobb.tech (recursos, novidades, FAQ, termos de uso) | mensal | versão nova, recursos novos, mudança de exportação, **termos de uso** | upmobb/*, exportar-producao |
| Versão instalada (`SK eval "Sketchup.extensions.map { \|x\| [x.name, x.version] }"`) | mensal | mudou desde a última revisão? Se sim, retestar o conhecimento validado | conhecimento-validado.md |
| Canal oficial · https://www.youtube.com/@upmobb e playlist do instrutor Hildnei Linhares | trimestral | títulos de aulas novas (indicam recursos); conteúdo só vale se o usuário confirmar | upmobb/operacoes.md |
| Suporte UpMobb (WhatsApp/e-mail) | evento | formato de exportação, API, compatibilidade com SketchUp novo: pergunte pelo usuário | modelo-de-dados.md |
| Ajuda Calcme sobre importação do UpMobb · https://ajuda.calcme.com.br | trimestral | formato do JSON de orçamento | modelo-de-dados.md |

## Claude Code (plugins, skills, hooks)

| Fonte | Cadência | O que observar | Afeta |
|---|---|---|---|
| Docs de plugins · https://code.claude.com/docs/en/plugins (manifest, marketplace, components) | trimestral | campos novos ou removidos em plugin.json, userConfig, variáveis | plugin.json, publicar.md |
| Docs de skills · https://code.claude.com/docs/en/skills | trimestral | frontmatter, limites de descrição, substituições | todos os SKILL.md |
| Docs de hooks · https://code.claude.com/docs/en/hooks | trimestral | eventos, formato de saída, comportamento no Windows | hooks.json, sessao-inicio.ps1 |
| Boas práticas de skills · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | trimestral | regras de escrita | publicar.md |
| Changelog do Claude Code · https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md | mensal | mudanças que quebram plugins, Windows | todos |

## Fabricantes e normas (mudam devagar)

| Fonte | Cadência | O que observar | Afeta |
|---|---|---|---|
| Arauco, Dexco/Duratex, Berneck, Eucatex, Guararapes (fichas técnicas de MDF) | anual | formatos de chapa, espessuras, linhas novas | padroes-construcao.md |
| Blum, Hettich, Grass, Salice, FGVTN e o fabricante das corrediças/dobradiças usadas na Art MDF (ex.: HARDT) | anual ou ao trocar fornecedor | descontos de corrediça, furação de dobradiça | padroes-construcao.md, padrao-da-casa.md |
| Rehau e fornecedores de fita | anual | larguras e espessuras | padroes-construcao.md |
| ABNT (NBR 14033, 17192, 13961, 13966, 15316-2, 9050) | anual | edição nova, cancelamento | padroes-construcao.md, ergonomia.md |

## Regras de qualidade da fonte

1. Fato técnico só entra com fonte primária (doc oficial, ficha de fabricante, teste feito aqui).
2. Número só com origem e data. Faixa de mercado entra marcada como prática de mercado.
3. Fórum e vídeo: só como pista para testar; vira conhecimento depois de testado aqui.
4. Texto gerado por IA, blog de SEO e marketplace de terceiros não são fonte.
5. Conflito entre fonte externa e teste feito na Art MDF: vale o teste, com a fonte registrada como divergente.
