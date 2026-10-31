# Checklist de conferência antes de entregar um móvel

Rode na ordem. Cada item tem como conferir. Anote o resultado (ok / corrigido / alerta) no resumo da entrega.

## A. Medidas

- [ ] Medidas externas = vão − folgas declaradas. Conferir: `medidas(modulo)` e comparar com a ficha.
- [ ] Nenhuma peça com medida 0, negativa ou absurda. Script: percorrer peças e listar as que têm alguma medida < 3 mm (fora fitas e ferragens) ou > 2750 mm.
- [ ] Nenhuma chapa maior que a chapa comercial (2750 × 1850, ou a do padrão da casa) sem emenda prevista.
- [ ] Cotas de profundidade medidas na chapa, não no contorno do módulo (cabeças de minifix somam ~2 mm).

## B. Construção

- [ ] Espessuras por tipo de peça conforme padrão da casa (caixa, frente, tamponamento, fundo, gaveta).
- [ ] Fundo presente e encaixado (ou fixado) conforme padrão.
- [ ] Frentes com folga entre si e nas bordas; nenhuma frente encostando ou sobrepondo outra.
- [ ] Gavetas: comprimento compatível com a corrediça (nominal − desconto) e a corrediça com a profundidade interna. Gaveta não atravessa a frente nem o fundo.
- [ ] Prateleiras: vão livre dentro do recomendado para a espessura; acima disso, reforço ou 25 mm.
- [ ] Dobradiças em quantidade compatível com a altura/peso da porta.
- [ ] Tamponamentos e testeiras onde há lateral ou topo aparente.

## C. Uso

- [ ] Porta abre 90°+ sem bater em parede, puxador de outro módulo ou eletrodoméstico.
- [ ] Gaveta abre sem bater em puxador de porta vizinha ou em rodapé.
- [ ] Alturas de uso dentro da faixa (bancada, cabideiro, aéreo) — `ergonomia.md`.
- [ ] Tomadas, registros e janelas do ambiente livres ou com recorte previsto.

## D. UpMobb

- [ ] Configurador mostra os valores reais do módulo (sem divergência instância × definição).
- [ ] `console(60)` sem erro novo desde o início da tarefa.
- [ ] Divergências: nada novo em relação ao módulo original da biblioteca.
- [ ] Nenhum grupo seu (cotas, testes) dentro de um módulo.
- [ ] Usinagem: se havia .scx anterior e a usinagem não devia mudar, reexportar e comparar (`scx.ps1 -Comparar`).

## E. Visual

- [ ] Fotos `iso`, `frente`, `direita`, `topo` olhadas uma a uma.
- [ ] Detalhes onde houve mudança, de perto (`alvo:`).
- [ ] Sem face invertida (cinza-azulado), linha sobrando, peça flutuando, frente sumida (camada oculta?), material errado.
- [ ] Se o usuário mandou print com defeito: mesmo ângulo antes e depois.

## F. Alertas que sempre vão para o usuário

- Furo ou cavilha deixando menos de 4 mm de material na face (ex.: cavilha 13 mm em frente de 15 mm).
- Cava ou rasgo deixando menos de 3 mm atrás (ex.: cava 14 mm em porta 15,5 mm).
- Ferragem sem código de ferramenta ou sem cadastro (afeta máquina e compras).
- Qualquer suposição feita sobre medida de obra.

## G. Limpeza

- [ ] Blocos e componentes de teste apagados.
- [ ] Câmera numa vista útil (iso, zoom no móvel).
- [ ] Modelo NÃO salvo sem OK.
