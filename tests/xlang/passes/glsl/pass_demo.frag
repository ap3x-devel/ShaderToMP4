// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 430 core
// Image : relit le Buffer A (GLSL 4.30)
// iChannel0=bufferA
uniform vec3 iResolution;
uniform sampler2D iChannel0;
out vec4 fragColor;
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    fragColor = vec4(texture(iChannel0, uv).rgb / 0.5, 1.0);
}
