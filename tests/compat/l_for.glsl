// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - for loops, nested loops, large iteration counts
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    int s = 0; for (int i = 1; i <= 100; i++) s += i; ok = ok && s == 5050;
    float f = 0.0; for (float x = 0.0; x < 1.0; x += 0.25) f += x; ok = ok && near(f, 1.5);
    int t = 0; for (int i = 0; i < 10; i++) for (int j = 0; j < 10; j++) t += (i == j) ? 1 : 0; ok = ok && t == 10;
    int big = 0; for (int i = 0; i < 2000; i++) big += 1 + int(z); ok = ok && big == 2000;
    int c = 0; for (int i = 10; i > 0; i -= 3) c++; ok = ok && c == 4;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
