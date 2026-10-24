// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 09_branch
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    if (uv.x > 0.5) {
        col = vec3(uv.y, 0.2, 0.7);
    } else {
        col = vec3(0.1, uv.y, 0.4);
    }
    if (uv.y > 0.75) {
        col *= 0.5;
    }
    fragColor = vec4(col, 1.0);
}
