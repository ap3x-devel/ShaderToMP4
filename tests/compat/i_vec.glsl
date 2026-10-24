// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: integer - ivec and uvec arithmetic and conversions
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ivec3 a = ivec3(1, 2, 3) + ivec3(int(z));
    ok = ok && a * 2 == ivec3(2, 4, 6) && a.yz == ivec2(2, 3) && (a + ivec3(1)) == ivec3(2, 3, 4);
    uvec2 u = uvec2(3u, 4u) + uvec2(uint(z));
    ok = ok && u.x + u.y == 7u && uvec2(ivec2(5, 6)) == uvec2(5u, 6u);
    ok = ok && near(vec3(a), vec3(1.0, 2.0, 3.0)) && ivec3(vec3(1.9, 2.9, -3.9)) == ivec3(1, 2, -3);
    ok = ok && all(equal(a, ivec3(1, 2, 3))) && any(lessThan(a, ivec3(2)));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
