// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: texture - mipmap filter: textureLod at a high level is the average, which is near 0.5 for noise
// expect=pass
// iChannel0=noise
// iChannel0.filter=mipmap
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    vec4 a = textureLod(iChannel0, vec2(0.5), 8.0);
    ok = ok && a.x > 0.3 && a.x < 0.7;
    ok = ok && near(textureLod(iChannel0, vec2(0.25), 0.0), texture(iChannel0, vec2(0.25)));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
