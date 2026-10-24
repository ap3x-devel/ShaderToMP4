# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Fabrique les vignettes (128x72, BMP 24 bits) des exemples de la galerie qui n'en ont pas, ou de ceux demandes.
.DESCRIPTION
  Rend chaque shader avec bin\ShaderToMP4.exe : une image a 3 s pour un shader seul ; une video de 4 s dont on garde la derniere image pour un shader a passes
  (le tampon doit avoir tourne). ffmpeg (bin\ffmpeg.exe) reduit l'image. Les fichiers temporaires sont effaces.
.PARAMETER Folder
  Dossier de la galerie a traiter (ex. examples\gallery\autres).
.PARAMETER Force
  Refait aussi les vignettes qui existent.
#>
param([string]$Folder = "examples\gallery", [switch]$Force)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$exe = Resolve-Path "bin\ShaderToMP4.exe"
$ffmpeg = Resolve-Path "bin\ffmpeg.exe"
$exts = ".glsl", ".hlsl", ".wgsl", ".frag"
$tmp = Join-Path $env:TEMP "gallery-thumbs"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $tmp | Out-Null
$files = Get-ChildItem $Folder -Recurse -File | Where-Object { $exts -contains $_.Extension.ToLower() -and ($_.Name.Split('.').Count -eq 2) }
$count = 0
foreach ($f in $files) {
  $bmp = Join-Path $f.DirectoryName ($f.BaseName + ".bmp")
  if ((Test-Path $bmp) -and -not $Force) { continue }
  $hasPass = @(Get-ChildItem $f.DirectoryName -Filter ($f.BaseName + ".*") | Where-Object { $_.Name.Split('.').Count -ge 3 -and $exts -contains $_.Extension.ToLower() }).Count -gt 0
  if ($hasPass) {
    $p = Start-Process $exe -ArgumentList "--render", "`"$($f.FullName)`"", "--start=0", "--duration=4", "--fps=15", "--width=256", "--height=144", "--outdir=`"$tmp`"", "--exists=overwrite", "--audio=", "--progress=none" -Wait -PassThru -NoNewWindow
    $video = Get-ChildItem $tmp -Filter ($f.BaseName + "*.mp4") | Select-Object -First 1
    if (-not $video) { throw "$($f.Name) : pas de video" }
    & $ffmpeg -y -loglevel error -sseof -0.2 -i $video.FullName -frames:v 1 -vf "scale=128:72:flags=area" $bmp
    Remove-Item $video.FullName -Force
  } else {
    $png = Join-Path $f.DirectoryName ($f.BaseName + ".png")
    $p = Start-Process $exe -ArgumentList "--render", "`"$($f.FullName)`"", "--png", "--start=3", "--width=256", "--height=144", "--progress=none" -Wait -PassThru -NoNewWindow
    if (-not (Test-Path $png)) { throw "$($f.Name) : pas d'image" }
    & $ffmpeg -y -loglevel error -i $png -vf "scale=128:72:flags=area" $bmp
    Remove-Item $png -Force
  }
  $count++
  Write-Output "vignette : $($bmp.Substring((Get-Location).Path.Length + 1))"
}
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "$count vignette(s) faite(s)."
