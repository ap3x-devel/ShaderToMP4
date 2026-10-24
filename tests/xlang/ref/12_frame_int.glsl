// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 12_frame_int
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    int f = iFrame;
    col = vec3(fract(float(f) * 0.37), float(f % 3) / 3.0, 0.3 + 0.1 * float(f));
    col += uv.x * 0.5;
    fragColor = vec4(col, 1.0);
}
