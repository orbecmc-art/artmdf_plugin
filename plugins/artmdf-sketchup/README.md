# Art MDF · SketchUp + UpMobb (plugin do Claude Code)

Plugin que ensina o Claude Code a projetar móveis planejados no SketchUp da Art MDF, trabalhando junto com o UpMobb. Mantido pela Orbe Assessoria Digital.

## O que tem dentro

| Skill | Para quê |
|---|---|
| `sketchup-ponte` | Liga o Claude ao SketchUp aberto, roda Ruby, confere com fotos, destrava janelas, salva com segurança |
| `sketchup-tela` | Opera SketchUp e UpMobb pela tela quando não há ponte, e para botões do painel do UpMobb (Aplicar, exportar, divergências) |
| `upmobb` | Como o UpMobb funciona por dentro e as regras para não quebrar orçamento, listas e usinagem |
| `modelar-movel` | Do pedido ao móvel conferido: ficha, biblioteca do UpMobb, padrão da casa, checklist |
| `personalizar-modulo` | Quando a biblioteca não atende: opções novas, recortes visuais, correções de módulo |
| `exportar-producao` | Divergências, usinagem .scx (com comparação), plano de corte, itens a comprar |
| `upmobb-cadastrar-itens-faltantes` | Cadastra em Insumos (painel web do UpMobb) os itens da lista de elementos sem cadastro e confere até a lista zerar |
| `documentar-projeto` | Cenas, cotas, imagens para o cliente, projeto executivo em PDF, CSV |
| `evoluir-plugin` | Aprendizados da equipe + revisão de fontes externas → conhecimento local na hora e nova versão do plugin |

Mais: a extensão **Claude Ponte** (pasta `sketchup/`), os scripts PowerShell (`scripts/`) e o aviso de início de sessão (`hooks/`).

## Como funciona a ponte

```
Claude Code ──(sk.ps1 grava script .rb)──> %LOCALAPPDATA%\ClaudePonte\instancias\<PID>\entrada
                                                    │  a cada 0,25 s
                                     SketchUp (extensão Claude Ponte) executa
                                                    │
Claude Code <──(lê resultado .json)── ...\saida   (valor em mm, texto, erro, se ficou alterado)
```

Sem rede, sem Python. Um SketchUp aberto = uma fila. Tudo que roda fica no histórico (`ClaudePonte\historico`).

Três degraus de acesso ao SketchUp:
1. **Ponte instalada** como extensão (preferida).
2. **Ponte carregada pelo Console Ruby** (`scripts\carregar-ponte.ps1`), quando a extensão não pode ser instalada ou não carrega; vale até fechar o SketchUp.
3. **Controle pela tela** (skill `sketchup-tela`), quando não há acesso ao Console Ruby, e para o que só existe na interface do UpMobb.

## Instalação numa máquina

1. **Claude Code** (PowerShell): `irm https://claude.ai/install.ps1 | iex`. Recomendado: Git for Windows.
2. **Acesso ao repositório privado:** `gh auth login` e `gh auth setup-git` (uma vez por máquina).
3. **No Claude Code:**
   ```
   /plugin marketplace add orbecmc-art/artmdf_plugin
   /plugin install artmdf-sketchup@artmdf
   ```
   Informe a pasta de trabalho (ex.: `C:/Users/Usuario/Desktop/Sketup Claude`) e a pasta de exportação do UpMobb. Para mudar depois: `/plugin configure artmdf-sketchup@artmdf`.
4. **Atualização automática:** `/plugin` > Marketplaces > artmdf > ativar atualização automática.
5. **Ponte no SketchUp:** peça ao Claude "instala a ponte do SketchUp" (ou rode `scripts\instalar-ponte.ps1`). Feche e abra o SketchUp. Se aparecer aviso de extensão não identificada, permita carregar.
6. **Teste:** "o que está aberto no SketchUp?". O Claude deve responder com o título do modelo e as peças.
7. **Conhecimento da casa:** peça "inicia o conhecimento do plugin". O Claude cria a pasta `_claude` na pasta de trabalho e revisa com vocês o `padrao-da-casa.md`.

## Como o plugin melhora

- Toda tarefa termina registrando o que foi aprendido em `_claude/aprendizados.md`.
- O início de cada sessão avisa quando há aprendizados pendentes ou fontes externas vencidas.
- "Evolui o plugin" consolida: o que é da casa entra na hora em `_claude/` (vale já na próxima tarefa); o que é melhoria do plugin vira versão nova no repositório e chega às outras máquinas pela atualização automática.

## Regras que o plugin segue sempre

- Não salva sem pedir; faz backup antes de sobrescrever.
- Não mexe na usinagem sem pedido explícito.
- Não altera a biblioteca do UpMobb sem OK.
- Não inventa dados do cliente (Detalhes do projeto).
- Confere medindo e olhando a imagem antes de dizer que terminou.

## Suporte

Orbe Assessoria Digital · orbeassessoria.com.br · (62) 99291-6191
