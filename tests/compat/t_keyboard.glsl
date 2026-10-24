// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: texture - keyboard channel: a key held from 0 s is down at 1 s, others are up
// expect=pass
// iChannel0=keyboard
// key=a:0-2
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && textureSize(iChannel0, 0) == ivec2(256, 3);
    ok = ok && texelFetch(iChannel0, ivec2(65, 0), 0).x > 0.5 && texelFetch(iChannel0, ivec2(66, 0), 0).x < 0.5;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
