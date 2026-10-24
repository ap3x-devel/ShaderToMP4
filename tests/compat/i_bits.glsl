// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: integer - floatBitsToInt, intBitsToFloat, floatBitsToUint, uintBitsToFloat
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && floatBitsToInt(1.0 + z) == 0x3F800000 && floatBitsToUint(2.0 + z) == 0x40000000u;
    ok = ok && near(intBitsToFloat(0x40400000 + int(z)), 3.0) && near(uintBitsToFloat(0x3F000000u + uint(z)), 0.5);
    ok = ok && floatBitsToInt(-1.0 + z) == int(0xBF800000u);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
