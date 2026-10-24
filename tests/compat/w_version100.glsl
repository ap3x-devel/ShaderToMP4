// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - #version 100 with a precision statement
// expect=pass
#version 100
precision mediump float;
void main() {
    gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}
