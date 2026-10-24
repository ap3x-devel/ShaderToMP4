// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - varying vec2 vUv is the normalised pixel position
// expect=pass
precision highp float;
varying vec2 vUv;
void main() {
    bool ok = vUv.x > 0.0 && vUv.x < 1.0 && vUv.y > 0.0 && vUv.y < 1.0;
    gl_FragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
