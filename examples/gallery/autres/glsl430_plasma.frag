// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Plasma (GLSL 4.30) — A complete fragment shader with #version 430, layout(location) and its own main(): it is translated to GLSL 3.30 before compiling.
// fr: Plasma (GLSL 4.30) — Un fragment shader complet avec #version 430, layout(location) et son propre main() : il est traduit en GLSL 3.30 avant la compilation.
#version 430 core
uniform vec3 iResolution;
uniform float iTime;
layout(location = 0) out vec4 fragColor;

void main() {
    vec2 p = (gl_FragCoord.xy - 0.5 * iResolution.xy) / iResolution.y * 6.0;
    float v = sin(p.x + iTime) + sin(p.y * 1.3 - iTime * 0.7) + sin((p.x + p.y) * 0.8 + iTime * 0.5) + sin(length(p) - iTime);
    fragColor = vec4(0.5 + 0.5 * cos(v + vec3(0.0, 2.1, 4.2)), 1.0);
}
