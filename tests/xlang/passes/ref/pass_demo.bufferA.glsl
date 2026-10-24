// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Buffer A de la reference Shadertoy : se relit lui-meme (retroaction)
// iChannel0=bufferA
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec3 prev = texture(iChannel0, uv).rgb;
    fragColor = vec4(prev * 0.5 + vec3(uv * k(), 0.25 + 0.1 * sin(iTime)) * 0.5, 1.0);
}
