// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 20_array_blend : fragment shader WGSL
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
    var w = array<f32, 3>(0.2, 0.3, 0.5);
    var c = array<vec2<f32>, 3>(vec2<f32>(-0.2, 0.0), vec2<f32>(0.2, 0.1), vec2<f32>(0.0, -0.2));
    col = vec3<f32>(0.0);
    for (var i = 0; i < 3; i++) {
        let d = length(p - c[i]);
        col += w[i] * (1.0 - smoothstep(0.1, 0.25, d)) * (0.5 + 0.5 * cos(f32(i) * 2.0 + vec3<f32>(0.0, 2.0, 4.0)));
    }
    col *= 2.0;
    return vec4<f32>(col, 1.0);
}
