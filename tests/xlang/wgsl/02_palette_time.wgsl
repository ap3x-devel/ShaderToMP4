// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 02_palette_time : fragment shader WGSL
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
    col = 0.5 + 0.5 * cos(u.iTime + uv.xyx + vec3<f32>(0.0, 2.0, 4.0));
    return vec4<f32>(col, 1.0);
}
