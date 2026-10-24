// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 16_pow_exp : fragment shader WGSL
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
    let c = vec3<f32>(uv, 0.5);
    col = pow(c, vec3<f32>(2.2)) * exp(-uv.x) + log(1.0 + uv.y) * 0.2;
    return vec4<f32>(col, 1.0);
}
