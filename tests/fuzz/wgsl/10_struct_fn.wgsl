// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 10_struct_fn : fragment shader WGSL
struct Uniforms {
    iResolution: vec3<f32>,
    iTime: f32,
    iMouse: vec4<f32>,
    iFrame: i32,
};
@group(0) @binding(0) var<uniform> u: Uniforms;
struct Light { dir: vec3<f32>, color: vec3<f32>, };
fn shade(l: Light, n: vec3<f32>) -> vec3<f32> { return l.color * max(dot(n, l.dir), 0.0) + 0.05; }

@fragment
fn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    let fragCoord = fragPos.xy;
    let uv = fragCoord / u.iResolution.xy;
    let p = (fragCoord - 0.5 * u.iResolution.xy) / u.iResolution.y;
    var col = vec3<f32>(0.0);
    let r2 = dot(p, p);
    let z = sqrt(max(0.0, 0.16 - r2));
    let n = normalize(vec3<f32>(p, z));
    let l = Light(normalize(vec3<f32>(0.5, 0.7, 0.6)), vec3<f32>(1.0, 0.9, 0.7));
    if (r2 < 0.16) {
        col = shade(l, n);
    } else {
        col = vec3<f32>(0.05);
    }
    return vec4<f32>(col, 1.0);
}
