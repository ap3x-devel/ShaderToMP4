// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - preprocessor macros: object-like, function-like, nested, #undef
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
#define SQ(x) ((x) * (x))
#define TWICE(x) (2.0 * (x))
#define ITER 8
#define PI_ 3.14159265
#define MIX3(a, b, t) mix(a, b, t)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(SQ(3.0 + z), 9.0) && near(SQ(1.0 + 2.0 + z), 9.0) && near(TWICE(SQ(2.0 + z)), 8.0);
    ok = ok && ITER == 8 && near(PI_ * 2.0 + z, 6.2831853);
    #undef ITER
    #define ITER 3
    ok = ok && ITER == 3;
    ok = ok && near(MIX3(vec3((0.0 + z), (1.0 + z), (2.0 + z)), vec3((1.0 + z), (2.0 + z), (3.0 + z)), 0.5), vec3(0.5, 1.5, 2.5));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
