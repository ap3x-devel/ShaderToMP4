// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 300 es
// 15_polar : fragment shader GLSL 300 es
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
    float a = atan(p.y, p.x);
    float r = length(p);
    col = vec3(0.5 + 0.5 * sin(a * 5.0 + iTime), 0.5 + 0.5 * cos(r * 10.0), 0.5);
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
