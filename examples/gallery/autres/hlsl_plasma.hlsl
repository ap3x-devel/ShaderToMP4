// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// en: Plasma (HLSL) — Sum of sines in a HLSL pixel shader; the uniforms come from a cbuffer named like Shadertoy's.
// fr: Plasma (HLSL) — Somme de sinus dans un pixel shader HLSL ; les uniforms viennent d'un cbuffer nommé comme ceux de Shadertoy.
// lang=hlsl
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
};

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 p = (fragPos.xy - 0.5 * iResolution.xy) / iResolution.y * 6.0;
    float v = sin(p.x + iTime) + sin(p.y * 1.3 - iTime * 0.7) + sin((p.x + p.y) * 0.8 + iTime * 0.5) + sin(length(p) - iTime);
    float3 col = 0.5 + 0.5 * cos(v + float3(0.0, 2.1, 4.2));
    return float4(col, 1.0);
}
