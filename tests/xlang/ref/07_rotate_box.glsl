// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 07_rotate_box
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float a = iTime * 0.5;
    vec2 q = vec2(cos(a) * p.x - sin(a) * p.y, sin(a) * p.x + cos(a) * p.y);
    vec2 b = abs(q) - vec2(0.25, 0.15);
    float d = length(max(b, 0.0)) + min(max(b.x, b.y), 0.0);
    col = vec3(1.0 - smoothstep(0.0, 0.01, d));
    fragColor = vec4(col, 1.0);
}
