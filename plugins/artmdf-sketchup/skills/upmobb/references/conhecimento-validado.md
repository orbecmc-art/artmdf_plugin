# UpMobb · conhecimento validado na Art MDF

Cada item: o que foi visto, onde, quando. Itens novos entram pela skill evoluir-plugin. Se um item deixar de valer (versão nova do UpMobb), marque como **superado** com data, não apague.

## 31/10/2026 · Criado-mudo 2 gavetas (sessão "Gaveta no SketchUp")

- Módulo usado: "Criado 2 Gavetas Cava" da biblioteca. Paramétrico, já com fitas, minifix, cavilhas, furações, cava usinada e corrediça HARDT soft-closing.
- Medidas finais: 501 × 422,5 × 618,5 mm (corpo 450, pés reguláveis 150). 21 peças. Ferragens: 39 minifix (bateu com os 39 furos Ø15 do .scx), 10 cavilhas, 4 sapatas, 2 cantoneiras, 2 pares de corrediças.
- Cota de profundidade: 422,5 real; 424,5 incluía 2 mm de cabeça de minifix. Ao cotar, meça a chapa, não o bounding box do módulo.
- Gaveta não acompanhava profundidade: fórmula da base procurava `reduceforbody`, ausente na corrediça HARDT (que tem `reduce_for_lengths = 1`). Adicionar `reduceforbody` ligado a ele resolveu (corrediça 350, gaveta 340).
- Configurador mostrava valores errados porque medidas e niveladores estavam só na instância. Movidos para a definição.
- Opção nova "Espessura Tamponamento" (15/18/25) criada e testada pelo Aplicar: muda só laterais de tamponamento e tampo; fita e código do MDF acompanham.
- .scx: 16 painéis; tamponamentos, tampo e réguas da cava ficaram de fora por não terem furação. Fresagem do recorte da cava com 15,5 mm nas laterais; furos Ø8, Ø15, Ø3; canal 16 × 8,5 para corrediça.
- Plano de corte e lista de compras bloqueados sem Detalhes do projeto.
- `m.save` abriu "Salvar como"; salvar pela janela confirmando substituição.

## 31/10/2026 · Roupeiro 2 portas com puxador RM416 (sessão "Modelagem puxador RM416")

- Perfil RM416: rasgo em rabo de andorinha, 58 mm no fundo, 38 mm na face, 14 mm de profundidade; entra pela borda inferior da porta. Fresa 45° Ø40 (`usi_45_rm416`, cadastrada sem código de ferramenta: conferir na máquina).
- "Recorte Cava RM416" da biblioteca faz um único caminho em U (pernas a ±9,3 mm do centro). O usuário **recusou** acrescentar passada central: a usinagem original é a correta para a fábrica.
- O que o usuário queria: o 3D mostrar a porta já recortada (sem madeira dentro do perfil), acompanhando a "Altura da pega". Feito com cortadores visuais ligados por fórmula + `parentrefresh = 1` no recorte. Testado com 800 e 1000 mm.
- Ponteira aberta assimétrica (0,84 mm de deslocamento): use o contorno real lido da geometria, não espelhe.
- Conjunto vai até altura da pega + 7,31 mm. Canal no fundo do perfil: ~44,8 mm de largura × 1,4 mm, ~38,7 mm visíveis de frente (para fita de acabamento na cor da face).
- Porta de 15,5 mm com cava de 14 mm deixa 1,5 mm atrás. Alertar e confirmar se o RM416 pede frente de 18 mm.
- Linhas de percurso da fresa ocultadas no 3D sem apagar (o UpMobb precisa delas para exportar).
- Projeto salvo em `Sketup Claude\Projeto Roupeiro RM416\ROUPEIRO 2 PORTAS RM416.skp`.

## Preferências do projetista (valem para tudo)

- Não alterar usinagem sem pedir.
- Não salvar sem pedir; backup antes de sobrescrever.
- Projetos em `Sketup Claude\Projeto <Nome>\`.
- Alterar biblioteca só com OK.
- Acabamento visual "100%": ele manda prints com defeitos circulados; trate cada um e mostre os mesmos ângulos depois.
