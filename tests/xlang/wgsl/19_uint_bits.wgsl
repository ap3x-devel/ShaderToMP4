// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 19_uint_bits : fragment shader WGSL
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
    let x = u32(uv.x * 255.0);
    let y = u32(uv.y * 255.0);
    let h = (x ^ y) & 255u;
    col = vec3<f32>(f32(h) / 255.0, f32((x * 3u) % 256u) / 255.0, f32(x >> 2u) / 63.0);
    return vec4<f32>(col, 1.0);
}
