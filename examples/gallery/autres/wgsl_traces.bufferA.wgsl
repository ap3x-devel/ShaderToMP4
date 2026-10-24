// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// iChannel0=bufferA
struct Uniforms {
    iResolution: vec3<f32>,
    iTime: f32,
};
@group(0) @binding(0) var<uniform> u: Uniforms;
@group(0) @binding(1) var iChannel0: texture_2d<f32>;
@group(0) @binding(2) var smp: sampler;

@fragment
fn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    let uv = fragPos.xy / u.iResolution.xy;
    let c = 0.5 + 0.35 * vec2<f32>(cos(u.iTime * 1.7), sin(u.iTime * 1.1));
    let d = length((uv - c) * vec2<f32>(u.iResolution.x / u.iResolution.y, 1.0));
    let dotColor = (1.0 - smoothstep(0.02, 0.04, d)) * (0.5 + 0.5 * cos(u.iTime + vec3<f32>(0.0, 2.0, 4.0)));
    let prev = textureSample(iChannel0, smp, uv).rgb * 0.96;
    return vec4<f32>(max(prev, dotColor), 1.0);
}
