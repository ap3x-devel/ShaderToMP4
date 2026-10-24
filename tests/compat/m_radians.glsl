// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - radians, degrees
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(radians((0.0 + z)), 0.0));
    ok = ok && (near(radians((90.0 + z)), 1.5707963267948966));
    ok = ok && (near(radians((180.0 + z)), 3.141592653589793));
    ok = ok && (near(radians((-45.0 + z)), -0.7853981633974483));
    ok = ok && (near(degrees((0.0 + z)), 0.0));
    ok = ok && (near(degrees((1.0 + z)), 57.29577951308232));
    ok = ok && (near(degrees((3.141592653589793 + z)), 180.0));
    ok = ok && (near(degrees((-0.5 + z)), -28.64788975654116));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
