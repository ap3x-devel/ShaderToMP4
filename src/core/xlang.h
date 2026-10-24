// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Autres langages de shader : HLSL (pixel shader), WGSL (fragment) et GLSL « natif » 4.x. Le moteur reste OpenGL 3.3 : le texte est traduit en GLSL 3.30 avant
// la compilation, par des programmes tiers lances a part (dossier tools/ a cote du programme) :
//   HLSL  : dxc (Microsoft DirectX Shader Compiler, telecharge a la demande) -> SPIR-V -> spirv-cross -> GLSL 330
//   WGSL  : naga (naga-cli) -> GLSL 330
//   GLSL 4.x : glslang -> SPIR-V -> spirv-cross -> GLSL 330
// Le GLSL obtenu est un fragment shader « a la WebGL » (void main, sortie, uniforms nommes comme Shadertoy) que adaptShaderCode sait lire.
#pragma once
#include "common.h"

enum class ShaderLang { Glsl, Hlsl, Wgsl };

const char* shaderLangName(ShaderLang l);  // "glsl", "hlsl", "wgsl"
// Langage d'un shader : ligne `// lang=hlsl|wgsl|glsl`, sinon extension (.hlsl, .wgsl), sinon contenu (SV_Target, @fragment...)
ShaderLang detectShaderLang(const std::wstring& path, const std::string& text);
// Faux si ce code GLSL se compile tel quel (versions <= 330 et ES) ; vrai pour un `#version` 400 a 460 hors ES
bool glslNeedsTranslation(const std::string& text);

// Dossier des outils de traduction (exeDir/tools/) et presence de ceux d'un langage
std::wstring xlangToolsDir(const std::wstring& exeDir);
bool xlangToolsPresent(const std::wstring& exeDir, ShaderLang lang, bool needsGlslang, std::wstring& missing);

// Traduit `code` (texte normalise) en GLSL 3.30 ; faux + err (lignes « fichier:ligne: message » quand l'outil donne une position) sinon.
// notes : une phrase par adaptation. path : nom montre dans les messages. Le resultat est garde en memoire par contenu.
// commonLines / commonPath : les premieres lignes de `code` viennent du fichier Common (leurs erreurs sont rapportees dans ce fichier).
bool translateShader(const std::string& code, ShaderLang lang, const std::wstring& path, const std::wstring& exeDir, std::string& out,
                     std::wstring& err, std::vector<std::wstring>& notes, int commonLines = 0, const std::wstring& commonPath = L"");

// Cas des rendus : detecte le langage de `code` et le remplace par son GLSL 3.30 si besoin ; sans effet (vrai) pour un GLSL qui se compile tel quel.
// HLSL et WGSL : le fichier `<nom>.common.<ext>` voisin est ajoute devant chaque passe avant la traduction ; le fichier Common lui-meme rend un texte vide
// (le GLSL traduit n'a plus besoin d'etre complete).
bool prepareShaderCode(std::string& code, const std::wstring& path, const std::wstring& exeDir, std::vector<std::wstring>& notes, std::wstring& err);

// Mention du langage pour la liste des shaders : « HLSL », « WGSL », « GLSL 430 » (4.x) ; "" pour un GLSL ordinaire. Lit le debut du fichier.
std::wstring shaderBadge(const std::wstring& path);

// Post-traitement du GLSL produit par spirv-cross ou naga (blocs d'uniforms aplatis, echantillonneurs nommes iChannelN, entrees, sorties) : teste seul
std::string finishTranslatedGlsl(const std::string& glsl, std::vector<std::wstring>& notes);

// Telechargement de dxc (version epinglee, SHA-256 verifie) dans exeDir/tools/dxc/
bool dxcPresent(const std::wstring& exeDir);
bool downloadDxc(const std::wstring& exeDir, const std::function<void(int, const std::wstring&)>& progress, const std::atomic<bool>* cancel, std::wstring& err);
