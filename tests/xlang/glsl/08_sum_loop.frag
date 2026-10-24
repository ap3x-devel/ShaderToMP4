// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 410 core
// 08_sum_loop : fragment shader GLSL 410 core
uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;
uniform int iFrame;
layout(location = 0) out vec4 fragColor;

void shade(out vec4 outColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float s = 0.0;
    for (int i = 0; i < 5; i++) {
        float f = float(i) + 1.0;
        s += sin(uv.x * f * 6.0 + iTime * f) / f;
    }
    col = vec3(0.5 + 0.5 * s) * vec3(0.9, 0.6, 0.3);
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
