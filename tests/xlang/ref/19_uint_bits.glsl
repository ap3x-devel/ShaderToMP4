// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 19_uint_bits
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    uint x = uint(uv.x * 255.0);
    uint y = uint(uv.y * 255.0);
    uint h = (x ^ y) & 255u;
    col = vec3(float(h) / 255.0, float((x * 3u) % 256u) / 255.0, float(x >> 2u) / 63.0);
    fragColor = vec4(col, 1.0);
}
