// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - helper functions and loops before main
// expect=pass
precision highp float;
float sq(float x) { return x * x; }
float total(int n) { float s = 0.0; for (int i = 1; i <= 10; i++) { if (i > n) break; s += float(i); } return s; }
bool near(float a, float b) { return abs(a - b) < 0.002; }
void main() {
    gl_FragColor = (near(sq(3.0), 9.0) && near(total(4), 10.0)) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
