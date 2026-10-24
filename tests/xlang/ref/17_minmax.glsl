// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 17_minmax
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    col = vec3(clamp(uv.x * 2.0 - 0.5, 0.0, 1.0), abs(sin(uv.y * 6.0)), max(min(uv.x, uv.y), 0.2)) * sign(uv.x + 0.1);
    fragColor = vec4(col, 1.0);
}
