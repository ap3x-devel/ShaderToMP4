// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: math - step, smoothstep
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && (near(step((0.5 + z), (0.2 + z)), 0.0));
    ok = ok && (near(step((0.5 + z), (0.8 + z)), 1.0));
    ok = ok && (near(step((1.0 + z), (1.0 + z)), 1.0));
    ok = ok && (near(smoothstep(0.0, 1.0, (0.0 + z)), 0.0));
    ok = ok && (near(smoothstep(0.0, 1.0, (0.25 + z)), 0.15625));
    ok = ok && (near(smoothstep(0.0, 1.0, (0.5 + z)), 0.5));
    ok = ok && (near(smoothstep(0.0, 1.0, (0.9 + z)), 0.972));
    ok = ok && (near(smoothstep(0.0, 1.0, (1.0 + z)), 1.0));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
