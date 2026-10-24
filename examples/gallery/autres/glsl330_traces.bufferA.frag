// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 330 core
// iChannel0=bufferA
uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D iChannel0;
out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 c = 0.5 + 0.35 * vec2(cos(iTime * 1.7), sin(iTime * 1.1));
    float d = length((uv - c) * vec2(iResolution.x / iResolution.y, 1.0));
    vec3 dotColor = (1.0 - smoothstep(0.02, 0.04, d)) * (0.5 + 0.5 * cos(iTime + vec3(0.0, 2.0, 4.0)));
    vec3 prev = texture(iChannel0, uv).rgb * 0.96;
    fragColor = vec4(max(prev, dotColor), 1.0);
}
