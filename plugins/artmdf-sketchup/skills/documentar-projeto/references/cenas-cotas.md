# Cenas, cotas e fotos · receitas Ruby

Todos os blocos rodam pela ponte (`SK rodar arquivo.rb`). Medidas em mm. Confira assinaturas novas na Ruby API (https://ruby.sketchup.com) antes de usar algo que não está aqui.

## Achar o móvel e a caixa dele

```ruby
movel = sel.first || m.entities.grep(Sketchup::ComponentInstance).max_by { |i| i.bounds.diagonal }
bb = movel.bounds   # no espaço do modelo (o móvel está na raiz)
{ 'movel' => movel, 'caixa' => bb }
```

## Criar cena com câmera ajustada

Desde o SketchUp 2026, mudar câmera e estilo de cena entra no desfazer: faça dentro de `operacao`.

```ruby
camera_para = lambda do |bb, direcao, up, perspectiva|
  centro = bb.center
  v = Geom::Vector3d.new(*direcao); v.length = bb.diagonal * 2
  cam = Sketchup::Camera.new(centro.offset(v), centro, Geom::Vector3d.new(*up))
  cam.perspective = perspectiva
  cam
end   # use lambda, não def: métodos definidos num script ficariam para os próximos

movel = sel.first or raise 'Selecione o móvel'
bb = movel.bounds
vistas = [
  ['01 Perspectiva', [-1, -1, 0.8], [0, 0, 1], true],
  ['02 Frontal',     [0, -1, 0],    [0, 0, 1], false],
  ['03 Lateral',     [1, 0, 0],     [0, 0, 1], false],
  ['04 Superior',    [0, 0, 1],     [0, 1, 0], false]
]
operacao('Criar cenas do projeto') do
  vistas.each do |nome, dir, up, persp|
    m.pages.erase(m.pages[nome]) if m.pages[nome]
    m.active_view.camera = camera_para.call(bb, dir, up, persp)
    m.active_view.zoom(movel)
    pag = m.pages.add(nome)
    pag.use_camera = true
  end
end
m.pages.map(&:name)
```

Ao fotografar uma cena, aplique a câmera **sem animação**: `ir_para_cena('02 Frontal')` e depois `foto(...)`. Selecionar a cena pela interface anima a transição e a foto sai torta.

## Cotas lineares na raiz, camada "Cotas"

```ruby
movel = sel.first or raise 'Selecione o móvel'
bb = movel.bounds
camada_cotas = camada('Cotas')
x0, y0, z0 = bb.min.x, bb.min.y, bb.min.z
x1, z1 = bb.max.x, bb.max.z
operacao('Cotas principais') do
  largura = m.entities.add_dimension_linear(Geom::Point3d.new(x0, y0, z1), Geom::Point3d.new(x1, y0, z1), Geom::Vector3d.new(0, 0, mm(80)))
  altura  = m.entities.add_dimension_linear(Geom::Point3d.new(x1, y0, z0), Geom::Point3d.new(x1, y0, z1), Geom::Vector3d.new(mm(80), 0, 0))
  [largura, altura].each { |c| c.layer = camada_cotas }
end
'cotas criadas'
```

- O offset (3º argumento) é um vetor: direção e distância da linha de cota em relação aos pontos.
- Profundidade: cote na lateral, entre a frente da chapa e o fundo, não no contorno do módulo.
- Cota no espaço do modelo, nunca dentro do componente do móvel.
- Unidade das cotas segue as opções do modelo (`m.options['UnitsOptions']`). Mudar para mm altera o arquivo: pergunte antes.

## Visibilidade da camada "Cotas" por cena

```ruby
cotas = m.layers['Cotas']
operacao('Cotas só nas vistas técnicas') do
  m.pages.each do |p|
    p.set_visibility(cotas, p.name !~ /Perspectiva/) if p.respond_to?(:set_visibility)
  end
end
```

## Foto para o cliente sem camadas técnicas

```ruby
tecnicas = m.layers.select { |l| l.name =~ /Cotas|Usinag|Fresa/i && l.visible? }
begin
  tecnicas.each { |l| l.visible = false }
  foto('cliente_perspectiva', vista: :iso, alvo: sel.first, largura: 2400, altura: 1600)
ensure
  tecnicas.each { |l| l.visible = true }
end
```

Ocultar e mostrar camada marca o modelo como alterado, mesmo voltando ao estado anterior. Avise o usuário se ele estranhar o "não salvo".

## Lista de peças (estrutura do JSON devolvido)

```ruby
pecas = []
percorrer(sel.first.definition.entities, sel.first.transformation) do |e, t, caminho|
  next unless e.definition.entities.grep(Sketchup::Face).size >= 6  # chapa tem geometria própria
  md = medidas(e)
  pecas << { 'nome' => (e.name.empty? ? e.definition.name : e.name),
             'medidas' => [md['x'], md['y'], md['z']].sort.reverse,   # comprimento, largura, espessura
             'material' => (e.material && e.material.display_name),
             'caminho' => caminho.map { |c| c.name.empty? ? c.definition.name : c.name }.join(' > ') }
end
pecas.group_by { |p| [p['nome'], p['medidas'], p['material']] }.map { |k, v| { 'peca' => k[0], 'medidas_mm' => k[1], 'material' => k[2], 'qtd' => v.size } }
```

O filtro por geometria é genérico. Prefira os atributos de peça do UpMobb (medida de corte, código do material, fitas): são eles que a fábrica usa. Ajuste o filtro com o mapa da casa (`_claude/upmobb-mapa.md`).
