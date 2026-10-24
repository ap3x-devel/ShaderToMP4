# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Essai pilote des autres langages de shader dans la vraie fenetre : un shader HLSL sans dxc propose le telechargement (reponse Oui), puis l'apercu se rend ;
  la liste affiche [HLSL] ; une erreur de traduction est ecrite avec « fichier:ligne: » dans le journal.
.DESCRIPTION
  Copie le programme et ses traducteurs (bin\tools sans dxc) dans un dossier temporaire, charge tests\xlang\hlsl\*.hlsl par queue.txt, pilote la fenetre par
  messages Windows. Reseau necessaire (dxc, 24 Mo). Code 1 si une verification echoue ; captures dans $Shots.
#>
param([string]$Work = "$env:TEMP\xlanggui", [string]$Shots = "$env:TEMP\xlanggui\shots", [string]$Lang = "en")
$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
Add-Type -ReferencedAssemblies System.Drawing @"
using System; using System.Text; using System.Runtime.InteropServices; using System.Drawing; using System.Drawing.Imaging;
public class XG {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string c, string t);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint f);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll")] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  public static IntPtr Dialog(uint pid) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); var sb = new StringBuilder(64); GetClassName(h, sb, 64);
      if (p == pid && sb.ToString() == "#32770" && IsWindowVisible(h)) { found = h; return false; } return true; }, IntPtr.Zero);
    return found;
  }
  public static string Title(IntPtr h) { var sb = new StringBuilder(256); GetWindowText(h, sb, 256); return sb.ToString(); }
  public static void Shot(IntPtr h, string path) {
    RECT r; GetWindowRect(h, out r);
    using (var bmp = new Bitmap(r.R - r.L, r.B - r.T)) {
      using (var g = Graphics.FromImage(bmp)) { IntPtr dc = g.GetHdc(); PrintWindow(h, dc, 2); g.ReleaseHdc(dc); }
      bmp.Save(path, ImageFormat.Png);
    }
  }
}
"@
$failed = $false
function Fail($m) { Write-Host "ECHEC : $m" -ForegroundColor Red; $script:failed = $true }
function Ok($m) { Write-Host "ok    : $m" -ForegroundColor Green }
if (Test-Path $Work) { Remove-Item $Work -Recurse -Force }
New-Item -ItemType Directory -Force $Work, $Shots, "$Work\tools" | Out-Null
Copy-Item (Join-Path $root "bin\ShaderToMP4.exe") $Work
foreach ($t in "spirv-cross.exe", "naga.exe", "glslang.exe") { Copy-Item (Join-Path $root "bin\tools\$t") "$Work\tools" }
Copy-Item (Join-Path $root "bin\ffmpeg.exe") $Work
$hlsl = Join-Path $Work "plasma.hlsl"
Copy-Item (Join-Path $root "examples\gallery\autres\hlsl_plasma.hlsl") $hlsl
$bad = Join-Path $Work "bad.hlsl"
Copy-Item (Join-Path $root "tests\xlang\errors\bad.hlsl") $bad
[System.IO.File]::WriteAllText((Join-Path $Work "queue.txt"), $hlsl + "`r`n" + $bad + "`r`n")
[System.IO.File]::WriteAllText((Join-Path $Work "window.ini"), "x=200 y=40 w=1100 h=900 max=0`r`nlang=$Lang`r`ntour=0`r`n")
$hdr = Get-Content (Join-Path $root "src\gui\app.h") -Raw
$enum = [regex]::Match($hdr, 'enum \{\s*ID_LIST = 101(.*?)\n\};', 'Singleline').Value -replace '//[^\n]*', ''
$ID = @{}; $next = 101
foreach ($tok in ($enum -replace '^enum \{', '' -replace '\};$', '') -split ',') {
  $t = $tok.Trim(); if (-not $t) { continue }
  if ($t -match '^(ID_[A-Z0-9_]+)\s*=\s*(\d+)$') { $next = [int]$Matches[2]; $ID[$Matches[1]] = $next } elseif ($t -match '^(ID_[A-Z0-9_]+)$') { $ID[$Matches[1]] = $next } else { continue }
  $next++
}
$p = Start-Process (Join-Path $Work "ShaderToMP4.exe") -WorkingDirectory $Work -PassThru
try {
  Start-Sleep -Seconds 4
  $main = [XG]::FindWindow("ShaderToMP4Main", [NullString]::Value)
  if ($main -eq [IntPtr]::Zero) { throw "fenetre principale introuvable" }
  [XG]::Shot($main, "$Shots\list-$Lang.png")
  # apercu : sans dxc, la question de telechargement
  [void][XG]::PostMessage($main, 0x111, [IntPtr]$ID["ID_PREVBTN"], [IntPtr]::Zero)
  $dlg = [IntPtr]::Zero
  for ($i = 0; $i -lt 20 -and $dlg -eq [IntPtr]::Zero; $i++) { Start-Sleep -Milliseconds 500; $dlg = [XG]::Dialog([uint32]$p.Id) }
  if ($dlg -eq [IntPtr]::Zero) { Fail "la question de telechargement de dxc n'apparait pas" } else {
    Ok "question affichee : $([XG]::Title($dlg))"
    [XG]::Shot($dlg, "$Shots\dxc-question-$Lang.png")
    [void][XG]::PostMessage($dlg, 0x111, [IntPtr]6, [IntPtr]::Zero)   # IDYES
    for ($i = 0; $i -lt 120 -and -not (Test-Path "$Work\tools\dxc\dxc.exe"); $i++) { Start-Sleep -Milliseconds 500 }
    if (Test-Path "$Work\tools\dxc\dxc.exe") { Ok "dxc telecharge et installe" } else { Fail "dxc n'est pas installe" }
    Start-Sleep -Seconds 2
  }
  # apercu du shader HLSL
  [void][XG]::PostMessage($main, 0x111, [IntPtr]$ID["ID_PREVBTN"], [IntPtr]::Zero)
  Start-Sleep -Seconds 6
  [XG]::Shot($main, "$Shots\preview-$Lang.png")
  $bmp = New-Object System.Drawing.Bitmap "$Shots\preview-$Lang.png"
  $colors = New-Object System.Collections.Generic.HashSet[int]
  for ($x = 770; $x -lt 915; $x += 7) { for ($y = 475; $y -lt 552; $y += 5) { [void]$colors.Add($bmp.GetPixel($x, $y).ToArgb()) } }
  $bmp.Dispose()
  if ($colors.Count -gt 60) { Ok "apercu rendu ($($colors.Count) couleurs)" } else { Fail "apercu vide ($($colors.Count) couleurs)" }
  # shader fautif : l'erreur de traduction est ecrite dans le journal avec « fichier:ligne: »
  Add-Type -Namespace XG2 -Name Ms -MemberDefinition '[System.Runtime.InteropServices.DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y); [System.Runtime.InteropServices.DllImport("user32.dll")] public static extern void mouse_event(uint f, int dx, int dy, uint d, UIntPtr e);'
  $r = New-Object XG+RECT; [void][XG]::GetWindowRect($main, [ref]$r)
  [void][XG]::SetForegroundWindow($main)
  [XG2.Ms]::SetCursorPos($r.L + 200, $r.T + 512) | Out-Null; Start-Sleep -Milliseconds 300   # deuxieme ligne de la liste (clic reel)
  [XG2.Ms]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero); [XG2.Ms]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 500
  [void][XG]::PostMessage($main, 0x111, [IntPtr]$ID["ID_PREVBTN"], [IntPtr]::Zero)
  Start-Sleep -Seconds 5
  [XG]::Shot($main, "$Shots\error-$Lang.png")
  Ok "capture de l'erreur de traduction : $Shots\error-$Lang.png"
} finally {
  Get-Process -Id $p.Id -ErrorAction SilentlyContinue | Stop-Process -Force
}
if ($failed) { exit 1 }
Write-Host "Essai des autres langages termine." -ForegroundColor Green
