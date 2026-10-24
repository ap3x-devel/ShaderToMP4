// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - compound assignment, increment and decrement on scalars, vectors and components
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    vec3 v = vec3(1.0 + z, 2.0, 3.0);
    v *= 2.0; v += vec3(1.0); v -= vec3(0.0, 1.0, 0.0); v /= vec3(1.0, 2.0, 1.0);
    ok = ok && near(v, vec3(3.0, 2.0, 7.0));
    v.y += 1.0; v.z *= 2.0; ok = ok && near(v, vec3(3.0, 3.0, 14.0));
    float f = 1.0; f++; ++f; f--; ok = ok && near(f, 2.0 + z);
    int i = 10; i /= 3; i %= 2; ok = ok && i == 1;
    float g = 4.0; g = g * g - 6.0; ok = ok && near(g, 10.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
