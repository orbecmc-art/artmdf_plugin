# UpMobb · roteiro de inspeção (somente leitura)

Use num módulo ou projeto que você ainda não conhece. Nada aqui altera o modelo. Rode cada bloco como arquivo com `SK rodar`.

## 1. Quais dicionários existem no projeto

```ruby
contagem = Hash.new(0)
percorrer do |e, _t, _c|
  [e, e.definition].each { |o| (o.attribute_dictionaries || []).each { |d| contagem[d.name] += 1 } }
end
modelo = (m.attribute_dictionaries || []).map(&:name)
{ 'dicionarios_em_pecas' => contagem.sort_by { |_, n| -n }.to_h, 'dicionarios_do_modelo' => modelo }
```

## 2. Árvore de um módulo (selecione o módulo no SketchUp antes)

```ruby
raiz = sel.first or raise 'Selecione um módulo'
linhas = []
arvore = lambda do |inst, nivel|
  md = medidas(inst)
  nome = inst.name.empty? ? inst.definition.name : "#{inst.name} <#{inst.definition.name}>"
  linhas << ('  ' * nivel) + "#{nome} · #{md['x']} × #{md['y']} × #{md['z']} mm · camada #{inst.layer.name}#{inst.hidden? ? ' · OCULTO' : ''}"
  inst.definition.entities.each do |f|
    arvore.call(f, nivel + 1) if (f.is_a?(Sketchup::ComponentInstance) || f.is_a?(Sketchup::Group)) && nivel < 6
  end
end
arvore.call(raiz, 0)
puts linhas.join("\n")
linhas.size
```

## 3. Atributos de uma peça (instância + definição)

```ruby
alvo = sel.first or raise 'Selecione uma peça (entre no componente e selecione)'
atributos(alvo)
```

Para uma peça dentro de módulo sem precisar selecionar:

```ruby
achado = achar(nome: /lateral/i).first or raise 'não achei'
{ 'caminho' => achado['caminho'], 'atributos' => atributos(achado['ent']) }
```

## 4. Opções do Configurador (componente dinâmico)

```ruby
alvo = sel.first or raise 'Selecione o módulo'
dados = dc(alvo)
opcoes = dados.keys.reject { |k| k.start_with?('_') }.sort
opcoes.map do |k|
  { 'opcao' => k, 'valor' => dados[k], 'rotulo' => dados["_#{k}_label"], 'formula' => dados["_#{k}_formula"],
    'acesso' => dados["_#{k}_access"], 'unidade' => dados["_#{k}_units"] }
end
```

Diferenças entre instância e definição (causa clássica do Configurador mostrar valor errado):

```ruby
alvo = sel.first
inst = (alvo.attribute_dictionary('dynamic_attributes') || {}).to_h
defn = (alvo.definition.attribute_dictionary('dynamic_attributes') || {}).to_h
inst.keys.reject { |k| k.start_with?('_') }.select { |k| defn[k] != inst[k] }.map { |k| [k, 'inst', inst[k], 'def', defn[k]] }
```

## 5. Comparar com um módulo que funciona

Quando algo do UpMobb não se comporta (não redimensiona, não redesenha, sai da usinagem), compare atributo a atributo com uma peça do próprio UpMobb que faz a mesma coisa direito:

```ruby
a = achar(nome: /Puxador Cava RM416/).first['ent']   # referência que funciona
b = achar(nome: /recorte_frente/).first['ent']       # a sua
da = dc(a); db = dc(b)
faltam = da.keys - db.keys
{ 'faltam_na_sua' => faltam.sort, 'valores_diferentes' => (da.keys & db.keys).select { |k| da[k] != db[k] }.first(40) }
```

## 6. Extensões carregadas

```ruby
Sketchup.extensions.map { |x| [x.name, x.version, x.creator, x.loaded?] }
```

## Depois de inspecionar

Registre em `_claude/upmobb-mapa.md` da pasta de trabalho (caminho completo na skill upmobb): nome do dicionário, chave, o que significa, em que tipo de peça aparece, data. Um parágrafo por descoberta. Ex.:

```
## parentrefresh (dynamic_attributes) · 31/10/2026
Em filhos (dobradiças, direcionais). 1 = o "Aplicar" redesenha o pai. Visto no RM416: sem ele, o recorte não acompanhava a altura da pega.
```
