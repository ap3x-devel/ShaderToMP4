// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 14_matrix : fragment shader WGSL
struct Uniforms {
    iResolution: vec3<f32>,
    iTime: f32,
    iMouse: vec4<f32>,
    iFrame: i32,
};
@group(0) @binding(0) var<uniform> u: Uniforms;

@fragment
fn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    let fragCoord = fragPos.xy;
    let uv = fragCoord / u.iResolution.xy;
    let p = (fragCoord - 0.5 * u.iResolution.xy) / u.iResolution.y;
    var col = vec3<f32>(0.0);
    let m = mat2x2<f32>(vec2<f32>(0.8, -0.6), vec2<f32>(0.6, 0.8));
    let q = m * p;
    col = 0.5 + 0.5 * cos(q.xyx * 6.0 + vec3<f32>(0.0, 2.0, 4.0));
    return vec4<f32>(col, 1.0);
}
