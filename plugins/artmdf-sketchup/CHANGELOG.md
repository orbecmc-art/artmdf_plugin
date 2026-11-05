# Changelog · artmdf-sketchup

## 1.0.3 · 05/11/2026

Revisão de fontes externas: dois vídeos de teste do conector SketchUp para Claude (The SketchUp Essentials, 30/04/2026; The Architecture Grind, 02/05/2026), post sobre modelagem de casa a partir de PDF (12/07/2026) e páginas oficiais da Trimble.

- `modelar-movel`: pedido a partir de foto, planta ou PDF passa por tabela de cotas com a origem de cada número (escrita, estimada ou a perguntar), conferida linha a linha no fim. Motivo: nos testes, forma e aberturas saíram certas e as medidas, erradas.
- `modelar-movel`: cadeira, eletro e decoração vêm de componente pronto ou caixa com medida real, não de forma modelada pela IA.
- `modelar-movel` e `sketchup-ponte`: regra para o conector SketchUp do Claude (Trimble), que gera modelo novo na nuvem, sem UpMobb e sem tocar no SketchUp aberto. Não substitui a ponte; só para estudo rápido pedido pelo usuário.
- `evoluir-plugin/fontes.md`: conector Trimble entra na lista de fontes, com o gatilho para reavaliar a ponte.

## 1.0.2 · 01/11/2026

- Skill nova `upmobb-cadastrar-itens-faltantes`: cadastro em Insumos dos itens da "Lista de elementos sem cadastro", agora com leitura do diálogo por `janelas.ps1`, checagem de código já cadastrado antes de criar (evita duplicata), aprovação da lista antes de gravar e regra nova salva em `_claude/regras-insumos.md`. Sai da `exportar-producao`, que passa a chamá-la.
- Guia de uso em Markdown (`docs/guia-plugin-art-mdf.md`) no lugar da versão HTML.

## 1.0.1 · 31/10/2026

- Rotina semanal no Windows: `scripts/agendar-rotina.ps1` agenda a revisão do plugin (só propõe, grava relatório em `_claude/relatorios`). A skill evoluir-plugin ganhou o modo revisão.
- Repositório oficial: orbecmc-art/artmdf_plugin.

## 1.0.0 · 31/10/2026

Primeira versão.

- Ponte Claude Code ↔ SketchUp por fila de arquivos (extensão Claude Ponte 1.0.0): um SketchUp por PID, histórico de execução, espelho do Console Ruby, fotos de verificação sem alterar o modelo.
- Scripts PowerShell: `sk.ps1` (status, rodar, eval, console), `janelas.ps1` (ler e responder diálogos), `instalar-ponte.ps1`, `scx.ps1` (ler e comparar usinagem), `pdf.ps1` (HTML → PDF), `sessao-inicio.ps1` (aviso de início de sessão).
- Oito skills: sketchup-ponte, sketchup-tela, upmobb, modelar-movel, personalizar-modulo, exportar-producao, documentar-projeto, evoluir-plugin.
- Três degraus de acesso ao SketchUp: ponte instalada, ponte carregada pelo Console Ruby (`carregar-ponte.ps1`) e controle pela tela (`sketchup-tela`).
- Correções da revisão independente: frontmatter YAML válido nas skills, mensagens de erro do `sk.ps1` visíveis, detecção de diálogo pelo tempo do script, clique em diálogo por WM_COMMAND com timeout, leitura de tag no `scx.ps1`, git sempre com `-C` na publicação.
- Conhecimento inicial vindo das sessões de 31/10/2026 (criado-mudo 2 gavetas; roupeiro com puxador RM416) e de pesquisa em fontes oficiais (Ruby API, docs de plugins do Claude Code, UpMobb, fabricantes de MDF e ferragens, ABNT).
- Cadastro de itens sem cadastro no UpMobb incorporado da skill anterior da Orbe.
- Ficha do cliente final (`modelar-movel`), aviso de imagem ilustrativa e receita de vídeo de apresentação em validação (`documentar-projeto`), a partir de revisão de fonte externa (artigo sobre estúdio de design com Claude Code, 12/07/2026).
