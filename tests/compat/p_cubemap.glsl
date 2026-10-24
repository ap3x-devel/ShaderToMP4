// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: pass - Cubemap A: the +X face is lit with the direction
// expect=pass
// iChannel0=cubeA
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    vec4 c = texture(iChannel0, vec3(1.0, 0.0, 0.0));
    ok = ok && near(c.xyz, vec3(1.0, 0.5, 0.5)) && near(texture(iChannel0, vec3(0.0, 1.0, 0.0)).xyz, vec3(0.5, 1.0, 0.5));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
