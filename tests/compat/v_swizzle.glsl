// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: vector - swizzles with xyzw, rgba and stpq
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    vec4 v = vec4((1.0 + z), (2.0 + z), (3.0 + z), (4.0 + z));
    ok = ok && near(v.zyx, vec3(3.0, 2.0, 1.0)) && near(v.wzyx, vec4(4.0, 3.0, 2.0, 1.0)) && near(v.xxyy, vec4(1.0, 1.0, 2.0, 2.0));
    ok = ok && near(v.rgb, vec3(1.0, 2.0, 3.0)) && near(v.a, 4.0) && near(v.stp, vec3(1.0, 2.0, 3.0));
    v.xy = v.yx; v.zw += vec2(1.0);
    ok = ok && near(v, vec4(2.0, 1.0, 4.0, 5.0));
    v.rb = vec2(9.0, 8.0);
    ok = ok && near(v, vec4(9.0, 1.0, 8.0, 5.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
