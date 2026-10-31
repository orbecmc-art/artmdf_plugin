<#
.SYNOPSIS
  Converte um HTML local em PDF com o Edge (ou Chrome) em modo headless. Não precisa de Python.

  pdf.ps1 -Html "C:\...\projeto.html" [-Pdf "C:\...\projeto.pdf"]
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Html,
  [string]$Pdf
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

if (-not (Test-Path -LiteralPath $Html)) { Write-Output "HTML não encontrado: $Html"; exit 2 }
$htmlCheio = (Resolve-Path -LiteralPath $Html).Path
if (-not $Pdf) { $Pdf = [System.IO.Path]::ChangeExtension($htmlCheio, '.pdf') }
elseif (-not [System.IO.Path]::IsPathRooted($Pdf)) { $Pdf = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Pdf)) }

$candidatos = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$nav = $candidatos | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $nav) { Write-Output 'Edge ou Chrome não encontrado.'; exit 2 }

$url = ([System.Uri]$htmlCheio).AbsoluteUri
$perfil = Join-Path $env:TEMP ('claude-pdf-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$argumentos = @(
  '--headless=new', '--disable-gpu', '--no-pdf-header-footer', '--run-all-compositor-stages-before-draw',
  "--user-data-dir=`"$perfil`"", "--print-to-pdf=`"$Pdf`"", "`"$url`""
)
if (Test-Path -LiteralPath $Pdf) { Remove-Item -LiteralPath $Pdf -Force }
$p = Start-Process -FilePath $nav -ArgumentList $argumentos -PassThru -WindowStyle Hidden
if (-not $p.WaitForExit(90000)) { try { $p.Kill() } catch { }; Write-Output 'O navegador não terminou em 90 s.'; exit 4 }
Remove-Item -LiteralPath $perfil -Recurse -Force -ErrorAction SilentlyContinue

if (-not (Test-Path -LiteralPath $Pdf)) { Write-Output 'PDF não foi gerado.'; exit 1 }
$kb = [math]::Round((Get-Item -LiteralPath $Pdf).Length / 1KB, 1)
Write-Output "PDF gerado: $Pdf ($kb KB)"
exit 0
