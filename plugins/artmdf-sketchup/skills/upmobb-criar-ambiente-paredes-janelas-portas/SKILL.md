---
name: upmobb-criar-ambiente-paredes-janelas-portas
description: >-
  Criar um ambiente novo no SketchUp com UpMobb: preencher detalhes do projeto, desenhar paredes no Construtor, inserir janelas e portas e posicionar hidráulica, elétrica e gás.
when_to_use: >-
  "começa o ambiente", "desenha as paredes", "cria o ambiente no upmobb", "coloca janela e porta", "marca os pontos de água, luz e gás", "construtor de paredes"
---

# Criar ambiente no UpMobb (paredes, janelas, portas e hidráulica)

Use quando o usuário (MDF Arte Design) pedir para começar um projeto/ambiente novo no SketchUp com o plugin UpMobb: preencher o projeto, construir as paredes, posicionar janelas e portas e marcar os pontos de hidráulica, elétrica e gás. Este fluxo só existe na interface do SketchUp/UpMobb: faça pela tela (skill `sketchup-tela`) e use a ponte (`sketchup-ponte`) só para conferir medidas no fim.

## 0. Insumos que o usuário envia
O usuário normalmente manda o **projeto em PDF**, as **medidas do ambiente** e a **foto** do local. Leia o PDF e a foto para extrair: nome do cliente, ambiente, comprimento de cada parede, pé direito, posição e tamanho de janelas e portas, e posição dos pontos de água, gás e elétrica. Monte a **tabela de cotas** da skill `modelar-movel` (cada medida com a origem: escrita no projeto, estimada ou a perguntar) e mostre ao usuário antes de desenhar. Foto sem cota não define medida. Pergunte apenas o que não estiver nesses materiais. No fim, confira cada parede, abertura e ponto contra a tabela.

## 1. Detalhes do projeto
1. No SketchUp, abra o painel UpMobb (ícone UpMobb na barra; menu lateral > Início / ícone de menu).
2. No cartão "Detalhes do projeto" clique em **Editar**.
3. Preencha: **Meu código** (ex.: alaor), **Projetista** (ex.: Alaor Jr), **Cliente** (ex.: Paulo) e **Descrição do projeto** (é o ambiente, ex.: cozinha). Os campos mostram sugestões de valores usados antes; pode escolher ou digitar.
4. Clique em **Salvar** (aguarde o spinner terminar) e depois em **Fechar**.

## 2. Desenhar as paredes
1. No UpMobb, abra **Construtor** (ícone de árvore/hierarquia na barra lateral) e escolha **Desenhando** ("Vamos iniciar: Desenhando").
2. Opção de desenhar paredes (ícone de parede, primeiro da barra lateral do Construtor). Preencha:
   - **Altura da parede (mm)**: pé direito (padrão visto: 2500,00; ajuste ao pedido, ex.: 2700).
   - **Espessura da parede (mm)**: 150,00.
   - **Elevação (mm)**: 0,00 (sempre zero = no chão).
   - **Alinhamento**: Parede à Esquerda.
   - Deixe desligados por enquanto: Unir parede, Criar piso, Criar teto, Bloquear paredes (podem ser revistos depois).
3. Role até o fim e clique em **iniciar desenho**.
4. A ferramenta de parede fica ativa: clique na origem (ponto de partida) e arraste na direção do eixo; digite o comprimento no campo **Comprimento(mm)** da barra de medidas e pressione Enter (ex.: 3000). Repita para cada parede (exemplo da aula: 3000, 5000, 3000 formando um "U").
5. Para sair da ferramenta pressione Esc / selecione a ferramenta de seleção. Se errar, pressione Ctrl+Z ou selecione a parede e Delete e reinicie com **iniciar desenho**.

## 3. Janelas e portas (referência)
1. No UpMobb: **Construtor > Decoração > Janelas e Portas**.
2. Clique na janela desejada (ex.: Janela 3 folhas) e clique na cena para inserir. Ela entra já selecionada na ferramenta Mover: clique para pegar, mova pela parede e clique para soltar (ou digite a distância).
3. Ajuste altura do peitoril, largura e tamanho da janela conforme o projeto.
4. Repita com a porta (porta1, Porta2, portas 1): insira, posicione na parede, ajuste largura/altura.
5. Se o ambiente não tiver porta, crie apenas o **vão** (abertura na parede) em vez de inserir porta.

## 4. Hidráulica, elétrica e gás
Os pontos técnicos vêm da biblioteca do UpMobb:
1. Vá em **Construtor > Decoração > Hidraulica Eletrica Gás**.
2. Itens disponíveis: **ponto de água**, **ponto de fogo**, **registro de água**, **quadro elétrico**, **registro de gás** e vários tipos de **tomadas**.
3. Clique no item para mandá-lo para a cena (ele aparece na cena automaticamente) e posicione-o na parede/altura conforme o projeto em PDF, usando a ferramenta Mover.
4. **Tomadas**: não precisa se preocupar com o tipo; use qualquer uma. Elas servem apenas para dimensionar onde a tomada ficará.
5. Insira cada ponto que constar no projeto (água, gás, fogo, registros, quadro elétrico, tomadas).

## Observações
- Outros itens de Decoração (eletrônicos, itens de banheiro, mesas etc.) não são necessários para montar o ambiente base; só use se o pedido exigir.
- Componentes baixados do menu Decoração não entram nos quantitativos nem nos orçamentos; servem só para composição visual e referência de medidas.
- Confira ao final a vista 3D (paredes fechando, janela, porta e pontos técnicos na posição correta) com uma captura de tela antes de entregar.
- Os valores exatos digitados na gravação (medidas, posições) não foram capturados; use o PDF/foto do usuário ou pergunte quando faltar informação.
- Esta skill é atualizada aos poucos conforme o usuário ensina novas etapas do projeto.