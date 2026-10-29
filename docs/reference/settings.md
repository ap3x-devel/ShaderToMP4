<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->
<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->

# Settings reference

Written by the program itself (`ShaderToMP4 --dump-reference=settings`): every key that `config.ini` can hold, with the value it gets by default. A key can be written in `config.ini`, in a `// key=value` comment of a shader and on the command line as `--key=value`.

| Key | Default | Description |
|---|---|---|
| `width` | `1920` | picture width in pixels, 16 to 16384 (rounded to an even number) |
| `height` | `1080` | picture height in pixels, 16 to 16384 (rounded to an even number) |
| `fps` | `60` | frames per second, 1 to 240 |
| `duration` | `90` | seconds (90 = one full loop of this shader) |
| `start` | `0` | start time (iTime) in seconds |
| `crf` | `12` | quality: 0 = lossless, 12 = nearly perfect, 18 = very good |
| `preset` | `slow` | ultrafast ... medium ... slow ... veryslow (slower = smaller file) |
| `codec` | `h264` | h264, h265, vp9 or av1 |
| `container` | `mp4` | mp4, mov, mkv or webm |
| `ss` | `1` | smoothing (supersampling): 1 = none, 2 = x2, 3 = x3, 4 = x4 |
| `outdir` | *empty* | output folder (empty = next to the shader) |
| `bitrate` | `0` | kb/s; 0 = constant quality (crf) |
| `color` | `bt709` | bt709, bt709full (full range), srgb or bt601 |
| `blur` | `1` | motion blur: sub-frames per frame (1 = none, 4, 8, 16) |
| `shutter` | `0.5` | blur shutter, as a fraction of a frame (0.5 = 180 degrees) |
| `loop` | `0` | shader period in seconds: the duration becomes a whole multiple (0 = free) |
| `audio` | *empty* | sound file mixed into the video, aligned with the start time (empty = none) |
| `fadein` | `0` | fade-in in seconds (picture and sound) |
| `fadeout` | `0` | fade-out in seconds |
| `encoder` | `cpu` | cpu, auto, nvenc, amf or qsv (hardware encoding when available) |
| `pbo` | `3` | depth of the GPU read-back queue (2 to 8) |
| `depth` | `8` | 8 or 10 (bits per channel; 10 for H.265, AV1, VP9, ProRes, 16-bit PNG/TIFF) |
| `name` | *empty* | output file name template: {shader} {w} {h} {fps} {date} {codec} |
| `exists` | `overwrite` | when the output already exists: overwrite, number or skip |
| `gpu` | `default` | graphics card on a two-GPU PC (Linux): default, high (the powerful one) or low (the integrated one); needs a restart |
| `endaction` | `none` | after a successful batch: none, folder (show the last file) or sleep |
| `chunk` | `30` | render in parts of N seconds, resumable after an interruption (0 = never) |
| `warmup` | `0` | warm-up: frames simulated before the first one (buffers are warmed up, iFrame starts at N), 0 = none |
| `vr` | `auto` | mainVR shader: auto (when there is no mainImage), off, mono or stereo (360° equirectangular, stereo = left eye on top) |
| `vripd` | `0.064` | distance between the two eyes of the stereo VR render, in shader units (0.064 by default) |
| `metadata` | `1` | 1 = write title and comment in the video file, 0 = none |
| `loopmode` | *written only when it is no longer the default* | seamless loop: none \| crossfade \| pingpong |
| `loopfade` | *written only when it is no longer the default* | duration of the crossfade loop in seconds |
| `timemap` | *written only when it is no longer the default* | time curve `video:shader` in seconds, for example `0:0;4:1;8:5` (empty = real time) |
| `speed` | *written only when it is no longer the default* | speed of the shader time (0.25 = four times slower) |
| `audiofollow` | *written only when it is no longer the default* | the sound follows the constant speed (tempo, pitch kept) |
| `iChannel0` | *written only when it is no longer the default* | texture of iChannel0-3: image path, noise or grid (+ .filter nearest\|linear\|mipmap, .wrap clamp\|repeat, .vflip 0\|1) |
| `bufferA` | *written only when it is no longer the default* | size of Buffer A to D: `bufferA.scale` (fraction of the render size) or `bufferA.size` (`WxH` pixels) |
| `date` | *written only when it is no longer the default* | fixed iDate: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS (reproducible render), add +rate=R for seconds of date per second of video (default 1, 0 = frozen) |
| `variant` | *written only when it is no longer the default* | extra rendering of the same shader: name:key=value\|key=value (e.g. 720p:width=1280\|height=720\|crf=23); repeat the line for each variant |
| `report` | *written only when it is no longer the default* | render report next to the video: json or text (off = none) |
| `samples` | *written only when it is no longer the default* | still image: samples averaged (1 = one) |
| `precheck` | *written only when it is no longer the default* | quality check before each video render (flashes, invalid values) |
| `target` | *written only when it is no longer the default* | publication target: youtube-shorts, tiktok, instagram-reel, discord, x, ... (see presets/targets.ini), sets size, duration, codec and weight |
| `targetsize` | *written only when it is no longer the default* | target file size, e.g. 8MB or 25MB: the bitrate is computed and corrected until the file fits (h264, h265, vp9, av1) |
| `crop` | *written only when it is no longer the default* | crop after rendering: W:H, W:H:X:Y or a ratio such as 9:16 (centred); the shader is rendered in full |
| `mastercache` | *written only when it is no longer the default* | 1 = keep a lossless master in cache/ and derive every format from it without rendering again |
| `cachemax` | *written only when it is no longer the default* | maximum size of cache/ in GB (oldest masters are removed first) |
| `embed` | *written only when it is no longer the default* | 1 = embed the shader, its passes and the settings in the video tag so --reproduce can render it again |
| `animpreview` | *written only when it is no longer the default* | animated preview of the finished video: off, gif or webp (a short loop next to the video) |
| `source` | *written only when it is no longer the default* | effect mode: a video, an image, a sequence (`img_%04d.png`) or a folder, read as `iChannel0`; size, rate, duration and sound follow it |
| `source2` | *written only when it is no longer the default* | second source, `iChannel1`: with a shader that reads `iProgress`, a transition from `source` to `source2` |
| `sourcematch` | *written only when it is no longer the default* | what the source imposes when `source` is set: size, fps, duration (a list) or none |
| `sourceaudio` | *written only when it is no longer the default* | 1 = take the sound of the source (default), 0 = keep the audio setting |
| `reverse` | *written only when it is no longer the default* | 1 = play the time range backwards |
| `sourcefps` | *written only when it is no longer the default* | rate of an image sequence used as source, in images per second (0 = 25) |
| `transitionduration` | *written only when it is no longer the default* | duration of the transition between source and source2, in seconds |
| `transitionoffset` | *written only when it is no longer the default* | shifts the start of the transition, in seconds (positive = later) |
| `parallel` | *written only when it is no longer the default* | parts rendered at the same time by this many OpenGL contexts (1 to 16; needs chunk, the render by parts) |
| `farm` | *written only when it is no longer the default* | shared folder of a render farm: several computers render the parts of the same video (needs `chunk`) |
| `farmtimeout` | *written only when it is no longer the default* | seconds without a sign of life after which the lock of a farm part is taken over (computer switched off) |
| `bpm` | *written only when it is no longer the default* | tempo imposed on the sound analysis, in beats per minute (0 or absent = detected) |
| `beatsperbar` | *written only when it is no longer the default* | beats per bar (2 to 12), used for the bars and the sections |
| `markers` | *written only when it is no longer the default* | markers from the rhythm of the sound: off, chapters (sections as chapters of the file), file (marker files) or all |
| `beatsync` | *written only when it is no longer the default* | montage: cuts placed on the music: off, beat, bar or section |
| `autocredit` | *written only when it is no longer the default* | 1 = write the shader title and author on the first seconds of the video |
| `stillformat` | *written only when it is no longer the default* | still image format: png \| tiff (16 bits per channel with depth=10) |
| `aov` | *written only when it is no longer the default* | output passes written to EXR sequences: name=bufferB.r;normal=bufferC.rgb;alpha;motion (`off` clears) |
| `exrcompression` | *written only when it is no longer the default* | EXR compression: none, zips (one line per block) or zip (sixteen lines, default) |
| `exrprecision` | *written only when it is no longer the default* | EXR precision of the colour: half (16 bits, default) or float (32 bits); depth and id are always 32 bits |
| `alphamode` | *written only when it is no longer the default* | alpha written to PNG, TIFF, DPX and EXR: straight (default) or premult (colour multiplied by alpha) |
| `depthrange` | *written only when it is no longer the default* | depth bounds near:far: the depth.Z channel is written normalised between them and the bounds are declared in the EXR header (empty: raw values) |
| `tifffloat` | *written only when it is no longer the default* | 1 = TIFF sequences written by the program in 32-bit floating point (RGB or RGBA) |
| `vectorblur` | *written only when it is no longer the default* | vector motion blur of the EXR output: fraction of the movement between two frames (0 = none, 1 = all of it); needs a motion pass |
| `dof` | *written only when it is no longer the default* | depth of field of the EXR output: focus:aperture[:max radius], the depth that stays sharp, the pixels of blur per unit of distance from it, and the largest blur radius in pixels (16); needs a depth pass (// aov depth) |
| `tile` | *written only when it is no longer the default* | still image: tile side in pixels (0 = automatic) |
| `printdpi` | *written only when it is no longer the default* | PNG still image: resolution written in the file (dots per inch) |
| `alpha` | *written only when it is no longer the default* | `1` keeps the alpha channel of the shader (ProRes 4444, VP9 WebM, WebP, PNG, TIFF, EXR) |
| `hdr` | *written only when it is no longer the default* | HDR output: `pq` (HDR10) or `hlg`; `off` for none |
| `hdrpeak` | *written only when it is no longer the default* | declared MaxCLL in cd/m² (1000 by default) |
| `hdrfall` | *written only when it is no longer the default* | declared MaxFALL in cd/m² (400 by default) |
| `hdrwhite` | *written only when it is no longer the default* | luminance in cd/m² of a shader white of 1.0 (203 by default) |
| `interp` | *written only when it is no longer the default* | output frame rate by interpolation (0 = none); the render is made at `fps` |
| `scale` | *written only when it is no longer the default* | output size: `1920x1080`, a factor (`2`, `0.5x`); empty = the render size |
| `scalefilter` | *written only when it is no longer the default* | scaling filter: `lanczos`, `bicubic`, `bilinear`, `area` or `neighbor` |
| `loudnorm` | *written only when it is no longer the default* | sound normalization in LUFS, for example `-16` (0 or `off` = none) |
| `title` | *written only when it is no longer the default* | text drawn in the middle of the picture during the first seconds |
| `credit` | *written only when it is no longer the default* | text drawn at the bottom left during the first seconds |
| `titledur` | *written only when it is no longer the default* | duration in seconds of `title` and `credit` (3 by default) |
| `post` | *written only when it is no longer the default* | post-processing effects, e.g. bloom:0.4,grain,vignette (sharpen chroma bloom contrast saturation hue vignette grain; amount after the colon) |
| `lut` | *written only when it is no longer the default* | color LUT in .cube format applied after the effects (1D or 3D, path relative to the shader) |

The program adds its own keys (3D scene, signals and data, colour and quality, dressing and delivery, performance): they are listed in the Pro settings window, one field per key.
