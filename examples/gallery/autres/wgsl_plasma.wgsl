// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Plasma (WGSL) — Sum of sines in a WGSL fragment shader; the uniforms are a struct bound at group 0, binding 0.
// fr: Plasma (WGSL) — Somme de sinus dans un fragment shader WGSL ; les uniforms sont une structure liée au groupe 0, liaison 0.
// lang=wgsl
struct Uniforms {
    iResolution: vec3<f32>,
    iTime: f32,
};
@group(0) @binding(0) var<uniform> u: Uniforms;

@fragment
fn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    let p = (fragPos.xy - 0.5 * u.iResolution.xy) / u.iResolution.y * 6.0;
    let v = sin(p.x + u.iTime) + sin(p.y * 1.3 - u.iTime * 0.7) + sin((p.x + p.y) * 0.8 + u.iTime * 0.5) + sin(length(p) - u.iTime);
    let col = 0.5 + 0.5 * cos(v + vec3<f32>(0.0, 2.1, 4.2));
    return vec4<f32>(col, 1.0);
}
