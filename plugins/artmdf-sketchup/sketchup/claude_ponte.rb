# encoding: UTF-8
# Claude Ponte: liga o Claude Code ao SketchUp por uma fila de arquivos.
# Instalado por scripts/instalar-ponte.ps1 na pasta Plugins do SketchUp.
# Orbe Assessoria Digital.

require 'sketchup.rb'
require 'extensions.rb'

module OrbeClaude
  module Ponte
    VERSAO = '1.0.0'.freeze

    unless file_loaded?(__FILE__)
      ext = SketchupExtension.new('Claude Ponte', 'claude_ponte/main')
      ext.description = 'Recebe scripts Ruby do Claude Code por uma pasta local e devolve o resultado. ' \
                        'Não abre porta de rede.'
      ext.version     = VERSAO
      ext.creator     = 'Orbe Assessoria Digital'
      ext.copyright   = '2026, Orbe Assessoria Digital'
      Sketchup.register_extension(ext, true)
      file_loaded(__FILE__)
    end
  end
end
