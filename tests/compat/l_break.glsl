// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - break and continue
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    int s = 0; for (int i = 0; i < 100; i++) { if (i == 10 + int(z)) break; s += i; } ok = ok && s == 45;
    int t = 0; for (int i = 0; i < 10; i++) { if (i % 2 == 1) continue; t += i; } ok = ok && t == 20;
    int w = 0; int i = 0; while (true) { i++; if (i > 5) break; if (i == 3) continue; w += i; } ok = ok && w == 12;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
