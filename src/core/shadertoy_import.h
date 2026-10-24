// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Import hors ligne d'un shader Shadertoy : le fichier JSON exporte depuis la page du shader (aucune cle d'API, aucun reseau).
// Chaque passe devient un fichier a cote du fichier principal (voir passes.h) et les entrees deviennent des commentaires
// `// iChannelN=...` ; ce que ShaderToMP4 ne sait pas rejouer (medias de Shadertoy, webcam, clavier) est signale.
#pragma once
#include "common.h"

struct ShadertoyImport {
    std::wstring mainFile;                 // <nom>.glsl (onglet Image)
    std::vector<std::wstring> files;       // tous les fichiers ecrits
    std::vector<std::wstring> notes;       // remarques pour le journal (medias remplaces, licence...)
    std::wstring title, author, id;
};

// Fichiers choisis par l'utilisateur pour les entrees que Shadertoy fournit lui-meme et que ce programme ne peut pas rejouer : la video de Shadertoy, la
// webcam, le micro et la musique deviennent `video:<fichier>` ou `audio:<fichier>` ; sans fichier, l'entree est remplacee par un canal de substitution et
// le journal le dit. Le clavier devient le canal clavier simule (// key=), la souris est iMouse (// mouse=).
struct ImportMedia {
    std::wstring video;   // entree « video » (extrait de video de Shadertoy)
    std::wstring webcam;  // entree « webcam »
    std::wstring mic;     // entree « mic »
    std::wstring music;   // entrees « music » et « musicstream »
};

// Ecrit les fichiers dans outDir (cree si besoin). false + err si le JSON n'est pas un export de shader.
bool importShadertoyJson(const std::wstring& jsonPath, const std::wstring& outDir, ShadertoyImport& result, std::wstring& err, const ImportMedia& media = ImportMedia());
// Idem a partir du texte JSON (reponse de l'API) ; `name` donne le nom des fichiers quand le shader n'a pas de titre
bool importShadertoyText(const std::string& jsonText, const std::wstring& outDir, ShadertoyImport& result, std::wstring& err, const ImportMedia& media = ImportMedia());

// Chemin a rendre pour un fichier donne a l'interface ou a la ligne de commande : le fichier lui-meme, ou, pour un `.json`,
// le shader importe dans <exeDir>/shadertoy/<nom>/. Vide + err en cas d'echec. log recoit les remarques de l'import.
std::wstring resolveShaderInput(const std::wstring& exeDir, const std::wstring& path, const std::function<void(const std::wstring&)>& log,
                                std::wstring& err);

// Importe un shader recu de l'API (JSON) dans <exeDir>/shadertoy/<nom>/ et renvoie le fichier principal ; `log` recoit les remarques. Vide + err en cas d'echec.
std::wstring importShadertoyForRender(const std::wstring& exeDir, const std::string& jsonText, const ImportMedia& media, const std::function<void(const std::wstring&)>& log,
                                      std::wstring& err);
