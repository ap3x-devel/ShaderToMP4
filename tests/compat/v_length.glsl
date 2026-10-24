// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: vector - length, distance, dot
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(length(vec2((3.0 + z), (4.0 + z))), 5.0));
    ok = ok && (near(length(vec3((1.0 + z), (2.0 + z), (2.0 + z))), 3.0));
    ok = ok && (near(distance(vec2((1.0 + z), (1.0 + z)), vec2((4.0 + z), (5.0 + z))), 5.0));
    ok = ok && (near(dot(vec3((1.0 + z), (2.0 + z), (3.0 + z)), vec3((4.0 + z), (5.0 + z), (6.0 + z))), 32.0));
    ok = ok && (near(dot(vec2((1.0 + z), (0.0 + z)), vec2((0.0 + z), (1.0 + z))), 0.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
