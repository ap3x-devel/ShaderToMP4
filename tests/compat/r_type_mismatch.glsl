// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - a float assigned to a vec3
// expect=refused
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 c = 0.5;
    fragColor = vec4(c, 1.0);
}
