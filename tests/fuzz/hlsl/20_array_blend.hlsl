// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 20_array_blend : pixel shader HLSL
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
    float w[3] = { 0.2, 0.3, 0.5 };
    float2 c[3] = { float2(-0.2, 0.0), float2(0.2, 0.1), float2(0.0, -0.2) };
    col = float3(0.0, 0.0, 0.0);
    for (int i = 0; i < 3; i++) {
        float d = length(p - c[i]);
        col += w[i] * (1.0 - smoothstep(0.1, 0.25, d)) * (0.5 + 0.5 * cos(float(i) * 2.0 + float3(0.0, 2.0, 4.0)));
    }
    col *= 2.0;
    return float4(col, 1.0);
}
