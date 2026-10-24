// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - iGlobalTime and iGlobalDelta (old Shadertoy names)
// expect=refused fix
bool near(float a, float b) { return abs(a - b) < 0.002; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = near(iGlobalTime, 1.0) ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
