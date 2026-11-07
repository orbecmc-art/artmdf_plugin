---
name: upmobb-exportar-otimizador
description: >-
  Exportar um projeto do SketchUp (UpMobb) para o Otimizador de produção em app.upmobb.net: JSON, lote, vínculo de materiais, otimização e etiquetas.
when_to_use: >-
  "exporta para o otimizador", "manda para o otimizador", "gera o lote de produção", "plano de corte no otimizador", "gera a etiqueta da peça"
---

# UpMobb: exportar projeto para o Otimizador

Quando o usuário disser "exportar para o otimizador", "mandar para o otimizador", "gerar lote de produção" ou "gerar etiqueta" de um projeto do SketchUp, este é o fluxo. O "otimizador" é o módulo Produção > Otimização do app.upmobb.net (plano de corte, lista de peças e etiquetas). A etiqueta é só uma das saídas; o objetivo principal é o projeto chegar otimizado no lote.

## Resultado esperado
1. Detalhes do projeto salvos no plugin UpMobb (SketchUp).
2. `<projeto>.json` exportado ("Todos da cena", com usinagens) em `Documentos/upmobb/<projeto>/` no OneDrive.
3. Lote criado no Otimizador com esse JSON importado e materiais vinculados.
4. Otimização concluída (status "Finalizado"), com plano de corte disponível.
5. Se pedido: etiqueta de uma peça aberta e entregue como imagem.

## Passos

### 1. Detalhes do projeto + exportação (SketchUp — único trecho com computer-use)
O plugin não tem API. Se o JSON já existe e está atualizado (passo 2) e o modelo não mudou, pule.
- Janela UpMobb > Home > **Detalhes do projeto**: Meu código, Projetista, Cliente, Descrição do projeto, Adicionais. Pergunte os valores se não foram dados (na demonstração, "teste" em tudo). **Salvar**.
- Menu **Exportação** > "Exportar para outros sistemas" > UpMobb > Como exportar: **Todos da cena**, **Incluir usinagens** ligado > **Aplicar**. Esperar o "Carregando..." sumir.

### 2. Localizar o JSON (shell no computador do usuário)
`Documentos/upmobb/<projeto>/<projeto>.json` (OneDrive). Confirme data de modificação recente. Use o caminho direto no upload; não precisa copiar/colar pelo Explorer.

### 3. Criar lote (Chrome MCP)
Carregue as ferramentas Claude in Chrome numa única ToolSearch, comece por tabs_context_mcp e use aba nova. O usuário já costuma estar logado; nunca digite senha — se pedir login, peça ao usuário.
- `https://app.upmobb.net/production_optimizer.html` > botão **+** > "Nome/Codigo Lote" (ex.: "teste painel"), Referência de importação **UpMobb 3D** > **Criar Lote** (URL vira `production_optimizer_batch.html?batch=<id>`).

### 4. Importar o JSON e vincular materiais
- No lote, ícone de adicionar peças > **Dados do projeto** (JSON gerado pelo sistema 3D) > upload do arquivo (file_upload do Chrome MCP; fallback: diálogo "Abrir" digitando o caminho).
- "Vinculo de materiais": para cada material do SketchUp, pesquise e escolha o equivalente do UpMobb (ex.: "branco tx" > BRANCO TX 15MM; a espessura deve bater). Pergunte se houver vários materiais ou dúvida. **Avançar**.
- Confira a tabela Listagem (ex.: 25 peças, bordas, acabamento, cliente = valor digitado).

### 5. Otimizar
Disparar a otimização no lote (status laranja "Em Processo"). Um erro transitório "Ocorreu um erro com a sua requisição" pode aparecer; aguarde e verifique o status. Concluiu quando o botão fica verde **Finalizado** e o material mostra "N pç / N chapa".

### 6. Saídas (conforme o pedido)
- **Plano de corte**: ícone de grade ao lado do material.
- **Etiqueta**: no plano de corte, botão direito na peça > **Etiqueta** (modal "Etiqueta de peça": material, cliente, descrição, módulo, peça, fita de borda, medidas, código e QR). Para só visualizar, não clique em Imprimir. Capture só a área da etiqueta (screenshot recortado via Chrome MCP, em vez de Win+Shift+S), salve como PNG e entregue; confira se os campos batem com o passo 1.
- Também disponíveis na barra do lote: imprimir etiquetas, exportar peça, relatórios.

## Observações
- O lote fica na conta real da empresa: avise que um lote foi criado; só exclua se o usuário pedir.
- Na demonstração, o material "Mdf 15.5 3000k" ficou sem vínculo; só o BRANCO TX foi vinculado. Pergunte quando houver mais de um.