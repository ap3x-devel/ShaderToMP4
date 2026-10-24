// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - u_time and u_resolution
// expect=pass
precision highp float;
uniform float u_time;
uniform vec2 u_resolution;
bool near(float a, float b) { return abs(a - b) < 0.002; }
void main() {
    gl_FragColor = (near(u_time, 1.0) && near(u_resolution.y, 48.0)) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
