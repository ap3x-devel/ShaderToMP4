// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - uniform vec2 mouse
// expect=pass
// mouse=0.5,0.25,down
precision highp float;
uniform vec2 mouse;
bool near(float a, float b) { return abs(a - b) < 0.002; }
void main() {
    gl_FragColor = (near(mouse.x, 32.0) && near(mouse.y, 12.0)) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
