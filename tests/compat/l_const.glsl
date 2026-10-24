// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - const variables, constant expressions and const arrays
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
const float PI_ = 3.14159265;
const float K2 = 2.0 * PI_;
const float HALF = 1.0 / 2.0;
const int T[3] = int[3](10, 20, 30);
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(K2, 6.2831853) && near(HALF + z, 0.5) && T[1] == 20;
    const int n = 3 * 4; ok = ok && n == 12;
    const vec2 c = vec2(1.0, 2.0) * 2.0; ok = ok && near(c, vec2(2.0, 4.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
