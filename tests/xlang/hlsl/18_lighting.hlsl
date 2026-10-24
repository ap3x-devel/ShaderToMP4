// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// 18_lighting : pixel shader HLSL
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
    float3 ro = float3(0.0, 0.0, 3.0);
    float3 rd = normalize(float3(p, -1.5));
    float b = dot(ro, rd);
    float c2 = dot(ro, ro) - 1.0;
    float h = b * b - c2;
    col = float3(0.1, 0.1, 0.1);
    if (h > 0.0) {
        float t = -b - sqrt(h);
        float3 pos = ro + t * rd;
        float3 n = normalize(pos);
        float3 l = normalize(float3(0.6, 0.7, 0.5));
        float dif = max(dot(n, l), 0.0);
        float3 r = reflect(-l, n);
        float spec = pow(max(dot(r, -rd), 0.0), 16.0);
        col = float3(0.8, 0.3, 0.2) * dif + spec;
    }
    return float4(col, 1.0);
}
