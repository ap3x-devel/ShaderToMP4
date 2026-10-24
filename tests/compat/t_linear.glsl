// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: texture - linear filter: the value between two texels lies between them
// expect=pass
// iChannel0=noise
// iChannel0.filter=linear
// iChannel0.wrap=clamp
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ivec2 s = textureSize(iChannel0, 0);
    vec2 inv = 1.0 / vec2(s);
    float a = texelFetch(iChannel0, ivec2(10, 10), 0).x, b = texelFetch(iChannel0, ivec2(11, 10), 0).x;
    float m = texture(iChannel0, vec2(11.0, 10.5) * inv).x;
    ok = ok && m >= min(a, b) - 0.01 && m <= max(a, b) + 0.01 && abs(m - 0.5 * (a + b)) < 0.02;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
