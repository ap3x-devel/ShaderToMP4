// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: pass - p_buffer_feedback
// iChannel0=bufferA
void mainImage(out vec4 fragColor, in vec2 fragCoord) { float prev = texelFetch(iChannel0, ivec2(fragCoord), 0).x; fragColor = vec4(prev + 1.0 / 60.0, 0.0, 0.0, 1.0); }
