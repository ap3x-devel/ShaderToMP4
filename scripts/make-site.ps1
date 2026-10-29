# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Fabrique les pages du site (docs\) a partir des sources du depot : guide, galerie des exemples, reference, recherche.
.DESCRIPTION
  Rien n'est ecrit a la main dans les pages produites :
    - guide\*.html        <- textes d'aide du programme (lang\en.json et lang\fr.json, cles help.*)
    - gallery\**.html     <- examples\gallery\<categorie>\<nom>.* (code, passes, ligne "// fr:" / "// en:") et les images de docs\gallery\img (scripts\make-site-media.ps1)
    - reference\*.html    <- docs\reference\*.md (ecrits par le programme, scripts\make-reference.ps1)
    - search.html, assets\search-data.js, sitemap.xml
  Les feuilles de style et le script (assets\site.css, assets\site.js) et la page d'accueil (index.html) restent des fichiers a la main.
  -Out : dossier de sortie (defaut : docs). scripts\check-site.ps1 produit dans un dossier temporaire et compare avec docs.
#>
param([string]$Out = "docs")
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$OutFull = if ([System.IO.Path]::IsPathRooted($Out)) { $Out } else { Join-Path (Get-Location) $Out }
$siteUrl = "https://ap3x-devel.github.io/ShaderToMP4/"
$repoUrl = "https://github.com/ap3x-devel/ShaderToMP4"

function Esc([string]$s) { [System.Net.WebUtility]::HtmlEncode($s) }
function Read-Text([string]$p) { ([System.IO.File]::ReadAllText((Resolve-Path $p).Path, $utf8) -replace "`r`n", "`n") }
function Read-Lang([string]$code) {
  $o = (Read-Text "lang\$code.json") | ConvertFrom-Json
  $h = @{}
  foreach ($p in $o.PSObject.Properties) { $h[$p.Name] = [string]$p.Value }
  $h
}
$en = Read-Lang "en"
$fr = Read-Lang "fr"

# Morceaux repris de la page d'accueil : icone et logo, pour que toutes les pages aient les memes
$indexText = Read-Text "docs\index.html"
$iconLink = [regex]::Match($indexText, '<link rel="icon"[^>]*>').Value
$brandSvg = [regex]::Match($indexText, '<a class="brand"[^>]*>\s*(<svg.*?</svg>)', 'Singleline').Groups[1].Value
if (-not $iconLink -or -not $brandSvg) { throw "docs\index.html : icone ou logo introuvable" }
$version = [regex]::Match((Read-Text "src\app_info.h"), 'APP_VER_STR\s+"([^"]+)"').Groups[1].Value

# ---------- Pieces communes ----------
function Bi([string]$e, [string]$f, [string]$tag = "span") {
  "<$tag lang=`"en`" data-lang=`"en`">$e</$tag><$tag lang=`"fr`" data-lang=`"fr`">$f</$tag>"
}
function Slug([string]$s) { ([regex]::Replace($s.ToLower(), '[^a-z0-9]+', '-')).Trim('-') }

# Texte courant : `code`, **gras**, *italique*, [lien](adresse) ; le reste est echappe
function Inline([string]$t) {
  $t = $t.Replace('\|', '|')
  $codes = New-Object System.Collections.ArrayList
  $t = [regex]::Replace($t, '`([^`]+)`', { param($m) [void]$codes.Add("<code>" + (Esc $m.Groups[1].Value) + "</code>"); "`u{E000}" + ($codes.Count - 1) + "`u{E001}" })
  $t = Esc $t
  $t = [regex]::Replace($t, '\*\*([^*]+)\*\*', '<strong>$1</strong>')
  $t = [regex]::Replace($t, '(?<![\w*])\*([^*\s][^*]*)\*(?![\w*])', '<em>$1</em>')
  $t = [regex]::Replace($t, '\[([^\]]+)\]\(([^)]+)\)', '<a href="$2">$1</a>')
  $t = [regex]::Replace($t, "`u{E000}(\d+)`u{E001}", { param($m) $codes[[int]$m.Groups[1].Value] })
  $t
}

$navItems = @(
  @{ id = "guide"; href = "guide/index.html"; en = "Guide"; fr = "Guide" },
  @{ id = "gallery"; href = "gallery/index.html"; en = "Examples"; fr = "Exemples" },
  @{ id = "reference"; href = "reference/index.html"; en = "Reference"; fr = "Référence" },
  @{ id = "search"; href = "search.html"; en = "Search"; fr = "Rechercher" },
  @{ id = "download"; href = "index.html#download"; en = "Download"; fr = "Télécharger" }
)

$pages = New-Object System.Collections.ArrayList   # {path, titleEn, titleFr}

function Write-Page([string]$rel, [string]$titleEn, [string]$titleFr, [string]$descEn, [string]$active, [string]$body, [string]$extraScript = "") {
  $depth = ($rel -split '/').Count - 1
  $root = "../" * $depth
  $nav = ""
  foreach ($n in $navItems) {
    $cur = if ($n.id -eq $active) { ' aria-current="page"' } else { "" }
    $nav += "      <a href=`"$root$($n.href)`"$cur>$(Bi (Esc $n.en) (Esc $n.fr))</a>`n"
  }
  $tEn = (Esc $titleEn) + " - ShaderToMP4"
  $tFr = (Esc $titleFr) + " - ShaderToMP4"
  $page = @"
<!doctype html>
<!-- SPDX-License-Identifier: GPL-3.0-or-later - Copyright (C) 2026 Patrick JAILLET -->
<!-- Page produite par scripts\make-site.ps1, ne pas modifier a la main. -->
<html lang="en" data-root="$root" data-title-en="$tEn" data-title-fr="$tFr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$tEn</title>
<meta name="description" content="$(Esc $descEn)">
$iconLink
<link rel="stylesheet" href="${root}assets/site.css">
</head>
<body>
<a class="skip" href="#content">$(Bi "Skip to content" "Aller au contenu")</a>
<header class="top">
  <div class="wrap">
    <a class="brand" href="${root}index.html">
      $brandSvg
      ShaderToMP4
    </a>
    <nav aria-label="$(Esc "Main / Principal")">
$nav      <button class="lang" id="langBtn" type="button" aria-label="Language / Langue">EN | FR</button>
    </nav>
  </div>
</header>
<main id="content" tabindex="-1">
<div class="wrap page">
$body
</div>
</main>
<footer>
  <div class="wrap">
    ShaderToMP4 $version - &copy; 2026 Patrick JAILLET - GPL-3.0-or-later - <a href="$repoUrl">GitHub</a> - <a href="mailto:ap3x.records@proton.me">ap3x.records@proton.me</a>
  </div>
</footer>
<script src="${root}assets/site.js"></script>
$extraScript</body>
</html>
"@
  $full = Join-Path $OutFull $rel
  New-Item -ItemType Directory -Force (Split-Path $full -Parent) | Out-Null
  [System.IO.File]::WriteAllText($full, ($page -replace "`r`n", "`n"), $utf8)
  [void]$pages.Add(@{ path = $rel; titleEn = $titleEn; titleFr = $titleFr })
}

$search = New-Object System.Collections.ArrayList   # {u, k, t{en,fr}, x{en,fr}}
function Add-Search([string]$url, [string]$kind, [string]$tEn, [string]$tFr, [string]$xEn, [string]$xFr) {
  $clean = { param($s) ([regex]::Replace($s, '\s+', ' ')).Trim() }
  [void]$search.Add([ordered]@{ u = $url; k = $kind; t = [ordered]@{ en = $tEn; fr = $tFr }; x = [ordered]@{ en = (& $clean $xEn); fr = (& $clean $xFr) } })
}

function Crumbs([string]$root, [string]$sectionHref, [string]$sectionEn, [string]$sectionFr) {
  "<p class=`"crumbs`"><a href=`"${root}index.html`">$(Bi 'Home' 'Accueil')</a> / <a href=`"$root$sectionHref`">$(Bi (Esc $sectionEn) (Esc $sectionFr))</a></p>"
}

# ---------- Guide : textes d'aide du programme ----------
$topics = @()
foreach ($k in ($en.Keys | Where-Object { $_ -match '^help\.(\w+)\.title$' })) { }
$order = New-Object System.Collections.ArrayList
foreach ($line in (Read-Text "lang\en.json") -split "`n") {
  $m = [regex]::Match($line, '^\s*"help\.(\w+)\.title"')
  if ($m.Success -and $m.Groups[1].Value -ne "gloss") { [void]$order.Add($m.Groups[1].Value) }
}
$topics = @($order | Where-Object { $en.ContainsKey("help.$_.body") })

function Help-Html([string]$text) {
  $out = New-Object System.Text.StringBuilder
  $inList = $false
  foreach ($ln in ($text -split "`n")) {
    if ($ln.Trim() -eq "") { continue }
    if ($ln -match '^\d+\.\s+(.*)$') {
      if (-not $inList) { [void]$out.Append("<ol>`n"); $inList = $true }
      [void]$out.Append("<li>" + (Esc $Matches[1]) + "</li>`n")
    } else {
      if ($inList) { [void]$out.Append("</ol>`n"); $inList = $false }
      [void]$out.Append("<p>" + (Esc $ln) + "</p>`n")
    }
  }
  if ($inList) { [void]$out.Append("</ol>`n") }
  $out.ToString()
}
function Plain([string]$t) { ([regex]::Replace($t, '\s+', ' ')).Trim() }

$sideItems = ""
foreach ($t in $topics) {
  $sideItems += "<li><a href=`"$t.html`"@@CUR_$t@@>$(Bi (Esc $en["help.$t.title"]) (Esc $fr["help.$t.title"]))</a></li>`n"
}
$sideItems += "<li><a href=`"glossary.html`"@@CUR_glossary@@>$(Bi 'Glossary' 'Glossaire')</a></li>`n"

function Guide-Side([string]$current) {
  $s = $sideItems
  foreach ($t in ($topics + "glossary")) { $s = $s.Replace("@@CUR_$t@@", $(if ($t -eq $current) { ' aria-current="page"' } else { "" })) }
  "<nav class=`"side`" aria-label=`"$(Esc 'Guide')`"><ul>`n$s</ul></nav>"
}

foreach ($t in $topics) {
  $bodyEn = Help-Html $en["help.$t.body"]
  $bodyFr = Help-Html $fr["help.$t.body"]
  $titleEn = $en["help.$t.title"]
  $titleFr = $fr["help.$t.title"]
  $body = @"
$(Crumbs '../' 'guide/index.html' 'Guide' 'Guide')
<div class="layout">
$(Guide-Side $t)
<article class="prose">
<h1>$(Bi (Esc $titleEn) (Esc $titleFr))</h1>
<div lang="en" data-lang="en">
$bodyEn</div>
<div lang="fr" data-lang="fr">
$bodyFr</div>
</article>
</div>
"@
  Write-Page "guide/$t.html" $titleEn $titleFr ($titleEn + " - " + (Plain $en["help.$t.body"]).Substring(0, [Math]::Min(150, (Plain $en["help.$t.body"]).Length))) "guide" $body
  Add-Search "guide/$t.html" "guide" $titleEn $titleFr (Plain $en["help.$t.body"]) (Plain $fr["help.$t.body"])
}

# Glossaire
$gloss = @($en.Keys | Where-Object { $_ -match '^help\.gloss\.\w+$' } | Sort-Object)
$dlEn = ""; $dlFr = ""; $glossTextEn = ""; $glossTextFr = ""
$glossOrder = New-Object System.Collections.ArrayList
foreach ($line in (Read-Text "lang\en.json") -split "`n") { $m = [regex]::Match($line, '^\s*"(help\.gloss\.\w+)"'); if ($m.Success) { [void]$glossOrder.Add($m.Groups[1].Value) } }
foreach ($k in $glossOrder) {
  $pe = $en[$k] -split '\|', 2; $pf = $fr[$k] -split '\|', 2
  $id = "t-" + $k.Substring(11)
  $dlEn += "<dt id=`"$id`">$(Esc $pe[0])</dt><dd>$(Esc $pe[1])</dd>`n"
  $dlFr += "<dt id=`"$id-fr`">$(Esc $pf[0])</dt><dd>$(Esc $pf[1])</dd>`n"
  $glossTextEn += $pe[0] + ": " + $pe[1] + " "
  $glossTextFr += $pf[0] + " : " + $pf[1] + " "
}
$body = @"
$(Crumbs '../' 'guide/index.html' 'Guide' 'Guide')
<div class="layout">
$(Guide-Side 'glossary')
<article class="prose">
<h1>$(Bi (Esc $en['help.gloss.title']) (Esc $fr['help.gloss.title']))</h1>
<dl class="gloss" lang="en" data-lang="en">
$dlEn</dl>
<dl class="gloss" lang="fr" data-lang="fr">
$dlFr</dl>
</article>
</div>
"@
Write-Page "guide/glossary.html" $en['help.gloss.title'] $fr['help.gloss.title'] "Glossary of the words used in ShaderToMP4: shader, channel, pass, loop, HDR, supersampling, motion blur, encoder, CRF." "guide" $body
Add-Search "guide/glossary.html" "guide" $en['help.gloss.title'] $fr['help.gloss.title'] $glossTextEn $glossTextFr

# Page d'entree du guide
$cards = ""
foreach ($t in $topics) {
  $se = Plain $en["help.$t.body"]; $sf = Plain $fr["help.$t.body"]
  $cut = { param($s) $x = $s.Substring(0, [Math]::Min(170, $s.Length)); if ($s.Length -gt 170) { $x = $x.Substring(0, $x.LastIndexOf(' ')) + " ..." }; $x }
  $cards += "<li class=`"card`"><h3><a href=`"$t.html`">$(Bi (Esc $en["help.$t.title"]) (Esc $fr["help.$t.title"]))</a></h3><p>$(Bi (Esc (& $cut $se)) (Esc (& $cut $sf)))</p></li>`n"
}
$cards += "<li class=`"card`"><h3><a href=`"glossary.html`">$(Bi (Esc $en['help.gloss.title']) (Esc $fr['help.gloss.title']))</a></h3><p>$(Bi 'The words used in the program and in this guide.' 'Les mots employés dans le programme et dans ce guide.')</p></li>`n"
$body = @"
$(Crumbs '../' 'guide/index.html' 'Guide' 'Guide')
<h1>$(Bi 'Guide' 'Guide')</h1>
<p class="lead">$(Bi 'The same texts as the help window of the program (F1), one page per topic.' 'Les mêmes textes que la fenêtre d&rsquo;aide du programme (F1), une page par sujet.')</p>
<ul class="grid" style="list-style:none;padding:0;margin:0">
$cards</ul>
"@
Write-Page "guide/index.html" "Guide" "Guide" "User guide of ShaderToMP4, built from the help texts of the program." "guide" $body

# ---------- Galerie ----------
$exts = ".glsl", ".hlsl", ".wgsl", ".frag"
$catOrder = "maths", "bruit", "fractales", "raymarching", "2d", "post", "boucles", "son", "vr", "passes", "autres"
$examples = New-Object System.Collections.ArrayList
foreach ($cat in $catOrder) {
  $dir = "examples\gallery\$cat"
  if (-not (Test-Path $dir)) { continue }
  foreach ($f in (Get-ChildItem $dir -File | Where-Object { $exts -contains $_.Extension.ToLower() -and $_.Name.Split('.').Count -eq 2 } | Sort-Object Name)) {
    $text = Read-Text $f.FullName
    $titles = @{}
    foreach ($lg in "fr", "en") {
      $m = [regex]::Match($text, "(?m)^//\s*${lg}:\s*(.+?)\s+—\s+(.*)$")
      if ($m.Success) { $titles[$lg] = @($m.Groups[1].Value, $m.Groups[2].Value) }
    }
    if (-not $titles.ContainsKey("fr")) { $titles["fr"] = $titles["en"] }
    if (-not $titles.ContainsKey("en")) { $titles["en"] = $titles["fr"] }
    if (-not $titles.ContainsKey("en")) { throw "$($f.FullName) : ligne // fr: ou // en: introuvable" }
    $passes = @(Get-ChildItem $dir -File | Where-Object { $_.Name.StartsWith($f.BaseName + ".") -and $_.Name.Split('.').Count -ge 3 -and $exts -contains $_.Extension.ToLower() } | Sort-Object Name)
    $img = "gallery/img/$cat-$($f.BaseName).jpg"
    if (-not (Test-Path (Join-Path "docs" $img))) { throw "image manquante : docs\$img (scripts\make-site-media.ps1)" }
    [void]$examples.Add(@{ cat = $cat; name = $f.BaseName; file = $f.Name; text = $text; en = $titles["en"]; fr = $titles["fr"]; passes = $passes; img = $img })
  }
}
$catName = @{}
foreach ($c in $catOrder) { $catName[$c] = @($en["gallery.cat.$c"], $fr["gallery.cat.$c"]) }

$chips = "<li><button type=`"button`" class=`"chip`" data-cat=`"`" aria-pressed=`"true`">$(Bi 'All' 'Tous')</button></li>`n"
foreach ($c in $catOrder) { $chips += "<li><button type=`"button`" class=`"chip`" data-cat=`"$c`" aria-pressed=`"false`">$(Bi (Esc $catName[$c][0]) (Esc $catName[$c][1]))</button></li>`n" }
$thumbs = ""
foreach ($e in $examples) {
  $thumbs += "<li data-cat=`"$($e.cat)`"><div class=`"thumb`"><a href=`"$($e.cat)/$($e.name).html`"><img src=`"img/$($e.cat)-$($e.name).jpg`" width=`"480`" height=`"270`" alt=`"`" loading=`"lazy`"><div class=`"t`"><b>$(Bi (Esc $e.en[0]) (Esc $e.fr[0]))</b><span class=`"c`">$(Bi (Esc $catName[$e.cat][0]) (Esc $catName[$e.cat][1]))</span></div></a></div></li>`n"
}
$body = @"
$(Crumbs '../' 'gallery/index.html' 'Examples' 'Exemples')
<h1>$(Bi 'Examples' 'Exemples')</h1>
<p class="lead">$(Bi "The $($examples.Count) example shaders shipped with the program (Examples button), each with its picture and its code." "Les $($examples.Count) shaders d&rsquo;exemple livrés avec le programme (bouton Exemples), chacun avec son image et son code.")</p>
<ul class="chips" aria-label="$(Esc 'Categories / Catégories')">
$chips</ul>
<p><span id="galleryCount">$($examples.Count)</span> $(Bi 'examples' 'exemples')</p>
<ul class="thumbs">
$thumbs</ul>
"@
Write-Page "gallery/index.html" "Examples" "Exemples" "The example shaders of ShaderToMP4 with their picture and their code." "gallery" $body

foreach ($e in $examples) {
  $codeBlocks = "<h2>$(Bi 'Code' 'Code')</h2>`n<h3><code>$(Esc $e.file)</code></h3>`n<pre tabindex=`"0`"><code>$(Esc $e.text.TrimEnd())</code></pre>`n"
  $searchCode = $e.text
  foreach ($p in $e.passes) {
    $pt = Read-Text $p.FullName
    $codeBlocks += "<h3><code>$(Esc $p.Name)</code></h3>`n<pre tabindex=`"0`"><code>$(Esc $pt.TrimEnd())</code></pre>`n"
    $searchCode += " " + $pt
  }
  $lines = ($e.text -split "`n").Count
  $github = "$repoUrl/blob/main/examples/gallery/$($e.cat)/$($e.file)"
  $kind = if ($e.passes.Count -gt 0) { "$(Bi 'This example uses several passes: the files below go together.' 'Cet exemple utilise plusieurs passes : les fichiers ci-dessous vont ensemble.')" } else { "" }
  $body = @"
$(Crumbs '../../' 'gallery/index.html' 'Examples' 'Exemples')
<h1>$(Bi (Esc $e.en[0]) (Esc $e.fr[0]))</h1>
<p class="lead">$(Bi (Esc $e.en[1]) (Esc $e.fr[1]))</p>
<img class="hero-img" src="../img/$($e.cat)-$($e.name).jpg" width="480" height="270" alt="$(Esc ($e.en[0] + ' / ' + $e.fr[0]))">
<p><strong>$(Bi 'Category' 'Catégorie')</strong>: $(Bi (Esc $catName[$e.cat][0]) (Esc $catName[$e.cat][1])) - <code>$(Esc $e.file)</code> - $lines $(Bi 'lines' 'lignes') - <a href="$github">$(Bi 'File on GitHub' 'Fichier sur GitHub')</a></p>
<p>$(Bi 'In the program: Examples, choose it, Add to the list. Or copy the code into a file next to the program and drop it on the window.' 'Dans le programme : Exemples, choisissez-le, Ajouter à la liste. Ou copiez le code dans un fichier et glissez-le sur la fenêtre.')</p>
<p>$kind</p>
$codeBlocks
"@
  Write-Page "gallery/$($e.cat)/$($e.name).html" $e.en[0] $e.fr[0] ($e.en[0] + " - " + $e.en[1]) "gallery" $body
  $cut = $searchCode.Substring(0, [Math]::Min(3000, $searchCode.Length))
  Add-Search "gallery/$($e.cat)/$($e.name).html" "gallery" $e.en[0] $e.fr[0] ($e.en[1] + " " + $catName[$e.cat][0] + " " + $e.file + " " + $cut) ($e.fr[1] + " " + $catName[$e.cat][1] + " " + $e.file + " " + $cut)
}

# ---------- Reference : fichiers Markdown ecrits par le programme ----------
function Split-Row([string]$line) {
  $cells = [regex]::Split($line.Trim().Trim('|'), '(?<!\\)\|')
  @($cells | ForEach-Object { $_.Trim() })
}
function Md-Table-Rows([string]$md) {   # lignes de donnees des tableaux, pour la recherche
  $rows = New-Object System.Collections.ArrayList
  $state = 0
  foreach ($ln in ($md -split "`n")) {
    if ($ln.StartsWith("|")) {
      if ($state -eq 0) { $state = 1; continue }
      if ($state -eq 1) { $state = 2; continue }
      [void]$rows.Add((Split-Row $ln))
    } else { $state = 0 }
  }
  $rows
}
function Md-ToHtml([string]$md, [string]$idPrefix) {
  $out = New-Object System.Text.StringBuilder
  $lines = $md -split "`n"
  $i = 0
  while ($i -lt $lines.Count) {
    $ln = $lines[$i]
    if ($ln.StartsWith("<!--") -or $ln.Trim() -eq "") { $i++; continue }
    if ($ln -match '^(#{1,3})\s+(.*)$') {
      $lv = $Matches[1].Length; $txt = $Matches[2]
      $tag = "h$lv"
      [void]$out.Append("<$tag>" + (Inline $txt) + "</$tag>`n"); $i++; continue
    }
    if ($ln.StartsWith('```')) {
      $i++; $code = New-Object System.Text.StringBuilder
      while ($i -lt $lines.Count -and -not $lines[$i].StartsWith('```')) { [void]$code.Append($lines[$i] + "`n"); $i++ }
      $i++
      [void]$out.Append("<pre tabindex=`"0`"><code>" + (Esc $code.ToString().TrimEnd()) + "</code></pre>`n"); continue
    }
    if ($ln.StartsWith("|")) {
      $head = Split-Row $ln; $i += 2
      [void]$out.Append("<div class=`"tablewrap`" tabindex=`"0`" role=`"region`" aria-label=`"" + (Esc ($head -join ", ")) + "`"><table class=`"ref`"><thead><tr>")
      foreach ($c in $head) { [void]$out.Append("<th scope=`"col`">" + (Inline $c) + "</th>") }
      [void]$out.Append("</tr></thead><tbody>`n")
      while ($i -lt $lines.Count -and $lines[$i].StartsWith("|")) {
        $cells = Split-Row $lines[$i]
        $key = ($cells[0] -replace '`', '')
        $id = $idPrefix + (Slug $key)
        [void]$out.Append("<tr id=`"$id`"><th scope=`"row`">" + (Inline $cells[0]) + "</th>")
        for ($c = 1; $c -lt $cells.Count; $c++) { [void]$out.Append("<td>" + (Inline $cells[$c]) + "</td>") }
        [void]$out.Append("</tr>`n"); $i++
      }
      [void]$out.Append("</tbody></table></div>`n"); continue
    }
    if ($ln -match '^[-*]\s+') {
      [void]$out.Append("<ul>`n")
      while ($i -lt $lines.Count -and $lines[$i] -match '^[-*]\s+(.*)$') { [void]$out.Append("<li>" + (Inline $Matches[1]) + "</li>`n"); $i++ }
      [void]$out.Append("</ul>`n"); continue
    }
    $para = @()
    while ($i -lt $lines.Count -and $lines[$i].Trim() -ne "" -and -not $lines[$i].StartsWith("|") -and -not $lines[$i].StartsWith("#") -and -not $lines[$i].StartsWith('```')) { $para += $lines[$i]; $i++ }
    [void]$out.Append("<p>" + (Inline ($para -join " ")) + "</p>`n")
  }
  $out.ToString()
}

$refPages = @(
  @{ id = "settings"; prefix = "s-"; en = "Settings"; fr = "Réglages"; descEn = "Every setting of config.ini with its default value."; descFr = "Tous les réglages de config.ini avec leur valeur par défaut." },
  @{ id = "project"; prefix = "f-"; en = "Project file"; fr = "Fichier projet"; descEn = "The .s2mproj project file format."; descFr = "Le format du fichier projet .s2mproj." },
  @{ id = "cli"; prefix = "o-"; en = "Command line"; fr = "Ligne de commande"; descEn = "The command-line options of ShaderToMP4."; descFr = "Les options de la ligne de commande de ShaderToMP4." }
)
$refSide = ""
foreach ($r in $refPages) { $refSide += "<li><a href=`"$($r.id).html`"@@CUR_$($r.id)@@>$(Bi (Esc $r.en) (Esc $r.fr))</a></li>`n" }
function Ref-Side([string]$current) {
  $s = $refSide
  foreach ($r in $refPages) { $s = $s.Replace("@@CUR_$($r.id)@@", $(if ($r.id -eq $current) { ' aria-current="page"' } else { "" })) }
  "<nav class=`"side`" aria-label=`"$(Esc 'Reference / Référence')`"><ul>`n$s</ul></nav>"
}
foreach ($r in $refPages) {
  $mdEn = Read-Text "docs\reference\$($r.id).md"
  $mdFr = Read-Text "docs\reference\$($r.id).fr.md"
  # le titre du fichier devient le h1 de la page (une seule fois, dans les deux langues)
  $h1En = [regex]::Match($mdEn, '(?m)^# (.*)$').Groups[1].Value; $h1Fr = [regex]::Match($mdFr, '(?m)^# (.*)$').Groups[1].Value
  $bodyMdEn = [regex]::Replace($mdEn, '(?m)^# .*$', '', 1); $bodyMdFr = [regex]::Replace($mdFr, '(?m)^# .*$', '', 1)
  $body = @"
$(Crumbs '../' 'reference/index.html' 'Reference' 'Référence')
<div class="layout">
$(Ref-Side $r.id)
<article class="prose">
<h1>$(Bi (Esc $h1En) (Esc $h1Fr))</h1>
<div lang="en" data-lang="en">
$(Md-ToHtml $bodyMdEn $r.prefix)</div>
<div lang="fr" data-lang="fr">
$(Md-ToHtml $bodyMdFr ("fr-" + $r.prefix))</div>
</article>
</div>
"@
  Write-Page "reference/$($r.id).html" $r.en $r.fr $r.descEn "reference" $body
  $rowsEn = @(Md-Table-Rows $mdEn); $rowsFr = @(Md-Table-Rows $mdFr)
  $txtEn = ($mdEn -replace '(?m)^<!--.*$', '')
  $txtFr = ($mdFr -replace '(?m)^<!--.*$', '')
  Add-Search "reference/$($r.id).html" "reference" $r.en $r.fr ($r.descEn) ($r.descFr)
  for ($i = 0; $i -lt $rowsEn.Count -and $i -lt $rowsFr.Count; $i++) {
    $key = ($rowsEn[$i][0] -replace '`', '')
    $id = $r.prefix + (Slug $key)
    $dEn = ($rowsEn[$i][1..($rowsEn[$i].Count - 1)] -join " - ") -replace '`', ''
    $dFr = ($rowsFr[$i][1..($rowsFr[$i].Count - 1)] -join " - ") -replace '`', ''
    Add-Search "reference/$($r.id).html#$id" "reference" $key $key ($r.en + ": " + $dEn) ($r.fr + " : " + $dFr)
  }
}
$cardsRef = ""
foreach ($r in $refPages) { $cardsRef += "<li class=`"card`"><h3><a href=`"$($r.id).html`">$(Bi (Esc $r.en) (Esc $r.fr))</a></h3><p>$(Bi (Esc $r.descEn) (Esc $r.descFr))</p></li>`n" }
$body = @"
$(Crumbs '../' 'reference/index.html' 'Reference' 'Référence')
<h1>$(Bi 'Reference' 'Référence')</h1>
<p class="lead">$(Bi 'Written by the program itself from its code: the tables cannot differ from what the program does.' 'Écrite par le programme lui-même à partir de son code : les tableaux ne peuvent pas différer de ce que fait le programme.')</p>
<ul class="grid" style="list-style:none;padding:0;margin:0">
$cardsRef</ul>
"@
Write-Page "reference/index.html" "Reference" "Référence" "Settings, project file format and command line of ShaderToMP4, written by the program." "reference" $body

# ---------- Recherche ----------
$body = @"
<h1>$(Bi 'Search' 'Rechercher')</h1>
<p class="lead">$(Bi 'Searches the guide, the examples (title, description, code) and the reference. Everything happens in your browser: nothing is sent.' 'Cherche dans le guide, les exemples (titre, description, code) et la référence. Tout se passe dans votre navigateur : rien n&rsquo;est envoyé.')</p>
<form id="searchForm" class="search-box" role="search" action="search.html" method="get">
  <label class="sr" for="q">$(Bi 'Search the site' 'Rechercher dans le site')</label>
  <input id="q" name="q" type="search" autocomplete="off" placeholder="loop, fbm, crf, bufferA...">
  <button class="btn" type="submit">$(Bi 'Search' 'Rechercher')</button>
</form>
<p id="searchStatus" role="status" aria-live="polite"></p>
<ul id="results" class="results"></ul>
<noscript><p class="notice">$(Bi 'The search needs JavaScript. Without it, use the <a href="guide/index.html">guide</a>, the <a href="gallery/index.html">examples</a> and the <a href="reference/index.html">reference</a>.' 'La recherche a besoin de JavaScript. Sans lui, utilisez le <a href="guide/index.html">guide</a>, les <a href="gallery/index.html">exemples</a> et la <a href="reference/index.html">référence</a>.')</p></noscript>
"@
Write-Page "search.html" "Search" "Rechercher" "Search the guide, the examples and the reference of ShaderToMP4." "search" $body "<script src=`"assets/search-data.js`"></script>`n"
# l'index doit etre charge avant site.js : on remet les balises dans le bon ordre
$sp = Join-Path $OutFull "search.html"
$st = [System.IO.File]::ReadAllText($sp, $utf8)
$st = $st.Replace("<script src=`"assets/site.js`"></script>`n<script src=`"assets/search-data.js`"></script>`n", "<script src=`"assets/search-data.js`"></script>`n<script src=`"assets/site.js`"></script>`n")
[System.IO.File]::WriteAllText($sp, $st, $utf8)

$json = ($search | ConvertTo-Json -Depth 5 -Compress)
New-Item -ItemType Directory -Force (Join-Path $OutFull "assets") | Out-Null
$js = "/* SPDX-License-Identifier: GPL-3.0-or-later - Copyright (C) 2026 Patrick JAILLET - produit par scripts/make-site.ps1 */`nwindow.STM_INDEX = " + ($json -replace '"([a-z]+)":', '"$1":') + ";`n"
[System.IO.File]::WriteAllText((Join-Path $OutFull "assets\search-data.js"), $js, $utf8)

# ---------- Plan du site ----------
$sm = New-Object System.Text.StringBuilder
[void]$sm.Append("<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n  <url><loc>$siteUrl</loc></url>`n")
foreach ($p in ($pages | Sort-Object { $_.path })) { [void]$sm.Append("  <url><loc>$siteUrl$($p.path)</loc></url>`n") }
[void]$sm.Append("</urlset>`n")
[System.IO.File]::WriteAllText((Join-Path $OutFull "sitemap.xml"), $sm.ToString(), $utf8)

Write-Output "$($pages.Count) pages, $($search.Count) entrees de recherche, $($examples.Count) exemples -> $Out"
