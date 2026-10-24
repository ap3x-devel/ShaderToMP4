// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 13_texture : pixel shader HLSL
// iChannel0=grid
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
    float4 iMouse;
    int iFrame;
};
Texture2D iChannel0 : register(t1);
SamplerState smp : register(s1);

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 fragCoord = fragPos.xy;
    float2 uv = fragCoord / iResolution.xy;
    float2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float3 col = float3(0.0, 0.0, 0.0);
    col = iChannel0.Sample(smp, uv).rgb * float3(1.0, 0.8, 0.8);
    return float4(col, 1.0);
}
