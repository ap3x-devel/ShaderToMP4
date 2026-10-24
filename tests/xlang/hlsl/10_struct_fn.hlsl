// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 10_struct_fn : pixel shader HLSL
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
    float4 iMouse;
    int iFrame;
};
struct Light { float3 dir; float3 color; };
float3 shade(Light l, float3 n) { return l.color * max(dot(n, l.dir), 0.0) + 0.05; }

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 fragCoord = fragPos.xy;
    float2 uv = fragCoord / iResolution.xy;
    float2 p = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    float3 col = float3(0.0, 0.0, 0.0);
    float r2 = dot(p, p);
    float z = sqrt(max(0.0, 0.16 - r2));
    float3 n = normalize(float3(p, z));
    Light l;
    l.dir = normalize(float3(0.5, 0.7, 0.6));
    l.color = float3(1.0, 0.9, 0.7);
    if (r2 < 0.16) {
        col = shade(l, n);
    } else {
        col = float3(0.05, 0.05, 0.05);
    }
    return float4(col, 1.0);
}
