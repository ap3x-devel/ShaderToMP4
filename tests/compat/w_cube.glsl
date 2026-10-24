// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - samplerCube read with textureCube
// expect=pass
// iChannel0=cube:sky
precision highp float;
uniform samplerCube iChannel0;
void main() {
    vec4 a = textureCube(iChannel0, vec3(0.0, 1.0, 0.0));
    gl_FragColor = a.a > 0.5 ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
