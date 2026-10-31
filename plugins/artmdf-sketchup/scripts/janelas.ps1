<#
.SYNOPSIS
  Vê e responde janelas do SketchUp (caixas de mensagem do UpMobb, "Salvar como", confirmações).

.DESCRIPTION
  Quando a ponte para de responder, quase sempre há uma janela modal esperando clique.
  Este script lista as janelas de um processo, mostra o texto e os botões de cada diálogo
  e, se pedido, clica num botão pelo texto. Não traz nada para a frente e não usa o mouse.

  Listar:     janelas.ps1 -ProcessoId 17348
  Clicar:     janelas.ps1 -ProcessoId 17348 -Clicar "Não"
              janelas.ps1 -ProcessoId 17348 -Clicar "Salvar" -Janela "Salvar como"
  Nome no Salvar como (antes de clicar Salvar):
              janelas.ps1 -ProcessoId 17348 -Janela "Salvar como" -NomeArquivo "CRIADO-MUDO 2 GAVETAS.skp"
  Capturar imagem de uma janela, mesmo encoberta:
              janelas.ps1 -ProcessoId 17348 -Capturar C:\temp\painel.png -Janela "UpMobb"

  Regras de uso (skill sketchup-ponte):
    - Leia o texto do diálogo ANTES de clicar.
    - Só clique em botão que não destrói nada ou que o usuário autorizou.
    - Nunca clique em "Excluir", "Substituir" ou "Sim" de sobrescrever sem OK do usuário.

  Sem -ProcessoId, usa todos os processos SketchUp abertos.
#>
[CmdletBinding()]
param(
  [int]$ProcessoId,
  [string]$Janela,
  [string]$Clicar,
  [string]$NomeArquivo,
  [string]$Capturar,
  [switch]$Todas,
  [switch]$Json
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

if (-not ('OrbeJanelas' -as [type])) {
  Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Text;

public static class OrbeJanelas {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr p, EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsWindowEnabled(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr GetWindow(IntPtr h, uint cmd);
  [DllImport("user32.dll")] static extern bool PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] static extern IntPtr GetParent(IntPtr h);
  [DllImport("user32.dll")] static extern int GetDlgCtrlID(IntPtr h);
  // Timeout: se a thread do SketchUp estiver ocupada, não trava este script.
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr SendMessageTimeout(IntPtr h, uint msg, IntPtr w, string l, uint flags, uint ms, out IntPtr res);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern IntPtr SendMessageTimeout(IntPtr h, uint msg, IntPtr w, StringBuilder l, uint flags, uint ms, out IntPtr res);
  [DllImport("user32.dll")] static extern IntPtr SendMessageTimeout(IntPtr h, uint msg, IntPtr w, IntPtr l, uint flags, uint ms, out IntPtr res);
  [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }

  const uint WM_GETTEXT = 0x000D, WM_GETTEXTLENGTH = 0x000E, WM_SETTEXT = 0x000C, WM_COMMAND = 0x0111;
  const uint SMTO_ABORTIFHUNG = 0x0002, ESPERA = 1000;

  public static List<IntPtr> Topo(uint pid, bool soVisiveis) {
    var r = new List<IntPtr>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p == pid && (!soVisiveis || IsWindowVisible(h))) r.Add(h);
      return true;
    }, IntPtr.Zero);
    return r;
  }

  public static List<IntPtr> Filhos(IntPtr pai) {
    var r = new List<IntPtr>();
    EnumChildWindows(pai, (h, l) => { r.Add(h); return true; }, IntPtr.Zero);
    return r;
  }

  public static string Titulo(IntPtr h) { var s = new StringBuilder(512); GetWindowText(h, s, 512); return s.ToString(); }
  public static string Classe(IntPtr h) { var s = new StringBuilder(256); GetClassName(h, s, 256); return s.ToString(); }

  // Texto de controles de outro processo (Edit, Static) pede WM_GETTEXT.
  public static string Texto(IntPtr h) {
    IntPtr r;
    if (SendMessageTimeout(h, WM_GETTEXTLENGTH, IntPtr.Zero, IntPtr.Zero, SMTO_ABORTIFHUNG, ESPERA, out r) == IntPtr.Zero) return Titulo(h);
    int n = (int)r;
    if (n <= 0) return Titulo(h);
    var s = new StringBuilder(n + 1);
    SendMessageTimeout(h, WM_GETTEXT, (IntPtr)(n + 1), s, SMTO_ABORTIFHUNG, ESPERA, out r);
    return s.ToString();
  }

  public static IntPtr Dono(IntPtr h) { return GetWindow(h, 4); }

  // WM_COMMAND/BN_CLICKED ao diálogo pai: funciona mesmo com o diálogo inativo.
  // PostMessage: não trava se o clique abrir outro diálogo (ex.: confirmar substituição).
  public static bool Clicar(IntPtr botao) {
    IntPtr pai = GetParent(botao);
    int id = GetDlgCtrlID(botao);
    return PostMessage(pai, WM_COMMAND, (IntPtr)(id & 0xFFFF), botao);
  }

  public static void DefinirTexto(IntPtr h, string t) { IntPtr r; SendMessageTimeout(h, WM_SETTEXT, IntPtr.Zero, t, SMTO_ABORTIFHUNG, ESPERA, out r); }

  public static void Capturar(IntPtr h, string arquivo) {
    RECT r; GetWindowRect(h, out r);
    int w = Math.Max(1, r.Right - r.Left), a = Math.Max(1, r.Bottom - r.Top);
    using (var bmp = new Bitmap(w, a, PixelFormat.Format32bppArgb)) {
      using (var g = Graphics.FromImage(bmp)) {
        IntPtr hdc = g.GetHdc();
        bool ok = PrintWindow(h, hdc, 2); // PW_RENDERFULLCONTENT: pega Chromium/CEF também
        g.ReleaseHdc(hdc);
        if (!ok) throw new Exception("PrintWindow falhou");
      }
      bmp.Save(arquivo, ImageFormat.Png);
    }
  }
}
'@
}

function Limpar-Rotulo([string]$t) { return ($t -replace '&', '').Trim() }

function Descrever([IntPtr]$h, [int]$processo) {
  $classe = [OrbeJanelas]::Classe($h)
  $dialogo = $classe -eq '#32770'
  $textos = @(); $botoes = @(); $campos = @()
  if ($dialogo) {
    foreach ($f in [OrbeJanelas]::Filhos($h)) {
      if (-not [OrbeJanelas]::IsWindowVisible($f)) { continue }
      $c = [OrbeJanelas]::Classe($f)
      if ($c -eq 'Button') {
        $b = Limpar-Rotulo ([OrbeJanelas]::Titulo($f))
        if ($b) { $botoes += $b }
      } elseif ($c -eq 'Static') {
        $t = ([OrbeJanelas]::Texto($f)).Trim()
        if ($t) { $textos += $t }
      } elseif ($c -eq 'Edit') {
        $campos += ([OrbeJanelas]::Texto($f))
      }
    }
  }
  [pscustomobject]@{
    Processo  = $processo
    Handle    = $h.ToInt64()
    Titulo    = [OrbeJanelas]::Titulo($h)
    Classe    = $classe
    Dialogo   = $dialogo
    Habilitada = [OrbeJanelas]::IsWindowEnabled($h)
    Texto     = ($textos -join ' | ')
    Botoes    = $botoes
    Campos    = $campos
  }
}

# ----- processos alvo -----
if ($ProcessoId) {
  $procs = @(Get-Process -Id $ProcessoId -ErrorAction SilentlyContinue)
} else {
  $procs = @(Get-Process -Name 'SketchUp' -ErrorAction SilentlyContinue)
}
if ($procs.Count -eq 0) { Write-Output 'Nenhum processo SketchUp encontrado.'; exit 2 }

$janelas = @()
foreach ($p in $procs) {
  foreach ($h in [OrbeJanelas]::Topo([uint32]$p.Id, $true)) {
    $d = Descrever $h $p.Id
    if (-not $Todas -and -not $d.Titulo -and -not $d.Dialogo) { continue }
    $janelas += $d
  }
}

$filtradas = $janelas
if ($Janela) { $filtradas = @($janelas | Where-Object { $_.Titulo -like "*$Janela*" }) }

# ----- ações -----
if ($Capturar) {
  $alvo = @($filtradas | Select-Object -First 1)
  if ($alvo.Count -eq 0) { Write-Output "Nenhuma janela para capturar (filtro: '$Janela')."; exit 2 }
  $pasta = Split-Path -Parent $Capturar
  if ($pasta -and -not (Test-Path -LiteralPath $pasta)) { New-Item -ItemType Directory -Path $pasta -Force | Out-Null }
  [OrbeJanelas]::Capturar([IntPtr]$alvo[0].Handle, $Capturar)
  Write-Output "Capturada: '$($alvo[0].Titulo)' -> $Capturar"
  exit 0
}

if ($NomeArquivo) {
  $dlg = @($filtradas | Where-Object { $_.Dialogo } | Select-Object -First 1)
  if ($dlg.Count -eq 0) { Write-Output 'Nenhum diálogo encontrado para preencher o nome.'; exit 2 }
  $edits = @([OrbeJanelas]::Filhos([IntPtr]$dlg[0].Handle) | Where-Object { [OrbeJanelas]::Classe($_) -eq 'Edit' -and [OrbeJanelas]::IsWindowVisible($_) })
  if ($edits.Count -eq 0) { Write-Output 'O diálogo não tem campo de nome visível.'; exit 2 }
  [OrbeJanelas]::DefinirTexto($edits[0], $NomeArquivo)
  Write-Output "Nome definido em '$($dlg[0].Titulo)': $NomeArquivo"
  if (-not $Clicar) { exit 0 }
}

if ($Clicar) {
  $rotulo = Limpar-Rotulo $Clicar
  $candidatos = @($filtradas | Where-Object { $_.Dialogo -and ($_.Botoes -contains $rotulo) })
  if ($candidatos.Count -eq 0) {
    Write-Output "Nenhum diálogo com o botão '$rotulo'. Diálogos abertos:"
    $janelas | Where-Object { $_.Dialogo } | ForEach-Object { Write-Output "  [$($_.Titulo)] $($_.Texto) · botões: $($_.Botoes -join ', ')" }
    exit 2
  }
  if ($candidatos.Count -gt 1) {
    Write-Output "Mais de um diálogo tem o botão '$rotulo'. Use -Janela para escolher:"
    $candidatos | ForEach-Object { Write-Output "  [$($_.Titulo)] $($_.Texto)" }
    exit 3
  }
  $d = $candidatos[0]
  $botao = [OrbeJanelas]::Filhos([IntPtr]$d.Handle) | Where-Object {
    [OrbeJanelas]::Classe($_) -eq 'Button' -and (Limpar-Rotulo ([OrbeJanelas]::Titulo($_))) -eq $rotulo
  } | Select-Object -First 1
  if (-not $botao) { Write-Output "Botão '$rotulo' não encontrado no momento do clique (o diálogo mudou?)."; exit 2 }
  [void][OrbeJanelas]::Clicar([IntPtr]$botao)
  Start-Sleep -Milliseconds 600
  Write-Output "Clicado '$rotulo' em [$($d.Titulo)] · texto do diálogo: $($d.Texto)"
  $restantes = @()
  foreach ($h in [OrbeJanelas]::Topo([uint32]$d.Processo, $true)) {
    $x = Descrever $h $d.Processo
    if ($x.Dialogo) { $restantes += $x }
  }
  if ($restantes.Count -gt 0) {
    Write-Output 'Diálogos ainda abertos:'
    $restantes | ForEach-Object { Write-Output "  [$($_.Titulo)] $($_.Texto) · botões: $($_.Botoes -join ', ')" }
  } else {
    Write-Output 'Nenhum diálogo aberto agora.'
  }
  exit 0
}

# ----- só listar -----
if ($Json) { Write-Output (ConvertTo-Json -InputObject @($filtradas) -Depth 4); exit 0 }
if ($filtradas.Count -eq 0) { Write-Output 'Nenhuma janela com título.'; exit 0 }
foreach ($j in $filtradas) {
  $tipo = if ($j.Dialogo) { 'DIÁLOGO' } else { 'janela' }
  $bloq = if (-not $j.Habilitada) { ' (desabilitada: há um diálogo modal por cima)' } else { '' }
  Write-Output "[$tipo] PID $($j.Processo) · '$($j.Titulo)' · $($j.Classe)$bloq"
  if ($j.Texto) { Write-Output "    texto: $($j.Texto)" }
  if ($j.Botoes.Count -gt 0) { Write-Output "    botões: $($j.Botoes -join ', ')" }
  if ($j.Campos.Count -gt 0) { Write-Output "    campos: $($j.Campos -join ' | ')" }
}
exit 0
