# Evals

Casos de teste das skills. Rodar (custa uso de modelo):

```
claude plugin eval . --runs 1 --ablation none           # rápido, só com o plugin
claude plugin eval . --case modelar-criado-mudo
```

Estes casos testam **acionamento** (a skill certa carrega com o pedido típico, inclusive com termos de voz como "openmob") e regras de segurança. Não precisam do SketchUp: `allowed_tools` não inclui execução.
Casos: acionamento das 8 skills.

Ao criar skill nova, crie pelo menos um caso aqui (skill evoluir-plugin, publicar.md).
