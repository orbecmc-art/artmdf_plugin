# Componentes dinâmicos (DC) por Ruby

Verificado em: 31/10/2026 · Volatilidade: baixa no SketchUp, média no UpMobb (que envolve o mecanismo de DC)
Fontes: ajuda do SketchUp sobre atributos predefinidos de DC; fórum de desenvolvedores SketchUp; testes na Art MDF (31/10/2026).

O mecanismo de componentes dinâmicos não tem API Ruby oficial e documentada. O que segue é o uso estável e conhecido, mais o que foi testado aqui. Os módulos do UpMobb são DC e o UpMobb **envolve** o redesenho: em módulo UpMobb, o caminho seguro é o Aplicar do Configurador.

## Onde ficam os dados

- Dicionário `dynamic_attributes`, na **definição** (padrões e fórmulas) e na **instância** (valores alterados nela).
- Leitura correta: instância primeiro, definição se não houver. O helper `dc(ent)` já mescla assim.
- **O Configurador do UpMobb lê da definição.** Gravando só na instância, o painel mostra valor velho e ignora mudança.

## Chaves de uma opção `x` (ex.: `lenx`, `esptamp`)

| Chave | Conteúdo |
|---|---|
| `x` | valor atual. Medidas em **polegada**, como número (Float). Nunca grave Length |
| `_x_formula` | fórmula, **sem "="** no começo (ex.: `Parent!LenX-2*esp`) |
| `_x_label` | nome da opção |
| `_x_formlabel` | rótulo mostrado no formulário de opções |
| `_x_access` | `NONE` (oculto), `VIEW` (só leitura), `TEXTBOX` (digitável), `LIST` (lista) |
| `_x_options` | lista para `LIST`, formato `&rotulo=valor&rotulo2=valor2&` (com codificação de URL: espaço vira `%20`) |
| `_x_units` | unidade de exibição (ex.: `CENTIMETERS`, `MILLIMETERS`, `INCHES`, `STRING`, `INTEGER`, `FLOAT`) |
| `_x_formulaunits` | unidade em que a fórmula é avaliada |
| `_x_nominal`, `_last_x` | usados no redimensionamento (vistos nos componentes do UpMobb) |

Medidas próprias da peça: `lenx`, `leny`, `lenz` (tamanho), `x`, `y`, `z` (posição), `rotx`, `roty`, `rotz`, `hidden`, `material`, `copies`, `name`.

**Antes de criar uma opção nova, copie o conjunto de chaves de uma opção do mesmo módulo que já aparece no Configurador.** É o jeito mais rápido de acertar formato, unidade e acesso.

## Fórmulas que ligam peças

- Do pai: `Parent!lenx`, `Parent!esptamp`.
- De um irmão ou filho pelo nome do componente: `NomeDoComponente!lenx`.
- Da própria peça: só o nome (`reduce_for_lengths`).
- Funções comuns: `IF(cond, a, b)`, `ROUND`, `MAX`, `MIN`, operações aritméticas. Unidades de comprimento nas fórmulas seguem `_x_formulaunits`.

## Redesenho

- Fórmulas são reavaliadas no redesenho. O redesenho padrão por Ruby: `$dc_observers.get_latest_class.redraw_with_undo(inst)` (helper `dc_redesenhar`). Não é API oficial: use quando não houver Aplicar do UpMobb e confira medindo.
- **Um filho só é redimensionado quando o PAI é redesenhado**, e só se o valor calculado mudou em relação ao último registrado (`_last_lenx`). Redesenhar só o filho não faz nada.
- Filho que deve forçar o redesenho do pai no Aplicar do UpMobb: `parentrefresh = 1`.
- Para escalar, o componente precisa do conjunto de chaves de redimensionamento (fórmula, unidades, acesso, nominal) **nas três medidas**. Copie de um componente do UpMobb que já redimensiona.

## Armadilhas (todas já aconteceram)

| Sintoma | Causa | Solução |
|---|---|---|
| `comparison of Length with nil` no redesenho | valor gravado como Length | regravar como número (`valor.to_f`) |
| Configurador mostra valor errado | valor na instância, painel lê a definição | gravar na definição e limpar a instância |
| Fórmula calcula certo, peça não escala | faltam chaves de redimensionamento, ou só o filho foi redesenhado | copiar chaves de componente que funciona; redesenhar o pai |
| "Não escala" mas escalou | leitura da escala por `transformation.xaxis` (normalizado) | medir com `medidas(inst)` |
| Valor passado ao Aplicar entra 10× menor/maior | unidade do campo (cm) × valor em mm | passar na unidade do campo e conferir |
| Peça "presa" numa medida antiga ao trocar ferragem | fórmula referencia atributo que a peça nova não tem | criar o atributo ligado ao equivalente (receita R4 da skill personalizar-modulo) |
| Alterar uma fita muda outras 5 | definição compartilhada | `inst.make_unique` antes |
