// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 15_polar : pixel shader HLSL
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
    float a = atan2(p.y, p.x);
    float r = length(p);
    col = float3(0.5 + 0.5 * sin(a * 5.0 + iTime), 0.5 + 0.5 * cos(r * 10.0), 0.5);
    return float4(col, 1.0);
}
