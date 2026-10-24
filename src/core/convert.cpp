// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#include "convert.h"
#include "xlang.h"
#include "render.h"
#include "compat.h"
#include "i18n.h"
#include "passfiles.h"
#include "util.h"
#include "platform/platform.h"

namespace {

bool wordChar(char c) { return isalnum((unsigned char)c) || c == '_'; }

// Remplace le mot entier `from` par `to` hors commentaires et hors membres (« a.time » reste) ; renvoie le nombre de remplacements
int renameWord(std::string& code, const std::string& from, const std::string& to) {
    int count = 0;
    std::string out;
    out.reserve(code.size());
    for (size_t i = 0; i < code.size();) {
        if (code.compare(i, 2, "//") == 0) {
            const size_t e = code.find('\n', i);
            const size_t n = e == std::string::npos ? code.size() : e;
            out.append(code, i, n - i);
            i = n;
        } else if (code.compare(i, 2, "/*") == 0) {
            const size_t e = code.find("*/", i + 2);
            const size_t n = e == std::string::npos ? code.size() : e + 2;
            out.append(code, i, n - i);
            i = n;
        } else if (code.compare(i, from.size(), from) == 0 && (i == 0 || !wordChar(code[i - 1])) && (i + from.size() >= code.size() || !wordChar(code[i + from.size()]))) {
            size_t b = out.size();
            while (b > 0 && (out[b - 1] == ' ' || out[b - 1] == '\t')) b--;
            if (b > 0 && out[b - 1] == '.') {  // membre d'une structure ou composante : on n'y touche pas
                out += from;
            } else {
                out += to;
                count++;
            }
            i += from.size();
        } else {
            out += code[i++];
        }
    }
    code.swap(out);
    return count;
}

// gl_FragColor -> fragColor (gl_FragCoord reste : il est valide dans toute fonction du GLSL 3.30)
int renameFragCoord(std::string& code) {
    int n = 0;
    n += renameWord(code, "gl_FragColor", "fragColor");
    return n;
}

}  // namespace

PortReport analyzePortability(const std::string& code) {
    PortReport rep;
    const std::string stripped = stripCodeComments(code);
    const bool webgl = isWebglMainCode(stripped);
    std::string out;
    out.reserve(code.size());
    std::vector<std::pair<std::string, std::string>> renames;  // nom -> remplacement
    int samplerIndex = 0;
    int lineNo = 0;
    size_t pos = 0;
    auto add = [&](const char* kind, const std::string& arg, const std::string& with, bool fixable = true) {
        PortIssue is;
        is.kind = kind;
        is.arg = arg;
        is.with = with;
        is.line = lineNo;
        is.fixable = fixable;
        rep.issues.push_back(is);
    };
    while (pos <= code.size()) {
        size_t e = code.find('\n', pos);
        if (e == std::string::npos) e = code.size();
        std::string line = code.substr(pos, e - pos);
        const bool last = e >= code.size();
        pos = e + 1;
        lineNo++;
        std::string cr;
        if (!line.empty() && line.back() == '\r') {
            cr = "\r";
            line.pop_back();
        }
        const std::string t = trim(line);
        std::string type, name, expr;
        bool drop = false;
        if (t.compare(0, 8, "#version") == 0 || t.compare(0, 10, "#extension") == 0 || (t.compare(0, 9, "precision") == 0 && t.back() == ';' && t.find('(') == std::string::npos)) {
            add("directive", t, "");
            drop = true;
        } else if (parseUniformDecl(line, type, name)) {
            if (providedUniformName(type, name)) {
                add("dupuniform", name, "");
                drop = true;
            } else if (aliasUniformName(type, name, expr)) {
                add("alias", name, expr);
                if (name != expr) renames.push_back({name, expr});
                drop = true;
            } else if (webgl && type == "sampler2D" && samplerIndex < 4) {
                const std::string ch = "iChannel" + std::to_string(samplerIndex++);
                add("alias", name, ch);
                renames.push_back({name, ch});
                drop = true;
            } else if (webgl) {
                add("unprovided", name, "", false);
            }
        } else if (webgl && parseOutDecl(line, name)) {
            add("webgl", name, "fragColor");
            if (name != "fragColor") renames.push_back({name, "fragColor"});
            drop = true;
        } else if (webgl && parseVaryingDecl(line, type, name)) {
            if (type == "vec2") {
                add("alias", name, "(gl_FragCoord.xy / iResolution.xy)");
                renames.push_back({name, "(gl_FragCoord.xy / iResolution.xy)"});
            } else {
                add("unprovided", name, "", false);
            }
            if (type == "vec2") drop = true;
        }
        if (!drop) out += line + cr + (last ? "" : "\n");
        else if (!last) out += "\n";  // la ligne devient vide : les numeros de ligne des messages d'erreur restent ceux de l'original
    }
    std::string fixed = out;
    for (const auto& r : renames) {
        // l'expression remplace le nom (une variable locale du meme nom serait alors confondue : cas rare, la copie se relit avant usage)
        renameWord(fixed, r.first, r.second);
    }
    // noms de fonctions et d'uniforms d'anciennes versions
    static const char* kOld[][2] = {{"texture2D", "texture"},      {"texture2DLod", "textureLod"}, {"texture3D", "texture"},    {"textureCube", "texture"},
                                    {"textureCubeLod", "textureLod"}, {"texture2DProj", "textureProj"}, {"iGlobalTime", "iTime"}, {"iGlobalDelta", "iTimeDelta"},
                                    {"iGlobalFrame", "iFrame"}};
    for (const auto& o : kOld) {
        if (!codeUsesWord(fixed, o[0])) continue;
        // numero de la premiere ligne qui l'emploie
        int first = 0, n = 0;
        {
            size_t p = 0;
            int ln = 0;
            while (p <= fixed.size()) {
                size_t q = fixed.find('\n', p);
                if (q == std::string::npos) q = fixed.size();
                ln++;
                if (codeUsesWord(fixed.substr(p, q - p), o[0])) {
                    first = ln;
                    break;
                }
                p = q + 1;
            }
        }
        n = renameWord(fixed, o[0], o[1]);
        if (n > 0) {
            PortIssue is;
            is.kind = "oldname";
            is.arg = o[0];
            is.with = o[1];
            is.line = first;
            rep.issues.push_back(is);
        }
    }
    if (webgl) {  // void main() + gl_FragColor / gl_FragCoord -> mainImage(out vec4 fragColor, in vec2 fragCoord)
        std::string res;
        bool entry = false;
        for (size_t i = 0; i < fixed.size();) {
            if (!entry && fixed.compare(i, 4, "void") == 0 && (i == 0 || !wordChar(fixed[i - 1]))) {
                size_t j = i + 4;
                while (j < fixed.size() && isspace((unsigned char)fixed[j])) j++;
                if (fixed.compare(j, 4, "main") == 0) {
                    size_t k = j + 4;
                    while (k < fixed.size() && isspace((unsigned char)fixed[k])) k++;
                    if (k < fixed.size() && fixed[k] == '(') {
                        size_t close = fixed.find(')', k);
                        if (close != std::string::npos) {
                            res += "void mainImage(out vec4 fragColor, in vec2 fragCoord)";
                            i = close + 1;
                            entry = true;
                            continue;
                        }
                    }
                }
            }
            res += fixed[i++];
        }
        if (entry) {
            fixed = res;
            renameFragCoord(fixed);
            int ln = 1;
            for (size_t p = 0; p < code.size() && ln > 0; p++) {  // ligne de « void main » dans l'original
                if (code.compare(p, 4, "void") == 0 && stripped.compare(p, 4, "void") == 0) {
                    size_t j = p + 4;
                    while (j < code.size() && isspace((unsigned char)code[j])) j++;
                    if (code.compare(j, 4, "main") == 0) break;
                }
                if (code[p] == '\n') ln++;
            }
            PortIssue is;
            is.kind = "webgl";
            is.arg = "main";
            is.with = "mainImage";
            is.line = ln;
            rep.issues.push_back(is);
        }
    }
    rep.fixed = rep.issues.empty() ? code : fixed;
    bool any = false;
    for (const auto& is : rep.issues) any = any || is.fixable;
    if (!any) rep.fixed = code;
    return rep;
}

std::wstring describePortIssue(const PortIssue& is) {
    static const struct { const char *kind, *problem, *fix; } kTexts[] = {
        {"directive", "port.directive", "port.directive.fix"}, {"dupuniform", "port.dupuniform", "port.dupuniform.fix"}, {"oldname", "port.oldname", "port.oldname.fix"},
        {"webgl", "port.webgl", "port.webgl.fix"},             {"alias", "port.alias", "port.alias.fix"}};
    const std::wstring head = is.line > 0 ? TXF("port.line", is.line) + L" " : std::wstring();
    if (is.kind == "unprovided") return head + TXF("port.unprovided", W(is.arg).c_str());
    for (const auto& t : kTexts)
        if (is.kind == t.kind) return head + TXF(t.problem, W(is.arg).c_str()) + L" \x2192 " + TXF(t.fix, W(is.with).c_str());  // un seul argument par texte
    return head + W(is.kind);
}

bool portabilityCopy(const std::wstring& shaderPath, const std::wstring& destStem, FixedCopy& out, std::wstring& err) {
    out = FixedCopy();
    const std::wstring stemSrc = shaderPath.substr(0, shaderPath.find_last_of(L'.'));
    struct Item {
        std::wstring src, suffix, ext;
    };
    std::vector<Item> items;
    for (const PassTab& t : passTabs(shaderPath)) {
        if (!t.exists) continue;
        const size_t dot = t.path.find_last_of(L'.');
        if (t.path.compare(0, stemSrc.size(), stemSrc) != 0) continue;
        items.push_back({t.path, t.path.substr(stemSrc.size(), dot - stemSrc.size()), t.path.substr(dot)});
    }
    const std::wstring leaf = shaderPath.substr(shaderPath.find_last_of(L"\\/") == std::wstring::npos ? 0 : shaderPath.find_last_of(L"\\/") + 1);
    bool anyFix = false;
    std::vector<std::pair<Item, PortReport>> reports;
    for (const Item& it : items) {
        std::string code;
        if (!readFile(it.src, code)) {
            err = TX("error.read_file") + L" " + it.src;
            return false;
        }
        const std::wstring name = it.src.substr(it.src.find_last_of(L"\\/") == std::wstring::npos ? 0 : it.src.find_last_of(L"\\/") + 1);
        {  // HLSL, WGSL, GLSL 4.x : traduits en GLSL 3.30 au rendu (core/xlang) ; les regles du style Shadertoy ne s'appliquent pas, rien a corriger ici
            std::string head = code;
            Hooks quiet;
            quiet.log = [](const std::wstring&) {};
            normalizeShaderText(head, quiet);
            const ShaderLang lang = detectShaderLang(it.src, head);
            if (lang != ShaderLang::Glsl || glslNeedsTranslation(head)) {
                out.lines.push_back(name + L": " + TXF("port.foreign", lang == ShaderLang::Glsl ? L"GLSL 4.x" : W(shaderLangName(lang)).c_str()));
                PortReport same;
                same.fixed = code;
                reports.push_back({it, std::move(same)});
                continue;
            }
        }
        PortReport r = analyzePortability(code);
        for (const PortIssue& is : r.issues) {
            out.lines.push_back(name + L": " + describePortIssue(is));
            (is.fixable ? out.fixable : out.notFixable)++;
            anyFix = anyFix || is.fixable;
        }
        reports.push_back({it, std::move(r)});
    }
    (void)leaf;
    if (destStem.empty() || !anyFix) return true;
    for (const auto& pr : reports) {
        const std::wstring dest = destStem + pr.first.suffix + pr.first.ext;
        if (!writeFileAtomic(dest, pr.second.fixed)) {
            err = TXF("error.write_failed", dest.c_str());
            return false;
        }
        out.files.push_back(dest);
    }
    return true;
}
