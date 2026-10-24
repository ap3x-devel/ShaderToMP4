// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: matrix - mat3 product, determinant, inverse of a diagonal and a general matrix
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    mat3 d = mat3(2.0 + z, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0);
    ok = ok && near(d * vec3(1.0), vec3(2.0, 3.0, 4.0)) && near(determinant(d), 24.0);
    ok = ok && near(inverse(d)[1], vec3(0.0, 1.0 / 3.0, 0.0));
    mat3 m = mat3(1.0 + z, 2.0, 3.0, 0.0, 1.0, 4.0, 5.0, 6.0, 0.0);
    ok = ok && near(determinant(m), 1.0);
    mat3 id = m * inverse(m);
    ok = ok && near(id[0], vec3(1.0, 0.0, 0.0)) && near(id[1], vec3(0.0, 1.0, 0.0)) && near(id[2], vec3(0.0, 0.0, 1.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
