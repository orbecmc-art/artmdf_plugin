# UpMobb · modelo de dados no SketchUp

Verificado em: 31/10/2026 · Volatilidade: média (muda com versão do UpMobb) · Fonte: sessões reais na Art MDF + upmobb.tech

O UpMobb não publica esquema. O que está aqui foi observado em projetos reais da Art MDF ou está em fonte pública. Marcação: **[visto]** observado no modelo; **[público]** documentado pelo UpMobb; **[provável]** inferência ainda não confirmada.

## Hierarquia

```
Módulo (ComponentInstance, componente dinâmico)          [visto]
 ├─ conteiners (caixa, gaveteiro...)                       [público]
 │   ├─ peças (chapas): lateral, base, tampo, fundo...    [visto]
 │   │   ├─ fita de borda (componente, muitas vezes compartilhado) [visto]
 │   │   └─ usinagens / furos (componentes com dados de fresa)     [visto]
 │   └─ agregados: prateleiras, divisórias, cabideiros    [público]
 ├─ frentes: portas, frentes de gaveta                     [visto]
 ├─ ferragens: dobradiças, corrediças, minifix, cavilhas, sapatas [visto]
 └─ tamponamentos (laterais e tampo externos)             [visto]
```

Peças ficam em camadas próprias ("UpPeças" e afins) [visto]. Se algo "sumiu" no 3D, cheque camada oculta antes de qualquer outra hipótese.

## Atributos

1. **`dynamic_attributes`** (padrão do SketchUp para componentes dinâmicos) [visto]
   - Valores padrão e fórmulas na **definição**; valores mudados ficam na **instância** [público, SketchUp].
   - O **Configurador do UpMobb lê da definição** [visto]. Por isso, ao gravar por script, grave na definição.
   - Medidas (`lenx`, `leny`, `lenz`) guardadas em **polegada**, como número [público, SketchUp].
   - Fórmulas: `_lenx_formula`; rótulos e unidades: `_lenx_label`, `_lenx_units`, `_lenx_formulaunits`, `_lenx_access`, `_lenx_nominal`, `_last_lenx`; comportamento: `_has_movetool_behaviors` [visto].
2. **Dados de fabricação do UpMobb** [visto, nomes exatos variam por peça]
   - Medida de corte, código do material (casa com Insumos do painel web), fitas por lado com comprimento, roteiro de produção (nem toda peça tem: no criado-mudo só laterais, base e réguas da cava tinham).
   - `parentrefresh` (1 = ao Aplicar, redesenha o pai), `reduceforbody` / `reduce_for_lengths` (desconto de corpo em corrediças), `pointinsert` (marca de inserção de fresagem).
3. **Dados do projeto** [visto]: "Detalhes do projeto" (Meu código, Projetista, Cliente, Descrição) ficam no modelo e são exigidos pelo plano de corte e pela lista de compras. Espessura padrão e MDF do projeto também (ex.: 15,5 e MDF).

Para descobrir os nomes exatos num projeto, use `inspecao.md` e registre em `_claude/upmobb-mapa.md`.

## Usinagem

- Furação aplicada **por contato** entre peças e recalculada quando a medida muda [público]. Mover peça "por fora" muda furação.
- Fresagem ponto a ponto existe como componente com caminho (ex.: "Recorte Cava RM416" com caminho em U) [visto].
- Na exportação, o UpMobb monta um índice de fresagens; as que ele julga "não aplicadas" à peça ficam de fora [visto]. Teste "usinagens não aplicadas" do verificador mostra isso.
- O UpMobb **não recorta a geometria 3D** pela usinagem: o 3D mostra a chapa inteira com perfil e caminho de fresa. O recorte é só no arquivo da máquina [visto]. Mostrar o rasgo no 3D exige cortador visual (skill personalizar-modulo).

## Saídas

| Saída | Formato | Exige Detalhes do projeto | Onde |
|---|---|---|---|
| Usinagem para máquinas | `.scx` (XML: painéis, contorno, furações; fresagens `Type="3"`; peças sem furação não entram) | não | `<pasta exportação>\<projeto>\usinagens\<projeto>.scx` |
| Plano de corte | `.json` (medidas, fitas, roteiro) | sim | pasta configurada no UpMobb ("ARQUIVOS GERADOS P PLANO DE CORTE" na Art MDF) |
| Itens a comprar / Lista de compras | lista; itens sem cadastro aparecem como `CODIGO - Descrição` | sim | diálogo do UpMobb |
| Orçamento Calcme | `.json` (não editar à mão) | — | [público] |
| ERP / CNC | XML, CSV, DXF, G-code, 15 pós-processadores | — | [público] |

## Peças e espessuras usadas na Art MDF (31/10/2026)

- Caixa e gavetas: MDF 15,5 mm. Frentes, tampo e tamponamento: 18,5 mm (opção 15/18/25 criada no criado-mudo).
- Fitas: 19×0,45 (15 mm), 22×0,45 (18 mm), 35×0,45 (25 mm).
- Material de face: `BRANCO_TX` (verso MDF cru). Acabamento de perfil: `CHAMPAGNE_ALTE`.
- Corrediça oculta HARDT soft-closing (350 mm no criado de 400 de profundidade).

Valores da casa mudam: a fonte de verdade é `_claude/padrao-da-casa.md` (skill modelar-movel).
