// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - ternary operator and short-circuit evaluation
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
int counter = 0;
bool bump() { counter++; return true; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    int before = counter;
    bool a = false && bump();
    bool b = true || bump();
    ok = ok && counter == before && !a && b;
    bool c = true && bump(); ok = ok && counter == before + 1 && c;
    float t = (z < 1.0) ? 3.0 : 4.0; ok = ok && near(t, 3.0);
    vec2 v = (z > 1.0) ? vec2(1.0) : vec2(2.0); ok = ok && near(v, vec2(2.0));
    ok = ok && (true ^^ false) && !(true ^^ true);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
