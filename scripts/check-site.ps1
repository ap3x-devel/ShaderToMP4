# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Verifie le site (docs\) : pages a jour, liens, structure, contrastes, et pages ouvertes dans un vrai navigateur (Edge sans fenetre).
.DESCRIPTION
  1. les pages produites par scripts\make-site.ps1 sont celles que le script produit aujourd'hui (comparaison avec un dossier temporaire) ;
  2. chaque lien et chaque image relatifs mene a un fichier du site, chaque ancre a un id de la page visee ;
  3. chaque page a une langue, un titre, un seul h1, un lien d'evitement, des images avec alt, aucun id en double ;
  4. les couleurs du texte ont un contraste d'au moins 4,5 contre leur fond (WCAG AA) ;
  5. des pages sont ouvertes avec Edge (--headless --dump-dom) : le script s'execute, le filtre de la galerie et la recherche repondent.
  -NoBrowser saute l'etape 5 (si Edge est absent). Code de sortie 1 s'il y a un probleme.
#>
param([switch]$NoBrowser)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$problems = New-Object System.Collections.ArrayList
function Fail([string]$m) { [void]$problems.Add($m); Write-Host "  PROBLEME : $m" -ForegroundColor Red }
function Read-Text([string]$p) { ([System.IO.File]::ReadAllText($p, $utf8) -replace "`r`n", "`n") }
$docs = (Resolve-Path "docs").Path

# ---------- 1. Pages a jour ----------
Write-Host "== Pages produites"
# dans le depot et non dans %TEMP% : sur les machines d'integration %TEMP% est un nom court (RUNNER~1) et les chemins relatifs ne se calculent plus
$tmp = Join-Path (Get-Location).Path "site-check-tmp"
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $tmp | Out-Null
Copy-Item "docs\assets" (Join-Path $tmp "assets") -Recurse
New-Item -ItemType Directory -Force (Join-Path $tmp "x") | Out-Null
$null = & powershell -NoProfile -ExecutionPolicy Bypass -File scripts\make-site.ps1 -Out $tmp
foreach ($f in (Get-ChildItem $tmp -Recurse -File | Where-Object { $_.Extension -in ".html", ".xml" -or $_.Name -eq "search-data.js" })) {
  $rel = $f.FullName.Substring($tmp.Length + 1)
  $mine = Join-Path $docs $rel
  if (-not (Test-Path $mine)) { Fail "$rel n'existe pas dans docs (lancer scripts\make-site.ps1)"; continue }
  if ((Read-Text $f.FullName) -ne (Read-Text $mine)) { Fail "$rel differe de ce que scripts\make-site.ps1 produit" }
}
# pages produites qui ne sont plus produites
foreach ($dir in "guide", "gallery", "reference") {
  foreach ($f in (Get-ChildItem (Join-Path $docs $dir) -Recurse -File -Filter *.html)) {
    $rel = $f.FullName.Substring($docs.Length + 1)
    if (-not (Test-Path (Join-Path $tmp $rel))) { Fail "$rel n'est plus produit par scripts\make-site.ps1 (a supprimer)" }
  }
}
Remove-Item $tmp -Recurse -Force

# ---------- 2 et 3. Liens et structure ----------
Write-Host "== Liens et structure"
$pages = @(Get-ChildItem $docs -Recurse -File -Filter *.html)
$idCache = @{}
function Ids-Of([string]$path) {
  if (-not $idCache.ContainsKey($path)) {
    $t = Read-Text $path
    $set = @{}
    foreach ($m in [regex]::Matches($t, '\sid="([^"]+)"')) { $set[$m.Groups[1].Value] = $true }
    $idCache[$path] = $set
  }
  $idCache[$path]
}
foreach ($pg in $pages) {
  $rel = $pg.FullName.Substring($docs.Length + 1)
  $t = Read-Text $pg.FullName
  if ($t -notmatch '<html lang="[a-z]{2}"') { Fail "$rel : pas de langue sur <html>" }
  if ($t -notmatch '<title>[^<]+</title>') { Fail "$rel : pas de titre" }
  if ([regex]::Matches($t, '<h1[ >]').Count -ne 1) { Fail "$rel : il faut un seul h1 ($([regex]::Matches($t, '<h1[ >]').Count))" }
  if ($t -notmatch 'class="skip"') { Fail "$rel : pas de lien d'evitement" }
  if ($t -notmatch '<meta name="viewport"') { Fail "$rel : pas de meta viewport" }
  foreach ($m in [regex]::Matches($t, '<img\b[^>]*>')) { if ($m.Value -notmatch '\salt="') { Fail "$rel : image sans attribut alt : $($m.Value.Substring(0, [Math]::Min(80, $m.Value.Length)))" } }
  $seen = @{}
  foreach ($m in [regex]::Matches($t, '\sid="([^"]+)"')) {
    $id = $m.Groups[1].Value
    if ($seen.ContainsKey($id) -and $id -ne "g") { Fail "$rel : id en double : $id" }
    $seen[$id] = $true
  }
  foreach ($m in [regex]::Matches($t, '<(?:a|link|script|img)\b[^>]*?\s(?:href|src)="([^"]*)"')) {
    $u = [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
    if ($u -eq "" -or $u -match '^(https?:|mailto:|data:|javascript:)') { continue }
    $frag = ""; $path = $u
    if ($u.Contains("#")) { $frag = $u.Substring($u.IndexOf("#") + 1); $path = $u.Substring(0, $u.IndexOf("#")) }
    if ($path.Contains("?")) { $path = $path.Substring(0, $path.IndexOf("?")) }
    $target = if ($path -eq "") { $pg.FullName } else { [System.IO.Path]::GetFullPath((Join-Path $pg.DirectoryName ($path -replace '/', '\'))) }
    if (-not (Test-Path $target -PathType Leaf)) { Fail "$rel : lien casse : $u"; continue }
    if ($frag -ne "" -and $target.EndsWith(".html")) { if (-not (Ids-Of $target).ContainsKey($frag)) { Fail "$rel : ancre introuvable : $u" } }
  }
}
Write-Host "  $($pages.Count) pages"

# ---------- 4. Contrastes ----------
Write-Host "== Contrastes"
function Lum([string]$hex) {
  $c = @(0, 2, 4 | ForEach-Object { [Convert]::ToInt32($hex.Substring($_, 2), 16) / 255.0 } | ForEach-Object { if ($_ -le 0.03928) { $_ / 12.92 } else { [Math]::Pow(($_ + 0.055) / 1.055, 2.4) } })
  0.2126 * $c[0] + 0.7152 * $c[1] + 0.0722 * $c[2]
}
function Ratio([string]$a, [string]$b) { $x = Lum $a; $y = Lum $b; if ($x -lt $y) { $x, $y = $y, $x }; ($x + 0.05) / ($y + 0.05) }
$css = Read-Text "docs\assets\site.css"
$var = @{}
foreach ($m in [regex]::Matches($css, '--(\w+):\s*#([0-9A-Fa-f]{6})')) { $var[$m.Groups[1].Value] = $m.Groups[2].Value }
$pairs = @(
  @("text", "bg"), @("text", "card"), @("muted", "bg"), @("muted", "card"), @("ok", "card"),
  @("9DA8FF", "bg"), @("9DA8FF", "card"), @("FFFFFF", "C2185B"), @("FFFFFF", "465AFF"), @("text", "0A0C10")
)
foreach ($p in $pairs) {
  $fg = if ($var.ContainsKey($p[0])) { $var[$p[0]] } else { $p[0] }
  $bg = if ($var.ContainsKey($p[1])) { $var[$p[1]] } else { $p[1] }
  $r = Ratio $fg $bg
  if ($r -lt 4.5) { Fail ("contraste {0} sur {1} : {2:N2} (minimum 4,5)" -f $fg, $bg, $r) }
}
# les couleurs du CSS employees en texte doivent bien etre celles qu'on verifie
foreach ($m in [regex]::Matches($css, '(?<![-\w])color:\s*#([0-9A-Fa-f]{6})')) {
  $fg = $m.Groups[1].Value
  if ($fg -notin @("9DA8FF", "FFFFFF", "fff") -and (Ratio $fg $var["card"]) -lt 4.5) { Fail "couleur de texte #$fg : contraste insuffisant sur le fond des cartes" }
}

# ---------- 5. Navigateur ----------
if (-not $NoBrowser) {
  Write-Host "== Navigateur (Edge)"
  $edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $edge) { Write-Host "  (Edge absent : etape sautee)" -ForegroundColor DarkYellow }
  else {
    $profile = Join-Path $env:TEMP ("edge-check-" + [guid]::NewGuid().ToString("N"))
    function Dump([string]$rel, [string]$query = "") {
      $url = "file:///" + ((Join-Path $docs $rel) -replace '\\', '/') + $query
      $out = Join-Path $env:TEMP "edge-dom.txt"
      Remove-Item $out -Force -ErrorAction SilentlyContinue
      $p = Start-Process $edge -ArgumentList "--headless=new", "--disable-gpu", "--no-first-run", "--user-data-dir=`"$profile`"", "--virtual-time-budget=4000", "--dump-dom", "`"$url`"" -Wait -PassThru -NoNewWindow -RedirectStandardOutput $out -RedirectStandardError (Join-Path $env:TEMP "edge-err.txt")
      Read-Text $out
    }
    $checks = @(
      @{ page = "index.html"; must = @('<h1>', 'data-lang="en"') },
      @{ page = "guide/index.html"; must = @('class="side"|class="grid"', 'href="start.html"') },
      @{ page = "guide/start.html"; must = @('<ol>', 'Getting started') },
      @{ page = "gallery/index.html"; must = @('class="thumbs"', 'aria-pressed="true"', 'id="galleryCount">\d+<') },
      @{ page = "gallery/maths/$((Get-ChildItem examples\gallery\maths -Filter *.glsl | Select-Object -First 1).BaseName).html"; must = @('<pre', 'hero-img') },
      @{ page = "reference/settings.html"; must = @('id="s-width"', 'scope="row"') }
    )
    foreach ($c in $checks) {
      $dom = Dump $c.page
      if ($dom.Length -lt 500) { Fail "$($c.page) : Edge n'a rien affiche"; continue }
      foreach ($pat in $c.must) { if ($dom -notmatch $pat) { Fail "$($c.page) : le motif '$pat' manque apres chargement" } }
      if ($dom -match 'class="lang"[^>]*>\s*EN \| FR\s*<' -and $dom -notmatch '<html lang="(en|fr)"') { Fail "$($c.page) : langue non appliquee" }
    }
    # filtre de la galerie : l'adresse #fractales ne laisse que cette categorie
    $dom = Dump "gallery/index.html" "#fractales"
    $hidden = [regex]::Matches($dom, '<li data-cat="[^"]+" hidden').Count
    $total = [regex]::Matches($dom, '<li data-cat="[^"]+"').Count
    if ($total -lt 60 -or $hidden -lt 40 -or $hidden -ge $total) { Fail "gallery/index.html#fractales : le filtre ne masque pas les autres categories ($hidden masques sur $total)" }
    # recherche : un mot du code d'un exemple et un reglage
    $dom = Dump "search.html" "?q=crf"
    if ($dom -notmatch '<ul id="results"[^>]*>\s*<li>') { Fail "search.html?q=crf : aucun resultat" }
    if ($dom -notmatch 'reference/settings\.html#s-crf') { Fail "search.html?q=crf : le reglage crf n'est pas trouve" }
    $dom = Dump "search.html" "?q=zzzzqqq"
    if ($dom -match '<ul id="results"[^>]*>\s*<li>') { Fail "search.html?q=zzzzqqq : un resultat pour un mot inconnu" }
    Remove-Item $profile -Recurse -Force -ErrorAction SilentlyContinue
  }
}

if ($problems.Count -gt 0) { Write-Host "`n$($problems.Count) probleme(s)." -ForegroundColor Red; exit 1 }
Write-Host "Site conforme."
