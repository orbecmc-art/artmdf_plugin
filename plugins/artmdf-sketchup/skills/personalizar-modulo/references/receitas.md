# Receitas testadas · personalizar módulo

Cada receita traz: quando usar, passos, como provar, armadilhas, origem. Receita só entra aqui depois de funcionar num projeto real. Novas chegam pela skill evoluir-plugin.

Atenção: fórmulas de componente dinâmico ficam gravadas **sem o "="** inicial (ex.: `_lenx_formula` = `Parent!LenX-2*esp`). Valores de medida ficam em **polegada**, como número. Detalhes: `skills/sketchup-ponte/references/componentes-dinamicos.md`.

---

## R1 · Opção nova no Configurador que passa valor às peças

**Quando:** o usuário quer escolher algo que o Configurador não oferece (ex.: "Espessura Tamponamento" 15/18/25).
**Origem:** criado-mudo, 31/10/2026. Funcionou pelo Aplicar.

1. Ache uma opção parecida que **já aparece** no Configurador (ex.: "Espessura Frente"). Leia todos os atributos dela na definição do módulo: o valor e todas as chaves `_<nome>_*` (rótulo, rótulo de formulário, acesso, opções, unidades).
2. Crie a opção nova na **definição** do módulo copiando exatamente o mesmo conjunto de chaves, trocando nome, rótulo e lista de opções. Valor padrão numérico = o valor atual do móvel (no caso, 18).
3. Nas peças que devem obedecer (laterais de tamponamento, tampo), troque o valor fixo pela fórmula que lê o pai (`Parent!<nome>`), seguindo o mesmo jeito que essas peças já leem a espessura da frente ou da caixa.
4. Se a mesma opção existir só na instância, mova para a definição e limpe a instância.
5. Reselecione o módulo e confira se o Configurador mostra o campo novo com o valor certo.

**Provar:** Aplicar 25 → medir peças e largura externa → Aplicar de volta 18 → medir. Resultado de referência: 15 → 495 × 615,5; 18 → 501 × 618,5; 25 → 515 × 625,5 (opção nominal 15/18/25, chapa real 15,5/18,5/25,5). Fita e código do MDF acompanharam sozinhos.
**Armadilha:** gravar só na instância faz o Configurador mostrar valor velho e ignorar mudanças.

---

## R2 · Recorte visual no 3D que acompanha uma medida

**Quando:** o usuário quer ver no 3D o rasgo/encaixe que a máquina vai fazer (o UpMobb não recorta a chapa no 3D), e o recorte precisa seguir uma medida (ex.: "Altura da pega").
**Origem:** porta com perfil RM416, 31/10/2026. Testado com 800 e 1000 mm.

1. **Medir a forma real** do encaixe a partir da geometria da peça que vai encaixar (contorno da ponteira aberta, perfil). Leia os vértices em ordem; não espelhe um lado (a ponteira era assimétrica em 0,84 mm).
2. **Cortadores 2D** colados nas faces que precisam abrir (frente da chapa, borda inferior da chapa, fita de borda inferior): componente com comportamento de colar e "cortar abertura", eixo Z apontando para dentro da face. Funciona encostado na borda e com eixo invertido.
3. **Paredes e fundo do rasgo:** geometria visual com o contorno, faces voltadas para dentro do rasgo (face invertida aparece cinza-azulado), fundo em MDF cru, ponta escondida sob a ponteira fechada.
4. **Fita de borda compartilhada:** torne única a fita da peça (`make_unique`) antes de pôr o cortador nela; senão o corte aparece nas outras peças iguais.
5. **Dinâmico:** ligue o comprimento dos cortadores à medida de origem por fórmula; copie de um componente do UpMobb que redimensiona (ex.: "Puxador Cava RM416") as chaves de unidade, acesso, nominal e comportamento; fórmula nas três medidas; valores numéricos.
6. **Redesenho:** no componente de origem (ex.: "Recorte Cava RM416") ponha `parentrefresh = 1` para o Aplicar redesenhar a porta. O dinâmico só escala filho quando o PAI é redesenhado e só se o valor mudou.
7. **Acabamento:** a ponta visível usa o mesmo material do perfil, ligado por fórmula (muda junto se o acabamento mudar).
8. **Arestas:** oculte linhas de emenda e as arestas próprias dos cortadores que cruzam a boca do rasgo.

**Provar:** Aplicar 800 → parte reta termina onde começa a ponteira fechada (790,91 no caso) → Aplicar 1000 → idem → .scx reexportado igual ao original (uma fresagem em U por peça).
**Armadilhas:**
- `transformation.xaxis` vem normalizado: medir escala pela medida real (`medidas(inst)`), não pelo eixo. Esse erro de leitura fez parecer que não escalava.
- Escala extrema (fita esticada ~13,6× na espessura) faz o SketchUp fundir pontos próximos: linha branca fina na boca. Pule pontos rasos ao desenhar o cortador da fita.
- Dois cortadores encostando na mesma aresta podem conflitar; teste cada um isolado.
**Limites conhecidos:** cava na posição inferior; deslocamento lateral da pega (mx) não acompanha no cortador da fita.

---

## R3 · Filho que precisa redesenhar o pai

**Quando:** mudar um valor num componente interno (pela fórmula ou pelo Aplicar) deveria refazer a peça mãe e ela não muda.
**Origem:** RM416. `parentrefresh = 1` no filho (padrão que o UpMobb usa em dobradiças e direcionais).
**Provar:** mudar o valor, Aplicar, medir a peça mãe.

---

## R4 · Atributo que a fórmula procura e não existe

**Quando:** uma peça não acompanha medida porque a fórmula referencia um atributo ausente no componente vizinho (troca de ferragem por modelo de outro fornecedor).
**Origem:** criado-mudo, gaveta presa em 440 mm com corrediça HARDT.

1. Siga a cadeia de fórmulas da peça que não acompanha até achar a referência sem valor.
2. Veja no componente novo se há atributo equivalente (no caso `reduce_for_lengths = 1` ≈ `reduceforbody`).
3. Crie o atributo que falta **ligado** ao equivalente (fórmula), não com valor fixo.
4. Redesenhe e meça (corrediça 350, gaveta 340 no caso).
**Depois:** avise que o módulo da biblioteca tem o mesmo problema e ofereça corrigir lá.

---

## R5 · Ocultar linhas de fresa e emendas no visual

**Quando:** o usuário quer o 3D limpo para mostrar ao cliente.
**Origem:** RM416.

1. Oculte (não apague) as arestas do percurso da fresa e as emendas: o UpMobb usa essa geometria para exportar.
2. Antes de editar uma definição, veja se ela é compartilhada (`definition.count_used_instances`); se for e a mudança deve valer só aqui, torne única.
3. Reexporte o .scx e confirme que saiu igual.

---

## R6 · Fita de acabamento no fundo do perfil, na cor da face (em validação)

**Quando:** perfil de puxador com canal no fundo (RM416: ~44,8 × 1,4 mm, ~38,7 mm visíveis) deve mostrar fita na cor da face da porta, mudando sozinha quando a face mudar.
**Estado:** feito em sessão paralela em 31/10/2026; resultado não consolidado aqui. Ao repetir: modele a fita dentro do canal, ligue o material ao da face da porta por fórmula, ligue o comprimento à altura da pega, e confira onde o UpMobb define o material de cada face (o painel tem a escolha de face e material). Registre o resultado em aprendizados para virar receita definitiva.
