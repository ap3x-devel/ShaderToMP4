<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->

[Français](security.fr.md) · **English**

# Security review of ShaderToMP4 4.1.0

Written for version 4.1.0 on 2026-10-29. It states what the program trusts, what it reads, what it sends, and how each reader is tested. It is not a guarantee: the checks below reduce the risk, they do not remove it.

## Threat model

| Source | Trusted? | What the program does about it |
|---|---|---|
| Shader files, passes, textures, audio and video you choose | **No**: they may come from anyone | Shader text goes to the graphics driver's compiler and is never executed by the program. Media are decoded by `ffmpeg` in a separate process. Every text and file reader below is fuzzed. A shader can still take a long time to render or use much memory. |
| Settings, presets, projects, queue, history, key files | Written by the program, but may be edited or copied from elsewhere | Read with the same fuzzed readers; an unknown key is ignored, a damaged or too new file is refused with a message. |
| 3D, MIDI, data, subtitle, ICC, LUT, colour-configuration files | **No** | Fuzzed readers with size limits (for example 65536 pixels and 2^28 samples for EXR, a depth limit in the expression reader). The OpenColorIO configuration is read by the OpenColorIO program, a separate process. |
| The network | **No** | The program sends nothing unless you ask for it by an explicit action: the update check, a Shadertoy import (with your own key), the ffmpeg or dxc download, a live stream to the address you typed. Only `https` addresses (or the loopback address for tests) are accepted for updates; the downloaded files are checked against a published SHA-256 sum. No telemetry. |
| The local API (`--serve`) | Off until asked | Listens on 127.0.0.1 only, token of 64 characters in `serve.token`, requests without or with a wrong token refused, foreign `Host` or any `Origin` header refused, request reader fuzzed. |
| Live inputs (OSC over UDP, MIDI) | Only when the live output is started | Packets are parsed by a fuzzed reader; values only drive the parameters you declared. |
| The license file | Signed by the author | Ed25519 signature checked offline; a wrong, expired or other-major file changes nothing but the displayed state. Fuzzed. |
| Windows, the graphics driver, `ffmpeg` and the translators | Trusted as the system | They are separate programs or system components; their own flaws are theirs. |

The program writes only in its own folder (portable mode). It never asks for administrator rights and never changes the registry; only the optional installer writes per-user registry keys and shortcuts.

## Inputs read and their fuzzing target

`ShaderToMP4 --fuzz=<target> --fuzz-count=N --fuzz-seed=S` damages valid inputs (flipped bits, inserted, removed and repeated pieces, tricky numbers) and requires that the reader neither crashes, nor loops for more than 8 s, nor throws. `--fuzz=list` prints the targets, `--fuzz=all` runs them all, and the self-test runs all of them with 500 inputs each. The starting inputs are in the code and in `tests/fuzz/<target>/`. The self-test case "security review" fails when a reader of this table has no target or no starting input, and when a target is missing from this table.

| Input | Fuzzing target |
|---|---|
| config.ini, user presets, shader comments (// key=value) | `ini` |
| jobs/*.ini (settings of one shader) | `jobs` |
| queue.txt | `queue` |
| project file (.s2mproj) | `project` |
| keys.ini and shortcut text | `shortcuts` |
| time-indexed key lists (mouse, keyboard) | `keys` |
| history.jsonl | `history` |
| montage file (.montage) | `montage` |
| LUT file (.cube, 1D and 3D) | `cube` |
| OpenEXR images read back | `exr` |
| floating-point TIFF images read back | `tifffloat` |
| parameters declared in a shader (// uniform ...) | `params` |
| expressions of animated parameters | `expr` |
| time curves and speed curves | `timemap` |
| post-processing chains | `post` |
| delivery targets (targets.ini) | `targets` |
| --check list | `check` |
| loudness measurement JSON from ffmpeg | `loudnorm` |
| compiler messages (file:line) | `location` |
| JSON documents (language files, schema, answers) | `json` |
| Shadertoy export JSON | `shadertoy` |
| Shadertoy API answer | `shadertoyapi` |
| shader source in the WebGL 1 / GLSL ES style | `portability` |
| HLSL shader source | `hlsl` |
| WGSL shader source | `wgsl` |
| GLSL 4.x shader source | `glslnative` |
| requests received by the local API | `http-request` |
| OSC packets | `osc` |
| beat markers and tempo | `beats` |
| release description of the update check | `update` |
| license file (ShaderToMP4.license) | `license` |
| MIDI files | `pro_midi` |
| data files (CSV, TSV, JSON, OSC capture) | `pro_csv` |
| OBJ meshes | `pro_obj` |
| PLY meshes | `pro_ply` |
| glTF and GLB meshes and animations | `pro_gltf` |
| subtitle files (.srt, .vtt, .ass, .ssa) | `pro_subtitles` |
| delivery files (delivery.ini) | `pro_delivery` |
| ICC profiles | `pro_icc` |
| layer lines (layer1 ... layer12) | `pro_layers` |
| 3D scene, camera and guide settings | `pro_scene` |
| tone curve, colour space and OpenColorIO settings | `pro_color` |

Not covered by a target of the program, because another component reads them: images, audio and video (decoded by `ffmpeg`), SVG logos (Direct2D), fonts (the system), `.ocio` configurations (OpenColorIO), GLSL source (the driver's compiler).

Defects found by this work and fixed: size limits in the TIFF and EXR readers, a depth limit in the expression reader, size limits in the mesh and data readers; in 4.1.0, an ASS subtitle file whose `Format:` line has no `Text` column read outside its field list (target `pro_subtitles`, starting input `tests/fuzz/pro_subtitles/seed_format_without_text.ass`).

## Known vulnerabilities of the shipped components

`scripts/check-vulnerabilities.ps1` asks the National Vulnerability Database about each component of `scripts/components.json`. Result of 2026-10-29:

| Component | Version | Records found |
|---|---|---|
| FFmpeg (gyan.dev essentials build) | 9.0.2 | 7 (6 medium, 1 low: CVE-2025-25468, CVE-2025-25469 and five CVE-2026 records) |
| OpenColorIO (`ociobakelut`) | 2.6.0 | none |
| glslang | 16.6.0 | none |
| NSIS run-time | 3.11 | none |

The FFmpeg records concern the decoding of crafted media files. The program only passes to `ffmpeg` the files you choose, in a separate process; do not open media from sources you do not trust, and update ffmpeg when a fixed build is published (the program downloads a pinned build, listed in `THIRD_PARTY_NOTICES.md`). The database only knows the versions that records name: an empty result is not a guarantee, and the program's own code is not covered by it.

## Reporting a problem

Write to ap3x.records@proton.me with the version (`--version`), the input that triggers it if you can share it, and what you saw.
