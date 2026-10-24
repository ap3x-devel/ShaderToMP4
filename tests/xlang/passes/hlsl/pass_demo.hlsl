// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// Image : relit le Buffer A
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
    return float4(iChannel0.Sample(smp, uv).rgb / k(), 1.0);
}
