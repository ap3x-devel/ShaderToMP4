// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 330 core
// 03_circle : fragment shader GLSL 330 core
uniform vec3 iResolution;
uniform float iTime;
uniform vec4 iMouse;
uniform int iFrame;
out vec4 fragColor;

void shade(out vec4 outColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    float d = length(p);
    col = vec3(1.0 - smoothstep(0.29, 0.31, d)) * vec3(1.0, 0.5, 0.2);
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
