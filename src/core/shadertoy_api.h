// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Import d'un shader Shadertoy par son identifiant, avec la cle d'API de l'utilisateur. Une seule requete GET, faite UNIQUEMENT quand l'utilisateur la
// demande (bouton « Importer » de la fenetre d'import, ou --import-shadertoy) : jamais en arriere-plan, jamais au demarrage. La cle est celle que
// l'utilisateur obtient sur son compte Shadertoy ; elle n'est ecrite que si l'utilisateur le demande, dans shadertoy.key, dans le dossier du programme.
// Le JSON recu est le meme que l'export de la page : il passe ensuite par importShadertoyJson (shadertoy_import.h).
#pragma once
#include "common.h"

// Adresse de base de l'API des shaders (https://www.shadertoy.com/api/v1/shaders/)
const wchar_t* defaultShadertoyApi();

// Identifiant d'un shader : « XsXXDn » tel quel, ou une adresse « https://www.shadertoy.com/view/XsXXDn » (avec ou sans « ?... » ni « # »). Vide si ce n'est pas un identifiant.
std::string shadertoyId(const std::wstring& input);

// Adresse de la requete : base + identifiant + « ?key=<cle> » (la cle est codee pour l'adresse)
std::wstring shadertoyRequestUrl(const std::wstring& apiBase, const std::string& id, const std::string& key);

// Lit la reponse de l'API : l'export JSON du shader (renvoye tel quel) ou, si la reponse porte un message d'erreur (cle refusee, identifiant inconnu...) ou n'est pas
// un export complet (tronquee, illisible), faux + message dans `err`.
bool checkShadertoyAnswer(const std::string& body, std::wstring& err);

// Fait la requete (https, ou http vers la boucle locale pour les essais) et controle la reponse. apiBase vide = l'API officielle.
bool fetchShadertoy(const std::wstring& idOrUrl, const std::string& apiKey, const std::wstring& apiBase, std::string& json, std::wstring& err);

// Cle memorisee a la demande de l'utilisateur : shadertoy.key dans le dossier du programme (texte, une ligne)
std::string loadShadertoyKey(const std::wstring& exeDir);
bool saveShadertoyKey(const std::wstring& exeDir, const std::string& key);
void forgetShadertoyKey(const std::wstring& exeDir);
