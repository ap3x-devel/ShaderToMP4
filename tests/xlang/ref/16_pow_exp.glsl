// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 16_pow_exp
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    vec3 c = vec3(uv, 0.5);
    col = pow(c, vec3(2.2)) * exp(-uv.x) + log(1.0 + uv.y) * 0.2;
    fragColor = vec4(col, 1.0);
}
