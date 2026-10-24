// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - block scope and shadowing
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
float G = 5.0;
float shadow() { float G = 7.0; return G; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    float x = 1.0 + z;
    { float x = 2.0; ok = ok && near(x, 2.0); { float x = 3.0; ok = ok && near(x, 3.0); } ok = ok && near(x, 2.0); }
    ok = ok && near(x, 1.0);
    for (int x = 0; x < 3; x++) { ok = ok && x < 3; }
    ok = ok && near(x, 1.0) && near(G, 5.0) && near(shadow(), 7.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
