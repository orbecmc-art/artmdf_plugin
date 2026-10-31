---
name: upmobb
description: >-
  Como o UpMobb (plugin de marcenaria do SketchUp usado na Art MDF) funciona por dentro e como trabalhar junto
  com ele sem quebrar orçamento, listas e usinagem. Use sempre que a tarefa envolver módulos, biblioteca,
  Configurador, botão Aplicar, peças, fitas de borda, ferragens, furação, usinagem, divergências ou exportações
  do UpMobb, ou quando o usuário falar "OpenMob", "Up Mob", "Upmob" (é o UpMobb, dito por voz). Consulte antes
  de alterar qualquer módulo do UpMobb por script.
when_to_use: >-
  "módulo da biblioteca", "configurador", "aplicar", "usinagem", "fresagem", "presagem", "cava", "tamponamento",
  "divergências", "itens a comprar", "plano de corte", "openmob", "upmob"
---

# UpMobb: trabalhar junto, não por cima

O UpMobb transforma o SketchUp num sistema de produção: cada módulo da biblioteca é um componente paramétrico que carrega espessura, material, fita por lado, furação por contato, usinagens, ferragens e roteiro. Orçamento, listas, plano de corte e arquivo de máquina saem desses dados.

**Consequência que guia tudo:** geometria que não veio do UpMobb não entra em orçamento, lista nem usinagem. Para produção, sempre parta de módulo da biblioteca e ajuste pelo próprio UpMobb. Geometria "crua" só para ambiente (paredes, vãos), estudo de volume ou detalhe visual combinado com o usuário.

Ambiente verificado em 31/10/2026: SketchUp 2026, UpMobb 2.18.30, Windows, painel web da empresa em `upmobb.com.br/mdfart`.

Scripts no SketchUp passam pela ponte: **SK** = `powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/sk.ps1"` (skill `sketchup-ponte`).

## Mapa rápido

| Conceito | Como é no modelo | Ver |
|---|---|---|
| Módulo | Componente dinâmico com dados de fabricação, formado por conteiners e agregados (prateleiras, divisórias, cabideiros) | `references/modelo-de-dados.md` |
| Configurador | Painel que mostra e altera as opções do módulo (medidas, espessuras, niveladores...). **Lê os valores da DEFINIÇÃO**, não da instância | idem |
| Aplicar | Botão do Configurador; redesenha o módulo. Por Ruby equivale a `apply_config_element` | `references/operacoes.md` |
| Painel de ações | Página HTML dentro do SketchUp que chama o Ruby do UpMobb. Exportações e testes saem daqui | `references/operacoes.md` |
| Verificar divergências | 13 testes: usinagens, materiais, componentes, alertas, elementos inválidos, ocultos, colisões | `references/operacoes.md` |
| Peça | Cada chapa traz medida de corte, código do material, fitas com comprimento e (algumas) roteiro | `references/modelo-de-dados.md` |
| Camadas | Peças nas camadas "UpPeças" (e afins). Frente sumiu? Confira camada oculta antes de mexer | idem |

## Regras de convivência

1. **Descubra antes de mexer.** Num módulo que você ainda não conhece, rode o roteiro de inspeção (`references/inspecao.md`): dicionários de atributos, hierarquia, fórmulas. Registre o que descobrir em `${user_config.pasta_trabalho}/_claude/upmobb-mapa.md` (o UpMobb não documenta nada disso; esse arquivo é o mapa da casa).
2. **Medidas e opções mudam pelo Configurador + Aplicar.** Alterar `lenx` ou escala por fora deixa furação, fita e lista inconsistentes. Se precisar gravar valor por script, grave na **definição** e dispare o redesenho do UpMobb; depois confira no Configurador que o painel mostra o valor certo.
3. **Usinagem é sagrada.** Não acrescente, mova nem remova fresagem, furo ou rebaixo sem pedido explícito. Recorte "visual" (o 3D mostrar o rasgo) é outra coisa e não pode alterar o arquivo da máquina: depois de qualquer mudança perto de usinagem, reexporte o .scx e compare com o anterior.
4. **Biblioteca só com OK.** Correção num projeto fica no projeto. Levar a correção para o módulo da biblioteca é decisão do usuário: pergunte, diga o que muda e faça backup do arquivo da biblioteca antes.
5. **Definição sem instância some.** Um observador do UpMobb apaga definições não usadas. Para estudar um módulo da biblioteca, insira uma instância temporária longe do projeto e apague no fim, ou estude no projeto onde ele já está.
6. **Um móvel por arquivo para exportar.** As exportações valem para o modelo inteiro e a pasta leva o nome do projeto.
7. **Erros no console.** `console(60)` depois de toda operação do UpMobb. Erros do tipo `undefined method ... for nil` nos `.rbe` costumam vir de dado malformado que você deixou (ex.: usinagem incompleta). Desfaça o que fez antes de seguir.
8. **Respeite os termos do UpMobb.** Os termos proíbem engenharia reversa, descompilação e extração automatizada da biblioteca. Não tente abrir, decifrar ou copiar os `.rbe`, nem exportar a biblioteca em massa. Trabalhe com os dados do projeto do cliente (que são dele) e com as mesmas ações que o painel oferece. Quando faltar informação técnica (formato de exportação, API), o caminho é perguntar ao suporte do UpMobb.

## Comportamentos já conhecidos (economizam horas)

- O Configurador mostrava "Niveladores: Não" com pés no modelo: valores tinham sido gravados só na instância. Gravar na definição resolveu.
- Corrediça HARDT não tem o atributo `reduceforbody` que a gaveta procura (tem `reduce_for_lengths = 1`). Sintoma: gaveta não acompanha a profundidade. Corrigido no projeto do criado-mudo; o módulo "Criado 2 Gavetas Cava" da biblioteca ainda tinha o problema em 31/10/2026.
- Filho que precisa redesenhar o pai ao "Aplicar": atributo `parentrefresh = 1` (o UpMobb usa em dobradiças e direcionais).
- Fresagem que o exportador descarta: a marca `pointinsert` precisa estar no caminho da fresagem.
- MessageBox do UpMobb ao fim de exportação ("abrir o local do arquivo?") fica esperando e bloqueia a próxima exportação. Responda com `janelas.ps1`.
- O painel de ações às vezes fecha sozinho ou trava em "Carregando..." (quase sempre por uma MessageBox pendente). Reabra antes de exportar.
- Plano de corte (.json) e Lista de Compras exigem "Detalhes do projeto" preenchidos (Meu código, Projetista, Cliente, Descrição). A usinagem (.scx) não exige. Esses dados são do cliente: peça ao usuário, não invente.
- Frente de 15 mm com cavilha de 13 mm de profundidade deixa 2,5 mm de face. Sempre alerte.
- Grupo criado por você sem atributos do UpMobb (ex.: grupo de cotas) aparece como "elemento inválido" no verificador. Deixe cotas na raiz do modelo.
- Fita de borda costuma ser componente compartilhado por várias peças: torne única antes de alterar uma só.

Mais detalhes e evidências: `references/conhecimento-validado.md`.

## Vocabulário (o usuário fala por voz)

"OpenMob", "Up Mob", "GitHub Mob" = UpMobb · "presagem" = fresagem · "cava" = puxador cava/usinado · "tamponamento" = laterais e tampo externos que cobrem a caixa · "pega" = puxador · "ponteira" = acabamento de ponta do perfil · "Aplicar" = botão do Configurador.

## Referências

- `references/modelo-de-dados.md`: como módulo, peças, atributos e fórmulas se organizam.
- `references/inspecao.md`: scripts prontos, só de leitura, para mapear um módulo ou o projeto inteiro.
- `references/operacoes.md`: inserir, configurar, aplicar, divergências e exportações, passo a passo.
- `references/conhecimento-validado.md`: tudo que já foi testado na Art MDF, com data e evidência.
- `${user_config.pasta_trabalho}/_claude/upmobb-mapa.md`: o mapa vivo da casa (leia se existir).
