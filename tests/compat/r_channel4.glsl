// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - iChannel4 does not exist
// expect=refused
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel4, vec2(0.5));
}
