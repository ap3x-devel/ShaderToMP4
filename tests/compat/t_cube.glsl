// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: texture - cubemap channel: the sky is lit above and darker below, textureCube works
// expect=pass
// iChannel0=cube:sky
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    vec4 up = texture(iChannel0, vec3(0.0, 1.0, 0.0)), down = texture(iChannel0, vec3(0.0, -1.0, 0.0));
    ok = ok && up.a > 0.5 && (up.x + up.y + up.z) != (down.x + down.y + down.z);
    ok = ok && near(textureCube(iChannel0, vec3(1.0, 0.2, 0.1)), texture(iChannel0, vec3(1.0, 0.2, 0.1)));
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
