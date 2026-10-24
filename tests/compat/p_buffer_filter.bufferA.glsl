// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: pass - p_buffer_filter
void mainImage(out vec4 fragColor, in vec2 fragCoord) { fragColor = vec4(fract(fragCoord.x * 0.37), 0.0, 0.0, 1.0); }
