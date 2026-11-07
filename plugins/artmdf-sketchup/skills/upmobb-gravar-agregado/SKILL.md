---
name: upmobb-gravar-agregado
description: >-
  Grava pela primeira vez um componente do SketchUp como AGREGADO na biblioteca UpMobb (MDF Arte Design) pelo
  painel Desenvolvimento: preparar o componente, Salvar Componente, criar grupo e subgrupo se faltar, imagem,
  Enviar e testar com a mira azul. Use SEMPRE que o usuário disser "gravar na minha biblioteca dentro de
  agregados" ou variações. Para componente que já está na biblioteca, use upmobb-atualizar-componente-biblioteca.
when_to_use: >-
  "grava na minha biblioteca dentro de agregados", "salva como agregado", "cadastra na biblioteca em
  agregados", "manda pro UpMobb em agregados", "cria o grupo do agregado", "publica esse componente"
---

# Gravar agregado novo na biblioteca UpMobb

Une três skills criadas entre 05 e 07/11/2026 (gravações do "Divisor de Talheres" e do "Recorte Cava RM416"; telas em `_claude/gravacao_agregado/`).

**Gatilho padrão:** "gravar na minha biblioteca dentro de agregados" (ou equivalente) é este fluxo. Não pergunte qual método usar. O Tipo é sempre **Agregados**.

**A biblioteca é da empresa inteira: só envie com OK explícito do usuário naquele momento, dizendo grupo, subgrupo e nome.** Se ele não disser o grupo/subgrupo, pergunte uma única vez (ou proponha, ex.: "<Grupo> em MDF", e confirme antes de criar).

O painel do UpMobb é uma página web (CEF): o UIA não lê o conteúdo, então os cliques são pela tela (skill `sketchup-tela`) ou o usuário faz e você confere. Antes de cada clique, tire screenshot e confirme em qual tela está. Não clique repetidamente no mesmo ponto sem efeito: tire novo screenshot.

Componente que **já está** na biblioteca e foi alterado: não envie de novo, use `upmobb-atualizar-componente-biblioteca`.

## 1. Preparar o componente (antes de abrir o painel)

- Componente dinâmico com `componentedit=1`, `delectable=1`, `name`/`description`, peças UpMobb dentro (com `upmcode`), filhos com `componentedit=0` e `_name` próprio.
- Medidas ligadas ao pai onde ele vai entrar (ex.: gaveta → `conteiner` type `conteiner_drawer`: `lenx/leny/lenz = parent!...`, x/y/z = 0). Testar dentro de um módulo real antes de gravar.
- Salvar o .skp de trabalho (com OK) para não perder o estado.

## 2. Salvar Componente

1. Selecionar o componente certo: duplo clique para entrar até ele ficar selecionado sozinho. Conferir em *Atributos de componente* (Name, ItemCode, `type`, `upmcode`). Se aparecer o pai (conteiner, gaveta, peça avulsa), sair e entrar no nível correto. Anotar o `name`.
2. Abrir **Desenvolvimento**: Extensões → UpMobb → Ações UpMobb → Menu → Desenvolvimento, ou o ícone `<>` no rodapé da barra lateral do UpMobb. Maximizar a janela se precisar.
3. Expandir **Ações geral** → **Salvar Componente**.
4. Aparece "***Elementos salvos*** <nome>" — o nome pode vir com sufixo, ex.: `Recorte Cava RM416#2`. Anotar o nome exato (selecionar e Ctrl+C) e clicar **OK**. Gera `Documentos\upmobb\<nome>.skp` e `<nome>.png`. Por baixo: `UpActionsC#save_component_upload_server`. O sufixo `#N` muda a cada salvamento: use sempre o do aviso.

## 3. Grupo e subgrupo

O envio exige Tipo + Grupo + Subgrupo; sem subgrupo o formulário recusa (campo fica vermelho).

1. Em Desenvolvimento → **Tipos, Grupos e Subgrupos da Modulação** → `2 Agregados` → Expandir → localizar o grupo → Expandir.
2. Grupo novo: **Grupo +** em "Agregados"; marcar Visível. Subgrupo novo: **Subgrupo +** no grupo, digitar o nome em "Novo Subgrupo", **Salvar** (verde) (`UpRequestC#add_new_subgroup`). Conferir que apareceu na lista.
3. **Onde o agregado pode entrar depende do grupo.** Grupos existentes e alvos: Internos (6), Para Internos (51) → vão do módulo; **Para Gavetas (10) → dentro da gaveta**; Para Frentes de Gaveta (27); Para Portas (26) → peça da porta (ex.: Para Portas › Puxadores RM416); Para Peça (11); Para Painéis (8); Externos (17); Inferiores (7); Superiores (9).
   - ATENÇÃO (teste de 05/11): o grupo novo "Divisor De Talheres" (58) criado solto em Agregados fez a mira azul oferecer só o vão interno do balcão (entrou em "Conjunto de prateleiras", 869×550). Agregado de gaveta deve ficar num subgrupo **dentro de "Para Gavetas" (10)** — confirmar no próximo teste e atualizar esta skill.

## 4. Imagem

Use o `<nome>.png` gerado no passo 2. Se o usuário preferir foto do produto (ex.: puxador de fabricante): buscar o nome no navegador, recortar com Win+Shift+S e salvar como PNG em `Documentos\upmobb\` com nome simples, ou usar o arquivo que ele indicar.

## 5. Enviar

1. Em Desenvolvimento → **Componentes** (feche *Ações geral* se atrapalhar a rolagem):
   - **Tipo** = Agregados
   - **Grupo** e **Sub Grupo** = os combinados (a lista é longa, rolar; se o subgrupo novo não aparecer, recarregar a tela pelo ícone de atualizar no canto superior direito)
   - **Nome** = nome do componente **sem** o sufixo `#N`
   - **Skp** = Choose File → `Documentos\upmobb\<nome>#N.skp` (os diálogos abrem em Documentos; entrar em `upmobb`)
   - **Imagem** = Choose File → o PNG (filtro "Image Files")
2. **Enviar** → "Módulo enviado com sucesso!" no topo, ou o formulário volta em branco. A mensagem nem sempre aparece claramente: valide sempre no passo 6. Se der erro ou campo vermelho, conte ao usuário o que apareceu em vez de insistir.

## 6. Testar (sempre)

1. Conferir na hierarquia do painel (Tipo › Grupo › Subgrupo) que o componente está listado.
2. Menu do UpMobb → **Agregados** → Grupo › Subgrupo → clicar no módulo.
3. Mira azul sobre o módulo de destino: "Caminhos possíveis n/N" mostra os alvos; setas ↑↓ trocam; clicar insere.
4. Conferir por script onde entrou (caminho até o pai e o `type` dele) e as medidas (gaveta = `conteiner_drawer`). O agregado inserido ganha `upmobb_attributes.keyname` (id na biblioteca).
5. Se entrou no lugar errado: apagar a instância de teste, ajustar grupo/subgrupo (ou o componente) e reenviar.

## Depois

- Registrar na memória do projeto: grupo, subgrupo, keyname e resultado do teste.
- Liberar para os projetistas: skill `upmobb-liberar-modulo` (sai de Desenvolvedor para Básico).
