<#
.SYNOPSIS
  Carrega a ponte num SketchUp aberto pelo Console Ruby, sem instalar extensão.

.DESCRIPTION
  Para máquinas onde a extensão não pode ser instalada ou não carrega (política de extensões,
  pasta Plugins bloqueada, instalação restrita). A ponte fica ativa até fechar o SketchUp.

  1. Copia a ponte para %LOCALAPPDATA%\ClaudePonte\ponte\ (caminho fixo, fora do cache do plugin).
  2. Procura a janela do Console Ruby do SketchUp alvo.
  3. Cola o comando  load '<...>/main.rb'  no console e tecla Enter.
  4. Espera a ponte responder (status.json do PID).

  carregar-ponte.ps1 -ProcessoId 17348     carrega no SketchUp desse PID
  carregar-ponte.ps1                       carrega no único SketchUp aberto
  carregar-ponte.ps1 -SoComando            só copia e mostra o comando (para colar à mão ou por controle de tela)

  O Console Ruby precisa estar aberto (SketchUp 2021+: Extensões > Developer > Ruby Console;
  em português: Extensões > Desenvolvedor > Console Ruby). Este script NÃO abre o console:
  se ele estiver fechado, o script avisa e mostra o comando.

  Este script traz o console para a frente e usa a área de transferência (restaurada no fim).
  Avise o usuário antes: por um instante o teclado vai para o console.

  Códigos de saída: 0 ponte ativa · 2 SketchUp não encontrado · 3 console fechado · 4 ponte não respondeu
#>
[CmdletBinding()]
param(
  [int]$ProcessoId,
  [switch]$SoComando,
  [int]$Espera = 15
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

# ----- 1. copiar a ponte para um caminho fixo -----
$origem = Join-Path (Split-Path -Parent $PSScriptRoot) 'sketchup'
$destino = Join-Path $env:LOCALAPPDATA 'ClaudePonte\ponte'
New-Item -ItemType Directory -Path $destino -Force | Out-Null
if (Test-Path -LiteralPath (Join-Path $destino 'claude_ponte')) { Remove-Item -LiteralPath (Join-Path $destino 'claude_ponte') -Recurse -Force }
Copy-Item -LiteralPath (Join-Path $origem 'claude_ponte.rb') -Destination $destino -Force
Copy-Item -LiteralPath (Join-Path $origem 'claude_ponte') -Destination $destino -Recurse -Force
$main = (Join-Path $destino 'claude_ponte\main.rb') -replace '\\', '/'
$comando = "load '$main'"

if ($SoComando) {
  Write-Output 'Cole no Console Ruby do SketchUp e tecle Enter:'
  Write-Output $comando
  exit 0
}

# ----- 2. achar o SketchUp e o Console Ruby -----
if ($ProcessoId) {
  $proc = Get-Process -Id $ProcessoId -ErrorAction SilentlyContinue
} else {
  $todos = @(Get-Process -Name 'SketchUp' -ErrorAction SilentlyContinue)
  if ($todos.Count -gt 1) {
    Write-Output 'Há mais de um SketchUp aberto. Use -ProcessoId:'
    $todos | ForEach-Object { Write-Output "  PID $($_.Id) · $($_.MainWindowTitle)" }
    exit 2
  }
  $proc = $todos | Select-Object -First 1
}
if (-not $proc) { Write-Output 'Nenhum SketchUp aberto.'; exit 2 }

if (-not ('OrbeFoco' -as [type])) {
  Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class OrbeFoco {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
  public static List<IntPtr> Janelas(uint pid) {
    var r = new List<IntPtr>();
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); if (p == pid && IsWindowVisible(h)) r.Add(h); return true; }, IntPtr.Zero);
    return r;
  }
  public static string Titulo(IntPtr h) { var s = new StringBuilder(512); GetWindowText(h, s, 512); return s.ToString(); }
  // Windows só deixa trocar o foco se o processo "acabou de usar o teclado": um toque de ALT libera.
  public static bool Focar(IntPtr h) {
    keybd_event(0x12, 0, 0, UIntPtr.Zero); keybd_event(0x12, 0, 2, UIntPtr.Zero);
    ShowWindow(h, 9);
    return SetForegroundWindow(h);
  }
}
'@
}

$console = [OrbeFoco]::Janelas([uint32]$proc.Id) | Where-Object { [OrbeFoco]::Titulo($_) -match 'Ruby' } | Select-Object -First 1
if (-not $console) {
  Write-Output "O Console Ruby do SketchUp (PID $($proc.Id)) está fechado."
  Write-Output 'Abra em Extensões > Developer > Ruby Console (ou Extensões > Desenvolvedor > Console Ruby) e rode de novo,'
  Write-Output 'ou cole este comando no console:'
  Write-Output $comando
  exit 3
}

# ----- 3. colar o comando -----
Add-Type -AssemblyName System.Windows.Forms
$antes = $null
try { $antes = Get-Clipboard -Raw -ErrorAction Stop } catch { }
Set-Clipboard -Value $comando
$janelaAnterior = [OrbeFoco]::GetForegroundWindow()
[void][OrbeFoco]::Focar([IntPtr]$console)
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::SendWait('^v')
Start-Sleep -Milliseconds 150
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
Start-Sleep -Milliseconds 300
if ($null -ne $antes) { try { Set-Clipboard -Value $antes } catch { } }
if ($janelaAnterior -ne [IntPtr]::Zero) { [void][OrbeFoco]::Focar($janelaAnterior) }

# ----- 4. esperar a ponte -----
$status = Join-Path $env:LOCALAPPDATA "ClaudePonte\instancias\$($proc.Id)\status.json"
$limite = (Get-Date).AddSeconds($Espera)
while ((Get-Date) -lt $limite) {
  if (Test-Path -LiteralPath $status) {
    $idade = ((Get-Date) - (Get-Item -LiteralPath $status).LastWriteTime).TotalSeconds
    if ($idade -lt 5) {
      Write-Output "Ponte ativa no SketchUp PID $($proc.Id) (carregada pelo Console Ruby; some ao fechar o SketchUp)."
      exit 0
    }
  }
  Start-Sleep -Milliseconds 500
}
Write-Output "A ponte não respondeu em $Espera s. Veja o Console Ruby (erro de carga?) ou cole o comando à mão:"
Write-Output $comando
exit 4
