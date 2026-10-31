<#
.SYNOPSIS
  Cliente da Claude Ponte: manda script Ruby para o SketchUp aberto e devolve o resultado.

.DESCRIPTION
  Comandos:
    status                      Lista os SketchUp abertos com a ponte ativa.
    rodar  <arquivo.rb>         Executa um arquivo .rb no SketchUp.
    eval   "<código ruby>"      Executa um trecho curto.
    console                     Últimas linhas do Console Ruby (erros do UpMobb aparecem aqui).
    limpar                      Remove pastas de SketchUp que já foram fechados.

  Opções:
    -Alvo <PID ou trecho do título>   Obrigatório quando há mais de um SketchUp aberto.
    -Tempo <segundos>                 Espera máxima (padrão 90). A ferramenta que chama este script
                                      precisa de timeout maior (Tempo + 30 s).
    -Json                             Devolve o resultado cru em JSON.
    -Linhas <n>                       Para "console" (padrão 60).

  Códigos de saída:
    0 ok · 1 erro no Ruby · 2 nenhum SketchUp com ponte · 3 mais de um SketchUp (use -Alvo)
    4 tempo esgotado ou janela modal travando · 5 uso incorreto

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File sk.ps1 eval "info_modelo"
  powershell -NoProfile -ExecutionPolicy Bypass -File sk.ps1 rodar C:\trab\medir.rb -Alvo "CRIADO"
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [ValidateSet('status', 'rodar', 'eval', 'console', 'limpar')]
  [string]$Comando = 'status',

  [Parameter(Position = 1)]
  [string]$Entrada,

  [string]$Alvo,
  [int]$Tempo = 90,
  [int]$Linhas = 60,
  [switch]$Json
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }
$Utf8SemBom = New-Object System.Text.UTF8Encoding($false)
$Raiz = Join-Path $env:LOCALAPPDATA 'ClaudePonte\instancias'

function Sair([int]$codigo, [string]$mensagem) {
  # Escreve direto no console: Write-Output dentro de uma função atribuída ($x = Funcao) seria engolido.
  if ($mensagem) { [Console]::Out.WriteLine($mensagem) }
  exit $codigo
}

function Ler-Json([string]$caminho) {
  $texto = [System.IO.File]::ReadAllText($caminho, [System.Text.Encoding]::UTF8)
  return ($texto | ConvertFrom-Json)
}

function Agora-Epoch {
  return [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0
}

function Obter-Instancias {
  $lista = @()
  if (-not (Test-Path -LiteralPath $Raiz)) { return $lista }
  foreach ($d in Get-ChildItem -LiteralPath $Raiz -Directory) {
    $arqStatus = Join-Path $d.FullName 'status.json'
    if (-not (Test-Path -LiteralPath $arqStatus)) { continue }
    $s = $null
    try { $s = Ler-Json $arqStatus } catch { continue }
    $num = 0
    if (-not [int]::TryParse($d.Name, [ref]$num)) { continue }
    $proc = Get-Process -Id $num -ErrorAction SilentlyContinue
    $viva = [bool]($proc -and ($proc.ProcessName -match 'SketchUp'))
    $lista += [pscustomobject]@{
      Pid        = $num
      Viva       = $viva
      Batimento  = [math]::Round((Agora-Epoch) - [double]$s.atualizado_em, 1)
      Titulo     = $s.titulo
      Caminho    = $s.caminho
      Modificado = $s.modificado
      Ocupado    = $s.ocupado
      Pausado    = $s.pausado
      Job        = $s.job_atual
      Ponte      = $s.versao_ponte
      SketchUp   = $s.sketchup
      UltimoErro = $s.ultimo_erro
      Pasta      = $d.FullName
    }
  }
  return $lista
}

function Escolher-Instancia {
  $vivas = @(Obter-Instancias | Where-Object { $_.Viva })
  if ($vivas.Count -eq 0) {
    Sair 2 ("Nenhum SketchUp com a ponte ativa.`n" +
      "Confira: (1) o SketchUp está aberto; (2) a ponte está instalada (scripts\instalar-ponte.ps1);`n" +
      "(3) o SketchUp foi reiniciado depois da instalação; (4) a extensão 'Claude Ponte' está ativa no Gerenciador de Extensões.")
  }
  if ($Alvo) {
    $n = 0
    if ([int]::TryParse($Alvo, [ref]$n)) {
      $achou = @($vivas | Where-Object { $_.Pid -eq $n })
    } else {
      $achou = @($vivas | Where-Object { ("" + $_.Titulo) -like "*$Alvo*" -or ("" + $_.Caminho) -like "*$Alvo*" })
    }
    if ($achou.Count -eq 1) { return $achou[0] }
    if ($achou.Count -eq 0) { Sair 2 ("Nenhum SketchUp corresponde a '$Alvo'. Abertos:`n" + (Formatar-Lista $vivas)) }
    Sair 3 ("Mais de um SketchUp corresponde a '$Alvo'. Use o PID:`n" + (Formatar-Lista $achou))
  }
  if ($vivas.Count -eq 1) { return $vivas[0] }
  Sair 3 ("Há $($vivas.Count) SketchUp abertos. Escolha com -Alvo <PID ou trecho do título>:`n" + (Formatar-Lista $vivas))
}

function Formatar-Lista($itens) {
  $linhas = @()
  foreach ($i in $itens) {
    $estado = @()
    if ($i.Ocupado) { $estado += "ocupado ($($i.Job))" }
    if ($i.Pausado) { $estado += 'pausado' }
    if ($i.Modificado) { $estado += 'não salvo' }
    if ($i.Batimento -gt 8) { $estado += "sem batimento há $($i.Batimento) s (janela modal?)" }
    $titulo = if ($i.Titulo) { $i.Titulo } else { '(sem nome)' }
    $linhas += "  PID $($i.Pid) · $titulo · ponte $($i.Ponte) · SketchUp $($i.SketchUp) · $($estado -join ', ')"
    if ($i.Caminho) { $linhas += "      $($i.Caminho)" }
  }
  return ($linhas -join "`n")
}

function Sem-Escape([string]$json) {
  # ConvertTo-Json do PowerShell 5.1 escapa alguns caracteres (\u00e7, \u003c). Devolve legível,
  # sem tocar em caracteres de controle nem em barras escapadas.
  return [regex]::Replace($json, '(?<!\\)\\u(00[2-7][0-9a-fA-F]|00[89a-fA-F][0-9a-fA-F]|0[1-9a-fA-F][0-9a-fA-F]{2}|[1-9a-fA-F][0-9a-fA-F]{3})', { param($x) [string][char][Convert]::ToInt32($x.Groups[1].Value, 16) })
}

function Dialogos-Abertos([int]$processo) {
  try {
    $txt = & (Join-Path $PSScriptRoot 'janelas.ps1') -ProcessoId $processo | Out-String
    return $txt.Trim()
  } catch { return '' }
}

function Rodar-Codigo([string]$codigo) {
  $inst = Escolher-Instancia
  $entrada = Join-Path $inst.Pasta 'entrada'
  $processando = Join-Path $inst.Pasta 'processando'
  $saida = Join-Path $inst.Pasta 'saida'
  $id = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + ([guid]::NewGuid().ToString('N').Substring(0, 6))
  $tmp = Join-Path $entrada "$id.tmp"
  $job = Join-Path $entrada "$id.rb"
  $resultado = Join-Path $saida "$id.json"

  [System.IO.File]::WriteAllText($tmp, $codigo, $Utf8SemBom)
  Move-Item -LiteralPath $tmp -Destination $job

  $inicio = Get-Date
  $inicioExec = $null
  $avisouModal = $false
  while ($true) {
    if (Test-Path -LiteralPath $resultado) { break }
    $decorrido = ((Get-Date) - $inicio).TotalSeconds

    # Timers do SketchUp continuam disparando com janela modal aberta, então o batimento não
    # prova nada. O sinal é o tempo do script em execução: passou de 10 s, mostra os diálogos.
    $rodando = Test-Path -LiteralPath (Join-Path $processando "$id.rb")
    if ($rodando -and -not $inicioExec) { $inicioExec = Get-Date }
    if ($rodando -and $inicioExec -and ((Get-Date) - $inicioExec).TotalSeconds -gt 10 -and -not $avisouModal) {
      $avisouModal = $true
      $dlg = Dialogos-Abertos $inst.Pid
      if ($dlg -match 'DIÁLOGO') {
        [Console]::Error.WriteLine("Aviso: script rodando há mais de 10 s e há diálogo aberto no SketchUp (provável causa da espera):`n$dlg")
      }
    }

    if ($decorrido -gt $Tempo) {
      if (Test-Path -LiteralPath $job) {
        $retirado = $false
        try { Remove-Item -LiteralPath $job -Force -ErrorAction Stop; $retirado = $true } catch { }
        if ($retirado) {
          Sair 4 "Tempo esgotado ($Tempo s) e o script NEM COMEÇOU (a ponte estava ocupada ou pausada). Ele foi retirado da fila e não vai rodar."
        }
      }
      $dlg = Dialogos-Abertos $inst.Pid
      Sair 4 ("Tempo esgotado ($Tempo s) com o script AINDA RODANDO no SketchUp (id $id).`n" +
        "Não repita o script: ele pode terminar sozinho. Resultado vai aparecer em: $resultado`n" +
        "Janelas do SketchUp agora:`n$dlg")
    }
    Start-Sleep -Milliseconds 200
  }

  Start-Sleep -Milliseconds 50
  $bruto = [System.IO.File]::ReadAllText($resultado, [System.Text.Encoding]::UTF8)
  if ($Json) { Write-Output $bruto; if ($bruto -match '"ok"\s*:\s*true') { exit 0 } else { exit 1 } }

  try {
    $r = $bruto | ConvertFrom-Json
  } catch {
    # ConvertFrom-Json do PowerShell 5.1 tem limite (~2 MB): mostra cru.
    Write-Output 'Resultado grande demais para formatar; JSON cru:'
    Write-Output $bruto
    if ($bruto -match '"ok"\s*:\s*true') { exit 0 } else { exit 1 }
  }
  $estado = if ($r.modificado) { 'modelo com alterações não salvas' } else { 'modelo sem alterações pendentes' }
  if ($r.ok) {
    Write-Output "OK em $($r.duracao_s) s · $($r.titulo) · $estado"
  } else {
    $linha = if ($r.erro.linha) { " (linha $($r.erro.linha) do script)" } else { '' }
    Write-Output "ERRO Ruby em $($r.duracao_s) s: $($r.erro.classe): $($r.erro.mensagem)$linha"
  }
  if ($r.saida) { Write-Output '--- saída (puts) ---'; Write-Output ($r.saida.TrimEnd()) }
  if ($r.ok -and $null -ne $r.valor) {
    Write-Output '--- valor ---'
    Write-Output (Sem-Escape (ConvertTo-Json -InputObject $r.valor -Depth 20))
  }
  if (-not $r.ok -and $r.erro.backtrace) {
    Write-Output '--- rastro ---'
    $r.erro.backtrace | Select-Object -First 6 | ForEach-Object { Write-Output "  $_" }
  }
  if ($r.ok) { exit 0 } else { exit 1 }
}

switch ($Comando) {
  'status' {
    $todas = @(Obter-Instancias)
    $vivas = @($todas | Where-Object { $_.Viva })
    if ($Json) { Write-Output (Sem-Escape (ConvertTo-Json -InputObject @($vivas) -Depth 5)); exit 0 }
    if ($vivas.Count -eq 0) { Sair 2 'Nenhum SketchUp com a ponte ativa.' }
    Write-Output "SketchUp com a ponte ativa: $($vivas.Count)"
    Write-Output (Formatar-Lista $vivas)
    foreach ($v in $vivas) { if ($v.UltimoErro) { Write-Output "  Último erro interno da ponte (PID $($v.Pid)): $($v.UltimoErro)" } }
    $mortas = @($todas | Where-Object { -not $_.Viva }).Count
    if ($mortas -gt 0) { Write-Output "($mortas pasta(s) de SketchUp já fechado; 'sk.ps1 limpar' remove)" }
    exit 0
  }
  'rodar' {
    if (-not $Entrada) { Sair 5 'Uso: sk.ps1 rodar <arquivo.rb>' }
    if (-not (Test-Path -LiteralPath $Entrada)) { Sair 5 "Arquivo não encontrado: $Entrada" }
    $codigo = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Entrada).Path, [System.Text.Encoding]::UTF8)
    Rodar-Codigo $codigo
  }
  'eval' {
    if (-not $Entrada) { Sair 5 'Uso: sk.ps1 eval "<código ruby>"' }
    Rodar-Codigo $Entrada
  }
  'console' {
    $inst = Escolher-Instancia
    $arq = Join-Path $inst.Pasta 'console.log'
    if (-not (Test-Path -LiteralPath $arq)) { Sair 0 'Console vazio (ou espelho desligado).' }
    Get-Content -LiteralPath $arq -Encoding UTF8 -Tail $Linhas
    exit 0
  }
  'limpar' {
    $removidas = 0
    foreach ($i in @(Obter-Instancias | Where-Object { -not $_.Viva })) {
      Remove-Item -LiteralPath $i.Pasta -Recurse -Force -ErrorAction SilentlyContinue
      $removidas++
    }
    Sair 0 "Pastas removidas: $removidas"
  }
}
