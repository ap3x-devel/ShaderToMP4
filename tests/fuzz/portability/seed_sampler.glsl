// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - uniform sampler2D read with texture2D
// expect=pass
// iChannel0=noise
precision highp float;
uniform sampler2D tex;
void main() {
    vec4 a = texture2D(tex, vec2(0.3, 0.3));
    bool ok = a.x >= 0.0 && a.x <= 1.0 && a.w > 0.5;
    gl_FragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
