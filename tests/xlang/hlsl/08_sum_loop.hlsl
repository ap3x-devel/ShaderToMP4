// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 08_sum_loop : pixel shader HLSL
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
    float s = 0.0;
    for (int i = 0; i < 5; i++) {
        float f = float(i) + 1.0;
        s += sin(uv.x * f * 6.0 + iTime * f) / f;
    }
    col = (0.5 + 0.5 * s) * float3(0.9, 0.6, 0.3);
    return float4(col, 1.0);
}
