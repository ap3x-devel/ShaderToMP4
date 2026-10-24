// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - fract, mod
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(fract((1.75 + z)), 0.75));
    ok = ok && (near(fract((-0.25 + z)), 0.75));
    ok = ok && (near(fract((3.0 + z)), 0.0));
    ok = ok && (near(fract((0.1 + z)), 0.1));
    ok = ok && (near(mod((7.0 + z), (3.0 + z)), 1.0));
    ok = ok && (near(mod((-1.0 + z), (3.0 + z)), 2.0));
    ok = ok && (near(mod((5.5 + z), (2.0 + z)), 1.5));
    ok = ok && (near(mod((0.25 + z), (1.0 + z)), 0.25));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
