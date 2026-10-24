// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Documentation de reference produite par le programme lui-meme (un seul endroit de verite) : les reglages que config.ini peut contenir avec leur valeur par
// defaut, le format du fichier projet et la ligne de commande. `ShaderToMP4 --dump-reference=settings|project|cli [--lang=fr]` ecrit du Markdown ;
// `scripts/make-reference.ps1` ecrit docs/reference/*.md et `scripts/check-repo.ps1` refuse un fichier different de ce que le programme produit.
#pragma once
#include "common.h"

struct SettingRef {
    std::string key;   // « width », « loopmode »... ; les quatre canaux sont une seule ligne « iChannel0 »
    std::string def;   // valeur ecrite dans config.ini par defaut (peut etre vide)
    bool written = false;  // la cle est ecrite par defaut ; sinon elle ne l'est que si elle n'a plus sa valeur par defaut
    std::string text;  // phrase d'explication dans la langue courante ; vide : aucune
};

// Les reglages de config.ini dans l'ordre ou le programme les ecrit
std::vector<SettingRef> settingsReference();

// Sujets : settings, project, cli
std::vector<std::string> referenceTopics();
// Markdown du sujet dans la langue courante ; vide si le sujet est inconnu
std::string referenceMarkdown(const std::string& topic);
