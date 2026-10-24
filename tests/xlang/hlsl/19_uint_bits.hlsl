// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 19_uint_bits : pixel shader HLSL
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
    uint x = (uint)(uv.x * 255.0);
    uint y = (uint)(uv.y * 255.0);
    uint h = (x ^ y) & 255u;
    col = float3(float(h) / 255.0, float((x * 3u) % 256u) / 255.0, float(x >> 2u) / 63.0);
    return float4(col, 1.0);
}
