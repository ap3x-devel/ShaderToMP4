// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// Buffer A : couleur dependant de la position et du temps, avec retroaction (il se relit lui-meme)
// iChannel0=bufferA
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
};
Texture2D iChannel0 : register(t1);
SamplerState smp : register(s1);

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 uv = fragPos.xy / iResolution.xy;
    float3 prev = iChannel0.Sample(smp, uv).rgb;
    return float4(prev * 0.5 + float3(uv * k(), 0.25 + 0.1 * sin(iTime)) * 0.5, 1.0);
}
