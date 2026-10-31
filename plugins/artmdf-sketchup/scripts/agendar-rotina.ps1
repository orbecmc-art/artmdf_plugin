<#
.SYNOPSIS
  Agenda (ou remove) a revisão semanal do plugin no Agendador de Tarefas do Windows.

.DESCRIPTION
  Cria <pasta de trabalho>\_claude\rotina-semanal.ps1 e uma tarefa que o executa toda semana.
  A rotina roda o Claude Code sem interação (claude -p) pedindo à skill evoluir-plugin que
  consolide aprendizados e revise fontes, SEM aplicar nada: o resultado vai para
  _claude\relatorios\revisao-AAAA-MM-DD.md, para o usuário aprovar depois numa conversa.

  agendar-rotina.ps1 -Pasta "C:\Users\Usuario\Desktop\Sketup Claude"
  agendar-rotina.ps1 -Pasta "..." -Dia Monday -Hora 08:00
  agendar-rotina.ps1 -Testar        roda a tarefa agora
  agendar-rotina.ps1 -Remover       apaga a tarefa (o script e os relatórios ficam)
#>
[CmdletBinding()]
param(
  [string]$Pasta = $env:CLAUDE_PLUGIN_OPTION_PASTA_TRABALHO,
  [ValidateSet('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
  [string]$Dia = 'Monday',
  [string]$Hora = '08:00',
  [switch]$Testar,
  [switch]$Remover
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }
$nome = 'Plugin Art MDF - revisao semanal'

if ($Remover) {
  Unregister-ScheduledTask -TaskName $nome -Confirm:$false -ErrorAction SilentlyContinue
  Write-Output "Tarefa '$nome' removida."
  exit 0
}
if ($Testar) {
  Start-ScheduledTask -TaskName $nome
  Write-Output "Tarefa iniciada. O relatório aparece em _claude\relatorios em alguns minutos."
  exit 0
}

if (-not $Pasta -or -not (Test-Path -LiteralPath $Pasta)) {
  Write-Output "Informe a pasta de trabalho com -Pasta (não encontrada: '$Pasta')."
  exit 2
}
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Output 'O comando "claude" não está no PATH deste usuário. Instale o Claude Code antes.'
  exit 2
}

$conh = Join-Path $Pasta '_claude'
New-Item -ItemType Directory -Force -Path (Join-Path $conh 'relatorios') | Out-Null
$script = Join-Path $conh 'rotina-semanal.ps1'

$conteudo = @"
# Rotina semanal do plugin artmdf-sketchup. Gerado por agendar-rotina.ps1.
Set-Location -LiteralPath '$($Pasta -replace "'", "''")'
`$data = Get-Date -Format yyyy-MM-dd
`$pedido = 'Rode a skill evoluir-plugin em modo revisão: consolide os aprendizados novos e revise as fontes vencidas. Não aplique nenhuma mudança na memória nem no plugin. Grave as mudanças propostas, com fonte e motivo, em _claude\relatorios\revisao-' + `$data + '.md e atualize a data de revisão em _claude\fontes-estado.json.'
claude -p `$pedido --permission-mode acceptEdits --allowedTools "Read,Write,Edit,Glob,Grep,WebSearch,WebFetch,Skill" *> "_claude\relatorios\execucao-`$data.log"
"@
Set-Content -LiteralPath $script -Value $conteudo -Encoding UTF8

$acao = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$quando = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Dia -At ([datetime]::ParseExact($Hora, 'HH:mm', $null))
$config = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
Register-ScheduledTask -TaskName $nome -Action $acao -Trigger $quando -Settings $config -Force | Out-Null

Write-Output "Rotina agendada: toda $Dia às $Hora (tarefa '$nome')."
Write-Output "Script: $script"
Write-Output "Relatórios: $(Join-Path $conh 'relatorios')"
Write-Output 'Teste agora com: agendar-rotina.ps1 -Testar'
exit 0
