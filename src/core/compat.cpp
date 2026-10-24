// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#include "compat.h"
#include "i18n.h"
#include "util.h"
#include <regex>

namespace {

// Code sans commentaires (// et /* */), meme longueur de lignes : les mots cites en commentaire ne comptent pas
std::string stripComments(const std::string& c) {
    std::string out = c;
    for (size_t i = 0; i < out.size();) {
        if (out[i] == '/' && i + 1 < out.size() && out[i + 1] == '/') {
            while (i < out.size() && out[i] != '\n') out[i++] = ' ';
        } else if (out[i] == '/' && i + 1 < out.size() && out[i + 1] == '*') {
            out[i] = out[i + 1] = ' ';
            i += 2;
            while (i < out.size() && !(out[i] == '*' && i + 1 < out.size() && out[i + 1] == '/')) {
                if (out[i] != '\n') out[i] = ' ';
                i++;
            }
            if (i < out.size()) out[i++] = ' ';
            if (i < out.size()) out[i++] = ' ';
        } else {
            i++;
        }
    }
    return out;
}

bool isWordChar(char c) { return isalnum((unsigned char)c) || c == '_'; }

bool usesWord(const std::string& code, const std::string& word) {
    for (size_t p = code.find(word); p != std::string::npos; p = code.find(word, p + 1)) {
        const bool before = p == 0 || !isWordChar(code[p - 1]);
        const bool after = p + word.size() >= code.size() || !isWordChar(code[p + word.size()]);
        if (before && after) return true;
    }
    return false;
}

}  // namespace

std::string stripCodeComments(const std::string& code) { return stripComments(code); }

bool codeUsesWord(const std::string& code, const std::string& word) { return usesWord(stripComments(code), word); }

namespace {

bool isWebglMain(const std::string& stripped) {
    // « void main( » sans point d'entree Shadertoy : un fragment shader a la maniere de WebGL 1 (gl_FragColor, uniforms nommes librement)
    bool hasMain = false;
    for (size_t p = stripped.find("main"); p != std::string::npos; p = stripped.find("main", p + 1)) {
        const bool before = p == 0 || !isWordChar(stripped[p - 1]);
        size_t q = p + 4;
        while (q < stripped.size() && (stripped[q] == ' ' || stripped[q] == '\t')) q++;
        if (before && q < stripped.size() && stripped[q] == '(') {
            // le mot qui precède doit etre « void »
            size_t b = p;
            while (b > 0 && (stripped[b - 1] == ' ' || stripped[b - 1] == '\t' || stripped[b - 1] == '\n' || stripped[b - 1] == '\r')) b--;
            if (b >= 4 && stripped.compare(b - 4, 4, "void") == 0) hasMain = true;
        }
    }
    return hasMain && !usesWord(stripped, "mainImage") && !usesWord(stripped, "mainVR") && !usesWord(stripped, "mainSound") && !usesWord(stripped, "mainCubemap");
}

// Uniforms que le programme fournit deja (avec leur type) : les redeclarer est une erreur de compilation
bool providedUniform(const std::string& type, const std::string& name) {
    static const struct { const char *type, *name; } kProvided[] = {
        {"vec3", "iResolution"}, {"float", "iTime"}, {"float", "iTimeDelta"}, {"int", "iFrame"}, {"float", "iFrameRate"}, {"vec4", "iMouse"}, {"vec4", "iDate"},
        {"float", "iSampleRate"}, {"sampler2D", "iChannel0"}, {"sampler2D", "iChannel1"}, {"sampler2D", "iChannel2"}, {"sampler2D", "iChannel3"},
        {"samplerCube", "iChannel0"}, {"samplerCube", "iChannel1"}, {"samplerCube", "iChannel2"}, {"samplerCube", "iChannel3"},
        {"sampler3D", "iChannel0"}, {"sampler3D", "iChannel1"}, {"sampler3D", "iChannel2"}, {"sampler3D", "iChannel3"}};
    for (const auto& p : kProvided)
        if (type == p.type && name == p.name) return true;
    return false;
}

// Noms usuels des uniforms des shaders WebGL : (nom, type) -> expression du programme
bool aliasUniform(const std::string& type, const std::string& name, std::string& expr) {
    static const struct { const char *name, *type, *expr; } kAlias[] = {
        {"time", "float", "iTime"},        {"u_time", "float", "iTime"},       {"uTime", "float", "iTime"},        {"iGlobalTime", "float", "iTime"},
        {"globalTime", "float", "iTime"},  {"iGlobalDelta", "float", "iTimeDelta"}, {"delta", "float", "iTimeDelta"}, {"u_delta", "float", "iTimeDelta"},
        {"resolution", "vec2", "iResolution.xy"}, {"u_resolution", "vec2", "iResolution.xy"}, {"uResolution", "vec2", "iResolution.xy"}, {"iResolution", "vec2", "iResolution.xy"},
        {"resolution", "vec3", "iResolution"},    {"u_resolution", "vec3", "iResolution"},    {"uResolution", "vec3", "iResolution"},
        {"mouse", "vec2", "iMouse.xy"},    {"u_mouse", "vec2", "iMouse.xy"},   {"uMouse", "vec2", "iMouse.xy"},
        {"mouse", "vec4", "iMouse"},       {"u_mouse", "vec4", "iMouse"},      {"uMouse", "vec4", "iMouse"},
        {"frame", "float", "float(iFrame)"}, {"u_frame", "float", "float(iFrame)"}, {"iGlobalFrame", "int", "iFrame"}, {"frame", "int", "iFrame"}, {"u_frame", "int", "iFrame"},
        {"iGlobalFrame", "float", "float(iFrame)"}};
    for (const auto& a : kAlias)
        if (type == a.type && name == a.name) {
            expr = a.expr;
            return true;
        }
    return false;
}

// « uniform [precision] type nom; » : renvoie vrai et decoupe la ligne
bool parseUniformLine(const std::string& line, std::string& type, std::string& name) {
    static const std::regex re("^\\s*uniform\\s+(?:(?:lowp|mediump|highp)\\s+)?([A-Za-z_][A-Za-z0-9_]*)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*;\\s*(?://.*)?$");
    std::smatch m;
    if (!std::regex_match(line, m, re)) return false;
    type = m[1];
    name = m[2];
    return true;
}

bool parseVaryingLine(const std::string& line, std::string& type, std::string& name) {
    static const std::regex re("^\\s*(?:varying|in)\\s+(?:(?:lowp|mediump|highp)\\s+)?([A-Za-z_][A-Za-z0-9_]*)\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*;\\s*(?://.*)?$");
    std::smatch m;
    if (!std::regex_match(line, m, re)) return false;
    type = m[1];
    name = m[2];
    return true;
}

bool parseOutDeclImpl(const std::string& line, std::string& name) {
    static const std::regex re("^\\s*(?:layout\\s*\\(\\s*location\\s*=\\s*0\\s*\\)\\s*)?out\\s+(?:(?:lowp|mediump|highp)\\s+)?vec4\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*;\\s*(?://.*)?$");
    std::smatch m;
    if (!std::regex_match(line, m, re)) return false;
    name = m[1];
    return true;
}

}  // namespace

bool isWebglMainCode(const std::string& strippedCode) { return isWebglMain(strippedCode); }
bool providedUniformName(const std::string& type, const std::string& name) { return providedUniform(type, name); }
bool aliasUniformName(const std::string& type, const std::string& name, std::string& expr) { return aliasUniform(type, name, expr); }
bool parseUniformDecl(const std::string& line, std::string& type, std::string& name) { return parseUniformLine(line, type, name); }
bool parseVaryingDecl(const std::string& line, std::string& type, std::string& name) { return parseVaryingLine(line, type, name); }
bool parseOutDecl(const std::string& line, std::string& name) { return parseOutDeclImpl(line, name); }

std::string adaptShaderCode(const std::string& code, std::vector<std::wstring>& notes) {
    const std::string stripped = stripComments(code);
    const bool webgl = isWebglMain(stripped);
    std::string out;
    out.reserve(code.size() + 256);
    std::string prelude;
    size_t pos = 0;
    bool version = false, extension = false, version100 = false;
    int samplerIndex = 0;
    std::vector<std::wstring> dupNames, aliasNotes, otherUniforms, varyingNotes;
    while (pos <= code.size()) {
        size_t e = code.find('\n', pos);
        if (e == std::string::npos) e = code.size();
        std::string line = code.substr(pos, e - pos);
        std::string cr;
        if (!line.empty() && line.back() == '\r') {  // les fins de ligne sont conservees telles quelles
            cr = "\r";
            line.pop_back();
        }
        const std::string t = trim(line);
        std::string type, name, expr;
        if (t.compare(0, 8, "#version") == 0) {
            version = true;
            if (t.find("100") != std::string::npos) version100 = true;
            line.clear();
        } else if (t.compare(0, 10, "#extension") == 0) {
            extension = true;
            line.clear();
        } else if (parseUniformLine(line, type, name)) {
            if (providedUniform(type, name)) {
                dupNames.push_back(W(name));
                line.clear();
            } else if (aliasUniform(type, name, expr)) {
                aliasNotes.push_back(W(name) + L"\x01" + W(expr));
                line = "#define " + name + " " + expr;
            } else if (webgl && type == "sampler2D" && samplerIndex < 4) {  // textures d'un shader WebGL : dans l'ordre, iChannel0 a iChannel3
                aliasNotes.push_back(W(name) + L"\x01" + W("iChannel" + std::to_string(samplerIndex)));
                line = "#define " + name + " iChannel" + std::to_string(samplerIndex++);
            } else if (webgl) {
                otherUniforms.push_back(W(name));  // sans valeur : zero (declaration conservee)
            }
        } else if (webgl && parseOutDeclImpl(line, name)) {  // sortie d un shader GLSL ES 3.00 : out vec4 nom;
            line = "#define " + name + " st_fragColor";
        } else if (webgl && parseVaryingLine(line, type, name) && (t.compare(0, 7, "varying") == 0 || t.compare(0, 3, "in ") == 0)) {
            // un varying de position (vUv, v_uv, texCoord...) : la position normalisee du pixel ; les autres : zero
            if (type == "vec2") line = "#define " + name + " (gl_FragCoord.xy / iResolution.xy)";
            else line = type + " " + name + " = " + type + "(0.0);";
            varyingNotes.push_back(W(name));
        }
        out += line + cr;
        if (e < code.size()) out += '\n';
        pos = e + 1;
    }
    if (version) notes.push_back(TX("log.compat_version"));
    if (extension) notes.push_back(TX("log.compat_extension"));
    for (const auto& n : dupNames) notes.push_back(TXF("log.compat_dupuniform", n.c_str()));
    for (const auto& a : aliasNotes) {
        const size_t k = a.find(L'\x01');
        notes.push_back(TXF("log.compat_alias", a.substr(0, k).c_str(), a.substr(k + 1).c_str()));
    }
    for (const auto& n : otherUniforms) notes.push_back(TXF("log.compat_unprovided", n.c_str()));
    for (const auto& n : varyingNotes) notes.push_back(TXF("log.compat_varying", n.c_str()));
    if (!webgl) return out;
    (void)version100;
    // Style WebGL 1 : void main() + gl_FragColor. Le main de l'utilisateur est renomme, gl_FragColor et gl_FragCoord deviennent des variables du programme
    // (gl_FragCoord suit ainsi le decalage des tuiles), et un mainImage appelle le tout. Les numeros de ligne du code restent ceux du fichier.
    std::string body;
    body.reserve(out.size());
    for (size_t p = 0; p < out.size();) {
        if (out.compare(p, 4, "main") == 0 && (p == 0 || !isWordChar(out[p - 1]))) {
            size_t q = p + 4;
            while (q < out.size() && (out[q] == ' ' || out[q] == '\t')) q++;
            size_t b = body.size();
            while (b > 0 && (body[b - 1] == ' ' || body[b - 1] == '\t')) b--;
            if (q < out.size() && out[q] == '(' && b >= 4 && body.compare(b - 4, 4, "void") == 0) {
                body += "st_webgl_main";
                p += 4;
                continue;
            }
        }
        body += out[p++];
    }
    prelude = "#define gl_FragColor st_fragColor\n"
              "#define gl_FragCoord vec4(st_fragCoord, gl_FragCoord.z, gl_FragCoord.w)\n"
              "vec4 st_fragColor;\n"
              "vec2 st_fragCoord;\n"
              "#line 1\n";
    notes.push_back(TX("log.compat_webgl1"));
    return prelude + body + "\nvoid mainImage(out vec4 fragColor, in vec2 fragCoord) { st_fragCoord = fragCoord; st_fragColor = vec4(0.0, 0.0, 0.0, 1.0); st_webgl_main(); fragColor = st_fragColor; }\n#undef gl_FragColor\n#undef gl_FragCoord\n";
}

void checkCompatibility(const std::string& allCode, const Settings& s, std::vector<std::wstring>& notes) {
    const std::string c = stripComments(allCode);
    if (usesWord(c, "mainSound")) notes.push_back(TX("log.compat_sound"));
    bool hasCube = false, hasVolume = false, hasTimed = false;
    for (int i = 0; i < 4; i++) {
        const std::wstring& ch = s.channel[i];
        hasTimed = hasTimed || ch == L"audio" || ch.compare(0, 6, L"audio:") == 0 || ch.compare(0, 6, L"video:") == 0;
        if (ch == L"keyboard" && s.keys.empty()) notes.push_back(TXF("log.compat_keyboard", i));
        hasCube = hasCube || s.channel[i].compare(0, 4, L"cube") == 0;
        hasVolume = hasVolume || s.channel[i].compare(0, 7, L"volume:") == 0;
    }
    if (usesWord(c, "samplerCube") && !hasCube) notes.push_back(TX("log.compat_cubemap"));
    if (usesWord(c, "sampler3D") && !hasVolume) notes.push_back(TX("log.compat_volume"));
    if (usesWord(c, "iMouse") && s.mouseKeys.empty()) notes.push_back(TX("log.compat_mouse"));
    if (usesWord(c, "iDate") && s.date.empty()) notes.push_back(TX("log.compat_date"));
    if (usesWord(c, "iChannelTime") && !hasTimed) notes.push_back(TX("log.compat_channel_time"));
}
