// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=wgsl
// Buffer A : couleur dependant de la position et du temps, avec retroaction (il se relit lui-meme)
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
    let prev = textureSample(iChannel0, smp, uv).rgb;
    return vec4<f32>(prev * 0.5 + vec3<f32>(uv * k(), 0.25 + 0.1 * sin(u.iTime)) * 0.5, 1.0);
}
