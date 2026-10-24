// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - the usual fract(sin()) hash stays inside 0..1 and is repeatable
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    float a = fract(sin(dot(fragCoord, vec2(12.9898, 78.233))) * 43758.5453);
    float b = fract(sin(dot(fragCoord, vec2(12.9898, 78.233))) * 43758.5453);
    ok = ok && a >= 0.0 && a < 1.0 && near(a, b);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
