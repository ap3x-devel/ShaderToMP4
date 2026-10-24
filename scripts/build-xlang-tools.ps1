# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Patrick JAILLET

<#
.SYNOPSIS
  Prepare le dossier tools\ des traducteurs de shaders (HLSL, WGSL, GLSL 4.x -> GLSL 3.30) : spirv-cross.exe, naga.exe et glslang.exe, avec leurs licences.
.DESCRIPTION
  Versions epinglees (voir THIRD_PARTY_NOTICES.md et scripts\components.json) :
    SPIRV-Cross  vulkan-sdk-1.4.363.0 (commit f11ba9f0b21ba8fc15153d50a2a1ae31ab1cf8f7), construit avec CMake + Ninja + Visual C++ (/MT)
    naga-cli     30.0.1, construit par `cargo install --locked` (Rust)
    glslang      16.6.0, archive officielle de Khronos (somme SHA-256 verifiee)
  dxc (DirectX Shader Compiler 1.9.2609) n'est pas fabrique ici : le programme le telecharge a la demande (`ShaderToMP4 --get-dxc`, somme verifiee).
  Sortie : <Out>\spirv-cross.exe, naga.exe, glslang.exe et <Out>\licenses\ ; les sommes SHA-256 des fichiers obtenus sont affichees.
.PARAMETER Out
  Dossier de sortie (defaut bin\tools).
.PARAMETER Work
  Dossier de travail (sources, constructions) ; defaut : un dossier temporaire.
#>
param([string]$Out = "bin\tools", [string]$Work = "$env:TEMP\xlang-build")
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)
$root = (Get-Location).Path
$scTag = "vulkan-sdk-1.4.363.0"
$scCommit = "f11ba9f0b21ba8fc15153d50a2a1ae31ab1cf8f7"
$nagaVersion = "30.0.1"
$glslangVersion = "16.6.0"
$glslangSha256 = "82BF434E69B9BB4829DE7E2B4BC2C5E7A7861E53D66CF75E5CC70F5F694A8D9B"
$ProgressPreference = "SilentlyContinue"
New-Item -ItemType Directory -Force $Work, $Out, (Join-Path $Out "licenses") | Out-Null
$Out = (Resolve-Path $Out).Path

# --- glslang : archive officielle ---
$zip = Join-Path $Work "glslang.zip"
Invoke-WebRequest "https://github.com/KhronosGroup/glslang/releases/download/$glslangVersion/glslang-$glslangVersion-windows-x86_64-release.zip" -OutFile $zip
if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $glslangSha256) { throw "glslang : somme SHA-256 differente de celle attendue" }
Expand-Archive $zip (Join-Path $Work "glslang") -Force
Copy-Item (Join-Path $Work "glslang\bin\glslang.exe") $Out -Force

# --- SPIRV-Cross : sources a la version epinglee, CMake + Ninja + MSVC ---
$sc = Join-Path $Work "SPIRV-Cross"
if (Test-Path $sc) { Remove-Item $sc -Recurse -Force }
git clone --quiet --depth 1 --branch $scTag https://github.com/KhronosGroup/SPIRV-Cross.git $sc
if ((git -C $sc rev-parse HEAD).Trim() -ne $scCommit) { throw "SPIRV-Cross : le commit de $scTag n'est pas celui attendu" }
$vcvars = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath
$vcvarsBat = Join-Path $vcvars "VC\Auxiliary\Build\vcvars64.bat"
$bat = Join-Path $Work "build-spirv-cross.bat"
$build = Join-Path $Work "SPIRV-Cross-build"
@(
  "@echo off",
  "call `"$vcvarsBat`" >nul",
  "cmake -S `"$sc`" -B `"$build`" -G Ninja -DCMAKE_BUILD_TYPE=Release -DSPIRV_CROSS_CLI=ON -DSPIRV_CROSS_ENABLE_TESTS=OFF -DSPIRV_CROSS_STATIC=ON -DSPIRV_CROSS_SHARED=OFF -DSPIRV_CROSS_ENABLE_HLSL=ON -DSPIRV_CROSS_ENABLE_MSL=ON -DSPIRV_CROSS_ENABLE_CPP=ON -DSPIRV_CROSS_ENABLE_REFLECT=ON -DSPIRV_CROSS_ENABLE_C_API=OFF -DSPIRV_CROSS_ENABLE_UTIL=ON -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded || exit /b 1",
  "cmake --build `"$build`" --target spirv-cross || exit /b 1"
) | Set-Content $bat -Encoding ASCII
cmd /c "`"$bat`"" | Out-Null
if ($LASTEXITCODE -ne 0) { throw "SPIRV-Cross : la construction a echoue" }
Copy-Item (Join-Path $build "spirv-cross.exe") $Out -Force

# --- naga-cli : cargo, versions verrouillees ---
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { throw "cargo (Rust) est absent : winget install Rustlang.Rustup" }
$nagaRoot = Join-Path $Work "naga"
cargo install naga-cli --version $nagaVersion --locked --root $nagaRoot
if ($LASTEXITCODE -ne 0) { throw "naga-cli : la construction a echoue" }
Copy-Item (Join-Path $nagaRoot "bin\naga.exe") $Out -Force

# --- licences ---
Copy-Item (Join-Path $root "tools-licenses\*") (Join-Path $Out "licenses") -Force
Get-ChildItem $Out -Filter *.exe | ForEach-Object { "{0}  {1}" -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash, $_.Name }
