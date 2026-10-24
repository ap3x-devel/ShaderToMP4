// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Tunnel (HLSL) — Polar coordinates with atan2 and length; saturate and frac are the HLSL names of clamp and fract.
// fr: Tunnel (HLSL) — Coordonnées polaires avec atan2 et length ; saturate et frac sont les noms HLSL de clamp et fract.
// lang=hlsl
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
};

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 p = (fragPos.xy - 0.5 * iResolution.xy) / iResolution.y;
    float a = atan2(p.y, p.x) / 6.28318;
    float r = length(p) + 0.001;
    float2 q = float2(a * 6.0, 0.4 / r + iTime * 0.8);
    float checker = abs(frac(q.x) - 0.5) + abs(frac(q.y) - 0.5);
    float3 col = lerp(float3(0.1, 0.2, 0.6), float3(1.0, 0.6, 0.2), step(0.5, checker));
    return float4(col * saturate(r * 2.5), 1.0);
}
