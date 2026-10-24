// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#include "passfiles.h"
#include "i18n.h"
#include "proext.h"
#include "util.h"
#include "platform/platform.h"

std::vector<PassTab> passTabs(const std::wstring& shaderPath) {
    const size_t dot = shaderPath.find_last_of(L'.');
    const size_t slash = shaderPath.find_last_of(L"\\/");
    const std::wstring stem = (dot == std::wstring::npos || (slash != std::wstring::npos && dot < slash)) ? shaderPath : shaderPath.substr(0, dot);
    const std::wstring own = dot == std::wstring::npos || (slash != std::wstring::npos && dot < slash) ? L".glsl" : shaderPath.substr(dot);
    struct Def { const char* id; const wchar_t* label; const char* suffix; };
    static const Def defs[] = {{"bufferA", L"Buffer A", "bufferA"}, {"bufferB", L"Buffer B", "bufferB"}, {"bufferC", L"Buffer C", "bufferC"},  // nom-technique
                               {"bufferD", L"Buffer D", "bufferD"}, {"common", L"Common", "common"}, {"cubemapA", L"Cubemap A", "cubemapA"},  // nom-technique
                               {"sound", L"Sound", "sound"}, {"post", L"Post", "post"},                                                        // nom-technique
                               // fichiers d'une scene 3D (edition Pro) : etage des sommets, passe d'ombre, passe de calcul
                               {"vert", L"Vertex", "vert"}, {"shadow", L"Shadow", "shadow"}, {"compute", L"Compute", "compute"}};            // nom-technique
    const size_t count = proExt() ? sizeof(defs) / sizeof(defs[0]) : 8;  // sans l'edition Pro : les huit passes de Shadertoy seulement
    std::vector<PassTab> tabs;
    PassTab image;
    image.id = "image";
    image.label = L"Image";  // nom-technique
    image.path = shaderPath;
    image.exists = true;
    tabs.push_back(image);
    for (size_t di = 0; di < count; di++) {
        const Def& d = defs[di];
        PassTab t;
        t.id = d.id;
        t.label = d.label;
        const bool foreign = own == L".hlsl" || own == L".wgsl";  // shader HLSL ou WGSL : ses passes neuves ont la meme extension
        t.path = stem + L"." + W(d.suffix) + (foreign ? own : std::wstring(L".glsl"));
        for (const std::wstring& e : {own, std::wstring(L".glsl"), std::wstring(L".txt")}) {  // meme recherche que le moteur
            const std::wstring p = stem + L"." + W(d.suffix) + e;
            if (platform::fileExists(p)) {
                t.path = p;
                t.exists = true;
                break;
            }
        }
        tabs.push_back(t);
    }
    return tabs;
}

// Squelettes des passes HLSL et WGSL (texte du pixel shader ; chaque passe declare ses propres uniforms, le fichier Common ne porte que des fonctions)
static std::string foreignTemplate(const std::string& id, bool hlsl) {
    if (id == "common")
        return hlsl ? "// Fonctions communes (ajoutees devant chaque passe HLSL avant la traduction) : pas de cbuffer ni de main ici.\nfloat3 palette(float t) { return 0.5 + 0.5 * cos(6.28318 * (t + float3(0.0, 0.33, 0.67))); }\n"
                    : "// Fonctions communes (ajoutees devant chaque passe WGSL avant la traduction) : pas de struct d'uniforms ni de point d'entree ici.\nfn palette(t: f32) -> vec3<f32> { return 0.5 + 0.5 * cos(6.28318 * (t + vec3<f32>(0.0, 0.33, 0.67))); }\n";
    const bool buffer = id.compare(0, 6, "buffer") == 0;
    const std::string chan = buffer ? "// iChannel0=" + id + "\n" : "";
    if (hlsl)
        return "// lang=hlsl\n" + chan + "cbuffer Uniforms : register(b0)\n{\n    float3 iResolution;\n    float iTime;\n    float4 iMouse;\n    int iFrame;\n};\n\nfloat4 main(float4 fragPos : SV_Position) : SV_Target\n{\n    float2 uv = fragPos.xy / iResolution.xy;\n    return float4(uv, 0.5 + 0.5 * sin(iTime), 1.0);\n}\n";
    return "// lang=wgsl\n" + chan + "struct Uniforms {\n    iResolution: vec3<f32>,\n    iTime: f32,\n    iMouse: vec4<f32>,\n    iFrame: i32,\n};\n@group(0) @binding(0) var<uniform> u: Uniforms;\n\n@fragment\nfn main(@builtin(position) fragPos: vec4<f32>) -> @location(0) vec4<f32> {\n    let uv = fragPos.xy / u.iResolution.xy;\n    return vec4<f32>(uv, 0.5 + 0.5 * sin(u.iTime), 1.0);\n}\n";
}

std::string passTemplate(const std::string& id) {
    if (id == "common") return "// " + U8(TX("ui.editor.tpl_common")) + "\n";
    if (id == "sound") return "vec2 mainSound(int samp, float time) {\n    return vec2(0.2 * sin(6.2831853 * 440.0 * time));\n}\n";
    if (id == "cubemapA")
        return "void mainCubemap(out vec4 fragColor, in vec2 fragCoord, in vec3 rayOri, in vec3 rayDir) {\n    fragColor = vec4(0.5 + 0.5 * rayDir, 1.0);\n}\n";
    if (id == "vert")
        return "out vec3 vWorldPos;\nout vec3 vNormal;\nout vec2 vUV;\nvoid main() {\n    vec4 w = iModel * vec4(aPosition, 1.0);\n    w.xyz += sceneInstanceOffset();\n    vWorldPos = w.xyz;\n    vNormal = normalize(iNormalMatrix * aNormal);\n    vUV = aUV;\n    gl_Position = iProjection * iView * w;\n}\n";
    if (id == "shadow") return "// light=4,7,3\n// lighttarget=0,0,0\n// shadowortho=5\n// shadowsize=1024\n// shadowrange=1,20\n";
    if (id == "compute")
        return "layout(local_size_x = 64) in;\nvoid main() {\n    uint i = gl_GlobalInvocationID.x;\n    if (int(i) >= iDataCount) return;\n    iData[i] = vec4(float(i), float(iFrame), iTime, 1.0);\n}\n";
    if (id == "post")
        return "// " + U8(TX("ui.editor.tpl_post")) + "\nvoid mainImage(out vec4 fragColor, in vec2 fragCoord) {\n    fragColor = texture(iChannel0, fragCoord / iResolution.xy);\n}\n";
    // tampons A a D : lisent leurs canaux par des commentaires // iChannel0=bufferA ...
    return "// iChannel0=" + id + "\nvoid mainImage(out vec4 fragColor, in vec2 fragCoord) {\n    vec2 uv = fragCoord / iResolution.xy;\n    fragColor = vec4(uv, 0.5 + 0.5 * sin(iTime), 1.0);\n}\n";
}

bool createPassFile(const PassTab& tab, std::wstring& err) {
    if (platform::fileExists(tab.path)) {
        err = TXF("error.pass_exists", tab.path.c_str());
        return false;
    }
    FILE* f = platform::openFile(tab.path, "wb");
    if (!f) {
        err = TXF("error.write_failed", tab.path.c_str());
        return false;
    }
    std::wstring ext = tab.path.size() > 5 ? tab.path.substr(tab.path.size() - 5) : L"";
    for (wchar_t& c : ext) c = (wchar_t)towlower(c);
    const bool foreignPass = (ext == L".hlsl" || ext == L".wgsl") && tab.id != "sound" && tab.id != "cubemapA";
    const std::string text = foreignPass ? foreignTemplate(tab.id, ext == L".hlsl") : passTemplate(tab.id);
    const bool ok = fwrite(text.data(), 1, text.size(), f) == text.size();
    fclose(f);
    if (!ok) err = TXF("error.write_failed", tab.path.c_str());
    return ok;
}
