// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Trails (GLSL 3.30, Buffer A) — Native GLSL with two passes: glsl330_traces.bufferA.frag keeps and fades the previous image, this file shows it.
// fr: Traînées (GLSL 3.30, Buffer A) — GLSL natif en deux passes : glsl330_traces.bufferA.frag garde et atténue l'image précédente, ce fichier l'affiche.
#version 330 core
// iChannel0=bufferA
uniform vec3 iResolution;
uniform sampler2D iChannel0;
out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    fragColor = vec4(texture(iChannel0, uv).rgb * 1.15, 1.0);
}
