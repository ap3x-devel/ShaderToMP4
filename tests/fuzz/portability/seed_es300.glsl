// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - GLSL ES 3.00 style: out vec4 and in vec2
// expect=pass
#version 300 es
precision highp float;
in vec2 vUv;
out vec4 outColor;
void main() {
    bool ok = vUv.x > 0.0 && vUv.y < 1.0;
    outColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
