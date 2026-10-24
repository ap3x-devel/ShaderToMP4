// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Reference Shadertoy de 18_lighting
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(p, -1.5));
    float b = dot(ro, rd);
    float c2 = dot(ro, ro) - 1.0;
    float h = b * b - c2;
    col = vec3(0.1);
    if (h > 0.0) {
        float t = -b - sqrt(h);
        vec3 pos = ro + t * rd;
        vec3 n = normalize(pos);
        vec3 l = normalize(vec3(0.6, 0.7, 0.5));
        float dif = max(dot(n, l), 0.0);
        vec3 r = reflect(-l, n);
        float spec = pow(max(dot(r, -rd), 0.0), 16.0);
        col = vec3(0.8, 0.3, 0.2) * dif + spec;
    }
    fragColor = vec4(col, 1.0);
}
