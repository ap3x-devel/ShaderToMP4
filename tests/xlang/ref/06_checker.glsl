// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 06_checker
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    vec2 c = floor(uv * 8.0);
    float k = mod(c.x + c.y, 2.0);
    col = mix(vec3(0.1), vec3(0.9, 0.8, 0.2), k);
    fragColor = vec4(col, 1.0);
}
