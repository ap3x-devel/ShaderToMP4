// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - structs: constructor, members, functions returning structs, arrays of structs, nesting
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
struct Disc { vec2 c; float r; };
struct Pair { Disc a, b; };
float area(Disc d) { return 3.14159265 * d.r * d.r; }
Disc grow(Disc d, float k) { d.r += k; return d; }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    Disc d = Disc(vec2(1.0 + z, 2.0), 3.0);
    ok = ok && near(d.c, vec2(1.0, 2.0)) && near(d.r, 3.0) && near(area(d), 28.2743338);
    Disc e = grow(d, 1.0);
    ok = ok && near(e.r, 4.0) && near(d.r, 3.0);
    Pair p; p.a = d; p.b = e; ok = ok && near(p.b.r - p.a.r, 1.0);
    Disc list[2] = Disc[](d, e); ok = ok && near(list[1].r, 4.0);
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
