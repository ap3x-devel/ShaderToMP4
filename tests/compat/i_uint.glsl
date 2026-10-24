// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: integer - uint arithmetic and wrap-around
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    uint a = 7u + uint(z), b = 2u;
    ok = ok && a / b == 3u && a % b == 1u && (a << 1u) == 14u && (a >> 1u) == 3u && (a & b) == 2u && (a | b) == 7u;
    uint m = 0xFFFFFFFFu + uint(z);
    ok = ok && m + 1u == 0u && (m >> 28u) == 15u && m == ~0u;
    ok = ok && uint(int(a)) == 7u && int(a) == 7;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
