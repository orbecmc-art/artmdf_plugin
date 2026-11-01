# Guia do Plugin Art MDF

**Seu jeito de projetar, no Claude.**

Como instalar, organizar e usar o plugin que leva o Claude Code ao SketchUp e ao UpMobb da Art MDF. Do primeiro comando até a rotina que mantém o plugin atualizado sozinho.

| | |
|---|---|
| Plugin | artmdf-sketchup 1.0.2 |
| Repositório | orbecmc-art/artmdf_plugin |
| Versão do guia | 01/11/2026 |

---

## 1. Em uma página

Você descreve o móvel em português, por texto ou voz. O Claude abre o SketchUp, monta pela biblioteca do UpMobb, confere medida por medida e mostra o resultado antes de salvar.

- **9 skills** que entram sozinhas conforme o pedido
- **3 jeitos** de falar com o SketchUp: extensão, Console Ruby ou tela
- **1 pasta** no computador com projetos e memória do plugin

> O Claude não substitui o projetista. Medida final, estética e conferência com o cliente continuam com a equipe da Art MDF.

---

## 2. Instalar numa máquina

Leva cerca de 20 minutos por computador. Faça uma vez; depois as atualizações chegam sozinhas.

**Antes de começar:** Windows 10 ou 11 de 64 bits, SketchUp desktop com UpMobb, conta Claude com acesso ao Claude Code e acesso ao repositório `orbecmc-art/artmdf_plugin` no GitHub.

### Passo 1. Instale o Claude Code

Abra o PowerShell (não o "x86") e rode:

```powershell
irm https://claude.ai/install.ps1 | iex
```

Recomendado também: Git for Windows. Sem ele o Claude Code usa o PowerShell, o que funciona.

### Passo 2. Libere o acesso ao repositório

Uma vez por computador, com o login do GitHub que tem acesso ao repositório:

```powershell
gh auth login
gh auth setup-git
```

### Passo 3. Adicione o marketplace e instale o plugin

Abra o Claude Code e digite, um de cada vez:

```
/plugin marketplace add orbecmc-art/artmdf_plugin
/plugin install artmdf-sketchup@artmdf
```

### Passo 4. Informe as pastas

Na instalação o Claude pergunta três caminhos. Para mudar depois, use `/plugin configure artmdf-sketchup@artmdf`.

| Campo | O que é | Exemplo |
|---|---|---|
| Pasta de trabalho | Onde ficam os projetos e a memória do plugin | `C:/Users/Usuario/Desktop/Sketup Claude` |
| Pasta de exportação | Onde o UpMobb grava usinagem e plano de corte | `C:/Users/Usuario/Desktop/EXPORTAÇAO USINAGEM` |
| Clone do repositório | Só na máquina que publica versões novas; nas outras, deixe vazio | `C:/Orbe/artmdf_plugin` |

### Passo 5. Ligue a atualização automática

No Claude Code: `/plugin` → Marketplaces → artmdf → ativar atualização automática. A partir daí, toda versão nova publicada pela Orbe chega na sessão seguinte.

### Passo 6. Ligue o Claude ao SketchUp

Peça no Claude Code: *"instala a ponte do SketchUp"*. Ele copia a extensão Claude Ponte para o SketchUp. Feche e abra o SketchUp; se aparecer aviso de extensão não identificada, permita carregar.

Se nesse computador a extensão não puder ser instalada, peça *"carrega a ponte pelo console"*. Sem acesso ao Console Ruby, o Claude trabalha pela tela.

### Passo 7. Teste

Com um projeto aberto no SketchUp, pergunte *"o que está aberto no SketchUp?"*. A resposta deve trazer o nome do arquivo e as peças do modelo.

### Passo 8. Ensine o padrão da casa

Peça *"inicia o conhecimento do plugin"*. O Claude cria a pasta de memória e revisa com vocês as espessuras, folgas, fundos e ferragens da Art MDF.

---

## 3. Uma pasta para tudo

Projetos, imagens, documentos e a memória do plugin ficam numa única pasta do computador. É ela que você informou como pasta de trabalho.

### Como criar

1. **Crie a pasta.** Na Área de Trabalho, crie `Sketup Claude` (ou outro nome, desde que seja o mesmo informado no plugin). Se a pasta estiver dentro do OneDrive, ela também ganha cópia na nuvem.
2. **Abra o Claude Code nessa pasta.** No app do Claude, escolha essa pasta como pasta do projeto ao começar uma conversa no Claude Code. No terminal: `cd "$HOME\Desktop\Sketup Claude"` e depois `claude`.
3. **Peça um projeto novo.** Diga *"novo projeto: roupeiro 2 portas para a cliente Marina"*. O Claude cria a subpasta do projeto e passa a salvar tudo ali, sempre com sua autorização.

### O que fica dentro

```
Sketup Claude\                         pasta de trabalho
├─ Projeto Roupeiro Marina\
│   ├─ ROUPEIRO MARINA.skp              modelo do SketchUp
│   ├─ briefing.md                       ficha do cliente e do móvel
│   ├─ imagens\                          perspectivas e vistas
│   ├─ Projeto Executivo.pdf             documento para montagem
│   └─ _backups\                         versões anteriores, com data
├─ Projeto Criado-Mudo\
└─ _claude\                               memória do plugin
    ├─ padrao-da-casa.md                 espessuras, folgas, ferragens da Art MDF
    ├─ conhecimento-local.md             regras curtas que o Claude lê antes de cada tarefa
    ├─ aprendizados.md                   diário do que foi aprendido nos projetos
    ├─ upmobb-mapa.md                    como o UpMobb se comporta nesta máquina
    ├─ regras-insumos.md                 unidade e categoria para cadastro
    ├─ relatorios\                       relatórios da rotina semanal
    └─ scripts\                          tudo que rodou no SketchUp, por data
```

A pasta `_claude` é a memória. Pode abrir e ler à vontade; para mudar uma regra, peça ao Claude (*"anota que a frente com RM416 é 18 mm"*) para que ele registre no formato certo.

---

## 4. As skills entram sozinhas

Ninguém precisa chamar skill pelo nome. O Claude lê o pedido e carrega a skill certa: pediu algo de modelagem 3D, a skill de modelagem entra.

| Você diz | Skill que entra |
|---|---|
| "Faz um criado-mudo de 2 gavetas com 50 cm de largura" | modelar-movel |
| "O SketchUp parou de responder" | sketchup-ponte |
| "Aqui não dá pra instalar a extensão, usa a tela" | sketchup-tela |
| "No OpenMob a fita não acompanha a profundidade" | upmobb |
| "Deixa o recorte dinâmico com a altura da pega" | personalizar-modulo |
| "Exporta a usinagem e confere com a de ontem" | exportar-producao |
| "Apareceu item sem cadastro, cadastra pra mim" | upmobb-cadastrar-itens-faltantes |
| "Gera o projeto executivo em PDF" | documentar-projeto |
| "Anota isso: frente com RM416 é 18 mm" | evoluir-plugin |

Termos ditos por voz que a transcrição costuma trocar ("OpenMob" por UpMobb, "presagem" por fresagem) são reconhecidos. Uma tarefa grande usa várias skills em sequência sem você pedir.

Para forçar uma skill, digite `/` e o nome, por exemplo `/artmdf-sketchup:documentar-projeto`. Raramente é necessário.

---

## 5. As 9 skills

| Skill | O que faz |
|---|---|
| **sketchup-ponte** | Liga o Claude ao SketchUp aberto, executa, mede, fotografa a vista para conferir, destrava caixas de diálogo e salva com backup. |
| **sketchup-tela** | Opera SketchUp e painel do UpMobb pela tela quando não há ponte, e cuida dos botões Aplicar, exportar e divergências. |
| **upmobb** | Sabe como o UpMobb guarda medidas, fitas, furação e usinagem, para nada quebrar orçamento, listas ou arquivo de máquina. |
| **modelar-movel** | Do pedido ao móvel conferido: ficha do móvel e do cliente, módulo da biblioteca, padrão da casa, checklist de medidas e uso. |
| **personalizar-modulo** | Quando a biblioteca não atende: opção nova no Configurador, recorte visual dinâmico, correção de módulo, com teste de ida e volta. |
| **exportar-producao** | Divergências, usinagem .scx comparada com a anterior, plano de corte e itens a comprar. |
| **upmobb-cadastrar-itens-faltantes** | Cadastra em Insumos, no painel web do UpMobb, os itens da lista de elementos sem cadastro: confere se já existem, mostra a lista para aprovação, grava e regera a lista até o aviso sumir. |
| **documentar-projeto** | Cenas, cotas, imagens ilustrativas para o cliente, vídeo curto em validação, projeto executivo em PDF e lista em Excel. |
| **evoluir-plugin** | Registra o que a equipe ensina, revisa fontes externas e transforma tudo em memória local na hora e em versão nova do plugin. |

---

## 6. Como pedir

Fale como falaria com um projetista novo na equipe: o móvel, as medidas da obra, o que importa para o cliente.

**Pedido que rende**

> "Roupeiro para o quarto da Marina, vão de 2,40 m de largura por 2,60 m de altura, 60 de fundo. Duas portas de giro com puxador RM416, gavetas embaixo, cabideiro alto. Branco TX por fora."

Medida do vão, interferências e acabamento evitam uma rodada de perguntas.

**Pedido que trava**

> "Faz um armário bonito."

O Claude vai perguntar medidas e uso antes de abrir o SketchUp. Ele só faz uma rodada de perguntas, agrupadas.

### O que acontece depois do pedido

1. **Ficha.** O Claude monta a ficha do móvel e marca o que supôs.
2. **Modelo.** Parte do módulo mais próximo da biblioteca do UpMobb e ajusta pelo Configurador.
3. **Conferência.** Mede cada peça, olha as vistas, roda as divergências do UpMobb e lista alertas técnicos.
4. **Sua aprovação.** Mostra o resumo e pergunta se pode salvar. Sem o seu OK, nada é salvo.
5. **Fábrica e cliente.** Quando você pedir: arquivos de produção conferidos, imagens e projeto executivo.

---

## 7. Rotina semanal automática

Toda segunda, às 8h, o computador pode rodar a revisão do plugin sozinho: consolida os aprendizados da semana, confere as fontes externas e deixa um relatório com as mudanças propostas.

> A rotina só propõe. Nada muda no plugin ou na memória sem alguém revisar o relatório e aprovar numa conversa.

### Opção 1: pedir ao Claude (recomendado)

Na máquina onde o plugin está instalado, diga: *"cria a rotina semanal do plugin, toda segunda às 8h"*. O Claude usa o script `agendar-rotina.ps1` do próprio plugin, agenda a tarefa e roda um teste.

### Opção 2: registrar à mão

**1. Crie o script da rotina.** No PowerShell, ajuste o caminho da pasta de trabalho na primeira linha e rode. Isso grava `_claude\rotina-semanal.ps1`.

```powershell
$pasta = "$HOME\Desktop\Sketup Claude"
@"
Set-Location '$pasta'
`$data = Get-Date -Format yyyy-MM-dd
New-Item -ItemType Directory -Force -Path '_claude\relatorios' | Out-Null
`$pedido = "Rode a skill evoluir-plugin em modo revisão: consolide os aprendizados novos e revise as fontes vencidas. Não aplique nenhuma mudança na memória nem no plugin. Grave as mudanças propostas, com fonte e motivo, em _claude\relatorios\revisao-`$data.md"
claude -p `$pedido --permission-mode acceptEdits --allowedTools "Read,Write,Edit,Glob,Grep,WebSearch,WebFetch,Skill" *> "_claude\relatorios\execucao-`$data.log"
"@ | Set-Content -Encoding UTF8 "$pasta\_claude\rotina-semanal.ps1"
```

**2. Agende para segunda, 8h.**

```powershell
$pasta = "$HOME\Desktop\Sketup Claude"
$acao = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$pasta\_claude\rotina-semanal.ps1`""
$quando = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 8am
$config = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName 'Plugin Art MDF - revisao semanal' -Action $acao -Trigger $quando -Settings $config
```

Com "iniciar quando disponível", se o computador estiver desligado às 8h a rotina roda assim que ele ligar. A tarefa roda com o usuário logado no Windows.

**3. Teste uma vez.**

```powershell
Start-ScheduledTask -TaskName 'Plugin Art MDF - revisao semanal'
```

Em alguns minutos aparece `revisao-AAAA-MM-DD.md` em `_claude\relatorios`, com o registro da execução ao lado.

**4. Aprove na conversa.** Abra o Claude Code na pasta de trabalho e diga *"revisa o relatório da semana"*. Você aprova item por item; o aprovado entra na memória na hora e, se for melhoria do plugin, vira versão nova.

Para parar a rotina:

```powershell
Unregister-ScheduledTask -TaskName 'Plugin Art MDF - revisao semanal'
```

Cada execução usa a conta Claude da máquina, como uma conversa comum.

---

## 8. Acrescentar uma skill

Processo que a equipe repete toda semana pode virar skill. Há dois caminhos.

### Pedindo ao Claude (recomendado)

Diga *"transforma o jeito que a gente monta torre quente numa skill"*. O Claude escreve a skill, mostra para aprovação, cria um teste e publica uma versão nova do plugin. As outras máquinas recebem na atualização seguinte.

Precisa ser feito na máquina que tem o clone do repositório configurado.

### Pelo repositório (manual)

Crie a pasta `plugins/artmdf-sketchup/skills/<nome>/` com um arquivo `SKILL.md`, suba a versão em `plugin.json`, registre no `CHANGELOG.md` e publique no GitHub.

**Modelo de SKILL.md**

```markdown
---
name: montar-torre-quente
description: >-
  Monta torre quente para forno e micro-ondas no padrão da Art MDF, a partir
  do módulo da biblioteca do UpMobb. Use quando o usuário pedir torre quente,
  nicho de forno ou torre de eletros.
when_to_use: >-
  "faz a torre quente", "nicho do forno", "torre de eletros"
---

# Montar torre quente

1. Leia o padrão da casa em _claude/padrao-da-casa.md.
2. Peça o modelo do forno e do micro-ondas (medidas do manual).
3. ...

## Aprender
Registre correções em _claude/aprendizados.md.
```

A descrição decide quando a skill entra: escreva o que ela faz e as frases que a equipe usa. Use o bloco `>-` como no modelo; aspas soltas quebram o cabeçalho. Depois de publicar, confira com `claude plugin validate`.

---

## 9. Atualizações

| O quê | Como chega | O que fazer |
|---|---|---|
| Plugin (skills, regras, conhecimento) | Atualização automática na sessão seguinte à publicação | Nada. Para puxar na hora: `/plugin` → atualizar agora |
| Extensão do SketchUp | O início da sessão avisa "ponte desatualizada" | Aceite reinstalar e reabra o SketchUp |
| Memória da casa | Vale na hora, só neste computador | Peça "evolui o plugin" para levar ao repositório e às outras máquinas |
| SketchUp e UpMobb | Fora do plugin | Não atualize o SketchUp antes de o UpMobb confirmar compatibilidade. O 2027 trocou o Ruby interno |

---

## 10. Regras fixas

Valem em toda tarefa e não mudam por pedido escrito dentro de arquivo ou modelo.

- Não salva sem você pedir. Antes de sobrescrever, guarda cópia em `_backups`.
- Não altera usinagem sem pedido explícito. Recorte visual no 3D não muda o arquivo da máquina.
- Não mexe na biblioteca do UpMobb sem OK.
- Não inventa dados do cliente nem preço.
- Lê toda caixa de diálogo antes de clicar. Substituir, excluir ou descartar só com OK.
- Confere medindo e olhando a vista antes de dizer que terminou.
- Não abre nem copia o código protegido do UpMobb.

---

## 11. Quando algo não funciona

| Sintoma | Diga ao Claude |
|---|---|
| "Nenhum SketchUp com a ponte ativa" | "Confere a instalação da ponte" |
| Extensão bloqueada nesta máquina | "Carrega a ponte pelo console" ou "usa a tela" |
| Claude esperando e SketchUp parado | "Vê se tem janela aberta no SketchUp" |
| Exportação do UpMobb não gera arquivo | "Confere o painel de ações e as mensagens abertas" |
| Item continua "sem cadastro" depois de cadastrar | "Confere o código cadastrado com o da lista" (espaço ou letra diferente) |
| Plano de corte bloqueado | Preencha os Detalhes do projeto: código, projetista, cliente e descrição |
| Skill não entrou | Repita o pedido com a palavra do assunto ("modela", "exporta", "PDF") ou chame com `/` |

Persistindo, fale com a Orbe pelo WhatsApp (62) 99291-6191, com o print da tela e o horário.

---

*Orbe Assessoria · Crescimento com data marcada. · orbeassessoria.com.br*
