# Mapa do UpMobb nesta instalação

O UpMobb não documenta atributos. Cada descoberta entra aqui: nome, dicionário, significado, onde aparece, data, evidência.
Versão do UpMobb quando o mapa foi iniciado: 2.18.30 (SketchUp 2026). Se a versão mudar, retestar.

## parentrefresh (dynamic_attributes) · 31/10/2026
Em filhos (dobradiças, direcionais). 1 = o "Aplicar" redesenha o pai. Sem ele, o recorte RM416 não acompanhava a altura da pega.

## reduceforbody / reduce_for_lengths · 31/10/2026
A gaveta procura `reduceforbody` na corrediça para descontar o corpo. A corrediça HARDT tinha só `reduce_for_lengths = 1` (mesmo desconto de 10 mm). Criar `reduceforbody` ligado a ele resolveu.

## pointinsert · 31/10/2026
Marca de inserção da fresagem. Fora do caminho da fresagem, o exportador descarta a fresagem.

## Atributos de redimensionamento de componente dinâmico · 31/10/2026
Componente que precisa escalar pelo redesenho do UpMobb precisou de: `_lenx_formula`, `_lenx_units`, `_lenx_formulaunits`, `_lenx_access`, `_lenx_nominal`, `_last_lenx`, rótulos e `_has_movetool_behaviors`, com fórmula nas três medidas e valores numéricos. Copiado do "Puxador Cava RM416".

## Atributos de peça (medida de corte, material, fitas, roteiro)
[CONFIRMAR nomes exatos com o roteiro de inspeção da skill upmobb e registrar aqui]
