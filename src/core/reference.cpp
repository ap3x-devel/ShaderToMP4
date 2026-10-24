// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

#include "reference.h"
#include "cli.h"
#include "i18n.h"
#include "project.h"
#include "settings.h"
#include "util.h"
#include <set>

namespace {

// Des reglages tous presents : ce que le programme n'ecrit que lorsqu'ils ne sont plus a leur valeur par defaut est ecrit aussi
Settings everythingSet() {
    Settings s;
    s.loopMode = "crossfade";
    s.timemap = "0:0;4:1";
    s.speed = 2;
    s.audioFollow = true;
    s.report = "json";
    s.samples = 2;
    s.precheck = true;
    s.target = "youtube-1080p";
    s.targetSizeMB = 8;
    s.crop = "9:16";
    s.masterCache = true;
    s.embed = true;
    s.animPreview = "gif";
    s.source = L"clip.mp4";
    s.source2 = L"other.mp4";
    s.sourceMatch = "size";
    s.sourceAudio = false;
    s.reverse = true;
    s.sourceFps = 25;
    s.transitionOffset = 1;
    s.parallel = 2;
    s.farm = L"farm";
    s.farmTimeout = 60;
    s.bpm = 120;
    s.beatsPerBar = 3;
    s.markers = "all";
    s.beatSync = "beat";
    s.autoCredit = true;
    s.stillFormat = "tiff";
    s.aovSpecs = {"depth=bufferB.r"};
    s.exrCompression = "none";
    s.exrPrecision = "float";
    s.alphaMode = "premult";
    s.depthRange = "0:10";
    s.vectorBlur = 1;
    s.tiffFloat = true;
    s.tile = 512;
    s.dpi = 300;
    s.alpha = true;
    s.hdr = "pq";
    s.interp = 60;
    s.scale = "1920x1080";
    s.loudnorm = -16;
    s.title = L"title";
    s.credit = L"credit";
    s.post = "bloom";
    s.lut = L"grade.cube";
    s.date = "2026-01-01";
    s.channel[0] = L"noise";
    s.variants = {"720p:width=1280"};
    s.bufScale[0] = 0.5;
    return s;
}

struct Line {
    std::string key, value, comment;
};

std::vector<Line> iniLines(const Settings& s) {
    std::vector<Line> out;
    const std::string text = iniText(s);
    size_t pos = 0;
    while (pos < text.size()) {
        size_t e = text.find('\n', pos);
        if (e == std::string::npos) e = text.size();
        std::string line = text.substr(pos, e - pos);
        pos = e + 1;
        while (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.empty() || line[0] == ';') continue;
        const size_t eq = line.find('=');
        if (eq == std::string::npos) continue;
        Line l;
        l.key = line.substr(0, eq);
        std::string rest = line.substr(eq + 1);
        const size_t semi = rest.find("      ; ");
        if (semi != std::string::npos) {
            l.comment = rest.substr(semi + 8);
            rest = rest.substr(0, semi);
        }
        l.value = rest;
        out.push_back(l);
    }
    return out;
}

std::string cell(std::string s) {
    for (size_t p = s.find('|'); p != std::string::npos; p = s.find('|', p + 2)) s.replace(p, 1, "\\|");
    return s;
}

std::string code(const std::string& s) { return s.empty() ? std::string() : "`" + cell(s) + "`"; }

bool missingText(const std::string& t) { return t.empty() || t[0] == '['; }

std::string settingsMarkdown() {
    std::string o = "# " + i18n::tr8("ref.settings.title") + "\n\n" + i18n::tr8("ref.settings.intro") + "\n\n";
    o += "| " + i18n::tr8("ref.col.key") + " | " + i18n::tr8("ref.col.default") + " | " + i18n::tr8("ref.col.desc") + " |\n|---|---|---|\n";
    for (const SettingRef& r : settingsReference()) o += "| `" + cell(r.key) + "` | " + (!r.written ? "*" + i18n::tr8("ref.default_none") + "*" : r.def.empty() ? "*" + i18n::tr8("ref.default_empty") + "*" : code(r.def)) + " | " + (r.text.empty() ? "" : cell(r.text)) + " |\n";
    o += "\n" + i18n::tr8("ref.settings.pro") + "\n";
    return o;
}

std::string projectMarkdown() {
    Project p;
    p.name = L"example";
    p.general = {{"width", "1920"}, {"fps", "30"}};
    ProjectShader s;
    s.path = L"C:/work/clip.glsl";
    s.batch = 1;
    s.priority = 1;
    s.ownSettings = true;
    s.own = {{"fps", "60"}};
    s.passes = {L"C:/work/clip.bufferA.glsl"};
    s.media = {L"C:/work/texture.png"};
    p.shaders.push_back(s);
    std::string o = "# " + i18n::tr8("ref.project.title") + "\n\n" + i18n::tr8("ref.project.intro") + "\n\n```json\n" + projectToJson(p, L"C:/work/") + "```\n\n";
    o += "| " + i18n::tr8("ref.project.field") + " | " + i18n::tr8("ref.project.type") + " | " + i18n::tr8("ref.col.desc") + " |\n|---|---|---|\n";
    static const struct { const char *field, *type, *key; } kFields[] = {
        {"format", "string", "projfmt.format"}, {"version", "number", "projfmt.version"}, {"name", "string", "projfmt.name"},
        {"general", "string[]", "projfmt.general"}, {"shaders", "object[]", "projfmt.shaders"}, {"shaders[].path", "string", "projfmt.path"},
        {"shaders[].batch", "number", "projfmt.batch"}, {"shaders[].priority", "number", "projfmt.priority"}, {"shaders[].settings", "string[]", "projfmt.settings"},
        {"shaders[].passes", "string[]", "projfmt.passes"}, {"shaders[].media", "string[]", "projfmt.media"}};
    for (const auto& f : kFields) o += std::string("| `") + f.field + "` | " + f.type + " | " + cell(i18n::tr8(f.key)) + " |\n";
    o += "\n" + i18n::tr8("ref.project.version") + " " + std::to_string(kProjectVersion) + ".\n";
    return o;
}

std::string cliMarkdown() {
    std::string o = "# " + i18n::tr8("ref.cli.title") + "\n\n" + i18n::tr8("ref.cli.intro") + "\n\n";
    std::string text;
    for (const char* k : {"cli.opt.files", "cli.opt.selftest", "cli.opt.update", "cli.opt.render", "cli.opt.quiet", "cli.opt.get_ffmpeg", "cli.opt.version", "cli.opt.help"})
        text += "  " + i18n::tr8(k) + "\n";
    text += renderHelpText();  // les options de --render, le diagnostic, le banc d'essai... : les memes lignes que --help
    o += "| " + i18n::tr8("ref.cli.option") + " | " + i18n::tr8("ref.col.desc") + " |\n|---|---|\n";
    std::string notes;
    size_t pos = 0;
    while (pos < text.size()) {
        size_t e = text.find('\n', pos);
        if (e == std::string::npos) e = text.size();
        const std::string line = text.substr(pos, e - pos);
        pos = e + 1;
        if (line.compare(0, 2, "  ") != 0) continue;
        const std::string body = trim(line);
        const size_t gap = body.find("  ");
        if (body.compare(0, 2, "--") != 0 && gap == std::string::npos) {
            notes += "\n" + body + "\n";
            continue;
        }
        if (gap == std::string::npos) {
            o += "| " + code(body) + " | |\n";
            continue;
        }
        if (body.compare(0, 11, "Exit codes:") == 0 || body.compare(0, 6, "Codes ") == 0) {
            notes += "\n" + body + "\n";
            continue;
        }
        o += "| " + code(body.substr(0, gap)) + " | " + cell(trim(body.substr(gap))) + " |\n";
    }
    return o + notes;
}

}  // namespace

std::vector<SettingRef> settingsReference() {
    std::vector<SettingRef> out;
    std::set<std::string> seen;
    const std::vector<Line> defaults = iniLines(Settings());
    std::set<std::string> written;
    for (const Line& l : defaults) written.insert(l.key);
    auto add = [&](const Line& l, bool isDefault) {
        std::string key = l.key;
        if (key.compare(0, 8, "iChannel") == 0) key = "iChannel0";  // les quatre canaux : une ligne
        if (key.compare(0, 6, "buffer") == 0) key = "bufferA";      // idem Buffer A a D
        if (!seen.insert(key).second) return;
        SettingRef r;
        r.key = key;
        r.written = isDefault;
        if (isDefault) r.def = l.value;
        r.text = l.comment;
        if (r.text.empty()) {
            const std::string t = i18n::tr8(("ini." + (key == "iChannel0" ? std::string("ichannel") : key)).c_str());
            if (!missingText(t)) r.text = t;
        }
        if (r.text.empty()) {
            const std::string t = i18n::tr8(("refset." + key).c_str());
            if (!missingText(t)) r.text = t;
        }
        out.push_back(r);
    };
    for (const Line& l : defaults) add(l, true);
    for (const Line& l : iniLines(everythingSet())) add(l, written.count(l.key) > 0);
    return out;
}

std::vector<std::string> referenceTopics() { return {"settings", "project", "cli"}; }

std::string referenceMarkdown(const std::string& topic) {
    if (topic == "settings") return settingsMarkdown();
    if (topic == "project") return projectMarkdown();
    if (topic == "cli") return cliMarkdown();
    return "";
}
