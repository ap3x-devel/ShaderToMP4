// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: pass - p_buffer_noise
// iChannel0=noise
// iChannel0.filter=nearest
void mainImage(out vec4 fragColor, in vec2 fragCoord) { fragColor = vec4(texelFetch(iChannel0, ivec2(fragCoord) % textureSize(iChannel0, 0), 0).x, 0.0, 0.0, 1.0); }
