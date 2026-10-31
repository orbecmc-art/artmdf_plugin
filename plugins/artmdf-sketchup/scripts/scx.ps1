<#
.SYNOPSIS
  Lê e compara arquivos de usinagem .scx do UpMobb (XML), sem depender do esquema exato.

.DESCRIPTION
  Resumo:     scx.ps1 -Arquivo "C:\...\usinagens\PROJETO.scx"
  Peça:       scx.ps1 -Arquivo "...scx" -Peca "Porta Esquerda"
  Comparar:   scx.ps1 -Arquivo "novo.scx" -Comparar "anterior.scx"
  Guardar cópia antes de reexportar:
              scx.ps1 -Arquivo "...scx" -Guardar      (copia para ...\usinagens\_anteriores\)

  Códigos de saída: 0 ok (ou arquivos IGUAIS) · 1 arquivos DIFERENTES (não é erro) · 2 arquivo não encontrado.

  O resumo conta elementos por tipo de tag, valores do atributo Type e lista as peças
  (qualquer elemento com atributo de nome/descrição). A comparação normaliza o XML
  e mostra o que entrou e o que saiu, linha a linha.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Arquivo,
  [string]$Comparar,
  [string]$Peca,
  [switch]$Guardar,
  [int]$Max = 80
)

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch { }

function Carregar([string]$caminho) {
  if (-not (Test-Path -LiteralPath $caminho)) { [Console]::Out.WriteLine("Arquivo não encontrado: $caminho"); exit 2 }
  $x = New-Object System.Xml.XmlDocument
  $x.PreserveWhitespace = $false
  $x.Load((Resolve-Path -LiteralPath $caminho).Path)
  return $x
}

function Nome-Do-No($n) {
  foreach ($a in @('Name', 'name', 'Nome', 'nome', 'Description', 'Descricao', 'Desc', 'Label')) {
    if ($n.Attributes -and $n.Attributes[$a]) { return $n.Attributes[$a].Value }
  }
  return $null
}

function Linhas-Normalizadas($doc) {
  # Uma linha por elemento: caminho de tags + atributos ordenados. Independe de indentação e ordem de atributos.
  $saida = New-Object System.Collections.Generic.List[string]
  $pilha = New-Object System.Collections.Stack
  function Visitar($no, [string]$caminho) {
    if ($no.NodeType -ne [System.Xml.XmlNodeType]::Element) { return }
    $nome = Nome-Do-No $no
    $rotulo = if ($nome) { "$($no.get_Name())[$nome]" } else { $no.get_Name() }
    $atual = if ($caminho) { "$caminho/$rotulo" } else { $rotulo }
    $attrs = @()
    foreach ($a in $no.Attributes) { $attrs += "$($a.Name)=$($a.Value)" }
    $attrs = $attrs | Sort-Object
    $texto = ''
    if ($no.ChildNodes.Count -eq 1 -and $no.FirstChild.NodeType -eq [System.Xml.XmlNodeType]::Text) { $texto = " = $($no.InnerText.Trim())" }
    $saida.Add("$atual {$($attrs -join '; ')}$texto")
    foreach ($f in $no.ChildNodes) { Visitar $f $atual }
  }
  Visitar $doc.DocumentElement ''
  return $saida
}

if ($Guardar) {
  $pasta = Join-Path (Split-Path -Parent (Resolve-Path -LiteralPath $Arquivo).Path) '_anteriores'
  New-Item -ItemType Directory -Path $pasta -Force | Out-Null
  $info = Get-Item -LiteralPath $Arquivo
  $destino = Join-Path $pasta ("{0} {1}{2}" -f $info.BaseName, $info.LastWriteTime.ToString('yyyy-MM-dd HHmmss'), $info.Extension)
  Copy-Item -LiteralPath $Arquivo -Destination $destino -Force
  Write-Output "Cópia guardada: $destino"
  exit 0
}

$doc = Carregar $Arquivo
$info = Get-Item -LiteralPath $Arquivo

if ($Comparar) {
  $antigo = Carregar $Comparar
  $a = Linhas-Normalizadas $antigo
  $b = Linhas-Normalizadas $doc
  $dif = Compare-Object -ReferenceObject @($a) -DifferenceObject @($b)
  if (-not $dif) {
    Write-Output "IGUAIS: nenhuma diferença de conteúdo entre`n  anterior: $Comparar`n  novo:     $Arquivo"
    exit 0
  }
  $saiu = @($dif | Where-Object { $_.SideIndicator -eq '<=' })
  $entrou = @($dif | Where-Object { $_.SideIndicator -eq '=>' })
  Write-Output "DIFERENTES: $($saiu.Count) linha(s) só no anterior, $($entrou.Count) só no novo."
  Write-Output '--- só no anterior (saiu) ---'
  $saiu | Select-Object -First $Max | ForEach-Object { Write-Output "  - $($_.InputObject)" }
  Write-Output '--- só no novo (entrou) ---'
  $entrou | Select-Object -First $Max | ForEach-Object { Write-Output "  + $($_.InputObject)" }
  exit 1
}

$todos = $doc.SelectNodes('//*')
Write-Output "Arquivo: $Arquivo"
Write-Output "Gravado em: $($info.LastWriteTime.ToString('dd/MM/yyyy HH:mm:ss')) · $([math]::Round($info.Length / 1KB, 1)) KB · raiz <$($doc.DocumentElement.get_Name())> · $($todos.Count) elementos"

Write-Output '--- elementos por tag ---'
$todos | Group-Object { $_.get_Name() } | Sort-Object Count -Descending | Select-Object -First 25 | ForEach-Object { Write-Output ("  {0,-28} {1}" -f $_.Name, $_.Count) }

$comType = @($todos | Where-Object { $_.Attributes -and $_.Attributes['Type'] })
if ($comType.Count -gt 0) {
  Write-Output '--- atributo Type (por tag) ---'
  $comType | Group-Object { "$($_.get_Name()) Type=$($_.Attributes['Type'].Value)" } | Sort-Object Name | ForEach-Object { Write-Output ("  {0,-34} {1}" -f $_.Name, $_.Count) }
}

$nomeados = @($todos | Where-Object { Nome-Do-No $_ })
$tagPeca = ($nomeados | Group-Object { $_.get_Name() } | Sort-Object Count -Descending | Select-Object -First 1).Name
if ($tagPeca) {
  $pecas = @($nomeados | Where-Object { $_.get_Name() -eq $tagPeca })
  if ($Peca) { $pecas = @($pecas | Where-Object { (Nome-Do-No $_) -like "*$Peca*" }) }
  Write-Output "--- peças (<$tagPeca>): $($pecas.Count) ---"
  foreach ($p in ($pecas | Select-Object -First $Max)) {
    $filhos = @($p.SelectNodes('.//*'))
    $tipos = ($filhos | Where-Object { $_.Attributes -and $_.Attributes['Type'] } | Group-Object { $_.Attributes['Type'].Value } | ForEach-Object { "Type $($_.Name)×$($_.Count)" }) -join ', '
    $medidas = @()
    foreach ($a in @('Length', 'Width', 'Thickness', 'Comprimento', 'Largura', 'Espessura', 'DX', 'DY', 'DZ')) {
      if ($p.Attributes[$a]) { $medidas += "$a=$($p.Attributes[$a].Value)" }
    }
    Write-Output ("  {0} · {1} · usinagens: {2}" -f (Nome-Do-No $p), ($medidas -join ' '), $(if ($tipos) { $tipos } else { 'nenhuma' }))
    if ($Peca) {
      foreach ($f in ($filhos | Select-Object -First $Max)) {
        $attrs = @(); foreach ($a in $f.Attributes) { $attrs += "$($a.Name)=$($a.Value)" }
        Write-Output "      <$($f.get_Name())> $($attrs -join ' ')"
      }
    }
  }
}
exit 0
