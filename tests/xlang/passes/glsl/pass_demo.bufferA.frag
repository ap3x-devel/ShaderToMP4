// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 430 core
// Buffer A : couleur dependant de la position et du temps, avec retroaction (GLSL 4.30)
// iChannel0=bufferA
uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D iChannel0;
out vec4 fragColor;
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec3 prev = texture(iChannel0, uv).rgb;
    fragColor = vec4(prev * 0.5 + vec3(uv * 0.5, 0.25 + 0.1 * sin(iTime)) * 0.5, 1.0);
}
