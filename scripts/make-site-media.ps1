# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Fabrique les images du site (docs\gallery\img\<categorie>-<nom>.jpg, 480x270) a partir des exemples de la galerie, avec le programme lui-meme.
.DESCRIPTION
  Meme methode que scripts\make-gallery-thumbs.ps1 : une image a 3 s pour un shader seul, une video de 4 s dont on garde la derniere image pour un shader a passes.
  Les images qui existent ne sont pas refaites sauf avec -Force. ffmpeg (bin\ffmpeg.exe) reduit et compresse. Les fichiers temporaires sont effaces.
#>
param([switch]$Force)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$exe = Resolve-Path "bin\ShaderToMP4.exe"
$ffmpeg = Resolve-Path "bin\ffmpeg.exe"
$exts = ".glsl", ".hlsl", ".wgsl", ".frag"
$out = "docs\gallery\img"
New-Item -ItemType Directory -Force $out | Out-Null
$tmp = Join-Path $env:TEMP "site-media"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $tmp | Out-Null
$files = Get-ChildItem examples\gallery -Recurse -File | Where-Object { $exts -contains $_.Extension.ToLower() -and ($_.Name.Split('.').Count -eq 2) }
$count = 0
$log = Join-Path $tmp "log.txt"
foreach ($f in $files) {
  $cat = $f.Directory.Name
  $jpg = Join-Path $out "$cat-$($f.BaseName).jpg"
  if ((Test-Path $jpg) -and -not $Force) { continue }
  $hasPass = @(Get-ChildItem $f.DirectoryName -Filter ($f.BaseName + ".*") | Where-Object { $_.Name.Split('.').Count -ge 3 -and $exts -contains $_.Extension.ToLower() }).Count -gt 0
  if ($hasPass) {
    $null = Start-Process $exe -ArgumentList "--render", "`"$($f.FullName)`"", "--start=0", "--duration=4", "--fps=15", "--width=480", "--height=270", "--outdir=`"$tmp`"", "--exists=overwrite", "--audio=", "--progress=none" -Wait -PassThru -NoNewWindow -RedirectStandardOutput $log
    $video = Get-ChildItem $tmp -Filter ($f.BaseName + "*.mp4") | Select-Object -First 1
    if (-not $video) { throw "$($f.Name) : pas de video" }
    & $ffmpeg -y -loglevel error -sseof -0.2 -i $video.FullName -frames:v 1 -q:v 4 $jpg
    Remove-Item $video.FullName -Force
  } else {
    $png = Join-Path $f.DirectoryName ($f.BaseName + ".png")
    $null = Start-Process $exe -ArgumentList "--render", "`"$($f.FullName)`"", "--png", "--start=3", "--audio=", "--width=480", "--height=270", "--progress=none" -Wait -PassThru -NoNewWindow -RedirectStandardOutput $log
    if (-not (Test-Path $png)) { throw "$($f.Name) : pas d'image" }
    & $ffmpeg -y -loglevel error -i $png -q:v 4 $jpg
    Remove-Item $png -Force
  }
  $count++
  Write-Output "image : $jpg"
}
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "$count image(s) faite(s)."
