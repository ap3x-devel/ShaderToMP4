// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#version 430 core
// erreur voulue : le nom n existe pas (ligne 7)
out vec4 fragColor;
void main() { fragColor = vec4(undefinedName); }
