// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - swizzles on function results, on constructors and on array elements
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
vec2 mk() { return vec2(1.0, 2.0); }
vec2[2] arr() { return vec2[2](vec2(1.0, 2.0), vec2(3.0, 4.0)); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(vec4(1.0, 2.0, 3.0 + z, 4.0).zw, vec2(3.0, 4.0)) && near(mk().yx, vec2(2.0, 1.0)) && near(arr()[1].y, 4.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
