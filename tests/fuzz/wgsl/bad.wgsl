// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// erreur voulue : type incompatible (ligne 8)
@fragment
fn main(@builtin(position) pos: vec4<f32>) -> @location(0) vec4<f32> {
    let a: f32 = vec3<f32>(1.0);
    return vec4<f32>(a, 0.0, 0.0, 1.0);
}
