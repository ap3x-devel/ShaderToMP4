// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 310 es
// 19_uint_bits : fragment shader GLSL 310 es
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
    uint x = uint(uv.x * 255.0);
    uint y = uint(uv.y * 255.0);
    uint h = (x ^ y) & 255u;
    col = vec3(float(h) / 255.0, float((x * 3u) % 256u) / 255.0, float(x >> 2u) / 63.0);
    outColor = vec4(col, 1.0);
}

void main() {
    shade(fragColor, gl_FragCoord.xy);
}
