// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - gl_FragCoord is the pixel centre
// expect=pass
precision highp float;
bool near(float a, float b) { return abs(a - b) < 0.002; }
void main() {
    vec2 p = gl_FragCoord.xy;
    bool ok = near(fract(p.x), 0.5) && near(fract(p.y), 0.5) && p.x < 64.0 && p.y < 48.0;
    gl_FragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
