// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// erreur voulue : le nom n existe pas (ligne 7)
float4 main(float4 pos : SV_Position) : SV_Target {
    return float4(undefinedName, 0, 0, 1);
}
