// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Rapport de portabilite et conversion assistee : ce qui empeche un shader ecrit pour un autre environnement (WebGL 1 ou 2, ancien Shadertoy, copie d'un
// exemple GLSL) de se compiler ici, avec pour chaque probleme la correction proposee. Appliquer les corrections ne touche jamais l'original : elles
// s'ecrivent dans une copie (<nom>.fixed.glsl et ses passes) ; le programme sait deja compiler la plupart de ces formes au vol (compat.cpp), la copie
// sert a obtenir un fichier propre, au style Shadertoy, que l'on peut garder et modifier.
#pragma once
#include "common.h"

struct PortIssue {
    std::string kind;   // directive | dupuniform | oldname | webgl | alias | unprovided
    std::string arg;    // nom en cause (uniform, fonction, directive...)
    std::string with;   // ce par quoi il est remplace (nom, expression), vide si la ligne est supprimee
    int line = 0;       // ligne du fichier d'origine (1 = premiere), 0 si le probleme est general
    bool fixable = true;
};

struct PortReport {
    std::vector<PortIssue> issues;
    std::string fixed;  // le code corrige (identique au code d'origine s'il n'y a rien a corriger)
};

// Analyse le texte d'une passe (shader ou onglet) et produit la version corrigee
PortReport analyzePortability(const std::string& code);

// Une ligne pour le journal : « ligne 3 : <probleme> -> <correction> », dans la langue courante
std::wstring describePortIssue(const PortIssue& issue);

struct FixedCopy {
    std::vector<std::wstring> files;   // fichiers ecrits (le shader d'abord)
    std::vector<std::wstring> lines;   // une ligne de journal par probleme, precedee du nom du fichier
    int fixable = 0, notFixable = 0;
};

// Analyse le shader et ses passes (ses onglets existants). Si `destStem` n'est pas vide et qu'il y a des corrections, ecrit la copie : <destStem>.glsl,
// <destStem>.bufferA.glsl... (le dossier de destination doit exister). L'original n'est jamais ecrit. Faux + `err` si un fichier ne se lit pas ou ne s'ecrit pas.
bool portabilityCopy(const std::wstring& shaderPath, const std::wstring& destStem, FixedCopy& out, std::wstring& err);
