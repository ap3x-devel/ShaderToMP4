# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Fabrique les illustrations des notes de version (docs\releases\<version>\) avec le programme lui-meme : une mosaique d'images et deux courtes animations GIF, rendues a partir d'exemples de la galerie, plus le texte en anglais et en francais.
.DESCRIPTION
  Les images sont des rendus de bin\ShaderToMP4.exe (une image a 3 s ; pour un shader a passes, la derniere image d'une video de 4 s), jamais des maquettes.
  Resultat : mosaic.jpg, clip-1.gif, clip-2.gif, <categorie>-<nom>.jpg, illustrations.md et illustrations.fr.md. Les images sont publiees avec le site (GitHub Pages) ; le job de
  publication ajoute les deux textes aux notes de la version (.github\workflows\build.yml). Pousser le site AVANT de creer l'etiquette de version.
.PARAMETER Version
  Version des notes (defaut : APP_VER_STR de src\app_info.h).
.PARAMETER Examples
  Exemples de la galerie, "<categorie>/<nom>", six pour la mosaique ; les deux premiers font aussi les animations.
#>
param(
  [string]$Version = "",
  [string[]]$Examples = @("autres/hlsl_plasma", "autres/wgsl_tunnel", "autres/glsl430_plasma", "fractales/julia", "raymarching/metaballs", "post/lueur_bloom")
)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$utf8 = New-Object System.Text.UTF8Encoding($false)
if (-not $Version) { $Version = [regex]::Match([System.IO.File]::ReadAllText((Resolve-Path "src\app_info.h").Path), 'APP_VER_STR\s+"([^"]+)"').Groups[1].Value }
if ($Examples.Count -ne 6) { throw "six exemples sont attendus pour la mosaique ($($Examples.Count) donnes)" }
$exe = (Resolve-Path "bin\ShaderToMP4.exe").Path
$ffmpeg = (Resolve-Path "bin\ffmpeg.exe").Path
$exts = ".glsl", ".hlsl", ".wgsl", ".frag"
$out = "docs\releases\$Version"
New-Item -ItemType Directory -Force $out | Out-Null
$tmp = Join-Path $env:TEMP "release-media"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $tmp | Out-Null
$log = Join-Path $tmp "log.txt"

function Find-Shader([string]$spec) {
  $cat, $name = $spec -split '/', 2
  foreach ($e in $exts) { $p = "examples\gallery\$cat\$name$e"; if (Test-Path $p) { return (Get-Item $p) } }
  throw "exemple introuvable : $spec"
}
function Title-Of([System.IO.FileInfo]$f, [string]$lang) {
  $t = [System.IO.File]::ReadAllText($f.FullName, $utf8)
  $m = [regex]::Match($t, "(?m)^//\s*${lang}:\s*(.+?)\s+—\s+")
  if ($m.Success) { $m.Groups[1].Value.Trim() } else { $f.BaseName }
}
function Run-Program([string[]]$arguments) {
  $p = Start-Process $exe -ArgumentList $arguments -Wait -PassThru -NoNewWindow -RedirectStandardOutput $log
  if ($p.ExitCode -ne 0) { throw "rendu refuse (code $($p.ExitCode)) : $($arguments -join ' ')" }
}

# 1. images fixes
$stills = @()
foreach ($spec in $Examples) {
  $f = Find-Shader $spec
  $jpg = Join-Path $out (($spec -replace '/', '-') + ".jpg")
  $hasPass = @(Get-ChildItem $f.DirectoryName | Where-Object { $_.Name.StartsWith($f.BaseName + ".") -and $_.Name.Split('.').Count -ge 3 -and $exts -contains $_.Extension.ToLower() }).Count -gt 0
  if ($hasPass) {
    Run-Program @("--render", "`"$($f.FullName)`"", "--start=0", "--duration=4", "--fps=15", "--width=640", "--height=360", "--outdir=`"$tmp`"", "--exists=overwrite", "--audio=", "--progress=none")
    $video = Get-ChildItem $tmp -Filter ($f.BaseName + "*.mp4") | Select-Object -First 1
    if (-not $video) { throw "$spec : pas de video" }
    & $ffmpeg -y -loglevel error -sseof -0.2 -i $video.FullName -frames:v 1 -q:v 3 $jpg
    Remove-Item $video.FullName -Force
  } else {
    $png = Join-Path $f.DirectoryName ($f.BaseName + ".png")
    Run-Program @("--render", "`"$($f.FullName)`"", "--png", "--start=3", "--audio=", "--width=640", "--height=360", "--progress=none")
    if (-not (Test-Path $png)) { throw "$spec : pas d'image" }
    & $ffmpeg -y -loglevel error -i $png -q:v 3 $jpg
    Remove-Item $png -Force
  }
  $stills += $jpg
  Write-Output "image : $jpg"
}

# 2. mosaique 3 x 2
$inputs = @(); $chain = ""; $labels = ""
for ($i = 0; $i -lt 6; $i++) { $inputs += "-i"; $inputs += $stills[$i]; $chain += "[$i`:v]scale=320:180[a$i];"; $labels += "[a$i]" }
$chain += $labels + "xstack=inputs=6:layout=0_0|320_0|640_0|0_180|320_180|640_180"
& $ffmpeg -y -loglevel error @inputs -filter_complex $chain -frames:v 1 -q:v 3 (Join-Path $out "mosaic.jpg")
Write-Output "mosaique : $out\mosaic.jpg"

# 3. deux animations GIF rendues par le programme (boucle de 3 s)
for ($i = 0; $i -lt 2; $i++) {
  $f = Find-Shader $Examples[$i]
  Run-Program @("--render", "`"$($f.FullName)`"", "--container=gif", "--start=0", "--duration=3", "--fps=15", "--width=384", "--height=216", "--outdir=`"$tmp`"", "--exists=overwrite", "--audio=", "--progress=none")
  $gif = Get-ChildItem $tmp -Filter ($f.BaseName + "*.gif") | Select-Object -First 1
  if (-not $gif) { throw "$($Examples[$i]) : pas de GIF" }
  Move-Item $gif.FullName (Join-Path $out "clip-$($i + 1).gif") -Force
  Write-Output ("animation : {0}\clip-{1}.gif ({2:N0} Ko)" -f $out, ($i + 1), ((Get-Item (Join-Path $out "clip-$($i + 1).gif")).Length / 1KB))
}

# 4. textes des notes
$base = "https://ap3x-devel.github.io/ShaderToMP4/releases/$Version"
$files = $Examples | ForEach-Object { Find-Shader $_ }
$namesEn = ($files | ForEach-Object { Title-Of $_ "en" }) -join ", "
$namesFr = ($files | ForEach-Object { Title-Of $_ "fr" }) -join ", "
$head = "<!-- SPDX-License-Identifier: GPL-3.0-or-later - Copyright (C) 2026 Patrick JAILLET -->`n`n"
$en = $head + @"
### Illustrations

![Six frames rendered by ShaderToMP4]($base/mosaic.jpg)

![Animation rendered by ShaderToMP4: $(Title-Of $files[0] 'en')]($base/clip-1.gif) ![Animation rendered by ShaderToMP4: $(Title-Of $files[1] 'en')]($base/clip-2.gif)

Rendered by ShaderToMP4 itself from the example gallery (``scripts/make-release-media.ps1``): $namesEn.

"@
$fr = $head + @"
### Illustrations (français)

![Six images rendues par ShaderToMP4]($base/mosaic.jpg)

![Animation rendue par ShaderToMP4 : $(Title-Of $files[0] 'fr')]($base/clip-1.gif) ![Animation rendue par ShaderToMP4 : $(Title-Of $files[1] 'fr')]($base/clip-2.gif)

Rendu par ShaderToMP4 lui-même à partir de la galerie d'exemples (``scripts/make-release-media.ps1``) : $namesFr.

"@
[System.IO.File]::WriteAllText((Join-Path (Get-Location) "$out\illustrations.md"), ($en -replace "`r`n", "`n"), $utf8)
[System.IO.File]::WriteAllText((Join-Path (Get-Location) "$out\illustrations.fr.md"), ($fr -replace "`r`n", "`n"), $utf8)
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "Illustrations de la version $Version : $out"
