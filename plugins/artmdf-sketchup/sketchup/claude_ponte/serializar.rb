# encoding: UTF-8
# Converte o valor devolvido por um script em algo que vira JSON.
# Regra: comprimentos (Length) e coordenadas saem SEMPRE em milímetros.

module OrbeClaude
  module Ponte
    module Serializar
      MAX_ITENS = 500
      MAX_PROF  = 6

      module_function

      def valor(v, prof = 0)
        return '[profundidade máxima]' if prof > MAX_PROF
        case v
        when nil, true, false, Integer then v
        when Length then mm(v)
        when Float then v.finite? ? v.round(6) : v.to_s
        when String then v.dup.force_encoding('UTF-8').scrub
        when Symbol then v.to_s
        when Array then lista(v, prof)
        when Hash
          v.first(MAX_ITENS).each_with_object({}) { |(k, x), h| h[k.to_s] = valor(x, prof + 1) }
        when Geom::Point3d then { 'x' => mm(v.x), 'y' => mm(v.y), 'z' => mm(v.z) }
        when Geom::Vector3d then [v.x.to_f.round(6), v.y.to_f.round(6), v.z.to_f.round(6)]
        when Geom::BoundingBox then caixa(v)
        when Geom::Transformation then { 'origem' => valor(v.origin, prof + 1), 'matriz' => v.to_a.map { |n| n.round(6) } }
        when Sketchup::Entity then entidade(v)
        when Enumerable then lista(v.to_a, prof) # seleção, entities, layers, materials, pages...
        else
          v.respond_to?(:to_h) ? valor(v.to_h, prof + 1) : v.inspect.to_s[0, 2000]
        end
      rescue StandardError => e
        "[não serializável: #{e.class}]"
      end

      def lista(v, prof)
        itens = v.first(MAX_ITENS).map { |x| valor(x, prof + 1) }
        itens << "... +#{v.size - MAX_ITENS} itens" if v.size > MAX_ITENS
        itens
      end

      def mm(comprimento)
        comprimento.to_f.to_mm.round(3)
      end

      def caixa(bb)
        return { 'vazia' => true } if bb.empty?
        {
          'larg_x_mm' => mm(bb.width), 'prof_y_mm' => mm(bb.height), 'alt_z_mm' => mm(bb.depth),
          'min' => valor(bb.min, 1), 'max' => valor(bb.max, 1)
        }
      end

      def entidade(e)
        return { 'apagada' => true } if e.deleted?
        h = { 'tipo' => e.typename, 'id' => e.entityID }
        h['pid'] = e.persistent_id if e.respond_to?(:persistent_id)
        case e
        when Sketchup::ComponentInstance
          h['nome'] = e.name
          h['definicao'] = e.definition.name
          h['camada'] = e.layer.name
        when Sketchup::Group
          h['nome'] = e.name
          h['camada'] = e.layer.name
        when Sketchup::ComponentDefinition
          h['nome'] = e.name
          h['instancias'] = e.count_used_instances
        when Sketchup::Face
          h['area_mm2'] = (e.area * 645.16).round(2)
          h['normal'] = valor(e.normal, 1)
        when Sketchup::Edge
          h['comprimento_mm'] = mm(e.length)
        when Sketchup::Material
          h['nome'] = e.name
        when Sketchup::Layer
          h['nome'] = e.name
        end
        h
      end
    end
  end
end
