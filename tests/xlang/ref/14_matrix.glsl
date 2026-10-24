// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 14_matrix
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    mat2 m = mat2(0.8, -0.6, 0.6, 0.8);
    vec2 q = m * p;
    col = 0.5 + 0.5 * cos(q.xyx * 6.0 + vec3(0.0, 2.0, 4.0));
    fragColor = vec4(col, 1.0);
}
