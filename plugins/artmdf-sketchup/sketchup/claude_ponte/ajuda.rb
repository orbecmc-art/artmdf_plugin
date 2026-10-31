# encoding: UTF-8
# Métodos de ajuda disponíveis em todo script enviado pela ponte.
# Convenção: tudo que entra e sai em medidas é MILÍMETRO. Por dentro, o SketchUp usa polegada.
# Referência completa: skills/sketchup-ponte/references/ajuda-ponte.md

require 'fileutils'

module OrbeClaude
  module Ponte
    module Ajuda
      DC = 'dynamic_attributes'.freeze
      IDENT = Geom::Transformation.new

      # ---------- atalhos ----------

      def m
        Sketchup.active_model
      end

      def ents
        m.active_entities
      end

      def sel
        m.selection
      end

      # mm(500) => Length de 500 mm (para passar à API)
      def mm(valor)
        valor.to_f.mm
      end

      # em_mm(length) => número em mm (para ler da API)
      def em_mm(comprimento)
        comprimento.to_f.to_mm.round(3)
      end

      def ponto(x, y, z)
        Geom::Point3d.new(mm(x), mm(y), mm(z))
      end

      # ---------- operação com desfazer ----------

      # Tudo dentro do bloco vira UM passo de desfazer (Ctrl+Z).
      # Se der erro no meio, desfaz o que foi feito e repassa o erro.
      def operacao(nome)
        m.start_operation(nome, true)
        resultado = yield
        m.commit_operation
        resultado
      rescue Exception
        m.abort_operation
        raise
      end

      # ---------- leitura do modelo ----------

      def info_modelo
        unidades = (m.options['UnitsOptions']['LengthUnit'] rescue nil)
        {
          'titulo' => m.title,
          'caminho' => m.path,
          'modificado' => m.modified?,
          'unidade' => { 0 => 'polegada', 1 => 'pé', 2 => 'mm', 3 => 'cm', 4 => 'm' }[unidades] || unidades,
          'definicoes' => m.definitions.size,
          'materiais' => m.materials.size,
          'camadas' => m.layers.map(&:name),
          'selecao' => sel.map { |e| Serializar.entidade(e) },
          'raiz' => m.entities.grep(Sketchup::ComponentInstance).map { |i| resumo(i) } +
                    m.entities.grep(Sketchup::Group).map { |g| resumo(g) }
        }
      end

      def resumo(inst)
        Serializar.entidade(inst).merge('medidas_mm' => medidas(inst), 'oculto' => inst.hidden?)
      end

      # Escala real de cada eixo de uma transformação.
      # Cuidado: transformation.xaxis vem NORMALIZADO (sem escala). E escala uniforme
      # pode estar guardada no 16º termo da matriz (w). Este método trata as duas coisas.
      def escalas(transformacao)
        a = transformacao.to_a
        w = a[15].to_f.zero? ? 1.0 : a[15].to_f
        [
          Geom::Vector3d.new(a[0], a[1], a[2]).length.to_f / w,
          Geom::Vector3d.new(a[4], a[5], a[6]).length.to_f / w,
          Geom::Vector3d.new(a[8], a[9], a[10]).length.to_f / w
        ]
      end

      # Medidas reais (definição × escala) nos eixos locais da peça, em mm.
      def medidas(inst)
        bb = inst.definition.bounds
        sx, sy, sz = escalas(inst.transformation)
        {
          'x' => (bb.width.to_f * sx).to_mm.round(3),
          'y' => (bb.height.to_f * sy).to_mm.round(3),
          'z' => (bb.depth.to_f * sz).to_mm.round(3),
          'escala' => [sx, sy, sz].map { |s| s.round(5) }
        }
      end

      # Percorre grupos e componentes aninhados.
      # Bloco recebe: entidade, transformação acumulada (mundo, já com a da peça),
      # caminho (lista de pais + a peça) e a transformação acumulada do PAI (para foto/caixa_mundo).
      def percorrer(entidades = m.entities, tr = IDENT, caminho = [], &bloco)
        entidades.each do |e|
          next unless e.is_a?(Sketchup::ComponentInstance) || e.is_a?(Sketchup::Group)
          t = tr * e.transformation
          novo = caminho + [e]
          yield e, t, novo, tr
          percorrer(e.definition.entities, t, novo, &bloco)
        end
        nil
      end

      # Caixa no espaço do mundo de uma peça aninhada (passe a transformação acumulada do pai).
      def caixa_mundo(inst, tr_pai = IDENT)
        bb = Geom::BoundingBox.new
        t = tr_pai * inst.transformation
        inst.definition.bounds.tap do |b|
          8.times { |i| bb.add(b.corner(i).transform(t)) }
        end
        bb
      end

      # Procura instâncias por nome, nome da definição ou atributo.
      #   achar(nome: /lateral/i)
      #   achar(definicao: 'Criado 2 Gavetas Cava')
      #   achar(atributo: ['dynamic_attributes', 'lenx'])
      def achar(nome: nil, definicao: nil, atributo: nil, raiz: m.entities)
        achados = []
        percorrer(raiz) do |e, t, caminho, tr_pai|
          ok = true
          ok &&= casa?(e.name, nome) if nome
          ok &&= casa?(e.definition.name, definicao) if definicao
          if atributo
            dic, chave = atributo
            ok &&= !(e.get_attribute(dic, chave) || e.definition.get_attribute(dic, chave)).nil?
          end
          if ok
            achados << { 'ent' => e, 'tr' => t, 'tr_pai' => tr_pai,
                         'caminho' => caminho.map { |c| c.name.empty? ? c.definition.name : c.name } }
          end
        end
        achados
      end

      def casa?(texto, padrao)
        padrao.is_a?(Regexp) ? !!(texto.to_s =~ padrao) : texto.to_s == padrao.to_s
      end

      # Todos os atributos de uma instância e da definição dela.
      def atributos(ent, dicionario = nil)
        ler = lambda do |alvo|
          (alvo.attribute_dictionaries || []).each_with_object({}) do |d, h|
            next if dicionario && d.name != dicionario
            h[d.name] = {}.tap { |x| d.each_pair { |k, v| x[k] = v } }
          end
        end
        dados = { 'instancia' => ler.call(ent) }
        dados['definicao'] = ler.call(ent.definition) if ent.respond_to?(:definition)
        dados
      end

      # ---------- componentes dinâmicos ----------
      # Medidas de DC (lenx, leny, lenz) ficam guardadas em POLEGADA, como número.
      # O Configurador do UpMobb lê da DEFINIÇÃO. Grave na definição.

      def dc(ent)
        defn = ent.respond_to?(:definition) ? (ent.definition.attribute_dictionary(DC) || {}).to_h : {}
        inst = (ent.attribute_dictionary(DC) || {}).to_h
        defn.merge(inst)
      end

      def dc_definir(ent, chave, valor, formula: nil, rotulo: nil, unidades: nil, alvo: :definicao)
        destino = alvo == :instancia ? ent : ent.definition
        valor = valor.to_f if valor.is_a?(Length) # nunca gravar Length: quebra o redesenho
        destino.set_attribute(DC, chave, valor)
        destino.set_attribute(DC, "_#{chave}_formula", formula) if formula
        destino.set_attribute(DC, "_#{chave}_label", rotulo || chave) if rotulo || formula
        destino.set_attribute(DC, "_#{chave}_units", unidades) if unidades
        dc(ent)[chave]
      end

      # Redesenho pelo mecanismo padrão de componentes dinâmicos.
      # Em módulos UpMobb prefira o "Aplicar" do Configurador (ver skill upmobb).
      def dc_redesenhar(inst)
        raise 'Componentes dinâmicos indisponíveis neste SketchUp' unless defined?($dc_observers) && $dc_observers
        $dc_observers.get_latest_class.redraw_with_undo(inst)
        true
      end

      # ---------- criação simples (estudos e ambiente) ----------
      # Produção vai pelos módulos do UpMobb. Isto aqui é para paredes, volumes e testes.

      def camada(nome)
        m.layers[nome] || m.layers.add(nome)
      end

      def material(nome, cor = nil)
        mat = m.materials[nome] || m.materials.add(nome)
        mat.color = Sketchup::Color.new(*cor) if cor
        mat
      end

      # Caixa sólida x × y × z mm, canto em `origem` (mm), como componente nomeado.
      # Uma chapa é uma caixa em que uma das medidas é a espessura.
      def bloco(nome, x:, y:, z:, origem: [0, 0, 0], em: ents, material: nil, camada: nil)
        defn = m.definitions.add(nome)
        pts = [ponto(0, 0, 0), ponto(x, 0, 0), ponto(x, y, 0), ponto(0, y, 0)]
        face = defn.entities.add_face(pts)
        face.reverse! if face.normal.z < 0
        face.pushpull(mm(z))
        inst = em.add_instance(defn, Geom::Transformation.translation(ponto(*origem)))
        inst.name = nome
        inst.material = material.is_a?(String) ? self.material(material) : material if material
        inst.layer = camada.is_a?(String) ? self.camada(camada) : camada if camada
        inst
      end

      # Parede reta para levantar o ambiente. direcao: :x ou :y. Fica na camada "Ambiente".
      def parede(nome, comprimento:, altura:, espessura: 150, origem: [0, 0, 0], direcao: :x, em: ents)
        x, y = direcao == :x ? [comprimento, espessura] : [espessura, comprimento]
        bloco(nome, x: x, y: y, z: altura, origem: origem, em: em, camada: 'Ambiente', material: material('Parede', [235, 235, 235]))
      end

      # ---------- imagem para conferir ----------

      VISTAS = {
        iso:      [[-1, -1, 0.8], [0, 0, 1], true],
        frente:   [[0, -1, 0],    [0, 0, 1], false],
        tras:     [[0, 1, 0],     [0, 0, 1], false],
        direita:  [[1, 0, 0],     [0, 0, 1], false],
        esquerda: [[-1, 0, 0],    [0, 0, 1], false],
        topo:     [[0, 0, 1],     [0, 1, 0], false],
        baixo:    [[0, 0, -1],    [0, 1, 0], false]
      }.freeze

      # Gera PNG da vista e devolve o caminho. Não altera o modelo: a câmera volta para onde estava.
      # Para fundo branco no PDF use transparente: true (não mexe nas opções de estilo).
      # Não usa transição de cena (a câmera é trocada direto), então nada sai "no meio da animação".
      #   foto('porta_frente', vista: :frente, alvo: inst)
      #   foto('geral') # vista atual
      def foto(nome, vista: :atual, alvo: nil, tr_alvo: IDENT, largura: 1600, altura: 1000,
               transparente: false, pasta: nil, margem: 1.0)
        v = m.active_view
        cam = v.camera
        antes = [cam.eye, cam.target, cam.up, cam.perspective?, (cam.perspective? ? cam.fov : cam.height)]
        unless vista == :atual
          bb = alvo ? caixa_mundo(alvo, tr_alvo) : m.bounds
          dir, up, persp = VISTAS.fetch(vista.to_sym)
          centro = bb.center
          dist = [bb.diagonal.to_f * 2.0, 1.0].max
          vetor = Geom::Vector3d.new(*dir)
          vetor.length = dist
          nova = Sketchup::Camera.new(centro.offset(vetor), centro, Geom::Vector3d.new(*up))
          nova.perspective = persp
          trocar_camera(v, nova)
          if alvo
            nova.height = bb.diagonal.to_f * margem * 1.15 unless persp
            trocar_camera(v, nova)
            v.zoom(alvo) if persp && tr_alvo == IDENT
          else
            v.zoom_extents
          end
        end

        destino = pasta || File.join(FOTOS, Time.now.strftime('%Y-%m-%d'))
        FileUtils.mkdir_p(destino)
        arquivo = File.join(destino, "#{nome}.png")
        ok = v.write_image(filename: arquivo, width: largura, height: altura, antialias: true, transparent: transparente)
        raise "write_image falhou: #{arquivo}" unless ok
        arquivo
      ensure
        if antes
          volta = Sketchup::Camera.new(antes[0], antes[1], antes[2])
          volta.perspective = antes[3]
          antes[3] ? (volta.fov = antes[4]) : (volta.height = antes[4])
          trocar_camera(v, volta)
        end
      end

      # Aplica a câmera de uma cena sem animação (selecionar a cena anima e estraga a foto).
      def ir_para_cena(nome)
        pagina = m.pages[nome]
        raise "Cena não encontrada: #{nome}" unless pagina
        trocar_camera(m.active_view, pagina.camera)
        pagina
      end

      # Troca a câmera sem animação de transição.
      def trocar_camera(view, camera)
        view.send(:camera=, camera, 0)
      rescue ArgumentError
        view.camera = camera
      end

      # ---------- arquivos e segurança ----------

      # Copia o .skp que está NO DISCO (versão salva) para uma pasta de backups ao lado.
      def backup_disco(pasta = nil)
        origem = m.path
        raise 'Este modelo ainda não foi salvo em disco.' if origem.to_s.empty?
        pasta ||= File.join(File.dirname(origem), '_backups')
        FileUtils.mkdir_p(pasta)
        destino = File.join(pasta, "#{File.basename(origem, '.skp')} #{Time.now.strftime('%Y-%m-%d %H%M%S')}.skp")
        FileUtils.cp(origem, destino)
        destino
      end

      # Salva uma CÓPIA do estado atual (com alterações não salvas) sem mudar o arquivo aberto.
      def copia_do_estado_atual(caminho)
        FileUtils.mkdir_p(File.dirname(caminho))
        m.save_copy(caminho) ? caminho : raise("save_copy falhou: #{caminho}")
      end

      # Dispara o salvar fora do script. Neste ambiente o UpMobb abre "Salvar como":
      # o script termina e o diálogo é tratado por scripts/janelas.ps1. Só com OK do usuário.
      def agendar_salvar
        # Timer que abre janela modal pode disparar de novo enquanto ela está aberta: para na 1ª vez.
        id = UI.start_timer(0.2, false) do
          UI.stop_timer(id)
          Sketchup.active_model.save
        end
        'salvar agendado: trate o diálogo com janelas.ps1'
      end

      # ---------- investigação de plugins (UpMobb é criptografado) ----------

      # Onde está definido um método? procurar_metodo(/apply_config/)
      def procurar_metodo(padrao, limite: 60)
        achados = []
        ObjectSpace.each_object(Module) do |mod|
          nome_mod = (mod.name rescue nil)
          next if nome_mod.nil? || nome_mod.start_with?('OrbeClaude')
          (mod.instance_methods(false) + mod.private_instance_methods(false)).each do |met|
            achados << "#{nome_mod}##{met}" if met.to_s =~ padrao
          end
          mod.singleton_methods(false).each do |met|
            achados << "#{nome_mod}.#{met}" if met.to_s =~ padrao
          end
          break if achados.size >= limite
        end
        achados.uniq.sort
      end

      # Últimas linhas do Console Ruby (precisa do espelho ligado).
      def console(linhas = 60)
        Espelho.descarregar
        return [] unless File.exist?(CONSOLE)
        File.readlines(CONSOLE, encoding: 'utf-8').last(linhas).map(&:chomp)
      end
    end
  end
end
