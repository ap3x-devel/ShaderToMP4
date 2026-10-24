// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - function overloading and prototypes
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
float f(float x) { return 1.0; }
float f(vec2 x) { return 2.0; }
float f(vec3 x) { return 3.0; }
int f(int x) { return x * 10; }
float later(float x);
float later(float x) { return x * 2.0; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(f((1.0 + z)), 1.0) && near(f(vec2((1.0 + z), (1.0 + z))), 2.0) && near(f(vec3((1.0 + z), (1.0 + z), (1.0 + z))), 3.0) && f(4) == 40;
    ok = ok && near(later(2.0 + z), 4.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
