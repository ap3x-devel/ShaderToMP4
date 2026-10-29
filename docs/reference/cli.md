<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->
<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->

# Command line

The options of `ShaderToMP4`, written by the program itself (`ShaderToMP4 --dump-reference=cli`); they are the lines of `--help`. Any setting of the settings reference can be given as `--key=value`.

| Option | Description |
|---|---|
| `shader files` | Add the files and start rendering right away |
| `--selftest` | Render the reference shaders and compare them (see tests/) |
| `--update` | With --selftest: rewrite the reference images |
| `--render` | Render the files without a window (any system, see below) |
| `--quiet` | No message box (--selftest, --get-ffmpeg) |
| `--get-ffmpeg` | Download and install ffmpeg, without a window |
| `--version` | Show the version, copyright and license |
| `--help` | Show this help |
| `--key=value` | Any setting of the settings table (--width=1280 --codec=h265 --container=mp4 --crf=18 --outdir=C:\out ...) |
| `--profile=f` | Apply an .ini profile (the --key=value options come after it) |
| `--progress=json\|text\|none` | JSON lines (start, progress, log, done, error, end) or a line every 10 % |
| `--png` | Render a single PNG image at the start time |
| `--thumb[=s]` | A cover thumbnail PNG (1280 pixels wide at most) at second s, by default the middle of the range |
| `--verify` | Re-read finished videos: duration, rate, frame count, SHA-256, and compare with the render report; exit code 7 on a mismatch |
| `--beats[=list\|clear] sound...` | analyse the tempo, beats, bars and sections of sound files (writes <sound>.beats.json next to each; list prints the times, clear removes the corrections made by hand) |
| `--parallel=N, --farm=folder, --farm-status folder` | render the parts of a video with N OpenGL contexts, or with several computers on a shared folder (same command on each; --farm-status lists the parts done, in progress and free); needs --chunk; --benchmark --parallel measures the gain |
| `--source=file\|folder\|img_%04d.png, --source2=file` | apply the shader to a video, an image, a sequence or every file of a folder (iChannel0; the second source is iChannel1 and iProgress runs from 0 to 1 for transitions); size, rate, duration, sound, subtitles and chapters come from the source (--sourcematch=..., --sourceaudio=0), --reverse=1 plays backwards |
| `--aov=depth=bufferB.r;normal=bufferC.rgb;alpha;motion, --exrcompression=none\|zips\|zip, --exrprecision=half\|float, --alphamode=straight\|premult, --depthrange=near:far, --tifffloat=1` | multilayer OpenEXR written by the program (container exr); --exr-info file\|folder lists the layers, --depthmap file\|folder [--depthinvert] writes a 16-bit depth map |
| `--reproduce` | Extract the source embedded in a video (embed=1) and render it again into <video>_reproduced/ |
| `--export-html` | Write a standalone HTML page (WebGL 2) from the shader and its passes instead of a video |
| `--cache-purge` | Empty the lossless master cache (cache/ next to the program) |
| `--check[=list]` | Quality check without rendering: flash, nan, flicker, alias, portability (all by default); exit code 6 when something is found |
| `--compare a b` | Compare two shaders (--compare-video=sbs\|curtain\|diff, --tolerance=N); exit code 7 when they differ |
| `--golden=record\|verify` | Keep reference frames of a shader in golden/ or check against them (exit code 7 on a change) |
| `--dry-run` | Estimate the render time (a few measured seconds per file) without writing the video |
| `--png=best` | Smart thumbnail: the three richest frames of the range, written as name_thumb.png, name_thumb2.png, name_thumb3.png |
| `--cubefaces[=n]` | The six faces (n x n pixels) of a cubemap of a mainVR shader: name_px.png, _nx, _py, _ny, _pz, _nz |
| `--heatmap[=CxR]` | Cost map: the GPU time of each zone of the screen (16x9 by default) as name_heat.png |
| `--samples=N` | With --png: average N independent samples of the same instant (path-traced shaders) |
| `--find-loop[=s]` | Search the period of the shader over s seconds (no render) and print the duration= / loop= to use |
| `--sheet=CxR` | A contact sheet PNG of C x R thumbnails taken evenly over the duration (--sheet=4x3) |
| `--param=name=value` | Set a shader parameter (// uniform): --param=speed=2.5 or keyframes --param="speed=smooth 0:1 ; 4:3" |
| `--watch=dir` | Keep running and render every .glsl / .txt that appears in the folder (stop with Ctrl+C; --watch-count=N stops after N renders) |
| `--watch-move` | With --watch: move each shader (and its passes) to done/ or failed/ after its render; profile.ini in the folder or a sub-folder sets its settings |
| `--log=file` | Also write everything that is displayed, with a time stamp, to this file (appended) |
| `--report=json\|text` | Write a render report (time, speed, bottleneck, size, warnings) next to each video |
| `a .json file` | An export of a Shadertoy shader (Export button of the page): imported into the "shadertoy" folder, then rendered. No account or key needed |
| `--diagnostic` | Print system, graphics card, OpenGL, ffmpeg and encoders (no path, no personal data) for a bug report |
| `--benchmark` | Measure frames per second by resolution and encoder (--seconds=N, --quick, --full, --json, --compare=file, --max-drop=N) |
| `--live` | Live output in a borderless window on a screen (--live-monitor=N, --live-monitors, --live-window[=WxH], --live-seconds=N, --live-fps=N, --live-record=file.mkv, --live-stream=srt://... or rtmp://..., --live-bitrate=kb/s, --live-osc=host:port, --live-midi=N, --live-midi-devices, --live-json) |
| `--license-info` | Show the license status and the file expected next to the program |
| `--check-update[=url] [--download]` | Ask GitHub for the latest version (only when you run this); exit code 8 when a newer one exists; --download saves the installer in updates/ after checking its SHA-256, installs nothing |

Exit codes: 0 all done, 1 a render failed, 2 invalid command line, 3 no OpenGL 3.3, 4 ffmpeg not found, 5 benchmark regression, 6 --check found something, 7 --compare / --golden found a difference
