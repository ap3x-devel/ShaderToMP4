// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 430 core
// 10_struct_fn : fragment shader GLSL 430 core
uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;
uniform int iFrame;
layout(location = 0) out vec4 fragColor;
struct Light { vec3 dir; vec3 color; };
vec3 shade(Light l, vec3 n) { return l.color * max(dot(n, l.dir), 0.0) + 0.05; }

void shade(out vec4 outColor, in vec2 fragCoord) {
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
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
