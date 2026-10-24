// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 11_mouse
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    vec2 m = iMouse.xy / iResolution.xy;
    col = vec3(1.0 - smoothstep(0.19, 0.2, length(uv - m)), uv.x * 0.3, 0.2);
    fragColor = vec4(col, 1.0);
}
