// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - mix
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(mix((0.0 + z), (10.0 + z), (0.25 + z)), 2.5));
    ok = ok && (near(mix((-1.0 + z), (1.0 + z), (0.5 + z)), 0.0));
    ok = ok && (near(mix((2.0 + z), (4.0 + z), (1.0 + z)), 4.0));
    ok = ok && (near(mix((5.0 + z), (7.0 + z), (0.0 + z)), 5.0));
    ok = ok && (near(mix((1.0 + z), (2.0 + z), (1.5 + z)), 2.5));
    ok = ok && (near(mix(vec3((0.0 + z), (1.0 + z), (2.0 + z)), vec3((1.0 + z), (2.0 + z), (3.0 + z)), 0.5), vec3(0.5, 1.5, 2.5)));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
