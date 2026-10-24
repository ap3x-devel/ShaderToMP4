// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - uniform vec2 resolution
// expect=pass
#version 100
precision highp float;
uniform vec2 resolution;
bool near(float a, float b) { return abs(a - b) < 0.002; }
void main() {
    gl_FragColor = (near(resolution.x, 64.0) && near(resolution.y, 48.0)) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
