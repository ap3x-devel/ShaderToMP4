// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: texture - grid channel: not constant
// expect=pass
// iChannel0=grid
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ivec2 s = textureSize(iChannel0, 0);
    float lo = 1.0, hi = 0.0;
    for (int i = 0; i < s.x; i += 4) { float t = texelFetch(iChannel0, ivec2(i, s.y / 2), 0).x; lo = min(lo, t); hi = max(hi, t); }
    ok = ok && hi - lo > 0.05;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
