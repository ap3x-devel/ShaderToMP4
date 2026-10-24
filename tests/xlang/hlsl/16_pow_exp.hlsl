// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 16_pow_exp : pixel shader HLSL
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
    float3 c = float3(uv, 0.5);
    col = pow(c, float3(2.2, 2.2, 2.2)) * exp(-uv.x) + log(1.0 + uv.y) * 0.2;
    return float4(col, 1.0);
}
