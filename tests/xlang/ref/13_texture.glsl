// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 13_texture
// iChannel0=grid
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    col = texture(iChannel0, uv).rgb * vec3(1.0, 0.8, 0.8);
    fragColor = vec4(col, 1.0);
}
