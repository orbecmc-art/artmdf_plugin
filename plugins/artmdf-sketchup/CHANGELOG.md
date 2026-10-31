# Changelog · artmdf-sketchup

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
