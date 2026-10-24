// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: integer - numeric literal forms: 1e3, .5, 5., 0x1F, octal, 1u
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(1e3 + z, 1000.0) && near(1.5e-2 + z, 0.015) && near(.5 + z, 0.5) && near(5. + z, 5.0);
    ok = ok && 0x1F == 31 && 017 == 15 && 1u == uint(1) && 0xFFu == 255u && 10 == int(10.0 + z);
    ok = ok && near(2.5E+1 + z, 25.0) && near(1.0e0 + z, 1.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
