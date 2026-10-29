<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->

[Français](THIRD_PARTY_NOTICES.fr.md) · **English**

# Third-party notices

ShaderToMP4 is **proprietary shareware** (see [LICENSE](LICENSE) and [EULA.md](EULA.md)). This document lists every third-party component the program uses, with its license and why it allows redistribution inside proprietary software. **No component may be added to the project without an entry here.**

Last review: ShaderToMP4 2.1.0 (the Windows installer ships ffmpeg 9.0.2 and the NSIS run-time, see sections 2 and 3, and no other new component; Mesa is used by the continuous integration tests only and is not distributed).

## 1. Code compiled into the program

**All systems**: the license signature check (`src/core/ed25519.cpp`: Ed25519 and SHA-512) is an adaptation of **TweetNaCl** (Daniel J. Bernstein, Wesley Janssen, Tanja Lange, Peter Schwabe and others, [tweetnacl.cr.yp.to](https://tweetnacl.cr.yp.to)), which is **in the public domain** (no condition, compatible with the GPL-3.0 and with a proprietary edition). The SHA-512 round function and its constants follow FIPS 180-4. The code is checked against the RFC 8032 and FIPS 180 test vectors by the self-test.

**Windows, live output**: the texture sharing with OBS and other programs (`--live-spout`) uses **Spout2** (Lynn Jarvis, [github.com/leadedge/Spout2](https://github.com/leadedge/Spout2)), **BSD 2-Clause license** (it allows redistribution in proprietary software if the copyright notice and the conditions are kept: text in `tools/licenses/Spout-LICENSE.txt` and in `third_party/spout/LICENSE`). The sources are compiled into the program (`third_party/spout`) with two changes marked `ShaderToMP4` in the code: the functions that write to the Windows registry are disabled (the program never writes outside its folder) and a debug message printed on the console is removed. Spout only uses the shared memory of the system; nothing goes through the network.

**Windows**: no library. The JSON reader (translations), the Direct2D drawing layer, the process, HTTP and file helpers are original code of the project (`src/`). Only the C++ runtime and the Windows SDK are used at build time (see section 3).

**Linux and macOS** (frozen since 2026-10-22: these components are only in the archives up to version 2.1.1, never in the Windows program, and are no longer updated; `scripts/check-repo.ps1` checks that the Windows build does not reference them): three libraries are downloaded at configuration time (pinned versions, see `CMakeLists.txt` and `src/ui_imgui/CMakeLists.txt`) and compiled into the executable, and one font is embedded. Their licenses are permissive and compatible with the GPL-3.0; their copyright notices are kept in their own source files.

| Component | Role | License | Use in proprietary software |
|---|---|---|---|
| **GLFW 3.4** ([glfw.org](https://www.glfw.org)) | Window, input, drag and drop and OpenGL context (Linux, macOS) | zlib/libpng license | Compatible (permissive, listed as GPL-compatible by the FSF). |
| **Dear ImGui 1.91.9** ([github.com/ocornut/imgui](https://github.com/ocornut/imgui)) | Interface widgets (Linux, macOS) | MIT | Compatible. |
| **NanoSVG** ([github.com/memononen/nanosvg](https://github.com/memononen/nanosvg)), commit `239e102` | Rasterises the SVG icons and the logo (Linux, macOS) | zlib license | Compatible. |
| **Inter** 4.1 ([rsms.me/inter](https://rsms.me/inter/)), Regular and SemiBold, embedded font (`assets/fonts/`, license text in `assets/fonts/Inter-LICENSE.txt`) | Interface text (Linux, macOS) | SIL Open Font License 1.1 | Compatible: the OFL allows bundling the font with software under any license; the font files are unmodified and not sold on their own. |

## 2. Components used at run time

| Component | Role | How it is used | License | Use in proprietary software |
|---|---|---|---|---|
| **FFmpeg** ([ffmpeg.org](https://ffmpeg.org)), "release essentials" build by Gyan Doshi ([gyan.dev](https://www.gyan.dev/ffmpeg/builds/)), with libx264 and libx265 | Video / audio encoding | **Not included** in this repository nor in the portable archives: the program downloads it on request (SHA-256 checked) into its own folder. **Included in the Windows installer** (`ShaderToMP4-<version>-win64-setup.exe`): the same build, version 9.0.2, SHA-256 `60f467265b1e312373dbcd92200c2618a74850f98d3d078e94296bb3fa2047ba` for the downloaded archive, copied unchanged and built without `--enable-nonfree`; its licence is installed as `FFMPEG-LICENSE.txt` and its description of libraries as `FFMPEG-README.txt`. In both cases it runs as a **separate process** (pipes). No linking. | GPL v3 for this build (it enables the GPL libraries libx264 and libx265; FFmpeg itself is LGPL 2.1+ / GPL 2+). Full license text: `FFMPEG-LICENSE.txt`. Corresponding source of the version in the installer: https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz (the build scripts of the Windows binaries are at https://github.com/GyanD/codexffmpeg); the source is also available on request at the contact address of the project. | Compatible: GPL v3, no code combined. |
| **FFmpeg** static build by BtbN ([github.com/BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds), `linux64-gpl` and `linuxarm64-gpl`) | Video / audio encoding on Linux | Same as above: **not included**, downloaded on request (SHA-256 checked against the file published with the build) and run as a separate process. On macOS nothing is downloaded: the user installs ffmpeg (Homebrew) or places it next to the application. | GPL v3 (libx264 and libx265 enabled). | Compatible: GPL v3, no code combined. |
| **`curl`, `tar` and `xz`** (Linux, macOS) | HTTPS download and archive extraction | Provided by the operating system and run as separate programs; **not redistributed**. | curl license / GPL | Not distributed with the program. |
| **Windows system components**: Direct2D, DirectWrite, Direct3D 11, DXGI, OpenGL (graphics driver), WinInet, CryptoAPI, Shell, Common Controls, RichEdit, OLE drag and drop, taskbar progress (ITaskbarList3) | Interface, rendering, download, hashing | Provided by Windows and the graphics driver; **not redistributed**. | Microsoft Windows license / graphics driver license | Covered by the GPL-3.0 "System Libraries" definition: they are part of the operating system the program runs on. |
| **System components of Linux and macOS**: X11 / Wayland client libraries, OpenGL (Mesa or the graphics driver, Apple OpenGL / CoreFoundation frameworks), `libEGL` (loaded at run time only when there is no display server), the system CJK fonts read at run time for Japanese and Chinese (Noto Sans CJK, WenQuanYi, PingFang...), the C library, `libstdc++` (linked statically on Linux), `libgcc` | Window, rendering, system services | Provided by the operating system; **not redistributed** (the GCC runtime parts that are linked statically fall under the GCC Runtime Library Exception). | Various system licenses | Covered by the GPL-3.0 "System Libraries" definition and the GCC Runtime Library Exception. |
| **Fonts (Windows)**: Segoe UI (interface), Cascadia Mono (log) | Text | Provided by Windows; **not redistributed**, not embedded. Cascadia Mono falls back to a system font when absent. | Microsoft font licenses / SIL OFL 1.1 (Cascadia) | Not distributed with the program, so no license obligation is transferred. |
| **SPIRV-Cross** vulkan-sdk-1.4.363.0 ([github.com/KhronosGroup/SPIRV-Cross](https://github.com/KhronosGroup/SPIRV-Cross), commit `f11ba9f0b21ba8fc15153d50a2a1ae31ab1cf8f7`) | Turns SPIR-V into GLSL 3.30 (HLSL and GLSL 4.x shaders) | **Included** in the portable archive and the installer as `tools/spirv-cross.exe`, built from the pinned source (`scripts/build-xlang-tools.ps1`, Visual C++ `/MT`), unmodified. Run as a **separate process** (command line); no linking. License text: `tools/licenses/SPIRV-Cross-LICENSE.txt`. | Apache-2.0 | Compatible: Apache-2.0 is compatible with GPL-3.0 and with a proprietary edition; separate program, no code combined. |
| **naga-cli** 30.0.1 ([github.com/gfx-rs/wgpu](https://github.com/gfx-rs/wgpu), crate `naga-cli`) | Translates WGSL into GLSL 3.30 | **Included** as `tools/naga.exe`, built with `cargo install naga-cli --version 30.0.1 --locked`, unmodified. Separate process. License texts: `tools/licenses/naga-LICENSE-MIT.txt`, `naga-LICENSE-APACHE.txt`. The Rust dependencies compiled into it (locked by the crate's `Cargo.lock`) are permissive (MIT, Apache-2.0, Unicode license). | MIT OR Apache-2.0 | Compatible; separate program. |
| **glslang** 16.6.0 ([github.com/KhronosGroup/glslang](https://github.com/KhronosGroup/glslang)), official release archive (SHA-256 `82bf434e69b9bb4829de7e2b4bc2c5e7a7861e53d66cf75e5cc70f5f694a8d9b` is checked by the build script from the published archive) | Compiles GLSL 4.x (and ES) to SPIR-V | **Included** as `tools/glslang.exe` (the official binary, unmodified). Separate process. License text: `tools/licenses/glslang-LICENSE.txt`. | BSD-3-Clause (with parts under MIT and Apache-2.0, listed in the license text) | Compatible; separate program. |
| **DirectX Shader Compiler** 1.9.2609 ([github.com/microsoft/DirectXShaderCompiler](https://github.com/microsoft/DirectXShaderCompiler)) | Compiles HLSL to SPIR-V | **Not included** (24 MB): downloaded on request by `ShaderToMP4 --get-dxc` from Microsoft's release page into `tools/dxc/`, SHA-256 `ad31b1fc8443175d204f77a611fdb3ef2ec42759bdc2f1167368de24a4a7e7f1` checked before use. Separate process. License text: `tools/licenses/DirectXShaderCompiler-LICENSE.txt`. | University of Illinois/NCSA Open Source License (LLVM-derived; third-party parts listed in the license text) | Compatible (permissive); not redistributed by this project. |

## 3. Tools used to build the program (not distributed)

| Tool | License note |
|---|---|
| Microsoft Visual C++ compiler, linker and resource compiler (Visual Studio Build Tools), Windows SDK headers and import libraries | The C/C++ runtime is **statically linked** (`/MT`): Microsoft's runtime library license allows redistribution as part of an application, and the GPL-3.0 treats the compiler's runtime libraries as System Libraries. |
| Windows PowerShell, `tar.exe` (bsdtar) | Provided by Windows. `tar.exe` is also run at run time to unpack the downloaded FFmpeg archive. |
| **NSIS 3** (Nullsoft Scriptable Install System, [nsis.sourceforge.io](https://nsis.sourceforge.io)) | Builds the Windows installer. The installer contains NSIS's small run-time (the "stub"; zlib/libpng license, LZMA decoder in the public domain), which is compatible with the GPL-3.0; it is shipped in `ShaderToMP4-<version>-win64-setup.exe` only. |
| CMake, Ninja, GCC / Clang (Linux, macOS), Apple developer tools (`codesign`, `iconutil`, `lipo`, `ditto`), GitHub Actions | Build, packaging and continuous integration. Not distributed; the compiler runtime libraries are covered by the GCC Runtime Library Exception or the system libraries clause. |

## 4. Assets

| Asset | Origin | License |
|---|---|---|
| Logo and application icon (`res/icons/logo.svg`, `res/app.ico`) | Original artwork created for ShaderToMP4 | Proprietary (EULA) |
| Interface icons (`res/icons/*.svg`), also used by the Linux / macOS interface | Original drawings made for the project in a geometric stroke style (24 × 24 grid, 2 px stroke). They are simple, generic pictograms (arrows, folders, eye, play...) and are not copied from an icon set. | Proprietary (EULA) |
| Example and test shaders (`examples/`, `tests/`) | Original code of the project | Proprietary (EULA) |
| Language files (`lang/*.json`: English, French, German, Spanish, Italian, Portuguese, Dutch, Japanese, Chinese) | Original texts of the project | Proprietary (EULA) |
| Screenshots and banner (`docs/`) | Produced from the program itself | Proprietary (EULA) |

## 5. Review for proprietary distribution

The program is distributed under a proprietary license, so every component must allow redistribution in proprietary software. Review of the components above: **no component is GPL-only** among those compiled into the program (TweetNaCl: public domain; GLFW and NanoSVG: zlib; Dear ImGui: MIT; Inter: OFL). FFmpeg stays a **separate program** that the program does not link: the Windows installer carries its GPL v3 build with its license text and its corresponding source offer (section 2); the portable archive downloads it. The contributor list was checked: the repository has a single author (the owner of the copyright), so no external contribution needs a written assignment, which is what allowed the move from the GPL to a proprietary license from version 4.0.0. Linux and macOS are frozen: their libraries are not part of the current program.

## 6. Rules for future components

Before adding a dependency (library, font, icon set, tool downloaded at run time):

1. Check that its license allows redistribution inside proprietary software (MIT, BSD, ISC, Zlib, Apache-2.0, MPL-2.0, public domain, SIL OFL for fonts: yes; GPL, AGPL, LGPL used by static linking, "non-commercial", "no derivatives", proprietary without permission: **no**; a GPL program may only be shipped as a separate program run as a separate process).
2. Add a row to this file (English) and to [THIRD_PARTY_NOTICES.fr.md](THIRD_PARTY_NOTICES.fr.md) (French), with the license and the way it is used.
3. Show it in the "About" window (button "Third-party notices").
4. Keep the program portable: nothing is installed outside the application folder. Only the optional Windows installer, which is not the program, writes elsewhere (per-user registry keys and shortcuts, listed in the README).
