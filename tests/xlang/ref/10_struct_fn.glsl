// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 10_struct_fn
struct Light { vec3 dir; vec3 color; };
vec3 shade(Light l, vec3 n) { return l.color * max(dot(n, l.dir), 0.0) + 0.05; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float r2 = dot(p, p);
    float z = sqrt(max(0.0, 0.16 - r2));
    vec3 n = normalize(vec3(p, z));
    Light l = Light(normalize(vec3(0.5, 0.7, 0.6)), vec3(1.0, 0.9, 0.7));
    if (r2 < 0.16) {
        col = shade(l, n);
    } else {
        col = vec3(0.05);
    }
    fragColor = vec4(col, 1.0);
}
