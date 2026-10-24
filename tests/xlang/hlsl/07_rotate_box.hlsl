// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 07_rotate_box : pixel shader HLSL
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
    float a = iTime * 0.5;
    float2 q = float2(cos(a) * p.x - sin(a) * p.y, sin(a) * p.x + cos(a) * p.y);
    float2 b = abs(q) - float2(0.25, 0.15);
    float d = length(max(b, 0.0)) + min(max(b.x, b.y), 0.0);
    col = (1.0 - smoothstep(0.0, 0.01, d)) * float3(1.0, 1.0, 1.0);
    return float4(col, 1.0);
}
