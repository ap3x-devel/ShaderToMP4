// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Tunnel (WGSL) — Polar coordinates with atan2 and length; mix and select are the WGSL tools for blending and choosing.
// fr: Tunnel (WGSL) — Coordonnées polaires avec atan2 et length ; mix et select sont les outils WGSL pour mélanger et choisir.
// lang=wgsl
struct Uniforms {
    iResolution: vec3<f32>,
    iTime: f32,
};
@group(0) @binding(0) var<uniform> u: Uniforms;

@fragment
fn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    let p = (fragPos.xy - 0.5 * u.iResolution.xy) / u.iResolution.y;
    let a = atan2(p.y, p.x) / 6.28318;
    let r = length(p) + 0.001;
    let q = vec2<f32>(a * 6.0, 0.4 / r + u.iTime * 0.8);
    let checker = abs(fract(q.x) - 0.5) + abs(fract(q.y) - 0.5);
    let col = mix(vec3<f32>(0.1, 0.2, 0.6), vec3<f32>(1.0, 0.6, 0.2), step(0.5, checker));
    return vec4<f32>(col * clamp(r * 2.5, 0.0, 1.0), 1.0);
}
