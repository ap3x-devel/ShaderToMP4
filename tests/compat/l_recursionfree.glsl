// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - a chain of small functions, early returns, and a function with no return value
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void add3(inout float a, float v) { a += v; a += v; a += v; }
float early(float x) { if (x < 0.0) return 1.0; return 2.0; }
float c1(float x) { return x + 1.0; }
float c2(float x) { return x * 2.0; }
float c3(float x) { return x + 3.0; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    float acc = 0.0; add3(acc, 1.0 + z); ok = ok && near(acc, 3.0) && near(early((-1.0 + z)), 1.0) && near(early((1.0 + z)), 2.0);
    ok = ok && near(c3(c2(c1(1.0 + z))), 7.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
