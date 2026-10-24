// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: matrix - mat4 translation, product with a vector, inverse
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    mat4 t = mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 5.0 + z, 6.0, 7.0, 1.0);
    ok = ok && near(t * vec4(1.0, 2.0, 3.0, 1.0), vec4(6.0, 8.0, 10.0, 1.0));
    ok = ok && near(inverse(t) * vec4(6.0, 8.0, 10.0, 1.0), vec4(1.0, 2.0, 3.0, 1.0));
    ok = ok && near((t * t)[3], vec4(10.0, 12.0, 14.0, 1.0));
    ok = ok && near(determinant(t), 1.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
