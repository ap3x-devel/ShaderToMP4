// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: texture - clamp wrap: outside the image returns the edge
// expect=pass
// iChannel0=noise
// iChannel0.wrap=clamp
// iChannel0.filter=nearest
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && near(texture(iChannel0, vec2(-3.0, 0.5)), texture(iChannel0, vec2(0.0, 0.5))) && near(texture(iChannel0, vec2(4.0, 0.5)), texture(iChannel0, vec2(1.0, 0.5)));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
