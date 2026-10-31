<#
  Hook SessionStart do plugin. Rápido, sem rede, nunca falha a sessão.
  Informa ao Claude: estado da ponte, versão instalada x versão do plugin,
  e se há conhecimento novo esperando a rotina "evoluir-plugin".
#>
$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

$linhas = @()
$raizPlugin = $env:CLAUDE_PLUGIN_ROOT
if (-not $raizPlugin) { $raizPlugin = Split-Path -Parent $PSScriptRoot }

# ----- ponte -----
function Versao-Do-Arquivo([string]$arquivo) {
  if (-not (Test-Path -LiteralPath $arquivo)) { return $null }
  $m = Select-String -LiteralPath $arquivo -Pattern "VERSAO\s*=\s*'([^']+)'" | Select-Object -First 1
  if ($m) { return $m.Matches[0].Groups[1].Value }
  return $null
}
$versaoPlugin = Versao-Do-Arquivo (Join-Path $raizPlugin 'sketchup\claude_ponte.rb')
$instaladas = @()
$baseSu = Join-Path $env:APPDATA 'SketchUp'
if (Test-Path -LiteralPath $baseSu) {
  foreach ($d in Get-ChildItem -LiteralPath $baseSu -Directory | Where-Object { $_.Name -match '^SketchUp \d{4}$' }) {
    $v = Versao-Do-Arquivo (Join-Path $d.FullName 'SketchUp\Plugins\claude_ponte.rb')
    if ($v) { $instaladas += "$($d.Name)=v$v" }
  }
}
if ($instaladas.Count -eq 0) {
  $linhas += 'Ponte SketchUp: NÃO instalada. Use a skill sketchup-ponte (instalação) ou, se não puder instalar, carregue pelo Console Ruby / use a skill sketchup-tela.'
} else {
  $linhas += "Ponte SketchUp instalada: $($instaladas -join ', ') (plugin traz v$versaoPlugin)."
  if (@($instaladas | Where-Object { $_ -notlike "*=v$versaoPlugin" }).Count -gt 0) {
    $linhas += 'A ponte instalada está desatualizada: rodar scripts\instalar-ponte.ps1 e reiniciar o SketchUp (avise o usuário).'
  }
}

$raizInst = Join-Path $env:LOCALAPPDATA 'ClaudePonte\instancias'
$agora = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0
$vivas = @()
if (Test-Path -LiteralPath $raizInst) {
  foreach ($d in Get-ChildItem -LiteralPath $raizInst -Directory) {
    $n = 0
    if (-not [int]::TryParse($d.Name, [ref]$n)) { continue }
    $p = Get-Process -Id $n -ErrorAction SilentlyContinue
    if (-not ($p -and $p.ProcessName -match 'SketchUp')) { continue }
    $st = Join-Path $d.FullName 'status.json'
    try {
      $s = [System.IO.File]::ReadAllText($st, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
      $idade = [math]::Round($agora - [double]$s.atualizado_em)
      $titulo = if ($s.titulo) { $s.titulo } else { '(sem nome)' }
      $extra = if ($idade -gt 8) { ", sem batimento há $idade s" } else { '' }
      $vivas += "PID $n '$titulo'$extra"
    } catch { }
  }
}
if ($vivas.Count -gt 0) { $linhas += "SketchUp abertos com ponte: $($vivas -join '; ')." }
else { $linhas += 'Nenhum SketchUp aberto com a ponte agora.' }

# ----- conhecimento vivo -----
$pastaTrabalho = $env:CLAUDE_PLUGIN_OPTION_PASTA_TRABALHO
if ($pastaTrabalho) {
  $conh = Join-Path $pastaTrabalho '_claude'
  $aprend = Join-Path $conh 'aprendizados.md'
  $fontes = Join-Path $conh 'fontes-estado.json'
  if (Test-Path -LiteralPath $aprend) {
    $novos = @(Select-String -LiteralPath $aprend -Pattern '^\s*-\s*status:\s*novo' ).Count
    if ($novos -gt 0) { $linhas += "Conhecimento: $novos aprendizado(s) novo(s) em _claude\aprendizados.md ainda não consolidado(s)." }
    if ($novos -ge 5) { $linhas += 'Sugira ao usuário rodar a skill evoluir-plugin (5+ aprendizados pendentes).' }
  } else {
    $linhas += "Conhecimento vivo ainda não iniciado (pasta $conh). A skill evoluir-plugin cria na primeira vez."
  }
  if (Test-Path -LiteralPath $fontes) {
    try {
      $f = [System.IO.File]::ReadAllText($fontes, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
      $dias = [math]::Floor(((Get-Date) - [datetime]$f.ultima_revisao_fontes).TotalDays)
      if ($dias -ge 30) { $linhas += "Fontes externas revisadas há $dias dias: sugira rodar evoluir-plugin (revisão de fontes)." }
    } catch { }
  }
} else {
  $linhas += 'Pasta de trabalho não configurada no plugin (/plugin configure).'
}

$contexto = "[Plugin artmdf-sketchup] " + ($linhas -join ' ')
$saida = @{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $contexto } }
Write-Output (ConvertTo-Json -InputObject $saida -Depth 4 -Compress)
exit 0
