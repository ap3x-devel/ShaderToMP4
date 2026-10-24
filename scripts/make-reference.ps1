# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Ecrit la documentation de reference produite par le programme lui-meme : docs\reference\<sujet>.<langue>.md (reglages, format du projet, ligne de commande).
.DESCRIPTION
  Appelle `ShaderToMP4 --dump-reference=<sujet> --lang=<langue>` (voir src\core\reference.cpp) : le texte vient du code (valeurs par defaut ecrites dans config.ini,
  champs du fichier projet, options de --help) et des fichiers de langue, rien n'est recopie a la main. Avec -Check, ne rien ecrire et echouer (code 1) si un fichier
  differe de ce que le programme produit (utilise par scripts\check-repo.ps1).
#>
param([string]$Exe = "bin\ShaderToMP4.exe", [switch]$Check)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$exeFull = (Resolve-Path $Exe).Path
$out = "docs\reference"
New-Item -ItemType Directory -Force $out | Out-Null
$bad = 0
foreach ($lang in "en", "fr") {
  foreach ($topic in "settings", "project", "cli") {
    $tmp = [System.IO.Path]::GetTempFileName()
    $p = Start-Process $exeFull -ArgumentList "--dump-reference=$topic", "--lang=$lang" -Wait -PassThru -NoNewWindow -RedirectStandardOutput $tmp
    if ($p.ExitCode -ne 0) { throw "--dump-reference=$topic a echoue (code $($p.ExitCode))" }
    $text = ([System.IO.File]::ReadAllText($tmp, [System.Text.Encoding]::UTF8) -replace "`r`n", "`n")
    Remove-Item $tmp -Force
    $file = Join-Path $out $(if ($lang -eq "en") { "$topic.md" } else { "$topic.fr.md" })
    $header = "<!-- SPDX-License-Identifier: GPL-3.0-or-later - Copyright (C) 2026 Patrick JAILLET -->`n<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->`n`n"
    $full = $header + $text
    if ($Check) {
      $have = if (Test-Path $file) { ([System.IO.File]::ReadAllText((Resolve-Path $file), [System.Text.Encoding]::UTF8) -replace "`r`n", "`n") } else { "" }
      if ($have -ne $full) { Write-Output "differe : $file"; $bad++ }
    } else {
      [System.IO.File]::WriteAllText((Join-Path (Get-Location) $file), $full, (New-Object System.Text.UTF8Encoding($false)))
      Write-Output $file
    }
  }
}
if ($bad -gt 0) { exit 1 }
