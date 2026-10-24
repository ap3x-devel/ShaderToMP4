// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// 18_lighting : fragment shader WGSL
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
    let ro = vec3<f32>(0.0, 0.0, 3.0);
    let rd = normalize(vec3<f32>(p, -1.5));
    let b = dot(ro, rd);
    let c2 = dot(ro, ro) - 1.0;
    let h = b * b - c2;
    col = vec3<f32>(0.1);
    if (h > 0.0) {
        let t = -b - sqrt(h);
        let pos = ro + t * rd;
        let n = normalize(pos);
        let l = normalize(vec3<f32>(0.6, 0.7, 0.5));
        let dif = max(dot(n, l), 0.0);
        let r = reflect(-l, n);
        let spec = pow(max(dot(r, -rd), 0.0), 16.0);
        col = vec3<f32>(0.8, 0.3, 0.2) * dif + spec;
    }
    return vec4<f32>(col, 1.0);
}
