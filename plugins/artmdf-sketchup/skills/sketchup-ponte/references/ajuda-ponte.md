# Métodos de ajuda da ponte

Disponíveis em todo script enviado com `SK rodar`/`SK eval`. Código: `sketchup/claude_ponte/ajuda.rb`.
Convenção: entra mm, sai mm. Por dentro o SketchUp usa polegada.

## Sumário
Atalhos · Desfazer · Leitura · Componentes dinâmicos · Criação simples · Fotos · Arquivos · Investigação · Memória entre scripts · Valor devolvido

## Atalhos

| Método | Retorna |
|---|---|
| `m` | `Sketchup.active_model` |
| `ents` | entidades do contexto ativo (se o usuário está editando um componente, é o de dentro) |
| `sel` | seleção atual |
| `mm(500)` | Length de 500 mm, para passar à API |
| `em_mm(length)` | número em mm, para ler da API |
| `ponto(x, y, z)` | `Geom::Point3d` a partir de mm |

## Desfazer

```ruby
operacao('Ajustar prateleira') do
  # alterações aqui
end
```
Um passo de Ctrl+Z com o nome dado. Erro no meio = desfaz tudo e o erro volta no resultado.

## Leitura

| Método | O que faz |
|---|---|
| `info_modelo` | título, caminho, alterado?, unidade, camadas, seleção, peças da raiz com medidas |
| `resumo(inst)` | dados da instância + medidas + oculto? |
| `medidas(inst)` | `{'x','y','z','escala'}` em mm nos eixos locais da peça (definição × escala real) |
| `escalas(transformacao)` | escala real de cada eixo (trata eixo normalizado e o termo w da matriz) |
| `percorrer(entidades, tr, caminho) { \|e, tr_mundo, caminho, tr_pai\| }` | visita grupos e componentes em todos os níveis (tr_mundo já inclui a peça; tr_pai é a do pai) |
| `caixa_mundo(inst, tr_pai)` | BoundingBox no espaço do modelo de uma peça aninhada |
| `achar(nome:, definicao:, atributo:, raiz:)` | lista de `{'ent','tr','tr_pai','caminho'}`; `nome`/`definicao` aceitam texto exato ou Regexp; `atributo: ['dicionario','chave']` |
| `atributos(ent, dicionario = nil)` | `{'instancia' => {...}, 'definicao' => {...}}` |
| `console(60)` | últimas linhas do Console Ruby |

Exemplo: todas as laterais com medidas e caminho.
```ruby
achar(nome: /lateral/i).map { |a| { 'caminho' => a['caminho'].join(' > '), 'medidas' => medidas(a['ent']) } }
```

## Componentes dinâmicos

| Método | O que faz |
|---|---|
| `dc(ent)` | atributos `dynamic_attributes` da definição mesclados com os da instância |
| `dc_definir(ent, chave, valor, formula:, rotulo:, unidades:, alvo: :definicao)` | grava valor numérico (nunca Length) e, se dados, fórmula/rótulo/unidade; padrão na **definição** |
| `dc_redesenhar(inst)` | redesenho padrão de componente dinâmico (em módulo UpMobb, prefira o Aplicar) |

Detalhes e armadilhas: `componentes-dinamicos.md`.

## Criação simples (ambiente e estudo, não produção)

| Método | O que faz |
|---|---|
| `camada(nome)` | acha ou cria a camada (tag) |
| `material(nome, [r, g, b])` | acha ou cria material |
| `bloco(nome, x:, y:, z:, origem: [x, y, z], em:, material:, camada:)` | caixa sólida x × y × z mm como componente nomeado (uma chapa é um bloco em que uma medida é a espessura) |
| `parede(nome, comprimento:, altura:, espessura: 150, origem:, direcao: :x)` | parede na camada "Ambiente" |

Peça criada assim **não tem dados do UpMobb**: não entra em lista, orçamento nem usinagem.

## Fotos

```ruby
foto('nome')                                     # vista atual
foto('frente', vista: :frente)                   # :iso :frente :tras :direita :esquerda :topo :baixo
foto('porta', vista: :frente, alvo: inst)        # enquadra a peça (peça da raiz)
foto('lateral_dentro', vista: :direita, alvo: a['ent'], tr_alvo: a['tr_pai'])   # peça aninhada: passe a transformação do pai
foto('cliente', vista: :iso, largura: 2400, altura: 1600, transparente: true, pasta: 'C:/.../imagens')
ir_para_cena('02 Frontal')                       # câmera da cena SEM animação; depois foto('...')
```
Devolve o caminho do PNG. Abra com Read. A câmera volta ao lugar depois. Padrão de pasta: `%LOCALAPPDATA%\ClaudePonte\fotos\<data>\`.

Para peça aninhada, `tr_alvo` é a transformação acumulada **do pai** (de `percorrer`, o caminho até o pai). Na dúvida, fotografe o módulo inteiro com `alvo: modulo`.

## Arquivos

| Método | O que faz |
|---|---|
| `backup_disco(pasta = nil)` | copia o .skp **salvo em disco** para `_backups\` ao lado, com data e hora |
| `copia_do_estado_atual(caminho)` | salva uma cópia do estado atual (com o que não foi salvo) sem trocar o arquivo aberto |
| `agendar_salvar` | dispara o salvar depois que o script termina (o diálogo é tratado com `janelas.ps1`); só com OK do usuário |

## Investigação

| Método | O que faz |
|---|---|
| `procurar_metodo(/padrao/)` | nomes de métodos carregados que casam com o padrão (ex.: achar o ponto de entrada que o painel do UpMobb usa). Não serve para ler código criptografado e não deve ser usado para isso |

## Memória entre scripts

`memoria[:chave] = valor` guarda até fechar o SketchUp (útil para guardar referência de entidade entre etapas). Variáveis locais e métodos não passam de um script para outro. Não use `def` no script (ficaria definido para os próximos): use `lambda`.

## Valor devolvido

A última expressão do script é o `valor`. Conversões automáticas:
- Length e coordenadas de pontos → mm;
- entidades → `{'tipo','id','pid','nome','definicao','camada'...}`;
- BoundingBox → `{'larg_x_mm','prof_y_mm','alt_z_mm','min','max'}`;
- listas grandes cortadas em 500 itens.

Devolva hashes pequenos e objetivos. Para muita informação, `puts` em linhas ou grave um arquivo e devolva o caminho.
