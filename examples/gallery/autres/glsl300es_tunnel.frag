// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Tunnel (GLSL ES 3.00) — A WebGL 2 style shader: #version 300 es, precision, out vec4. The usual names time and resolution also work.
// fr: Tunnel (GLSL ES 3.00) — Un shader à la WebGL 2 : #version 300 es, precision, out vec4. Les noms usuels time et resolution fonctionnent aussi.
#version 300 es
precision highp float;
uniform vec3 iResolution;
uniform float iTime;
out vec4 fragColor;

void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    float a = atan(p.y, p.x) / 6.28318;
    float r = length(p) + 0.001;
    vec2 q = vec2(a * 6.0, 0.4 / r + iTime * 0.8);
    float checker = abs(fract(q.x) - 0.5) + abs(fract(q.y) - 0.5);
    vec3 col = mix(vec3(0.1, 0.2, 0.6), vec3(1.0, 0.6, 0.2), step(0.5, checker));
    fragColor = vec4(col * clamp(r * 2.5, 0.0, 1.0), 1.0);
}
