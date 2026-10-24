// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 15_polar
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float a = atan(p.y, p.x);
    float r = length(p);
    col = vec3(0.5 + 0.5 * sin(a * 5.0 + iTime), 0.5 + 0.5 * cos(r * 10.0), 0.5);
    fragColor = vec4(col, 1.0);
}
