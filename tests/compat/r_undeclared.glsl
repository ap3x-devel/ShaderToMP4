// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - a variable that was never declared
// expect=refused
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = vec4(nothing_here);
}
