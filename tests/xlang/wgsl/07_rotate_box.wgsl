// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 07_rotate_box : fragment shader WGSL
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
    let a = u.iTime * 0.5;
    let q = vec2<f32>(cos(a) * p.x - sin(a) * p.y, sin(a) * p.x + cos(a) * p.y);
    let b = abs(q) - vec2<f32>(0.25, 0.15);
    let d = length(max(b, vec2<f32>(0.0))) + min(max(b.x, b.y), 0.0);
    col = vec3<f32>(1.0 - smoothstep(0.0, 0.01, d));
    return vec4<f32>(col, 1.0);
}
