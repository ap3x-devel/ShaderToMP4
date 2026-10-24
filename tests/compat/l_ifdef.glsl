// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: language - conditional compilation: #if, #ifdef, #ifndef, #elif, __VERSION__, GL_ES
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
#define FEATURE
#define LEVEL 2
#ifdef GL_ES
precision mediump float;
#endif
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    #ifdef FEATURE
ok = ok && true;
#else
ok = false;
#endif
    #ifndef MISSING
ok = ok && true;
#endif
    #if LEVEL == 2
ok = ok && true;
#elif LEVEL == 3
ok = false;
#else
ok = false;
#endif
    #if defined(FEATURE) && !defined(MISSING)
ok = ok && true;
#endif
    #if __VERSION__ >= 300
ok = ok && true;
#else
ok = false;
#endif
    #ifdef GL_ES
ok = ok && false;
#endif
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
