// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: matrix - outerProduct, matrixCompMult, column access, compound assignment
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    mat3 o = outerProduct(vec3(1.0 + z, 2.0, 3.0), vec3(4.0, 5.0, 6.0));
    ok = ok && near(o[1].y, 10.0) && near(o[2], vec3(6.0, 12.0, 18.0));
    mat2 a = mat2(1.0 + z, 2.0, 3.0, 4.0), b = mat2(2.0);
    ok = ok && near(matrixCompMult(a, b)[1], vec2(0.0, 8.0));
    a *= 2.0; ok = ok && near(a[0], vec2(2.0, 4.0));
    a += mat2(1.0); ok = ok && near(a[1], vec2(6.0, 9.0));
    ok = ok && near(a[1][1], 9.0) && near(mat2(0.0 + z, 1.0, 2.0, 3.0)[1][0], 2.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
