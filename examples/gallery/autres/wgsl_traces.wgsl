// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Trails (WGSL, Buffer A) — Buffer A keeps the previous image and fades it: a moving dot leaves a trail. The Image pass only shows the buffer.
// fr: Traînées (WGSL, Buffer A) — Le Buffer A garde l'image précédente et l'atténue : un point mobile laisse une traînée. La passe Image n'affiche que le tampon.
// lang=wgsl
// iChannel0=bufferA
struct Uniforms {
    iResolution: vec3<f32>,
};
@group(0) @binding(0) var<uniform> u: Uniforms;
@group(0) @binding(1) var iChannel0: texture_2d<f32>;
@group(0) @binding(2) var smp: sampler;

@fragment
fn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {
    let uv = fragPos.xy / u.iResolution.xy;
    return vec4<f32>(textureSample(iChannel0, smp, uv).rgb * 1.15, 1.0);
}
