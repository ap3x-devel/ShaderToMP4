// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - sinh, cosh, tanh
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(sinh((0.0 + z)), 0.0));
    ok = ok && (near(sinh((0.5 + z)), 0.5210953054937474));
    ok = ok && (near(sinh((-1.0 + z)), -1.1752011936438014));
    ok = ok && (near(sinh((2.0 + z)), 3.6268604078470186));
    ok = ok && (near(cosh((0.0 + z)), 1.0));
    ok = ok && (near(cosh((0.5 + z)), 1.1276259652063807));
    ok = ok && (near(cosh((-1.0 + z)), 1.5430806348152437));
    ok = ok && (near(cosh((2.0 + z)), 3.7621956910836314));
    ok = ok && (near(tanh((0.0 + z)), 0.0));
    ok = ok && (near(tanh((0.5 + z)), 0.46211715726000974));
    ok = ok && (near(tanh((-1.0 + z)), -0.7615941559557649));
    ok = ok && (near(tanh((3.0 + z)), 0.9950547536867305));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
