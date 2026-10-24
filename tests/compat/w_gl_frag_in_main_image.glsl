// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - gl_FragColor inside mainImage (a common mix-up)
// expect=refused
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}
