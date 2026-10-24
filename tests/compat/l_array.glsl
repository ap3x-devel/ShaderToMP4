// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - arrays: constructor, indexing, length, loops, array parameters
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
float sum4(float x[4]) { return x[0] + x[1] + x[2] + x[3]; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    float a[4] = float[4](1.0, 2.0, 3.0 + z, 4.0);
    float s = 0.0;
    for (int i = 0; i < a.length(); i++) s += a[i];
    ok = ok && near(s, 10.0) && a.length() == 4 && near(sum4(a), 10.0);
    vec2 v[3] = vec2[](vec2(1.0), vec2(2.0), vec2(3.0 + z));
    ok = ok && near(v[2], vec2(3.0)) && near(v[0] + v[1], vec2(3.0));
    int k[3]; k[0] = 5; k[1] = k[0] * 2; k[2] = k[1] + 1;
    ok = ok && k[2] == 11;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
