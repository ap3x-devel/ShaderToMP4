// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET
// compat: webgl - void main and gl_FragColor
// expect=pass
void main() {
    gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}
