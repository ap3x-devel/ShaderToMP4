// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - asinh, acosh, atanh
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(asinh((0.0 + z)), 0.0));
    ok = ok && (near(asinh((0.5 + z)), 0.48121182505960347));
    ok = ok && (near(asinh((-1.0 + z)), -0.881373587019543));
    ok = ok && (near(asinh((3.0 + z)), 1.8184464592320668));
    ok = ok && (near(acosh((1.0 + z)), 0.0));
    ok = ok && (near(acosh((1.5 + z)), 0.9624236501192069));
    ok = ok && (near(acosh((4.0 + z)), 2.0634370688955608));
    ok = ok && (near(atanh((0.0 + z)), 0.0));
    ok = ok && (near(atanh((0.5 + z)), 0.5493061443340549));
    ok = ok && (near(atanh((-0.9 + z)), -1.4722194895832204));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
