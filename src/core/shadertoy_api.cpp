// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#include "shadertoy_api.h"
#include "i18n.h"
#include "json.h"
#include "updatecheck.h"
#include "util.h"
#include "platform/platform.h"

namespace {

constexpr size_t kMaxAnswer = 8u << 20;

std::string urlEncode(const std::string& s) {
    std::string o;
    char b[4];
    for (unsigned char c : s) {
        if (isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
            o += (char)c;
        } else {
            snprintf(b, sizeof(b), "%%%02X", c);
            o += b;
        }
    }
    return o;
}

bool idChars(const std::string& s) {
    if (s.size() < 4 || s.size() > 12) return false;
    for (unsigned char c : s)
        if (!isalnum(c)) return false;
    return true;
}

}  // namespace

const wchar_t* defaultShadertoyApi() { return L"https://www.shadertoy.com/api/v1/shaders/"; }

std::string shadertoyId(const std::wstring& input) {
    std::string t = trim(U8(input));
    const size_t cut = t.find_first_of("?#");
    if (cut != std::string::npos) t = t.substr(0, cut);
    while (!t.empty() && (t.back() == '/' || t.back() == ' ')) t.pop_back();
    const size_t view = t.find("/view/");
    if (view != std::string::npos) t = t.substr(view + 6);
    else if (t.find('/') != std::string::npos || t.find(':') != std::string::npos) return "";
    return idChars(t) ? t : "";
}

std::wstring shadertoyRequestUrl(const std::wstring& apiBase, const std::string& id, const std::string& key) {
    std::wstring base = apiBase.empty() ? std::wstring(defaultShadertoyApi()) : apiBase;
    if (base.back() != L'/') base += L'/';
    return base + W(id) + L"?key=" + W(urlEncode(key));
}

bool checkShadertoyAnswer(const std::string& body, std::wstring& err) {
    JsonValue doc;
    std::string jerr;
    if (!parseJson(body, doc, jerr) || doc.kind != JsonValue::Object) {
        err = TX("error.shadertoy_unreadable");  // reponse tronquee, page HTML d'un proxy, etc.
        return false;
    }
    if (const JsonValue* e = doc.get("Error")) {
        err = TXF("error.shadertoy_refused", W(e->kind == JsonValue::String ? e->text : std::string("?")).c_str());
        return false;
    }
    const JsonValue* sh = doc.get("Shader");
    const JsonValue* passes = sh ? sh->get("renderpass") : nullptr;
    if (!passes || passes->kind != JsonValue::Array || passes->items.empty()) {
        err = TX("error.shadertoy_unreadable");
        return false;
    }
    return true;
}

bool fetchShadertoy(const std::wstring& idOrUrl, const std::string& apiKey, const std::wstring& apiBase, std::string& json, std::wstring& err) {
    json.clear();
    const std::string id = shadertoyId(idOrUrl);
    if (id.empty()) {
        err = TXF("error.shadertoy_id", idOrUrl.c_str());
        return false;
    }
    const std::string key = trim(apiKey);
    if (key.empty()) {
        err = TX("error.shadertoy_nokey");
        return false;
    }
    const std::wstring url = shadertoyRequestUrl(apiBase, id, key);
    if (!updateUrlAllowed(url)) {  // https seulement (ou la boucle locale pour les essais)
        err = TXF("error.shadertoy_url", apiBase.c_str());
        return false;
    }
    std::string body;
    std::wstring nerr;
    const bool got = platform::httpGet(url, [&](const uint8_t* d, size_t n, unsigned long long) {
        body.append((const char*)d, n);
        return body.size() < kMaxAnswer;
    }, nerr);
    if (!got) {
        for (const std::wstring& secret : {W(urlEncode(key)), W(key)}) {  // les messages du reseau citent l'adresse : la cle n'y figure jamais
            for (size_t p = nerr.find(secret); !secret.empty() && p != std::wstring::npos; p = nerr.find(secret, p + 3)) nerr.replace(p, secret.size(), L"***");
        }
        err = TXF("error.shadertoy_network", nerr.c_str());
        return false;
    }
    if (body.size() >= kMaxAnswer) {
        err = TX("error.shadertoy_unreadable");
        return false;
    }
    if (!checkShadertoyAnswer(body, err)) return false;
    json = body;
    return true;
}

static std::wstring keyFile(const std::wstring& exeDir) { return exeDir + L"shadertoy.key"; }

std::string loadShadertoyKey(const std::wstring& exeDir) {
    std::string t;
    if (!readFile(keyFile(exeDir), t) || t.size() > 256) return "";
    const size_t e = t.find_first_of("\r\n");
    return trim(e == std::string::npos ? t : t.substr(0, e));
}

bool saveShadertoyKey(const std::wstring& exeDir, const std::string& key) { return writeFileAtomic(keyFile(exeDir), trim(key) + "\n"); }

void forgetShadertoyKey(const std::wstring& exeDir) { platform::removeFile(keyFile(exeDir)); }
