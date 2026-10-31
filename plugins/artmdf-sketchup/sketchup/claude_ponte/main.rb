# encoding: UTF-8
# Claude Ponte · núcleo
#
# Como funciona:
#   %LOCALAPPDATA%\ClaudePonte\instancias\<PID>\
#     entrada\<id>.rb        o cliente (sk.ps1) grava o script aqui
#     processando\<id>.rb    a ponte move para cá enquanto executa
#     saida\<id>.json        resultado: ok, valor, saída de texto, erro, duração
#     status.json            batimento a cada 2 s (título, caminho, ocupado...)
#     console.log            últimas linhas do Console Ruby (se o espelho estiver ligado)
#
# Um SketchUp = um processo = uma pasta. Dois SketchUp abertos não se misturam.
# Tudo roda na thread principal do SketchUp, por um UI.start_timer. Nada de rede.

require 'json'
require 'stringio'
require 'fileutils'

module OrbeClaude
  module Ponte
    # A versão oficial fica no loader claude_ponte.rb. Se a ponte foi carregada direto pelo
    # Console Ruby (sem o loader), lê a versão do arquivo do loader ao lado.
    CARREGADA_PELO_CONSOLE = !const_defined?(:VERSAO) unless const_defined?(:CARREGADA_PELO_CONSOLE)
    unless const_defined?(:VERSAO)
      loader = File.join(File.dirname(__dir__.to_s), 'claude_ponte.rb')
      lida = File.exist?(loader) ? File.read(loader, encoding: 'utf-8')[/VERSAO\s*=\s*'([^']+)'/, 1] : nil
      VERSAO = (lida || '?').freeze
    end
    BASE_LOCAL = begin
      base = (ENV['LOCALAPPDATA'] || File.join(Dir.home, 'AppData', 'Local')).dup
      base = begin
        base.encode('UTF-8')
      rescue EncodingError
        base.force_encoding('UTF-8')
      end
      base.tr('\\', '/')
    end
    RAIZ      = File.join(BASE_LOCAL, 'ClaudePonte').freeze
    PID       = Process.pid
    PASTA     = File.join(RAIZ, 'instancias', PID.to_s).freeze
    ENTRADA   = File.join(PASTA, 'entrada').freeze
    PROCESSO  = File.join(PASTA, 'processando').freeze
    SAIDA     = File.join(PASTA, 'saida').freeze
    STATUS    = File.join(PASTA, 'status.json').freeze
    CONSOLE   = File.join(PASTA, 'console.log').freeze
    CONFIG    = File.join(RAIZ, 'config.json').freeze
    FOTOS     = File.join(RAIZ, 'fotos').freeze
    LIMITE_SAIDA_TEXTO = 200_000

    # ||= : carregar de novo (load pelo Console Ruby) não perde os timers já ativos,
    # e iniciar() para os antigos antes de criar novos.
    @ocupado     = false
    @pausado   ||= false
    @job_atual   = nil
    @job_inicio  = nil
    @executados ||= 0
    @ultimo_erro = nil
    @iniciado_em = Time.now.to_f
    @timers     ||= []

    class << self
      attr_reader :ocupado, :pausado, :executados

      # ---------- ciclo de vida ----------

      def iniciar
        parar
        [ENTRADA, PROCESSO, SAIDA, FOTOS].each { |d| FileUtils.mkdir_p(d) }
        limpar_antigos
        recuperar_orfaos
        Espelho.ligar(CONSOLE) if config.fetch('espelhar_console', true)
        escrever_status
        @timers << UI.start_timer(0.25, true) { ciclo }
        @timers << UI.start_timer(2.0, true) { batimento }
        true
      rescue Exception => e
        @ultimo_erro = "#{e.class}: #{e.message}"
        puts "[Claude Ponte] falha ao iniciar: #{@ultimo_erro}"
        false
      end

      def parar
        @timers.each { |t| UI.stop_timer(t) rescue nil }
        @timers.clear
      end

      def pausar(valor = true)
        @pausado = valor
        escrever_status
      end

      def config
        return {} unless File.exist?(CONFIG)
        JSON.parse(File.read(CONFIG, encoding: 'bom|utf-8'))
      rescue StandardError
        {}
      end

      # ---------- fila ----------

      def ciclo
        return if @ocupado || @pausado
        arquivo = Dir.glob(File.join(ENTRADA, '*.rb')).min_by { |f| File.mtime(f) }
        return unless arquivo
        executar(arquivo)
      rescue Exception => e
        @ultimo_erro = "ciclo: #{e.class}: #{e.message}"
        @ocupado = false
      end

      def executar(arquivo)
        @ocupado = true
        id = File.basename(arquivo, '.rb')
        destino = File.join(PROCESSO, "#{id}.rb")
        FileUtils.mv(arquivo, destino)
        @job_atual  = id
        @job_inicio = Time.now.to_f
        escrever_status

        codigo = File.read(destino, encoding: 'bom|utf-8')
        resultado = rodar(id, codigo)

        gravar_atomico(File.join(SAIDA, "#{id}.json"), JSON.generate(resultado))
        registrar_historico(id, codigo, resultado)
        File.delete(destino) if File.exist?(destino)
        @executados += 1
      rescue Exception => e
        @ultimo_erro = "executar #{id}: #{e.class}: #{e.message}"
        begin
          gravar_atomico(File.join(SAIDA, "#{id}.json"),
                         JSON.generate('id' => id, 'ok' => false, 'erro' => { 'classe' => e.class.to_s, 'mensagem' => e.message }))
        rescue Exception
          nil
        end
      ensure
        @ocupado    = false
        @job_atual  = nil
        @job_inicio = nil
        escrever_status
      end

      def rodar(id, codigo)
        texto = StringIO.new
        stdout_antes = $stdout
        inicio = Time.now
        valor = nil
        erro = nil
        begin
          $stdout = texto
          ctx = Contexto.new(id)
          valor = ctx.__avaliar(codigo, "job_#{id}.rb")
        rescue Exception => e
          erro = {
            'classe'    => e.class.to_s,
            'mensagem'  => e.message.to_s.dup.force_encoding('UTF-8').scrub,
            'linha'     => linha_do_job(e, id),
            'backtrace' => (e.backtrace || []).first(12)
          }
        ensure
          $stdout = stdout_antes
        end

        modelo = Sketchup.active_model
        saida = texto.string
        saida = saida[0, LIMITE_SAIDA_TEXTO] + "\n...[cortado]" if saida.length > LIMITE_SAIDA_TEXTO
        {
          'id'         => id,
          'ok'         => erro.nil?,
          'valor'      => erro ? nil : Serializar.valor(valor),
          'saida'      => saida.force_encoding('UTF-8').scrub,
          'erro'       => erro,
          'duracao_s'  => (Time.now - inicio).round(3),
          'modificado' => (modelo.modified? rescue nil),
          'titulo'     => (modelo.title rescue nil)
        }
      end

      def linha_do_job(e, id)
        linha = (e.backtrace || []).find { |l| l.include?("job_#{id}.rb") }
        linha && linha[/:(\d+)/, 1].to_i
      end

      # ---------- status ----------

      def batimento
        Espelho.descarregar
        escrever_status
      rescue Exception => e
        @ultimo_erro = "batimento: #{e.class}: #{e.message}"
      end

      def escrever_status
        modelo = Sketchup.active_model
        dados = {
          'pid'           => PID,
          'versao_ponte'  => VERSAO,
          'modo'          => (CARREGADA_PELO_CONSOLE ? 'console' : 'extensao'),
          'sketchup'      => Sketchup.version,
          'ruby'          => RUBY_VERSION,
          'titulo'        => (modelo && modelo.title rescue nil),
          'caminho'       => (modelo && modelo.path rescue nil),
          'modificado'    => (modelo && modelo.modified? rescue nil),
          'ocupado'       => @ocupado,
          'pausado'       => @pausado,
          'job_atual'     => @job_atual,
          'job_inicio'    => @job_inicio,
          'executados'    => @executados,
          'ultimo_erro'   => @ultimo_erro,
          'iniciado_em'   => @iniciado_em,
          'atualizado_em' => Time.now.to_f
        }
        gravar_atomico(STATUS, JSON.generate(dados))
      end

      # ---------- arquivos ----------

      def gravar_atomico(caminho, conteudo)
        tmp = "#{caminho}.#{PID}.tmp"
        File.open(tmp, 'wb') { |f| f.write(conteudo.to_s.dup.force_encoding('UTF-8')) }
        begin
          File.rename(tmp, caminho)
        rescue SystemCallError
          File.delete(caminho) if File.exist?(caminho)
          File.rename(tmp, caminho)
        end
      end

      # Auditoria: todo código executado fica registrado por dia (o que rodou, quando, se deu certo).
      def registrar_historico(id, codigo, resultado)
        pasta = File.join(RAIZ, 'historico')
        FileUtils.mkdir_p(pasta)
        situacao = resultado['ok'] ? 'ok' : "ERRO #{resultado.dig('erro', 'classe')}: #{resultado.dig('erro', 'mensagem')}"
        File.open(File.join(pasta, "#{Time.now.strftime('%Y-%m-%d')}.log"), 'ab') do |f|
          f.write("===== #{Time.now.strftime('%H:%M:%S')} pid #{PID} job #{id} (#{resultado['duracao_s']} s) #{situacao}\n")
          f.write(codigo.to_s.dup.force_encoding('UTF-8'))
          f.write("\n")
        end
      rescue StandardError
        nil
      end

      def limpar_antigos
        limite = Time.now - 86_400
        Dir.glob(File.join(SAIDA, '*.json')).each { |f| File.delete(f) if File.mtime(f) < limite }
        Dir.glob(File.join(RAIZ, 'historico', '*.log')).each { |f| File.delete(f) if File.mtime(f) < Time.now - (30 * 86_400) }
        # pastas de processos que já não existem são limpas pelo cliente (sk.ps1 limpar)
      rescue StandardError
        nil
      end

      # Job que estava "processando" quando o SketchUp fechou não volta para a fila:
      # vira resultado de erro, para o cliente não ficar esperando nem repetir algo pela metade.
      def recuperar_orfaos
        Dir.glob(File.join(PROCESSO, '*.rb')).each do |f|
          id = File.basename(f, '.rb')
          gravar_atomico(File.join(SAIDA, "#{id}.json"),
                         JSON.generate('id' => id, 'ok' => false,
                                       'erro' => { 'classe' => 'Interrompido',
                                                   'mensagem' => 'O SketchUp fechou ou travou durante este script. Confira o modelo antes de repetir.' }))
          File.delete(f)
        end
      rescue StandardError
        nil
      end
    end

    # Espelho do Console Ruby: guarda as últimas linhas num arquivo para o Claude ler
    # erros do UpMobb e de outros plugins sem precisar ver a janela.
    module Espelho
      MAX = 400
      @linhas = []
      @sujo = false
      @arquivo = nil

      class Saida
        def initialize(original, rotulo)
          @original = original
          @rotulo = rotulo
        end

        def write(*args)
          texto = args.join
          Espelho.registrar(@rotulo, texto)
          @original.write(*args)
        end

        def puts(*args)
          if args.empty?
            write("\n")
          else
            args.flatten.each do |a|
              s = a.nil? ? '' : a.to_s
              write(s.end_with?("\n") ? s : "#{s}\n")
            end
          end
          nil
        end

        def print(*args)
          write(args.join)
          nil
        end

        def <<(obj)
          write(obj.to_s)
          self
        end

        def flush
          @original.flush if @original.respond_to?(:flush)
          self
        end

        def sync
          @original.respond_to?(:sync) ? @original.sync : true
        end

        def sync=(v)
          @original.sync = v if @original.respond_to?(:sync=)
        end

        def respond_to_missing?(nome, privado = false)
          @original.respond_to?(nome, privado) || super
        end

        def method_missing(nome, *args, &bloco)
          @original.send(nome, *args, &bloco)
        end
      end

      class << self
        def ligar(arquivo)
          @arquivo = arquivo
          return if $stdout.is_a?(Saida)
          $stdout = Saida.new($stdout, 'out')
          $stderr = Saida.new($stderr, 'err') unless $stderr.is_a?(Saida)
        rescue StandardError
          nil
        end

        def registrar(rotulo, texto)
          return if texto.nil? || texto.empty?
          carimbo = Time.now.strftime('%H:%M:%S')
          texto.to_s.dup.force_encoding('UTF-8').scrub.each_line do |l|
            l = l.chomp
            next if l.strip.empty?
            @linhas << "#{carimbo} [#{rotulo}] #{l}"
          end
          @linhas.shift(@linhas.size - MAX) if @linhas.size > MAX
          @sujo = true
        rescue StandardError
          nil
        end

        def descarregar
          return unless @sujo && @arquivo
          File.open(@arquivo, 'wb') { |f| f.write(@linhas.join("\n") + "\n") }
          @sujo = false
        rescue StandardError
          nil
        end
      end
    end
  end
end

require File.join(__dir__, 'serializar.rb')
require File.join(__dir__, 'ajuda.rb')
require File.join(__dir__, 'contexto.rb')

unless file_loaded?(__FILE__)
  menu = UI.menu('Extensions').add_submenu('Claude Ponte')
  menu.add_item('Status') do
    p = OrbeClaude::Ponte
    UI.messagebox("Claude Ponte #{p::VERSAO}\nPID #{p::PID}\nScripts executados: #{p.executados}\n" \
                  "Pausada: #{p.pausado ? 'sim' : 'não'}\nPasta: #{p::PASTA}")
  end
  menu.add_item('Pausar / retomar') { OrbeClaude::Ponte.pausar(!OrbeClaude::Ponte.pausado) }
  menu.add_item('Reiniciar') { OrbeClaude::Ponte.iniciar }
  menu.add_item('Abrir pasta da ponte') { UI.openURL("file:///#{OrbeClaude::Ponte::PASTA.tr('\\', '/')}") }
  file_loaded(__FILE__)
end

OrbeClaude::Ponte.iniciar
