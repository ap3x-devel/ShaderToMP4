// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 300 es
// 20_array_blend : fragment shader GLSL 300 es
precision highp float;
precision highp int;
uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;
uniform int iFrame;
out vec4 fragColor;

void shade(out vec4 outColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float w[3] = float[3](0.2, 0.3, 0.5);
    vec2 c[3] = vec2[3](vec2(-0.2, 0.0), vec2(0.2, 0.1), vec2(0.0, -0.2));
    col = vec3(0.0);
    for (int i = 0; i < 3; i++) {
        float d = length(p - c[i]);
        col += w[i] * (1.0 - smoothstep(0.1, 0.25, d)) * (0.5 + 0.5 * cos(float(i) * 2.0 + vec3(0.0, 2.0, 4.0)));
    }
    col *= 2.0;
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
