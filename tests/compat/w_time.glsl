// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - uniform float time
// expect=pass
precision highp float;
uniform float time;
bool near(float a, float b) { return abs(a - b) < 0.002; }
void main() {
    gl_FragColor = near(time, 1.0) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
