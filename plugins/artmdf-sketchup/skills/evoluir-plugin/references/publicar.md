# Publicar uma nova versão do plugin

Verificado em: 31/10/2026 · Fonte: docs de plugins do Claude Code (code.claude.com/docs/en/plugins).

## Estrutura do repositório

```
<repo>/                                   marketplace "artmdf"
├── .claude-plugin/marketplace.json
└── plugins/artmdf-sketchup/
    ├── .claude-plugin/plugin.json        nome, versão, userConfig
    ├── CHANGELOG.md
    ├── README.md
    ├── hooks/hooks.json                  início de sessão
    ├── scripts/*.ps1                     cliente da ponte e utilitários (UTF-8 com BOM)
    ├── sketchup/                         extensão Ruby da ponte (VERSAO em claude_ponte.rb)
    ├── skills/<skill>/SKILL.md           + references/ e assets/
    └── evals/                            casos de teste das skills
```

## Passo a passo

`<REPO>` abaixo = o caminho do repositório informado na skill evoluir-plugin (configuração `repo_plugin`). Os comandos de git usam **sempre** `-C "<REPO>"`: nunca rode git no diretório atual.

0. Se `<REPO>` estiver vazio, não existir ou não for um repositório git (`git -C "<REPO>" rev-parse --is-inside-work-tree`), **pare** e use a seção "Sem acesso ao repositório".
1. `git -C "<REPO>" pull` antes de mexer.
2. Aplique os diffs aprovados. Para cada arquivo de referência alterado, atualize a linha "Verificado em".
3. Versão em `plugins/artmdf-sketchup/.claude-plugin/plugin.json`:
   - 1.0.**x**: correção de texto, ajuste pequeno;
   - 1.**x**.0: conhecimento novo, receita nova, skill nova;
   - **x**.0.0: mudança que exige ação do usuário (reinstalar ponte, reconfigurar).
   Sem subir a versão, as máquinas **não** recebem a atualização (o cache só troca quando a versão muda).
4. Mudou algo em `sketchup/`? Suba `VERSAO` em `sketchup/claude_ponte.rb`. As máquinas verão "ponte desatualizada" no início da sessão e o Claude oferece reinstalar.
5. `CHANGELOG.md`: data, versão, o que mudou em linguagem do usuário, origem (aprendizado de tal data, fonte tal).
6. Validar:
   ```
   claude plugin validate "<REPO>"
   claude plugin validate "<REPO>/plugins/artmdf-sketchup"
   ```
   Arquivos `.ps1` com acento precisam estar em UTF-8 **com BOM** (o Windows PowerShell 5.1 lê sem BOM como ANSI e estraga o texto).
7. Testes: se mexeu em skill, rode os casos de `evals/` relacionados (`claude plugin eval <pasta-do-plugin> --case <nome>`), quando o usuário aceitar o custo.
8. Mostre o resumo (`git -C "<REPO>" status` e `git -C "<REPO>" diff --stat`) e peça OK. Então: `git -C "<REPO>" add -A`, `git -C "<REPO>" commit -m "artmdf-sketchup vX.Y.Z: <resumo>"`, `git -C "<REPO>" push`.
9. Nas máquinas com atualização automática, a versão nova entra na próxima sessão (ou com `/plugin` > atualizar agora).

## Skills novas

- Uma pasta em `skills/<nome-em-minusculas-com-hifen>/` com `SKILL.md`.
- Frontmatter em YAML válido: use bloco dobrado (`description: >-` e o texto nas linhas seguintes, recuado), porque aspas, dois-pontos e listas de frases quebram o YAML e a skill carrega sem descrição. Confira com `claude plugin validate`.
- Campos: `name`, `description` (o que faz + quando usar, terceira pessoa, até ~1000 caracteres, com os termos que o usuário fala), `when_to_use` com frases típicas.
- Corpo com menos de 500 linhas; detalhe em `references/` (um nível só); scripts em `scripts/` executados, não lidos.
- Diga só o que o Claude não sabe: o padrão da casa, o comportamento do UpMobb, o passo que já deu errado.
- Passos destrutivos com instrução exata; passos de julgamento com critério.
- Termine com a seção "Aprender" apontando para `_claude/aprendizados.md`.
- Crie pelo menos um caso em `evals/` que verifica se a skill é acionada pelo pedido típico.
- Poucas skills, bem descritas, rendem mais que muitas: antes de criar, veja se o procedimento cabe como receita numa skill existente.

## Sem acesso ao repositório nesta máquina

Gere em `<pasta de trabalho>/_claude/para-publicar/AAAA-MM-DD/` os arquivos alterados (caminho relativo ao plugin) e um `LEIA.md` com o resumo. A publicação é feita depois pela Orbe ou pela máquina que tem o repositório.
