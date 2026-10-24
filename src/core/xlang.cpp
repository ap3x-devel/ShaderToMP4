// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#include "xlang.h"
#include "explain.h"
#include "i18n.h"
#include "util.h"
#include "platform/platform.h"
#include <algorithm>
#include <map>
#include <mutex>
#include <cstring>
#include <thread>

namespace {

constexpr size_t kMaxSource = 1u << 20;  // un shader de plus de 1 Mo n'est pas traduit
constexpr int kToolTimeoutMs = 30000;    // et aucun outil ne tourne plus de 30 secondes

std::wstring sep() { return std::wstring(1, platform::pathSeparator()); }

std::wstring toolFile(const std::wstring& exeDir, const wchar_t* name) {
    const std::wstring exe = platform::exeFileName(name);
    const std::wstring a = xlangToolsDir(exeDir) + exe;
    if (fileExists(a)) return a;
    const std::wstring b = exeDir + exe;  // a cote du programme (essais, installation a la main)
    return fileExists(b) ? b : a;
}

std::wstring dxcFile(const std::wstring& exeDir) { return xlangToolsDir(exeDir) + L"dxc" + sep() + platform::exeFileName(L"dxc"); }

// Lance un outil sans fenetre, recupere sa sortie, l'arrete au bout de kToolTimeoutMs ; faux si le lancement ou le delai echoue
bool runTool(const std::vector<std::wstring>& argv, std::string& output, int& code, bool& timedOut) {
    output.clear();
    timedOut = false;
    std::unique_ptr<platform::Process> p = platform::Process::start(argv, false, true);
    if (!p) return false;
    std::thread reader([&] {
        char buf[4096];
        size_t n;
        while ((n = p->readOutput(buf, sizeof buf)) > 0) {
            if (output.size() < (1u << 20)) output.append(buf, n);
        }
    });
    std::atomic<bool> done{false};
    std::thread watchdog([&] {
        for (int waited = 0; !done.load() && waited < kToolTimeoutMs; waited += 20) std::this_thread::sleep_for(std::chrono::milliseconds(20));
        if (!done.load()) {
            timedOut = true;
            p->terminate();
        }
    });
    reader.join();
    code = p->wait();
    done = true;
    watchdog.join();
    return !timedOut;
}

// Dossier de travail des traductions (a cote du programme, jamais ailleurs), nom unique par appel
std::wstring workDir(const std::wstring& exeDir) {
    static std::atomic<unsigned> counter{0};
    const std::wstring base = exeDir + L"xlang_tmp";
    platform::makeDir(base);
    const std::wstring dir = base + sep() + std::to_wstring((unsigned long long)std::hash<std::thread::id>()(std::this_thread::get_id()) % 100000) + L"_" + std::to_wstring(counter++);
    platform::makeDir(dir);
    return dir;
}

std::mutex g_cacheLock;
std::map<std::string, std::string> g_cache;

std::string firstLines(const std::string& text, size_t n) {
    std::string out;
    size_t pos = 0;
    for (size_t i = 0; i < n && pos < text.size(); i++) {
        size_t e = text.find('\n', pos);
        if (e == std::string::npos) e = text.size();
        out += text.substr(pos, e - pos) + "\n";
        pos = e + 1;
    }
    return out;
}

// Messages des outils -> « fichier:ligne: message ». `inName` : le nom du fichier temporaire donne aux outils.
std::wstring formatErrors(ShaderLang lang, const std::string& raw, const std::string& inName, const std::wstring& shown, int commonLines, const std::wstring& commonPath) {
    std::wstring out;
    int count = 0;
    auto add = [&](int line, const std::string& msg) {
        if (count++ >= 12) return;
        const std::wstring text = W(trim(msg));
        if (commonLines > 0 && line <= commonLines) out += commonPath + L":" + std::to_wstring(line) + L": " + text + L"\n";
        else out += shown + L":" + std::to_wstring(line - commonLines) + L": " + text + L"\n";
        ErrorHelp help;  // la meme explication en clair que pour les erreurs du compilateur GLSL
        if (explainGlslError(text, help)) out += TXF("explain.line", help.help.c_str()) + L"\n" + TXF("explain.fixline", help.fix.c_str()) + L"\n";
    };
    std::string pendingMsg;
    size_t pos = 0;
    while (pos < raw.size()) {
        size_t e = raw.find('\n', pos);
        if (e == std::string::npos) e = raw.size();
        std::string line = raw.substr(pos, e - pos);
        pos = e + 1;
        while (!line.empty() && (line.back() == '\r')) line.pop_back();
        if (lang == ShaderLang::Hlsl) {  // in.hlsl:7:12: error: message
            const size_t k = line.find(inName + ":");
            if (k != std::string::npos) {
                int ln = 0;
                if (sscanf(line.c_str() + k + inName.size() + 1, "%d", &ln) == 1) {
                    const size_t m = line.find("error:");
                    if (m != std::string::npos) add(ln, line.substr(m + 6));
                }
            }
        } else if (lang == ShaderLang::Wgsl) {  // error: message, puis « ┌─ in.wgsl:3:7 »
            if (line.compare(0, 6, "error:") == 0) {
                pendingMsg = line.substr(6);
            } else {
                const size_t k = line.find(inName + ":");
                if (k != std::string::npos && line.find("\xE2\x94\x8C") != std::string::npos) {
                    int ln = 0;
                    if (sscanf(line.c_str() + k + inName.size() + 1, "%d", &ln) == 1) {
                        add(ln, pendingMsg);
                        pendingMsg.clear();
                    }
                }
            }
        } else {  // glslang : ERROR: in.frag:2: message
            if (line.compare(0, 6, "ERROR:") == 0) {
                const size_t k = line.find(inName + ":");
                int ln = 0;
                if (k != std::string::npos && sscanf(line.c_str() + k + inName.size() + 1, "%d", &ln) == 1) {
                    const size_t m = line.find(':', k + inName.size() + 1);
                    add(ln, m == std::string::npos ? line : line.substr(m + 1));
                }
            }
        }
    }
    if (out.empty()) {  // pas de position lisible : le texte de l'outil, tel quel (abrege)
        out = W(firstLines(raw, 8));
    }
    return out;
}

bool readTextFile(const std::wstring& path, std::string& out) { return readFile(path, out); }

// --- lecture du texte sans std::regex (les entrees abimees, jusqu'a 1 Mo, font depasser la complexite de std::regex ou sa pile) ---

bool isIdentChar(char c) { return isalnum((unsigned char)c) || c == '_'; }

size_t skipBlanks(const std::string& s, size_t p) {  // espaces et tabulations
    while (p < s.size() && (s[p] == ' ' || s[p] == '\t')) p++;
    return p;
}

size_t skipSpaces(const std::string& s, size_t p) {  // y compris les fins de ligne
    while (p < s.size() && isspace((unsigned char)s[p])) p++;
    return p;
}

// Le mot entier `w` commence en p
bool wordAt(const std::string& s, size_t p, const char* w) {
    const size_t n = strlen(w);
    if (s.compare(p, n, w) != 0) return false;
    if (p > 0 && isIdentChar(s[p - 1])) return false;
    return p + n >= s.size() || !isIdentChar(s[p + n]);
}

std::string identAt(const std::string& s, size_t& p) {
    p = skipSpaces(s, p);
    const size_t b = p;
    while (p < s.size() && isIdentChar(s[p])) p++;
    return s.substr(b, p - b);
}

// Mot qui precede la position p (espaces sautes) ; p est ramene au debut de ce mot
std::string wordBefore(const std::string& s, size_t& p) {
    while (p > 0 && isspace((unsigned char)s[p - 1])) p--;
    const size_t e = p;
    while (p > 0 && isIdentChar(s[p - 1])) p--;
    return s.substr(p, e - p);
}

// Texte entre la parenthese ouvrante en `open` et sa fermante (200 caracteres au plus) ; end = position apres la fermante ; faux si elle manque
bool parenText(const std::string& s, size_t open, std::string& inside, size_t& end) {
    int depth = 0;
    for (size_t i = open; i < s.size() && i < open + 400; i++) {
        if (s[i] == '(') depth++;
        else if (s[i] == ')' && --depth == 0) {
            inside = s.substr(open + 1, i - open - 1);
            end = i + 1;
            return true;
        }
    }
    return false;
}

std::vector<std::string> splitTokens(const std::string& s, char sepChar) {
    std::vector<std::string> out;
    size_t pos = 0;
    while (pos <= s.size()) {
        size_t e = s.find(sepChar, pos);
        if (e == std::string::npos) e = s.size();
        out.push_back(trim(s.substr(pos, e - pos)));
        pos = e + 1;
    }
    return out;
}

std::vector<std::string> words(const std::string& s) {
    std::vector<std::string> out;
    std::string cur;
    for (char c : s) {
        if (isspace((unsigned char)c)) {
            if (!cur.empty()) out.push_back(cur), cur.clear();
        } else {
            cur += c;
        }
    }
    if (!cur.empty()) out.push_back(cur);
    return out;
}

struct HlslEntry {
    std::string name;
    std::string wrapper;  // texte ajoute a la fin du fichier (les numeros de ligne ne bougent pas)
};

HlslEntry findHlslEntry(const std::string& code) {
    HlslEntry e;
    // 1. une fonction qui rend la semantique SV_Target : « nom(...) : SV_Target »
    for (size_t k = code.find("SV_Target"); k != std::string::npos; k = code.find("SV_Target", k + 1)) {
        size_t q = k;
        while (q > 0 && isspace((unsigned char)code[q - 1])) q--;
        if (q == 0 || code[q - 1] != ':') continue;
        q--;
        while (q > 0 && isspace((unsigned char)code[q - 1])) q--;
        if (q == 0 || code[q - 1] != ')') continue;
        int depth = 0;
        size_t i = q - 1;
        bool found = false;
        for (;; i--) {
            if (code[i] == ')') depth++;
            else if (code[i] == '(' && --depth == 0) {
                found = true;
                break;
            }
            if (i == 0 || q - i > 600) break;
        }
        if (!found) continue;
        size_t n = i;
        const std::string name = wordBefore(code, n);
        if (!name.empty()) {
            e.name = name;
            return e;
        }
    }
    // 2. le style Shadertoy : float4 mainImage(float2 p) ou void mainImage(out float4 c, in float2 p)
    for (size_t p = code.find("mainImage"); p != std::string::npos; p = code.find("mainImage", p + 1)) {
        if (!wordAt(code, p, "mainImage")) continue;
        size_t open = skipSpaces(code, p + 9);
        std::string inside;
        size_t end = 0;
        if (open >= code.size() || code[open] != '(' || !parenText(code, open, inside, end)) continue;
        size_t b = p;
        const std::string prev = wordBefore(code, b);
        const std::vector<std::string> params = splitTokens(inside, ',');
        auto vec2Param = [](const std::string& decl) {
            std::vector<std::string> w = words(decl);
            if (!w.empty() && w[0] == "in") w.erase(w.begin());
            return w.size() == 2 && w[0] == "float2";
        };
        if (prev == "float4" && params.size() == 1 && vec2Param(params[0])) {
            e.name = "st_entry";
            e.wrapper = "\nfloat4 st_entry(float4 st_pos : SV_Position) : SV_Target { return mainImage(st_pos.xy); }\n";
            return e;
        }
        if (prev == "void" && params.size() == 2) {
            const std::vector<std::string> a = words(params[0]);
            if (a.size() == 3 && a[0] == "out" && a[1] == "float4" && vec2Param(params[1])) {
                e.name = "st_entry";
                e.wrapper = "\nfloat4 st_entry(float4 st_pos : SV_Position) : SV_Target { float4 st_c = float4(0, 0, 0, 1); mainImage(st_c, st_pos.xy); return st_c; }\n";
                return e;
            }
        }
    }
    e.name = "main";
    return e;
}

std::string noSpaces(const std::string& s) {
    std::string out;
    for (char c : s)
        if (!isspace((unsigned char)c)) out += c;
    return out;
}

HlslEntry findWgslEntry(const std::string& code) {
    HlslEntry e;
    for (size_t k = code.find("@fragment"); k != std::string::npos; k = code.find("@fragment", k + 1)) {
        size_t p = skipSpaces(code, k + 9);
        if (!wordAt(code, p, "fn")) continue;
        p += 2;
        const std::string name = identAt(code, p);
        if (!name.empty()) {
            e.name = name;
            return e;
        }
    }
    // style Shadertoy : fn mainImage(p: vec2<f32>) -> vec4<f32>
    for (size_t p = code.find("mainImage"); p != std::string::npos; p = code.find("mainImage", p + 1)) {
        if (!wordAt(code, p, "mainImage")) continue;
        size_t b = p;
        if (wordBefore(code, b) != "fn") continue;
        size_t open = skipSpaces(code, p + 9);
        std::string inside;
        size_t end = 0;
        if (open >= code.size() || code[open] != '(' || !parenText(code, open, inside, end)) continue;
        const std::string param = noSpaces(inside);
        const size_t colon = param.find(':');
        if (colon == std::string::npos || param.find(',') != std::string::npos || param.substr(colon + 1) != "vec2<f32>") continue;
        const size_t brace = code.find('{', end);
        if (brace == std::string::npos || noSpaces(code.substr(end, brace - end)) != "->vec4<f32>") continue;
        e.name = "st_entry";
        e.wrapper = "\n@fragment fn st_entry(@builtin(position) st_pos: vec4<f32>) -> @location(0) vec4<f32> { return mainImage(st_pos.xy); }\n";
        return e;
    }
    e.name = "main";
    return e;
}

std::string toLowerCopy(std::string s) {
    for (char& c : s) c = (char)tolower((unsigned char)c);
    return s;
}

}  // namespace

const char* shaderLangName(ShaderLang l) { return l == ShaderLang::Hlsl ? "hlsl" : l == ShaderLang::Wgsl ? "wgsl" : "glsl"; }

std::wstring xlangToolsDir(const std::wstring& exeDir) { return exeDir + L"tools" + sep(); }

ShaderLang detectShaderLang(const std::wstring& path, const std::string& text) {
    const size_t dot = path.find_last_of(L'.');
    std::string ext = dot == std::wstring::npos ? "" : toLowerCopy(U8(path.substr(dot + 1)));
    // ligne `// lang=...` dans les 60 premieres lignes : elle l'emporte sur l'extension
    size_t pos = 0;
    for (int i = 0; i < 60 && pos < text.size(); i++) {
        size_t e = text.find('\n', pos);
        if (e == std::string::npos) e = text.size();
        const std::string line = trim(text.substr(pos, e - pos));
        pos = e + 1;
        if (line.compare(0, 2, "//") != 0) continue;
        const std::string body = trim(line.substr(2));
        if (body.compare(0, 5, "lang=") == 0 || body.compare(0, 6, "lang =") == 0) {
            const std::string v = toLowerCopy(trim(body.substr(body.find('=') + 1)));
            if (v == "hlsl") return ShaderLang::Hlsl;
            if (v == "wgsl") return ShaderLang::Wgsl;
            if (v == "glsl") return ShaderLang::Glsl;
        }
    }
    if (ext == "hlsl") return ShaderLang::Hlsl;
    if (ext == "wgsl") return ShaderLang::Wgsl;
    if (ext == "glsl" || ext == "frag" || ext == "fs") return ShaderLang::Glsl;
    // contenu (.txt, sans extension reconnue)
    const std::string stripped = text.size() < kMaxSource ? text : text.substr(0, kMaxSource);
    if (stripped.find("@fragment") != std::string::npos || (stripped.find("var<uniform>") != std::string::npos && stripped.find("fn ") != std::string::npos)) return ShaderLang::Wgsl;
    const bool glslMain = stripped.find("vec4") != std::string::npos || stripped.find("gl_FragColor") != std::string::npos;
    if (!glslMain && (stripped.find("SV_Target") != std::string::npos || stripped.find("cbuffer") != std::string::npos || stripped.find("float4") != std::string::npos)) return ShaderLang::Hlsl;
    return ShaderLang::Glsl;
}

bool glslNeedsTranslation(const std::string& text) {
    // premiere ligne utile : `#version N [profil]`
    size_t pos = 0;
    while (pos < text.size()) {
        size_t e = text.find('\n', pos);
        if (e == std::string::npos) e = text.size();
        const std::string line = trim(text.substr(pos, e - pos));
        pos = e + 1;
        if (line.empty() || line.compare(0, 2, "//") == 0) continue;
        if (line.compare(0, 8, "#version") != 0) return false;
        int v = 0;
        char profile[16] = "";
        const int n = sscanf(line.c_str() + 8, "%d %15s", &v, profile);
        if (n < 1) return false;
        return v >= 400 && std::string(profile) != "es";
    }
    return false;
}

std::wstring shaderBadge(const std::wstring& path) {
    FILE* f = platform::openFile(path, "rb");
    if (!f) return L"";
    std::string head(8192, '\0');
    head.resize(fread(&head[0], 1, head.size(), f));
    fclose(f);
    const ShaderLang lang = detectShaderLang(path, head);
    if (lang == ShaderLang::Hlsl) return L"HLSL";
    if (lang == ShaderLang::Wgsl) return L"WGSL";
    if (!glslNeedsTranslation(head)) return L"";
    const size_t k = head.find("#version");
    int v = 0;
    if (k != std::string::npos && sscanf(head.c_str() + k + 8, "%d", &v) == 1) return L"GLSL " + std::to_wstring(v);
    return L"GLSL 4";
}

bool xlangToolsPresent(const std::wstring& exeDir, ShaderLang lang, bool needsGlslang, std::wstring& missing) {
    missing.clear();
    auto need = [&](const std::wstring& file, const wchar_t* name) {
        if (!fileExists(file)) missing += (missing.empty() ? L"" : L", ") + std::wstring(name);
    };
    if (lang == ShaderLang::Hlsl) {
        need(dxcFile(exeDir), L"dxc");
        need(toolFile(exeDir, L"spirv-cross"), L"spirv-cross");
    } else if (lang == ShaderLang::Wgsl) {
        need(toolFile(exeDir, L"naga"), L"naga");
    } else if (needsGlslang) {
        need(toolFile(exeDir, L"glslang"), L"glslang");
        need(toolFile(exeDir, L"spirv-cross"), L"spirv-cross");
    }
    return missing.empty();
}

// --- post-traitement du GLSL traduit ---

namespace {

struct Member {
    std::string type, name;  // name peut porter un tableau : « v[4] »
};

// Membres d'un corps de bloc ou de structure « type nom; type nom; » (les layout(...) ont deja ete retires)
std::vector<Member> parseMembers(const std::string& body) {
    std::vector<Member> out;
    size_t pos = 0;
    while (pos < body.size()) {
        size_t e = body.find(';', pos);
        if (e == std::string::npos) break;
        std::string decl = trim(body.substr(pos, e - pos));
        pos = e + 1;
        for (bool again = true; again;) {  // qualificatifs de precision et d'interpolation ignores
            again = false;
            for (const char* q : {"highp ", "mediump ", "lowp ", "flat ", "smooth "}) {
                if (decl.compare(0, strlen(q), q) == 0) {
                    decl = trim(decl.substr(strlen(q)));
                    again = true;
                }
            }
        }
        const size_t sp = decl.find_last_of(" \t\n");
        if (sp == std::string::npos) continue;
        out.push_back({trim(decl.substr(0, sp)), trim(decl.substr(sp + 1))});
    }
    return out;
}

// Accolade fermante qui correspond a l'ouvrante en `open` ; npos si elle manque
size_t matchingBrace(const std::string& s, size_t open) {
    int depth = 0;
    for (size_t i = open; i < s.size(); i++) {
        if (s[i] == '{') depth++;
        else if (s[i] == '}' && --depth == 0) return i;
    }
    return std::string::npos;
}

// Retire `layout(...)` : sans objet en GLSL 3.30 (un seul fragment de sortie, uniforms hors bloc)
std::string removeLayouts(const std::string& g) {
    std::string out;
    out.reserve(g.size());
    for (size_t i = 0; i < g.size();) {
        if (g[i] == 'l' && wordAt(g, i, "layout")) {
            const size_t j = skipBlanks(g, i + 6);
            if (j < g.size() && g[j] == '(') {
                const size_t k = g.find(')', j);
                if (k != std::string::npos) {
                    i = skipBlanks(g, k + 1);
                    continue;
                }
            }
        }
        out += g[i++];
    }
    return out;
}

// Remplace « inst.membre » par « membre »
std::string dropInstancePrefix(std::string s, const std::string& inst) {
    if (inst.empty()) return s;
    const std::string key = inst + ".";
    size_t p = 0;
    while ((p = s.find(key, p)) != std::string::npos) {
        if (p > 0 && isIdentChar(s[p - 1])) {
            p += key.size();
            continue;
        }
        s.erase(p, key.size());
    }
    return s;
}

struct Edit {
    size_t start, end;
    std::string text;
};

}  // namespace

std::string finishTranslatedGlsl(const std::string& glslIn, std::vector<std::wstring>& notes) {
    std::string g = glslIn;
    g.erase(std::remove(g.begin(), g.end(), '\r'), g.end());
    // 1. extension 420pack et son #ifdef / #endif
    {
        std::string out;
        size_t pos = 0;
        bool skipEndif = false;
        while (pos < g.size()) {
            size_t e = g.find('\n', pos);
            if (e == std::string::npos) e = g.size();
            const std::string line = g.substr(pos, e - pos);
            const std::string t = trim(line);
            pos = e + 1;
            if (t.find("GL_ARB_shading_language_420pack") != std::string::npos && (t.compare(0, 6, "#ifdef") == 0 || t.compare(0, 10, "#extension") == 0)) {
                if (t.compare(0, 6, "#ifdef") == 0) skipEndif = true;
                continue;
            }
            if (skipEndif && t.compare(0, 6, "#endif") == 0) {
                skipEndif = false;
                continue;
            }
            out += line + "\n";
        }
        g = out;
    }
    g = removeLayouts(g);
    // 2. structures declarees (pour aplatir un bloc dont l'unique membre est une structure : sortie de naga)
    struct StructDef {
        std::string name;
        size_t start, end;
        std::vector<Member> members;
    };
    std::vector<StructDef> structs;
    for (size_t i = g.find("struct"); i != std::string::npos; i = g.find("struct", i + 1)) {
        if (!wordAt(g, i, "struct")) continue;
        size_t p = i + 6;
        const std::string name = identAt(g, p);
        p = skipSpaces(g, p);
        if (name.empty() || p >= g.size() || g[p] != '{') continue;
        const size_t close = matchingBrace(g, p);
        if (close == std::string::npos) continue;
        size_t semi = skipSpaces(g, close + 1);
        if (semi >= g.size() || g[semi] != ';') continue;
        structs.push_back({name, i, semi + 1, parseMembers(g.substr(p + 1, close - p - 1))});
    }
    // 3. blocs d'uniforms -> uniforms simples
    std::vector<Edit> edits;
    std::vector<std::string> instances, usedStructs;
    for (size_t i = g.find("uniform"); i != std::string::npos; i = g.find("uniform", i + 1)) {
        if (!wordAt(g, i, "uniform")) continue;
        size_t p = i + 7;
        identAt(g, p);  // le nom du bloc
        p = skipSpaces(g, p);
        if (p >= g.size() || g[p] != '{') continue;  // « uniform float x; » : pas un bloc
        const size_t close = matchingBrace(g, p);
        if (close == std::string::npos) continue;
        size_t q = close + 1;
        const std::string inst = identAt(g, q);
        q = skipSpaces(g, q);
        if (q >= g.size() || g[q] != ';') continue;
        std::string text;
        for (const Member& mb : parseMembers(g.substr(p + 1, close - p - 1))) {
            const StructDef* sd = nullptr;
            for (const StructDef& s : structs)
                if (s.name == mb.type) sd = &s;
            if (sd) {  // un membre structure : ses champs deviennent les uniforms, son nom est l'instance a effacer
                instances.push_back(mb.name);
                usedStructs.push_back(sd->name);
                for (const Member& f : sd->members) text += "uniform " + f.type + " " + f.name + ";\n";
            } else {
                text += "uniform " + mb.type + " " + mb.name + ";\n";
            }
        }
        if (!inst.empty()) instances.push_back(inst);
        edits.push_back({i, q + 1, text});
    }
    for (const StructDef& s : structs)
        if (std::find(usedStructs.begin(), usedStructs.end(), s.name) != usedStructs.end()) edits.push_back({s.start, s.end, ""});
    if (!edits.empty()) {
        std::sort(edits.begin(), edits.end(), [](const Edit& a, const Edit& b) { return a.start < b.start; });
        std::string out;
        size_t last = 0;
        for (const Edit& e : edits) {
            if (e.start < last) continue;  // blocs imbriques : le premier l'emporte
            out += g.substr(last, e.start - last) + e.text;
            last = e.end;
        }
        out += g.substr(last);
        g = out;
        for (const std::string& inst : instances) g = dropInstancePrefix(g, inst);
        notes.push_back(TX("xlang.note_uniforms"));
    }
    // 4. echantillonneurs combines nommes d'apres une texture iChannelN : « SPIRV_Cross_CombinediChannel0smp » -> iChannel0
    {
        static const char* kPrefix = "SPIRV_Cross_Combined";
        const size_t pl = strlen(kPrefix);
        std::string out;
        for (size_t i = 0; i < g.size();) {
            if (g[i] == 'S' && g.compare(i, pl, kPrefix) == 0 && (i == 0 || !isIdentChar(g[i - 1])) && g.compare(i + pl, 8, "iChannel") == 0 && i + pl + 8 < g.size() &&
                g[i + pl + 8] >= '0' && g[i + pl + 8] <= '3') {
                size_t e = i + pl;
                while (e < g.size() && isIdentChar(g[e])) e++;
                out += "iChannel";
                out += g[i + pl + 8];
                i = e;
                continue;
            }
            out += g[i++];
        }
        g = out;
    }
    // 5. entrees du fragment : « in vec2 nom; » devient une variable remplie au debut de main (vec2 = position dans l'image de 0 a 1)
    {
        std::string out, init;
        size_t pos = 0;
        while (pos < g.size()) {
            size_t e = g.find('\n', pos);
            if (e == std::string::npos) e = g.size();
            const std::string line = g.substr(pos, e - pos);
            pos = e + 1;
            std::vector<std::string> w = words(line);
            while (!w.empty() && (w[0] == "flat" || w[0] == "smooth" || w[0] == "noperspective")) w.erase(w.begin());
            if (w.size() == 3 && w[0] == "in" && !w[2].empty() && w[2].back() == ';') {
                const std::string type = w[1], name = w[2].substr(0, w[2].size() - 1);
                bool simple = !name.empty();
                for (char c : name) simple = simple && isIdentChar(c);
                if (simple) {
                    out += type + " " + name + ";\n";
                    if (type == "vec2") init += "    " + name + " = gl_FragCoord.xy / iResolution.xy;\n";
                    else if (type == "vec4") init += "    " + name + " = vec4(1.0);\n";
                    continue;
                }
            }
            out += line + "\n";
        }
        g = out;
        if (!init.empty()) {
            for (size_t i = g.find("main"); i != std::string::npos; i = g.find("main", i + 1)) {
                if (!wordAt(g, i, "main")) continue;
                size_t b = i;
                if (wordBefore(g, b) != "void") continue;
                size_t p = skipSpaces(g, i + 4);
                if (p >= g.size() || g[p] != '(') continue;
                const size_t close = g.find(')', p);
                if (close == std::string::npos) continue;
                p = skipSpaces(g, close + 1);
                if (p >= g.size() || g[p] != '{') continue;
                g.insert(p + 1, "\n" + init);
                notes.push_back(TX("xlang.note_inputs"));
                break;
            }
        }
    }
    return g;
}

// --- traduction ---

namespace {

bool spirvToGlsl(const std::wstring& exeDir, const std::wstring& spv, std::string& glsl, std::wstring& err) {
    std::string out;
    int code = 0;
    bool timedOut = false;
    const std::wstring sc = toolFile(exeDir, L"spirv-cross");
    if (!runTool({sc, spv, L"--version", L"330", L"--no-es", L"--remove-unused-variables"}, out, code, timedOut) || code != 0) {
        err = timedOut ? TXF("xlang.err_timeout", L"spirv-cross") : TXF("xlang.err_failed", L"spirv-cross", W(firstLines(out, 6)).c_str());
        return false;
    }
    glsl = out;
    return true;
}

}  // namespace

bool translateShader(const std::string& codeIn, ShaderLang lang, const std::wstring& path, const std::wstring& exeDir, std::string& out, std::wstring& err,
                     std::vector<std::wstring>& notes, int commonLines, const std::wstring& commonPath) {
    err.clear();
    if (codeIn.size() > kMaxSource) {
        err = TXF("xlang.err_too_big", (int)(kMaxSource >> 20));
        return false;
    }
    const bool fromGlsl = lang == ShaderLang::Glsl;
    std::wstring missing;
    if (!xlangToolsPresent(exeDir, lang, fromGlsl, missing)) {
        err = TXF("xlang.err_missing", W(shaderLangName(lang)).c_str(), missing.c_str());
        return false;
    }
    const std::string key = std::string(shaderLangName(lang)) + '\0' + codeIn;
    {
        std::lock_guard<std::mutex> lk(g_cacheLock);
        const auto it = g_cache.find(key);
        if (it != g_cache.end()) {
            out = it->second;
            return true;
        }
    }
    std::string code = codeIn;
    HlslEntry entry;
    const char* ext = lang == ShaderLang::Hlsl ? "hlsl" : lang == ShaderLang::Wgsl ? "wgsl" : "frag";
    if (lang == ShaderLang::Hlsl) entry = findHlslEntry(code);
    else if (lang == ShaderLang::Wgsl) entry = findWgslEntry(code);
    code += entry.wrapper;

    const std::wstring dir = workDir(exeDir);
    const std::string inName = std::string("in.") + ext;
    const std::wstring inFile = dir + sep() + W(inName), spv = dir + sep() + L"out.spv", frag = dir + sep() + L"out.frag";
    bool ok = false;
    std::string glsl, raw;
    if (writeFileAtomic(inFile, code)) {
        int rc = 0;
        bool timedOut = false;
        if (lang == ShaderLang::Hlsl) {
            const bool ran = runTool({dxcFile(exeDir), L"-T", L"ps_6_0", L"-E", W(entry.name), L"-spirv", L"-fspv-target-env=vulkan1.0", inFile, L"-Fo", spv}, raw, rc, timedOut);
            if (!ran || rc != 0) err = timedOut ? TXF("xlang.err_timeout", L"dxc") : formatErrors(lang, raw, inName, path, commonLines, commonPath);
            else ok = spirvToGlsl(exeDir, spv, glsl, err);
        } else if (lang == ShaderLang::Wgsl) {
            const bool ran = runTool({toolFile(exeDir, L"naga"), inFile, frag, L"--profile", L"core330", L"--entry-point", W(entry.name)}, raw, rc, timedOut);
            if (!ran || rc != 0) err = timedOut ? TXF("xlang.err_timeout", L"naga") : formatErrors(lang, raw, inName, path, commonLines, commonPath);
            else ok = readTextFile(frag, glsl) && !glsl.empty();
            if (!ok && err.empty()) err = TXF("xlang.err_failed", L"naga", L"");
        } else {
            const bool ran = runTool({toolFile(exeDir, L"glslang"), L"-G", L"--aml", L"--amb", L"-S", L"frag", inFile, L"-o", spv}, raw, rc, timedOut);
            if (!ran || rc != 0) err = timedOut ? TXF("xlang.err_timeout", L"glslang") : formatErrors(lang, raw, inName, path, commonLines, commonPath);
            else ok = spirvToGlsl(exeDir, spv, glsl, err);
        }
    } else {
        err = TXF("error.write_failed", inFile.c_str());
    }
    removeTree(dir);
    if (!ok) {
        if (err.empty()) err = TXF("xlang.err_failed", W(shaderLangName(lang)).c_str(), L"");
        return false;
    }
    out = finishTranslatedGlsl(glsl, notes);
    notes.push_back(TXF("xlang.note_translated", W(shaderLangName(lang)).c_str()));
    {
        std::lock_guard<std::mutex> lk(g_cacheLock);
        if (g_cache.size() > 64) g_cache.clear();
        g_cache[key] = out;
    }
    return true;
}

bool prepareShaderCode(std::string& code, const std::wstring& path, const std::wstring& exeDir, std::vector<std::wstring>& notes, std::wstring& err) {
    const ShaderLang lang = detectShaderLang(path, code);
    if (lang == ShaderLang::Glsl && !glslNeedsTranslation(code)) return true;
    // fichier Common du meme langage : il est ajoute devant chaque passe, il n'est pas traduit seul
    std::string full = code;
    int commonLines = 0;
    std::wstring commonPath;
    if (lang != ShaderLang::Glsl) {
        const size_t dot = path.find_last_of(L'.'), slash = path.find_last_of(L"\\/");
        if (dot != std::wstring::npos && (slash == std::wstring::npos || dot > slash)) {
            std::wstring stem = path.substr(0, dot);
            const std::wstring ext = path.substr(dot);
            if (stem.size() > 7 && stem.compare(stem.size() - 7, 7, L".common") == 0) {
                code.clear();
                return true;
            }
            for (const wchar_t* suffix : {L".bufferA", L".bufferB", L".bufferC", L".bufferD", L".cubemapA", L".post"}) {
                const size_t n = wcslen(suffix);
                if (stem.size() > n && stem.compare(stem.size() - n, n, suffix) == 0) {
                    stem.resize(stem.size() - n);
                    break;
                }
            }
            const std::wstring cp = stem + L".common" + ext;
            std::string common;
            if (fileExists(cp) && readFile(cp, common)) {
                std::string tmp = common;
                tmp.erase(std::remove(tmp.begin(), tmp.end(), '\r'), tmp.end());
                while (!tmp.empty() && tmp.back() == '\n') tmp.pop_back();
                commonLines = 1 + (int)std::count(tmp.begin(), tmp.end(), '\n');
                commonPath = cp;
                full = tmp + "\n" + code;
            }
        }
    }
    std::string out;
    if (!translateShader(full, lang, path, exeDir, out, err, notes, commonLines, commonPath)) return false;
    // les commentaires que le programme lit (`// iChannel0=bufferA`, `// fps=30`, `// uniform float k = 1 [0..2]`) disparaissent a la traduction : on les remet en tete
    std::string directives;
    for (size_t pos = 0; pos < code.size();) {
        size_t e = code.find('\n', pos);
        if (e == std::string::npos) e = code.size();
        const std::string line = trim(code.substr(pos, e - pos));
        pos = e + 1;
        if (line.compare(0, 2, "//") != 0) continue;
        const std::string body = trim(line.substr(2));
        const size_t eq = body.find('=');
        const size_t sp = body.find(' ');
        if (body.compare(0, 8, "uniform ") == 0 || body.compare(0, 4, "key ") == 0 || (eq != std::string::npos && eq > 0 && (sp == std::string::npos || sp > eq))) directives += line + "\n";
    }
    code = directives + out;
    return true;
}

// --- telechargement de dxc ---

namespace {
// Version epinglee : DirectX Shader Compiler 1.9.2609 (2026-09-29), archive officielle de Microsoft
const wchar_t* kDxcUrl = L"https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.9.2609/dxc_2026_09_29.zip";
const char* kDxcSha256 = "ad31b1fc8443175d204f77a611fdb3ef2ec42759bdc2f1167368de24a4a7e7f1";
}  // namespace

bool dxcPresent(const std::wstring& exeDir) { return fileExists(dxcFile(exeDir)); }

bool downloadDxc(const std::wstring& exeDir, const std::function<void(int, const std::wstring&)>& progress, const std::atomic<bool>* cancel, std::wstring& err) {
    const std::wstring zip = exeDir + L"dxc_download.tmp", tmp = exeDir + L"dxc_tmp";
    platform::makeDir(xlangToolsDir(exeDir).substr(0, xlangToolsDir(exeDir).size() - 1));
    FILE* f = platform::openFile(zip, "wb");
    if (!f) {
        err = TXF("error.write_failed", zip.c_str());
        return false;
    }
    unsigned long long got = 0;
    progress(0, TX("xlang.dl_dxc"));
    const bool ok = platform::httpGet(kDxcUrl, [&](const uint8_t* d, size_t n, unsigned long long total) {
        if (cancel && cancel->load()) return false;
        fwrite(d, 1, n, f);
        got += n;
        if (total) progress((int)(got * 90 / total), TXF("dl.progress", got / 1048576.0, total / 1048576.0));
        return true;
    }, err);
    fclose(f);
    if (!ok) {
        platform::removeFile(zip);
        return false;
    }
    progress(92, TX("dl.verify"));
    std::string actual;
    if (!platform::sha256File(zip, actual) || actual != kDxcSha256) {
        platform::removeFile(zip);
        err = TX("error.sha_mismatch");
        return false;
    }
    progress(95, TX("dl.extract"));
    removeTree(tmp);
    platform::makeDir(tmp);
    std::wstring log;
    std::string text;
    int rc = 0;
    bool timedOut = false;
    runTool({L"tar", L"-xf", zip, L"-C", tmp}, text, rc, timedOut);
    bool installed = false;
    const std::wstring dest = xlangToolsDir(exeDir) + L"dxc";
    if (rc == 0) {
        platform::makeDir(dest);
        installed = true;
        for (const wchar_t* name : {L"dxc.exe", L"dxcompiler.dll", L"dxil.dll"}) {
            const std::wstring from = tmp + sep() + L"bin" + sep() + L"x64" + sep() + name;
            if (!fileExists(from) || !platform::moveFile(from, dest + sep() + name, true)) installed = false;
        }
    }
    platform::removeFile(zip);
    removeTree(tmp);
    if (!installed) {
        err = rc != 0 ? TXF("error.extract_failed", W(firstLines(text, 3)).c_str()) : TX("xlang.err_dxc_archive");
        return false;
    }
    progress(100, TX("dl.installed"));
    return true;
}
