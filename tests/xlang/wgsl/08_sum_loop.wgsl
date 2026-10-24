// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 08_sum_loop : fragment shader WGSL
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
    var s = 0.0;
    for (var i = 0; i < 5; i++) {
        let f = f32(i) + 1.0;
        s += sin(uv.x * f * 6.0 + u.iTime * f) / f;
    }
    col = vec3<f32>(0.5 + 0.5 * s) * vec3<f32>(0.9, 0.6, 0.3);
    return vec4<f32>(col, 1.0);
}
