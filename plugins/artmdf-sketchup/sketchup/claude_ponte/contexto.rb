# encoding: UTF-8
# Cada script roda dentro de um Contexto novo: variáveis locais de um job não vazam para o próximo.
# Os métodos de Ajuda (m, mm, operacao, foto, ...) ficam disponíveis direto no script.
# Para guardar algo entre jobs, use `memoria[:chave] = valor` (dura até fechar o SketchUp).

module OrbeClaude
  module Ponte
    MEMORIA = {}

    class Contexto
      include Ajuda

      attr_reader :job_id

      def initialize(job_id)
        @job_id = job_id
      end

      def memoria
        MEMORIA
      end

      def __avaliar(codigo, nome_arquivo)
        eval(codigo, binding, nome_arquivo, 1) # rubocop:disable Security/Eval
      end
    end
  end
end
