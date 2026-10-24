// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - asin, acos, atan
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(asin((0.0 + z)), 0.0));
    ok = ok && (near(asin((0.5 + z)), 0.5235987755982989));
    ok = ok && (near(asin((-0.8 + z)), -0.9272952180016123));
    ok = ok && (near(asin((1.0 + z)), 1.5707963267948966));
    ok = ok && (near(acos((0.0 + z)), 1.5707963267948966));
    ok = ok && (near(acos((0.5 + z)), 1.0471975511965979));
    ok = ok && (near(acos((-0.8 + z)), 2.498091544796509));
    ok = ok && (near(acos((1.0 + z)), 0.0));
    ok = ok && (near(atan((0.0 + z)), 0.0));
    ok = ok && (near(atan((0.5 + z)), 0.4636476090008061));
    ok = ok && (near(atan((-2.0 + z)), -1.1071487177940904));
    ok = ok && (near(atan((10.0 + z)), 1.4711276743037347));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
