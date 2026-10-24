// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: matrix - mat2 product, transpose, determinant, inverse
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    mat2 m = mat2(1.0 + z, 2.0, 3.0, 4.0);
    ok = ok && near(m * vec2(1.0), vec2(4.0, 6.0)) && near(transpose(m) * vec2(1.0), vec2(3.0, 7.0));
    ok = ok && near(determinant(m), -2.0);
    mat2 id = inverse(m) * m;
    ok = ok && near(id[0], vec2(1.0, 0.0)) && near(id[1], vec2(0.0, 1.0));
    ok = ok && near((m * m)[1], vec2(15.0, 22.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
