// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - in, out and inout parameters
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void bump(in float x) { x += 1.0; }
void setb(out float x) { x = 42.0; }
void twice(inout float x) { x *= 2.0; }
void swap2(inout vec2 v) { v = v.yx; }
void split(float x, out float frac_) { frac_ = fract(x); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    float a = 1.0 + z, b = 0.0, c = 5.0;
    bump(a); ok = ok && near(a, 1.0);
    setb(b); ok = ok && near(b, 42.0);
    twice(c); ok = ok && near(c, 10.0);
    vec2 p = vec2(1.0, 2.0 + z); swap2(p); ok = ok && near(p, vec2(2.0, 1.0));
    float q; split(7.5 + z, q); ok = ok && near(q, 0.5);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
