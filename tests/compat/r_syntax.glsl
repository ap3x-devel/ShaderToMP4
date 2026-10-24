// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - a missing semicolon
// expect=refused
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float x = 1.0
    fragColor = vec4(x);
}
