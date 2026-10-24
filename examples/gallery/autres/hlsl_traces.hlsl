// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Trails (HLSL, Buffer A) — Buffer A keeps the previous image and fades it: a moving dot leaves a trail. The Image pass only shows the buffer.
// fr: Traînées (HLSL, Buffer A) — Le Buffer A garde l'image précédente et l'atténue : un point mobile laisse une traînée. La passe Image n'affiche que le tampon.
// lang=hlsl
// iChannel0=bufferA
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
};
Texture2D iChannel0 : register(t1);
SamplerState smp : register(s1);

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 uv = fragPos.xy / iResolution.xy;
    return float4(iChannel0.Sample(smp, uv).rgb * 1.15, 1.0);
}
