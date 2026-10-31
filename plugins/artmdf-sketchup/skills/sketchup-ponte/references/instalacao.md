# Instalação, versões e problemas da ponte

Verificado em: 31/10/2026 · Volatilidade: média (muda com versão do SketchUp)

## Requisitos

- Windows 10/11 64 bits, SketchUp **desktop** (Pro/Studio). SketchUp Web/Go não roda extensões nem Ruby.
- Claude Code instalado (PowerShell: `irm https://claude.ai/install.ps1 | iex`, ou `winget install Anthropic.ClaudeCode`). Git for Windows recomendado; sem ele o Claude Code usa PowerShell.
- Nada de Python: a ponte é Ruby (dentro do SketchUp) + PowerShell.

## Instalar

```
powershell -NoProfile -ExecutionPolicy Bypass -File "<pasta do plugin>/scripts/instalar-ponte.ps1"   (caminho completo na skill sketchup-ponte, seção 6)
```

Copia `claude_ponte.rb` e a pasta `claude_ponte\` para `%APPDATA%\SketchUp\SketchUp <ano>\SketchUp\Plugins` de cada versão encontrada. `-Versao 2026` limita a uma versão. Depois: fechar e abrir o SketchUp.

Conferir: `SK status` deve listar o SketchUp. No SketchUp, menu Extensões > Claude Ponte > Status.

## Política de carregamento de extensões

A ponte não é assinada. Em Extensões > Gerenciador de Extensões > engrenagem:
- "Somente extensões identificadas" bloqueia a ponte;
- "Aprovar extensões não identificadas" pergunta na primeira vez (escolha carregar);
- "Irrestrito" carrega tudo.

Para entrega definitiva, a Orbe pode assinar a extensão no Extension Signing Portal da SketchUp (gratuito) e trocar a pasta `sketchup/` por um `.rbz` assinado.

## Versões do SketchUp

| Versão | Ruby | Observação |
|---|---|---|
| 2024 | 3.2 | ok |
| 2025 | 3.2 | executável em `C:\Program Files\SketchUp\SketchUp 2025\SketchUp\SketchUp.exe` |
| 2026 | 3.2 | ambiente da Art MDF em 31/10/2026; câmera de cena passou a entrar no desfazer |
| 2027 (out/2026) | **3.4.9** | a ponte é Ruby puro e deve funcionar; **o UpMobb precisa confirmar compatibilidade antes de atualizar** |

Não atualize o SketchUp da produção sem o UpMobb confirmar a versão nova. Plugins de marcenaria já pararam de funcionar em troca de versão do SketchUp.

## Onde ficam as coisas

| O quê | Onde |
|---|---|
| Fila e status por SketchUp aberto | `%LOCALAPPDATA%\ClaudePonte\instancias\<PID>\` |
| Histórico de todo código executado (30 dias) | `%LOCALAPPDATA%\ClaudePonte\historico\<data>.log` |
| Fotos | `%LOCALAPPDATA%\ClaudePonte\fotos\<data>\` |
| Configuração opcional | `%LOCALAPPDATA%\ClaudePonte\config.json` (ex.: `{"espelhar_console": false}`) |

## Problemas comuns

| Sintoma | Causa | Solução |
|---|---|---|
| `SK status`: nenhum SketchUp | ponte não instalada, SketchUp não reiniciado, extensão desativada ou bloqueada pela política | instalar, reiniciar, ativar no Gerenciador, ajustar política |
| Script não começa (tempo esgotado "NEM COMEÇOU") | ponte ocupada com script anterior ou pausada | `SK status`; menu Extensões > Claude Ponte > Pausar/retomar |
| Script começou e não termina | janela modal (MessageBox, Salvar como) | `janelas.ps1 -ProcessoId <PID>` |
| PID mudou | SketchUp foi fechado e aberto | `SK status` de novo; `SK limpar` remove pastas antigas |
| Acentos estranhos na saída do PowerShell | arquivo .ps1 salvo sem BOM | os scripts do plugin são UTF-8 com BOM; não regrave sem BOM |
| Erro de outro plugin aparece no console a cada ação | observador do UpMobb | não afeta o trabalho; só investigar se for erro novo depois de algo que você fez |

## Segurança

- A ponte só lê arquivos de uma pasta do próprio usuário; não abre porta de rede.
- Todo código executado fica registrado no histórico.
- O menu Extensões > Claude Ponte > Pausar desliga a execução na hora.
- Os prompts de permissão do Claude Code continuam valendo: não libere execução automática para tudo.
