# Vídeo de apresentação para o cliente final · receita EM VALIDAÇÃO

Status: não testado na máquina da Art MDF (31/10/2026). Ao usar pela primeira vez, registre o resultado em `_claude/aprendizados.md` para a skill evoluir-plugin promover ou corrigir esta receita.
Origem da ideia: vídeo curto de passeio pelo projeto convence o cliente final mais que imagens paradas.

Objetivo: MP4 de 8 a 12 s girando em volta do móvel (ou percorrendo o ambiente), sem cotas, sem linhas de fresa.

## Caminho A · quadros pela ponte + ffmpeg

1. Verifique se a máquina tem ffmpeg: `Get-Command ffmpeg -ErrorAction SilentlyContinue`. Sem ffmpeg, use o caminho B (não instale nada sem OK do usuário).
2. Oculte as camadas técnicas só durante o vídeo (receita "Foto para o cliente" em `cenas-cotas.md`) e volte ao final.
3. Gere os quadros em **lotes de até 60 por script** (cada quadro leva de 0,3 s a 1 s; um lote grande trava o SketchUp por minutos). Rode com `SK rodar lote.rb -Tempo 600`.

```ruby
# lote.rb — gira a câmera em volta do móvel selecionado e grava quadros numerados
movel = sel.first or raise 'Selecione o móvel'
pasta = 'C:/Users/Usuario/Desktop/Sketup Claude/Projeto X/video/quadros'   # ajuste
total = 240                       # 8 s a 30 qps
inicio = memoria[:proximo_quadro] || 0
fim = [inicio + 60, total].min
FileUtils.mkdir_p(pasta)
bb = movel.bounds
centro = bb.center
raio = bb.diagonal * 1.6
altura = bb.depth * 0.6
v = m.active_view
cam_antes = v.camera
(inicio...fim).each do |i|
  ang = Math::PI * 1.25 + (i.to_f / total) * (Math::PI / 2)   # um quarto de volta pela frente-esquerda
  olho = Geom::Point3d.new(centro.x + raio * Math.cos(ang), centro.y + raio * Math.sin(ang), centro.z + altura)
  v.camera = Sketchup::Camera.new(olho, centro, Geom::Vector3d.new(0, 0, 1))
  v.write_image(filename: File.join(pasta, format('q%04d.png', i)), width: 1920, height: 1080, antialias: true)
end
v.camera = cam_antes
memoria[:proximo_quadro] = fim < total ? fim : nil
"quadros #{inicio}..#{fim - 1} de #{total}"
```

4. Repita até o retorno indicar o último quadro. Olhe o primeiro, o do meio e o último com Read.
5. Monte o vídeo:
```
ffmpeg -y -framerate 30 -i "<pasta>\q%04d.png" -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast "<pasta>\..\apresentacao.mp4"
```

## Caminho B · animação nativa do SketchUp

1. Crie 3 a 5 cenas em volta do móvel (receita de cenas em `cenas-cotas.md`), sem cotas.
2. Peça ao usuário: Arquivo > Exportar > Animação > Vídeo, escolhendo resolução 1920 × 1080 e transição de cena de 2 a 3 s.
3. Confira o vídeo gerado e apague as cenas temporárias se o usuário não quiser mantê-las (com OK).

## Regras

- O vídeo é apresentação: leve o aviso "imagem ilustrativa" no nome do arquivo ou na mensagem ao cliente.
- Não altera o modelo além de cenas temporárias e visibilidade de camadas, ambas revertidas.
- Ajuste a fração da volta e a altura da câmera ao tipo de móvel (aéreo pede câmera mais alta).
