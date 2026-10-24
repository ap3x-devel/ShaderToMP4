// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: vector - reflect, refract, faceforward
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(reflect(vec3((1.0 + z), (-1.0 + z), (0.0 + z)), vec3(0.0, 1.0, 0.0)), vec3(1.0, 1.0, 0.0)));
    ok = ok && (near(refract(vec3((0.0 + z), (-1.0 + z), (0.0 + z)), vec3(0.0, 1.0, 0.0), 1.0), vec3(0.0, -1.0, 0.0)));
    ok = ok && (near(faceforward(vec3(0.0, 1.0, 0.0), vec3((0.0 + z), (1.0 + z), (0.0 + z)), vec3(0.0, 1.0, 0.0)), vec3(0.0, -1.0, 0.0)));
    ok = ok && (near(faceforward(vec3(0.0, 1.0, 0.0), vec3((0.0 + z), (-1.0 + z), (0.0 + z)), vec3(0.0, 1.0, 0.0)), vec3(0.0, 1.0, 0.0)));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
