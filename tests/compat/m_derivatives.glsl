// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - dFdx, dFdy, fwidth of the pixel position
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && abs(dFdx(fragCoord.x) - 1.0) < 0.001 && abs(dFdy(fragCoord.y) - 1.0) < 0.001;
    ok = ok && abs(dFdy(fragCoord.x)) < 0.001 && abs(dFdx(fragCoord.y)) < 0.001;
    ok = ok && abs(fwidth(fragCoord.x + fragCoord.y) - 2.0) < 0.001;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
