// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// lang=hlsl
// iChannel0=bufferA
cbuffer Uniforms : register(b0)
{
    float3 iResolution;
    float iTime;
};
Texture2D iChannel0 : register(t1);
SamplerState smp : register(s1);

float4 main(float4 fragPos : SV_Position) : SV_Target
{
    float2 uv = fragPos.xy / iResolution.xy;
    float2 c = 0.5 + 0.35 * float2(cos(iTime * 1.7), sin(iTime * 1.1));
    float d = length((uv - c) * float2(iResolution.x / iResolution.y, 1.0));
    float3 dotColor = (1.0 - smoothstep(0.02, 0.04, d)) * (0.5 + 0.5 * cos(iTime + float3(0.0, 2.0, 4.0)));
    float3 prev = iChannel0.Sample(smp, uv).rgb * 0.96;
    return float4(max(prev, dotColor), 1.0);
}
