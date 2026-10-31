---
name: documentar-projeto
description: >-
  Produz a documentação de um móvel modelado no SketchUp — cenas (perspectiva, frontal, lateral, superior),
  cotas, imagens e vídeo curto para apresentar ao cliente final e o projeto executivo em PDF com vistas cotadas,
  lista de peças, chapas e fitas, ferragens, usinagem, montagem e pendências, além de CSV para Excel. Use quando
  o usuário pedir para mostrar o móvel ao cliente, gerar imagens, criar cenas, cotar, montar o projeto
  executivo, PDF do projeto ou lista de peças em planilha.
when_to_use: >-
  "mostra pro cliente", "gera as imagens", "faz um vídeo do móvel", "cria as cenas", "coloca as cotas", "projeto
  executivo", "pdf do projeto", "lista de peças", "manda o pdf"
---

# Documentar o projeto

Duas audiências, dois produtos:
- **Cliente final:** imagens bonitas e claras (perspectiva, frente, detalhe), sem linhas de fresa nem cotas poluindo.
- **Fábrica / montagem:** projeto executivo com vistas cotadas, lista de peças, ferragens, usinagem e montagem.

Depende de: `sketchup-ponte` (scripts e fotos), `upmobb` (dados das peças). Sem ponte: cenas, vistas e exportação de imagem pela tela (`sketchup-tela`), e o PDF montado com o que der para ler do modelo.

**SK** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/sk.ps1"` (cliente da ponte; detalhes na skill `sketchup-ponte`).

## 1. Preparar o modelo

1. `SK status`. Trabalhe no arquivo do móvel.
2. Antes de criar cenas e cotas, confirme com o usuário que pode alterar o arquivo (cenas e cotas mudam o modelo; salvar continua exigindo OK).
3. Cotas ficam na **raiz** do modelo, na camada "Cotas". Nunca dentro de módulo (o UpMobb acusa elemento inválido).

Receitas de cena, cota e foto: `references/cenas-cotas.md`.

## 2. Cenas

Padrão: `01 Perspectiva`, `02 Frontal`, `03 Lateral`, `04 Superior`, mais detalhes se pedidos (`05 Detalhe cava`). Vistas técnicas em projeção paralela; perspectiva em perspectiva. Câmera ajustada no móvel com margem.

## 3. Cotas

Mínimo: largura, altura e profundidade externas; alturas de vãos internos e frentes na vista frontal. Meça as chapas, não o contorno do módulo (cabeça de minifix soma 2 mm). Confira cada cota contra `medidas()`.

## 4. Imagens

- Cliente: `foto('cliente_perspectiva', vista: :iso, largura: 2400, altura: 1600)` com camadas técnicas (cotas, linhas de fresa) ocultas só durante a foto, ou cena específica sem cotas.
- Técnicas: cada cena com fundo transparente (`transparente: true`) para entrar na página branca do PDF.
- Olhe cada imagem com Read antes de usar. Câmera torta, corte no enquadramento ou peça sumida: refaça.

Salve as imagens do projeto em `${user_config.pasta_trabalho}/Projeto <Nome>/imagens/`.

**Imagem de apresentação não é projeto de fabricação.** Toda imagem ou vídeo para o cliente final sai identificado como ilustrativo (no nome do arquivo, ex.: `cliente_perspectiva_ilustrativa.png`, e na mensagem de envio): cor de tela, textura e iluminação variam do material real, e medida final vale a do projeto executivo aprovado.

**Vídeo de apresentação** (passeio curto em volta do móvel): receita em `references/video-apresentacao.md`, ainda **em validação**. Na primeira vez, avise o usuário que é um teste e registre o resultado em aprendizados.

## 5. Dados das peças

Script de leitura que percorre o móvel e devolve, por peça: nome, medidas de corte (do atributo do UpMobb quando existir; senão a geometria), espessura, material, fitas por lado, roteiro. Agrupe peças iguais. Totalize área de chapa por material e metros de fita por largura. Os nomes exatos dos atributos do UpMobb estão em `${user_config.pasta_trabalho}/_claude/upmobb-mapa.md` (ou descubra com o roteiro de inspeção da skill `upmobb`).

Ferragens: conte no modelo e confira com a usinagem (.scx) quando houver (minifix = furos Ø15, etc.).

## 6. Projeto executivo (PDF)

Monte um HTML com o modelo `references/modelo-executivo.html` (já paginado para A4) e gere o PDF:

```
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/pdf.ps1" -Html "<pasta>/projeto.html"
```

Conteúdo (5 páginas é o normal):
1. Visão geral: perspectiva, ficha (cliente se informado, medidas externas, materiais, puxador, ferragens principais, nº de peças).
2. Vistas cotadas: frontal em destaque; lateral e superior.
3. Lista de peças (agrupada) + chapas e fitas totais.
4. Ferragens + usinagem (resumo do .scx, se exportado).
5. Montagem e pendências/alertas (Detalhes do projeto faltando, furos rasos, suposições).

Abra o PDF gerado (Read) e confira página por página: título isolado no fim da página, tabela partida, imagem vazia ou pequena demais = refaça o layout.

## 7. CSV para Excel

Lista de peças em CSV com separador `;` e UTF-8 com BOM (o Excel em português abre direto). Escreva com PowerShell (`Export-Csv -Delimiter ';' -Encoding UTF8`) ou, se gravar pelo Ruby no Windows, em modo binário (`'wb'`) para não sair linha em branco entre linhas.

## 8. Entregar

Caminhos dos arquivos, o que contém cada um, alertas. Pergunte se quer salvar o modelo (cenas e cotas ficaram nele).

## Aprender

Registre o que o usuário pediu para mudar no layout ou nas imagens em `${user_config.pasta_trabalho}/_claude/aprendizados.md`: vira o padrão de documentação da casa.
