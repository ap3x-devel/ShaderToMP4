// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 300 es
// 16_pow_exp : fragment shader GLSL 300 es
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
    vec3 c = vec3(uv, 0.5);
    col = pow(c, vec3(2.2)) * exp(-uv.x) + log(1.0 + uv.y) * 0.2;
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
