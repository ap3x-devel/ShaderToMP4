// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - sin, cos, tan
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(sin((0.0 + z)), 0.0));
    ok = ok && (near(sin((0.5 + z)), 0.479425538604203));
    ok = ok && (near(sin((1.0 + z)), 0.8414709848078965));
    ok = ok && (near(sin((-1.2 + z)), -0.9320390859672263));
    ok = ok && (near(sin((2.5 + z)), 0.5984721441039565));
    ok = ok && (near(cos((0.0 + z)), 1.0));
    ok = ok && (near(cos((0.5 + z)), 0.8775825618903728));
    ok = ok && (near(cos((1.0 + z)), 0.5403023058681397));
    ok = ok && (near(cos((-1.2 + z)), 0.3623577544766736));
    ok = ok && (near(cos((2.5 + z)), -0.8011436155469337));
    ok = ok && (near(tan((0.0 + z)), 0.0));
    ok = ok && (near(tan((0.5 + z)), 0.5463024898437905));
    ok = ok && (near(tan((1.0 + z)), 1.5574077246549023));
    ok = ok && (near(tan((-0.7 + z)), -0.8422883804630794));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
