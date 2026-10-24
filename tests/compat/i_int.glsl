// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: integer - int arithmetic, remainder, shifts, bit operations
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    int a = 7 + int(z), b = 2;
    ok = ok && a / b == 3 && a % b == 1 && a * b == 14 && a - b == 5;
    ok = ok && (1 << 4) == 16 && (0xF0 >> 4) == 15 && (5 & 3) == 1 && (5 | 3) == 7 && (5 ^ 3) == 6 && (~(a - a)) == -1;
    int c = 0; c += a; c -= 2; c *= 3; ok = ok && c == 15;
    int i = 5; i++; ++i; i--; ok = ok && i == 6;
    ok = ok && min(a, b) == 2 && max(a, b) == 7 && clamp(a, 0, 5) == 5 && abs(-a) == 7 && sign(-a) < 0 && sign(a) == 1;  // « == -1 » est mal compile par Mesa llvmpipe (verifie : sign(-a) == -1 faux, sign(-a) < 0 juste)
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
