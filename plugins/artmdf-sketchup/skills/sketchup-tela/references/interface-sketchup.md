# Interface do SketchUp para operar pela tela

Verificado em: 31/10/2026 · Volatilidade: média (nomes mudam com versão e idioma)
Marcação: **[padrão]** padrão de fábrica do SketchUp em inglês, a tradução pode variar; **[confirmar]** conferir na máquina da Art MDF e registrar o nome exato em aprendizados.

## Menus [confirmar nomes em português]

| Menu | Uso principal |
|---|---|
| Arquivo | Salvar, Salvar como, Exportar (Gráfico 2D, Animação) |
| Editar | Desfazer, Refazer, Tornar único, Ocultar/Mostrar |
| Exibir (Visualizar) | Arestas ocultas, Eixos, Barras de ferramentas |
| Câmera | Vistas padrão (Superior, Frente, Direita, Fundo, Esquerda, Iso), Projeção paralela, Perspectiva, Zoom extensões |
| Janela | Bandeja padrão (Informações da entidade, Estrutura/Outliner, Componentes, Materiais, Tags, Cenas), Preferências |
| Extensões | UpMobb, Claude Ponte, Developer/Desenvolvedor > Ruby Console |

## Atalhos [padrão; conferir em Janela > Preferências > Atalhos]

| Tecla | Ferramenta |
|---|---|
| Espaço | Selecionar |
| L | Linha |
| R | Retângulo |
| P | Empurrar/Puxar |
| M | Mover (Ctrl alterna cópia) |
| Q | Girar |
| S | Escala |
| F | Equidistância (Offset) |
| T | Fita métrica |
| E | Borracha |
| B | Balde de tinta |
| O / H / Z | Orbitar / Mão (Pan) / Zoom |
| Shift+Z | Zoom extensões |
| G | Criar componente |
| Ctrl+Z / Ctrl+Y | Desfazer / Refazer |
| Esc | Cancelar a ferramenta; sair de dentro de grupo/componente |

Se o usuário tem atalhos próprios, eles valem: pergunte uma vez e registre.

## Caixa Medidas (VCB)

- Fica no canto inferior direito. Não precisa clicar nela: depois de iniciar a ferramenta, só digite e tecle Enter.
- Separador decimal segue o Windows: em português, **vírgula** (`18,5`). Separador de lista: **ponto e vírgula** (`500;400`).
- Sempre com unidade: `500mm;400mm`, `18,5mm`. Sem unidade, vale a unidade do modelo (pode ser cm).
- Retângulo: clique o primeiro canto, digite `L;C` e Enter. Empurrar/Puxar: clique a face, digite a distância, Enter. Mover: escolha o ponto base, indique a direção com o mouse travado no eixo (setas: → X vermelho, ← Y verde, ↑ Z azul), digite a distância, Enter.
- Logo após a operação, digitar de novo corrige o último valor.

## Seleção e hierarquia

- Duplo clique entra no grupo/componente; Esc sai. Peças do UpMobb ficam vários níveis abaixo do módulo.
- Janela > Estrutura (Outliner) mostra a árvore com nomes: o jeito mais seguro de achar uma peça sem clicar no lugar errado.
- Botão direito na peça: Tornar único, Opções de componente (componente dinâmico), Ocultar. **Não use Explodir em peça do UpMobb.**
- Informações da entidade: nome da instância, definição, tag (camada). Para medida, use Fita métrica ou o Configurador do UpMobb.

## Vistas para conferir

- Câmera > Vistas padrão > Frente / Direita / Superior / Iso, depois Zoom extensões (Shift+Z).
- Câmera > Projeção paralela para conferir alinhamento e medidas; volte para Perspectiva para apresentação.
- Para ver dentro do móvel: Exibir > Raio X (ou ocultar portas pela Estrutura e mostrar de novo no fim).

## Diálogos comuns

| Diálogo | O que fazer |
|---|---|
| "Salvar alterações?" ao fechar ou abrir outro arquivo | Não fechar nem abrir arquivo sem OK; se aparecer, pergunte ao usuário |
| "Salvar como" | Conferir pasta e nome; Salvar; "Substituir" só com OK |
| Aviso de extensão não identificada | Decisão do usuário: mostre o texto e pergunte |
| MessageBox do UpMobb | Ler o texto; informativo → responder; com consequência → perguntar |
