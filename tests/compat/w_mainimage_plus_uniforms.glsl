// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - a mainImage shader that also declares the Shadertoy uniforms itself
// expect=pass
// iChannel0=noise
uniform vec3 iResolution;
uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
bool near(float a, float b) { return abs(a - b) < 0.002; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = (near(iTime, 1.0) && near(iResolution.x, 64.0) && iFrame == 0) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
