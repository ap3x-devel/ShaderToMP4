// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 14_matrix : pixel shader HLSL
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
    float4 iMouse;
    int iFrame;
};

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 fragCoord = fragPos.xy;
    float2 uv = fragCoord / iResolution.xy;
    float2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float3 col = float3(0.0, 0.0, 0.0);
    float2x2 m = float2x2(0.8, 0.6, -0.6, 0.8);
    float2 q = mul(m, p);
    col = 0.5 + 0.5 * cos(q.xyx * 6.0 + float3(0.0, 2.0, 4.0));
    return float4(col, 1.0);
}
