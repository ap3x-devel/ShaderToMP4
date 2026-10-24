// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 04_rings
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float v = 0.5 + 0.5 * sin(length(p) * 20.0 - iTime * 3.0);
    col = vec3(v, v * 0.5, 1.0 - v);
    fragColor = vec4(col, 1.0);
}
