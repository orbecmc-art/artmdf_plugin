<#
.SYNOPSIS
  Instala (ou atualiza) a extensão Claude Ponte na pasta Plugins do SketchUp.

.DESCRIPTION
  Copia sketchup\claude_ponte.rb e a pasta sketchup\claude_ponte\ do plugin para
  %APPDATA%\SketchUp\SketchUp <versão>\SketchUp\Plugins.
  Sem -Versao, instala em todas as versões do SketchUp encontradas no usuário.
  Depois de instalar, é preciso FECHAR E ABRIR o SketchUp.

  instalar-ponte.ps1                 instala/atualiza
  instalar-ponte.ps1 -Versao 2026    só no SketchUp 2026
  instalar-ponte.ps1 -Verificar      só mostra o que está instalado
  instalar-ponte.ps1 -Remover        desinstala
#>
[CmdletBinding()]
param(
  [string]$Versao,
  [switch]$Verificar,
  [switch]$Remover
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

$origem = Join-Path (Split-Path -Parent $PSScriptRoot) 'sketchup'
$loader = Join-Path $origem 'claude_ponte.rb'
$pastaSuporte = Join-Path $origem 'claude_ponte'
if (-not (Test-Path -LiteralPath $loader)) { Write-Output "Fonte da ponte não encontrada em $origem"; exit 1 }

function Versao-Do-Arquivo([string]$arquivo) {
  if (-not (Test-Path -LiteralPath $arquivo)) { return $null }
  $m = Select-String -LiteralPath $arquivo -Pattern "VERSAO\s*=\s*'([^']+)'" | Select-Object -First 1
  if ($m) { return $m.Matches[0].Groups[1].Value }
  return $null
}

$versaoNova = Versao-Do-Arquivo $loader
$base = Join-Path $env:APPDATA 'SketchUp'
if (-not (Test-Path -LiteralPath $base)) {
  Write-Output "Nenhum SketchUp encontrado em $base. Abra o SketchUp uma vez e rode de novo."
  exit 2
}

$alvos = @(Get-ChildItem -LiteralPath $base -Directory | Where-Object { $_.Name -match '^SketchUp (\d{4})$' })
if ($Versao) { $alvos = @($alvos | Where-Object { $_.Name -eq "SketchUp $Versao" }) }
if ($alvos.Count -eq 0) { Write-Output "Nenhuma pasta 'SketchUp $Versao' em $base."; exit 2 }

$abertos = @(Get-Process -Name 'SketchUp' -ErrorAction SilentlyContinue)

foreach ($a in $alvos) {
  $plugins = Join-Path $a.FullName 'SketchUp\Plugins'
  $destLoader = Join-Path $plugins 'claude_ponte.rb'
  $destPasta = Join-Path $plugins 'claude_ponte'
  $versaoAtual = Versao-Do-Arquivo $destLoader

  if ($Verificar) {
    $txt = if ($versaoAtual) { "instalada v$versaoAtual" } else { 'não instalada' }
    $txt2 = if ($versaoAtual -and $versaoAtual -ne $versaoNova) { " (o plugin traz v$versaoNova: rode sem -Verificar para atualizar)" } else { '' }
    Write-Output "$($a.Name): $txt$txt2"
    continue
  }

  if ($Remover) {
    if (Test-Path -LiteralPath $destLoader) { Remove-Item -LiteralPath $destLoader -Force }
    if (Test-Path -LiteralPath $destPasta) { Remove-Item -LiteralPath $destPasta -Recurse -Force }
    Write-Output "$($a.Name): ponte removida."
    continue
  }

  New-Item -ItemType Directory -Path $plugins -Force | Out-Null
  if (Test-Path -LiteralPath $destPasta) { Remove-Item -LiteralPath $destPasta -Recurse -Force }
  Copy-Item -LiteralPath $loader -Destination $destLoader -Force
  Copy-Item -LiteralPath $pastaSuporte -Destination $destPasta -Recurse -Force
  $antes = if ($versaoAtual) { "v$versaoAtual -> " } else { '' }
  Write-Output "$($a.Name): ponte instalada ($antes v$versaoNova) em $plugins"
}

New-Item -ItemType Directory -Path (Join-Path $env:LOCALAPPDATA 'ClaudePonte\instancias') -Force | Out-Null

if (-not $Verificar -and -not $Remover) {
  Write-Output ''
  Write-Output 'Próximos passos:'
  if ($abertos.Count -gt 0) {
    Write-Output "  1. Há $($abertos.Count) SketchUp aberto(s). Salve o trabalho, feche e abra de novo para carregar a ponte."
  } else {
    Write-Output '  1. Abra o SketchUp.'
  }
  Write-Output '  2. Se aparecer aviso de extensão não identificada, escolha carregar (ou ajuste em Extensões > Gerenciador de Extensões > engrenagem > política de carregamento).'
  Write-Output '  3. Confira com: sk.ps1 status'
}
exit 0
