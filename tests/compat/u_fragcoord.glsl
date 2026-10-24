// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: uniform - fragCoord is the pixel centre and stays inside the image
// expect=pass
bool near(float a, float b) { return abs(a - b) < 0.002 * max(1.0, abs(b)); }
bool near(vec2 a, vec2 b) { return near(a.x, b.x) && near(a.y, b.y); }
bool near(vec3 a, vec3 b) { return near(a.xy, b.xy) && near(a.z, b.z); }
bool near(vec4 a, vec4 b) { return near(a.xyz, b.xyz) && near(a.w, b.w); }
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float z = min(iTime, 0.0);
    bool ok = true;
    ok = ok && abs(fract(fragCoord.x) - 0.5) < 0.001 && abs(fract(fragCoord.y) - 0.5) < 0.001;
    ok = ok && fragCoord.x > 0.0 && fragCoord.x < iResolution.x && fragCoord.y > 0.0 && fragCoord.y < iResolution.y;
    vec2 uv = fragCoord / iResolution.xy; ok = ok && uv.x > 0.0 && uv.x < 1.0 && uv.y > 0.0 && uv.y < 1.0;
    fragColor = ok ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
