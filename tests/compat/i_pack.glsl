// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: integer - packUnorm4x8, packHalf2x16, packSnorm2x16 and their inverses
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && packUnorm4x8(vec4(1.0 + z, 0.0, 1.0, 0.0)) == 0x00FF00FFu;
    ok = ok && near(unpackUnorm4x8(0x00FF00FFu + uint(z)), vec4(1.0, 0.0, 1.0, 0.0));
    ok = ok && packHalf2x16(vec2(1.0 + z, 2.0)) == 0x40003C00u;
    ok = ok && near(unpackHalf2x16(0x40003C00u + uint(z)), vec2(1.0, 2.0));
    ok = ok && packSnorm2x16(vec2(1.0 + z, -1.0)) == 0x80017FFFu;
    ok = ok && near(unpackSnorm2x16(0x80017FFFu + uint(z)), vec2(1.0, -1.0));
    ok = ok && packUnorm2x16(vec2(1.0 + z, 0.0)) == 0x0000FFFFu;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
