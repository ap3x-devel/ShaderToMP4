// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - exp, log, exp2, log2
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(exp((0.0 + z)), 1.0));
    ok = ok && (near(exp((1.0 + z)), 2.718281828459045));
    ok = ok && (near(exp((-1.0 + z)), 0.36787944117144233));
    ok = ok && (near(exp((2.5 + z)), 12.182493960703473));
    ok = ok && (near(log((1.0 + z)), 0.0));
    ok = ok && (near(log((2.718281828 + z)), 0.9999999998311266));
    ok = ok && (near(log((10.0 + z)), 2.302585092994046));
    ok = ok && (near(log((0.25 + z)), -1.3862943611198906));
    ok = ok && (near(exp2((0.0 + z)), 1.0));
    ok = ok && (near(exp2((3.0 + z)), 8.0));
    ok = ok && (near(exp2((-2.0 + z)), 0.25));
    ok = ok && (near(exp2((0.5 + z)), 1.4142135623730951));
    ok = ok && (near(log2((1.0 + z)), 0.0));
    ok = ok && (near(log2((8.0 + z)), 3.0));
    ok = ok && (near(log2((0.125 + z)), -3.0));
    ok = ok && (near(log2((10.0 + z)), 3.321928094887362));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
