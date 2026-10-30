<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->

[Français](compare-4.1.0.fr.md) · **English**

# ShaderToMP4 4.1.0 against 3.0.0: compatibility and performance

Measured on 2026-10-29 on the maintainer's PC (Windows 11, Intel UHD graphics, no NVIDIA card), with the released 3.0.0 built from its tag and the 4.1.0 of this repository, both **without a license file** (so the 4.1.0 draws its trial watermark, which is part of its cost). Nothing was tuned between the runs; the numbers describe this machine only, see [hardware.md](hardware.md) for the rules of reading them.

## Shadertoy compatibility

The corpus is the 113 self-checking shaders of `tests/compat` (WebGL 1 and GLSL ES styles, legacy macros, uniform redeclarations, texture function names, packing functions, deliberate errors). Each one is rendered at 64x48 with `--render`; 104 of them are expected to render, 9 are expected to be refused with a message.

| Version | Shaders rendered | Of the 104 expected to render |
|---|---|---|
| 3.0.0 | 91 | 91 |
| 4.1.0 | 104 | **104** |

Every shader that 3.0.0 rendered still renders, and 13 more render. The compatibility work after 3.0.0 (WebGL 1 / GLSL ES reading, packing functions, texture function names) targets exactly this kind of shader; the individual cause of each of the 13 was not traced.

## Performance

`--benchmark --full --seconds=2`, three runs of each version taken one after the other, median of the three, frames per second (higher is better).

| Case | 3.0.0 | 4.1.0 | Change |
|---|---|---|---|
| 1280x720, x264 on the CPU | 224.7 | 202.5 | -9.9 % |
| 1920x1080, x264 on the CPU | 99.2 | 103.9 | +4.7 % |
| 1920x1080, Intel Quick Sync | 106.5 | 106.4 | -0.1 % |
| 3840x2160, x264 on the CPU | 29.8 | 29.5 | -1.0 % |
| 1920x1080, Intel Quick Sync (second case) | 102.2 | 105.3 | +3.0 % |
| 1920x1080, in parts (chunks) | 143.4 | 130.7 | -8.9 % |
| 1920x1080, with a video channel | 92.9 | 90.0 | -3.1 % |

The largest drop is 9.9 %, under the 15 % limit set for this release. The 720p case varies by several percent from one run to the next on this machine.

## Start and memory

| Measure | 3.0.0 | 4.1.0 |
|---|---|---|
| `--version` (process start to exit), three runs | 165, 92, 95 ms | 94, 97, 96 ms |
| Peak memory of a 3 s 1080p render, three runs | 119, 120, 119 MB | 121, 118, 118 MB |

## How to repeat

```
ShaderToMP4 --benchmark --full --seconds=2 --json
ShaderToMP4 --selftest-compat
```
