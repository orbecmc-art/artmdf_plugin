# UpMobb pela tela

Verificado em: 31/10/2026 (UpMobb 2.18.30) · Volatilidade: média
Origem: sessões reais na Art MDF e site do UpMobb. **[visto]** = observado nas sessões; **[confirmar]** = descrever melhor na primeira vez e registrar em aprendizados.

O painel do UpMobb é uma página web dentro do SketchUp (Chromium). A automação de acessibilidade do Windows não lê o conteúdo dele: leia por captura de tela (controle do computador) ou `janelas.ps1 -Capturar <arquivo.png> -Janela "UpMobb"` + Read [visto].

## Painel e Configurador

- Selecionar o módulo no modelo faz o Configurador mostrar as opções dele: Comprimento, Profundidade, Altura, Espessura Caixa, Espessura Frente, Niveladores e outras do módulo [visto].
- Mudar um valor: clicar no campo, apagar, digitar (unidade do campo: confira se é cm ou mm), e clicar **Aplicar**. O redesenho pode levar alguns segundos [visto].
- Depois do Aplicar: captura do painel (o valor ficou?) e do modelo (a peça mudou?). Se o painel mostrar valor diferente do modelo, o valor está gravado só na instância (skill `upmobb`).
- Se o painel travar em "Carregando...", quase sempre há uma MessageBox pendente: `janelas.ps1 -ProcessoId <PID>` [visto].
- Painel fechado: reabra pelo menu Extensões > UpMobb ou pela barra de ferramentas do UpMobb [confirmar].

## Biblioteca e inserção [confirmar o passo a passo]

- Abas da biblioteca: Construir (montar por etapas), Ambientes (modulação pronta), Personalizado (biblioteca da empresa) [público].
- Escolher o módulo, clicar no modelo para posicionar, depois ajustar pelo Configurador.
- Posicionar com precisão: depois de inserir, Mover (M) a partir de um canto, travando o eixo, e digitar a distância na caixa Medidas.

## Verificar divergências [visto]

- No painel de ações: "Verificar divergências" mostra os testes (usinagens, materiais, componentes, alertas, elementos inválidos, ocultos, colisões).
- Disparar todos e ler o resultado por captura. Comparar com o módulo original antes de chamar algo de defeito (skill `upmobb`).

## Exportações [visto]

| O quê | Caminho no painel | Depois |
|---|---|---|
| Usinagem (.scx) | painel de ações > exportação de usinagem | MessageBox "abrir local do arquivo?": responder (normalmente "Não") |
| Plano de corte (.json) | painel de ações > plano de corte | exige Detalhes do projeto |
| Itens a comprar | Exportação > Exportar listagens > Itens a comprar > "Todo o projeto" > Exportar | lista de "elementos sem cadastro", se houver |

Uma exportação por vez: a MessageBox de uma bloqueia a próxima.

## Detalhes do projeto [visto]

Formulário com Meu código, Projetista, Cliente e Descrição. Exigido pelo plano de corte e pela lista de compras. Preencha **só** com dados que o usuário informou nesta conversa; nunca invente.

## Conferência depois de qualquer ação no painel

1. Captura do painel e do modelo.
2. Se a ponte estiver ativa: `SK console` para erros do UpMobb.
3. Arquivo exportado: conferir data/hora e conteúdo com `scx.ps1`.
