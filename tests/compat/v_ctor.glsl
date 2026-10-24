// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: vector - constructors from mixed parts and conversions
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(vec4(vec2((1.0 + z), (2.0 + z)), 3.0, 4.0), vec4(1.0, 2.0, 3.0, 4.0));
    ok = ok && near(vec3(vec2((1.0 + z), (2.0 + z)), 3.0), vec3(1.0, 2.0, 3.0)) && near(vec2(5.0 + z), vec2(5.0));
    ok = ok && near(vec4((0.5 + z)), vec4(0.5));
    ok = ok && ivec2(vec2(1.7, -1.7)) == ivec2(1, -1) && int(2.9) == 2 && float(3) == 3.0;
    ok = ok && bool(1.0) && !bool(0) && uint(3.0) == 3u;
    ok = ok && near(vec3(ivec3(1, 2, 3)), vec3(1.0, 2.0, 3.0)) && near(vec2(uvec2(4u, 5u)), vec2(4.0, 5.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
