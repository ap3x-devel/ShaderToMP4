// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Import d'un shader Shadertoy par son identifiant (ou son adresse) avec la cle d'API de l'utilisateur. UNE requete, au clic sur « Importer » : rien n'est
// demande au demarrage ni en arriere-plan. La cle n'est ecrite (shadertoy.key, dans le dossier du programme) que si la case « memoriser » est cochee.
// Les entrees que Shadertoy fournit lui-meme (video, webcam, micro, musique) peuvent etre remplacees par des fichiers choisis ici.
#include "accessible.h"
#include "app.h"
#include "core/i18n.h"
#include "core/shadertoy_api.h"
#include "core/shadertoy_import.h"
#include "core/util.h"
#include "ui_controls.h"
#include "ui_theme.h"
#include "../../res/resource.h"
#include <commdlg.h>

using namespace theme;

namespace {

enum { ID_IMP_ID = 970, ID_IMP_KEY, ID_IMP_REMEMBER, ID_IMP_VIDEO, ID_IMP_VIDEOB, ID_IMP_SOUND, ID_IMP_SOUNDB, ID_IMP_GO, ID_IMP_CLOSE = IDCANCEL };
constexpr UINT WM_IMPORT_DONE = WM_APP + 70;

struct Dialog {
    HWND wnd = nullptr, edId = nullptr, edKey = nullptr, edVideo = nullptr, edSound = nullptr, bRemember = nullptr, bGo = nullptr, bClose = nullptr, status = nullptr;
    HWND labels[5] = {};
    HWND bVideoB = nullptr, bSoundB = nullptr;
    UINT dpi = 96;
    bool remember = false, busy = false;
    std::thread worker;
} D;

struct Result {
    bool ok = false;
    std::string json;
    std::wstring err;
};

const wchar_t* kClass = L"ShaderToMP4Import";

int S(int v) { return MulDiv(v, (int)D.dpi, 96); }

void setStatus_(const std::wstring& t, bool error) {
    SetWindowTextW(D.status, t.c_str());
    (void)error;
}

void layoutControls() {
    RECT c;
    GetClientRect(D.wnd, &c);
    const int pad = S(16), lh = S(20), fh = S(28), gap = S(10), w = c.right - 2 * pad;
    int y = pad;
    auto row = [&](HWND label, HWND edit, HWND browse) {
        MoveWindow(label, pad, y, w, lh, TRUE);
        y += lh + S(2);
        MoveWindow(edit, pad, y, browse ? w - S(112) : w, fh, TRUE);
        if (browse) MoveWindow(browse, pad + w - S(104), y, S(104), fh, TRUE);
        y += fh + gap;
    };
    row(D.labels[0], D.edId, nullptr);
    row(D.labels[1], D.edKey, nullptr);
    MoveWindow(D.bRemember, pad, y - S(2), w, S(30), TRUE);
    y += S(30) + gap;
    row(D.labels[2], D.edVideo, D.bVideoB);
    row(D.labels[3], D.edSound, D.bSoundB);
    MoveWindow(D.status, pad, y, w, S(40), TRUE);
    MoveWindow(D.bGo, pad, c.bottom - pad - S(36), S(170), S(36), TRUE);
    MoveWindow(D.bClose, c.right - pad - S(110), c.bottom - pad - S(36), S(110), S(36), TRUE);
}

void applyRemember() { ui::setButtonStyle(D.bRemember, D.remember ? ui::BtnStyle::Primary : ui::BtnStyle::Chip); }

void browseInto(HWND edit) {
    std::vector<wchar_t> buf(32768, 0);
    OPENFILENAMEW o{};
    o.lStructSize = sizeof(o);
    o.hwndOwner = D.wnd;
    const std::wstring filter = makeFilter({{TX("dialog.all_files"), L"*.*"}});
    o.lpstrFilter = filter.c_str();
    o.lpstrFile = buf.data();
    o.nMaxFile = (DWORD)buf.size();
    o.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST;
    if (GetOpenFileNameW(&o)) SetWindowTextW(edit, buf.data());
}

void startImport() {
    if (D.busy) return;
    const std::wstring idText = getText(D.edId);
    const std::string key = trim(U8(getText(D.edKey)));
    if (shadertoyId(idText).empty()) {
        setStatus_(TXF("error.shadertoy_id", idText.c_str()), true);
        SetFocus(D.edId);
        return;
    }
    if (key.empty()) {
        setStatus_(TX("error.shadertoy_nokey"), true);
        SetFocus(D.edKey);
        return;
    }
    if (D.remember) saveShadertoyKey(g.exeDir, key);
    else forgetShadertoyKey(g.exeDir);
    D.busy = true;
    EnableWindow(D.bGo, FALSE);
    setStatus_(TX("ui.import.working"), false);
    if (D.worker.joinable()) D.worker.join();
    HWND wnd = D.wnd;
    D.worker = std::thread([wnd, idText, key] {  // la requete se fait hors de la fenetre : elle ne la fige pas
        Result* r = new Result();
        r->ok = fetchShadertoy(idText, key, L"", r->json, r->err);
        PostMessageW(wnd, WM_IMPORT_DONE, 0, (LPARAM)r);
    });
}

void finishImport(Result* r) {
    D.busy = false;
    EnableWindow(D.bGo, TRUE);
    if (!r->ok) {
        setStatus_(r->err, true);
        delete r;
        return;
    }
    ImportMedia media;
    media.video = W(trim(U8(getText(D.edVideo))));
    media.webcam = media.video;
    media.mic = W(trim(U8(getText(D.edSound))));
    media.music = media.mic;
    std::wstring err;
    const std::wstring main = importShadertoyForRender(g.exeDir, r->json, media, [](const std::wstring& m) { appendLog(m); }, err);
    delete r;
    if (main.empty()) {
        setStatus_(err, true);
        return;
    }
    addFiles({main});
    appendLog(TXF("log.import_added", main.c_str()));
    DestroyWindow(D.wnd);
}

LRESULT CALLBACK proc(HWND h, UINT msg, WPARAM wp, LPARAM lp) {
    switch (msg) {
        case WM_SIZE: layoutControls(); return 0;
        case WM_DRAWITEM: {
            DRAWITEMSTRUCT* d = (DRAWITEMSTRUCT*)lp;
            if (d->CtlType == ODT_BUTTON) {
                ui::drawButton(d, D.dpi);
                return TRUE;
            }
            break;
        }
        case WM_CTLCOLORSTATIC: {
            HDC hdc = (HDC)wp;
            SetTextColor(hdc, cref(MUTED));
            SetBkColor(hdc, cref(BG));
            static HBRUSH br = CreateSolidBrush(cref(BG));
            return (LRESULT)br;
        }
        case WM_CTLCOLOREDIT: {
            HDC hdc = (HDC)wp;
            SetTextColor(hdc, cref(TEXT));
            SetBkColor(hdc, cref(FIELD));
            return (LRESULT)g.brField;
        }
        case WM_COMMAND: {
            switch (LOWORD(wp)) {
                case ID_IMP_GO: startImport(); break;
                case ID_IMP_REMEMBER:
                    D.remember = !D.remember;
                    applyRemember();
                    break;
                case ID_IMP_VIDEOB: browseInto(D.edVideo); break;
                case ID_IMP_SOUNDB: browseInto(D.edSound); break;
                case IDCANCEL: DestroyWindow(h); break;
            }
            return 0;
        }
        case WM_IMPORT_DONE: finishImport((Result*)lp); return 0;
        case WM_SETFOCUS: SetFocus(D.edId); return 0;
        case WM_CLOSE: DestroyWindow(h); return 0;
        case WM_DESTROY:
            if (D.worker.joinable()) D.worker.detach();  // une requete en cours se termine seule : sa reponse est ignoree
            D.wnd = nullptr;
            return 0;
    }
    return DefWindowProcW(h, msg, wp, lp);
}

}  // namespace

void showImportShadertoy(HWND owner) {
    if (D.wnd) {
        SetForegroundWindow(D.wnd);
        return;
    }
    HINSTANCE hi = GetModuleHandleW(nullptr);
    static bool registered = false;
    if (!registered) {
        WNDCLASSEXW wc{};
        wc.cbSize = sizeof(wc);
        wc.lpfnWndProc = proc;
        wc.hInstance = hi;
        wc.hCursor = LoadCursorW(nullptr, MAKEINTRESOURCEW(32512));
        wc.hbrBackground = CreateSolidBrush(cref(BG));
        wc.hIcon = LoadIconW(hi, MAKEINTRESOURCEW(1));
        wc.lpszClassName = kClass;
        RegisterClassExW(&wc);
        registered = true;
    }
    D.dpi = dpiFor(owner ? owner : g.wnd);
    D.busy = false;
    const std::string saved = loadShadertoyKey(g.exeDir);
    D.remember = !saved.empty();
    RECT want{0, 0, S(560), S(470)};
    const DWORD style = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU;
    AdjustWindowRectExForDpi(&want, style, FALSE, 0, D.dpi);
    RECT pr{};
    GetWindowRect(owner ? owner : g.wnd, &pr);
    const int ww = want.right - want.left, wh = want.bottom - want.top;
    RECT place = fitToWorkArea({pr.left + 60, pr.top + 60, pr.left + 60 + ww, pr.top + 60 + wh});
    D.wnd = CreateWindowExW(0, kClass, TX("ui.import.title").c_str(), style | WS_VISIBLE | WS_CLIPCHILDREN, place.left, place.top, place.right - place.left, place.bottom - place.top,
                            owner ? owner : g.wnd, nullptr, hi, nullptr);
    if (!D.wnd) return;
    ui::darkTitleBar(D.wnd);
    auto label = [&](int i, const char* key) {
        D.labels[i] = CreateWindowExW(0, L"STATIC", TX(key).c_str(), WS_CHILD | WS_VISIBLE | SS_LEFT | SS_NOPREFIX, 0, 0, 10, 10, D.wnd, nullptr, hi, nullptr);
        SendMessageW(D.labels[i], WM_SETFONT, (WPARAM)g.font, TRUE);
    };
    auto edit = [&](int id, DWORD extra) {
        HWND e = CreateWindowExW(0, L"EDIT", L"", WS_CHILD | WS_VISIBLE | WS_TABSTOP | ES_AUTOHSCROLL | extra, 0, 0, 10, 10, D.wnd, (HMENU)(INT_PTR)id, hi, nullptr);
        SendMessageW(e, WM_SETFONT, (WPARAM)g.font, TRUE);
        ui::darkTheme(e, L"DarkMode_CFD");
        return e;
    };
    auto button = [&](int id, const char* key, int icon, ui::BtnStyle st) {
        HWND b = CreateWindowExW(0, L"BUTTON", TX(key).c_str(), WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_OWNERDRAW, 0, 0, 10, 10, D.wnd, (HMENU)(INT_PTR)id, hi, nullptr);
        ui::setupButton(b, icon, st, BG);
        SendMessageW(b, WM_SETFONT, (WPARAM)g.font, TRUE);
        return b;
    };
    label(0, "ui.import.id");
    D.edId = edit(ID_IMP_ID, 0);
    label(1, "ui.import.key");
    D.edKey = edit(ID_IMP_KEY, ES_PASSWORD);
    D.bRemember = button(ID_IMP_REMEMBER, "ui.import.remember", IC_SAVE, D.remember ? ui::BtnStyle::Primary : ui::BtnStyle::Chip);
    label(2, "ui.import.video");
    D.edVideo = edit(ID_IMP_VIDEO, 0);
    D.bVideoB = button(ID_IMP_VIDEOB, "ui.btn.browse", IC_FOLDER, ui::BtnStyle::Secondary);
    label(3, "ui.import.sound");
    D.edSound = edit(ID_IMP_SOUND, 0);
    D.bSoundB = button(ID_IMP_SOUNDB, "ui.btn.browse", IC_FOLDER, ui::BtnStyle::Secondary);
    D.status = CreateWindowExW(0, L"STATIC", TX("ui.import.hint").c_str(), WS_CHILD | WS_VISIBLE | SS_LEFT | SS_NOPREFIX, 0, 0, 10, 10, D.wnd, nullptr, hi, nullptr);
    SendMessageW(D.status, WM_SETFONT, (WPARAM)g.font, TRUE);
    D.bGo = button(ID_IMP_GO, "ui.import.go", IC_DOWNLOAD, ui::BtnStyle::Primary);
    D.bClose = button(ID_IMP_CLOSE, "ui.history.close", IC_CHECK, ui::BtnStyle::Secondary);
    if (!saved.empty()) SetWindowTextW(D.edKey, W(saved).c_str());
    setAccessibleName(D.edId, "ui.import.id");
    setAccessibleName(D.edKey, "ui.import.key");
    setAccessibleName(D.edVideo, "ui.import.video");
    setAccessibleName(D.edSound, "ui.import.sound");
    layoutControls();
    SetFocus(D.edId);
}
