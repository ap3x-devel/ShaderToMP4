// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Patrick JAILLET

// Petit serveur HTTP sur la boucle locale (127.0.0.1), pour les essais seulement : l'auto-test y fait pointer le client reseau du programme et verifie ce
// qu'il demande et comment il reagit a chaque reponse (export correct, cle refusee, identifiant inconnu, reponse tronquee, erreur 500). Il n'est jamais
// demarre par le programme lui-meme.
#pragma once
#include <functional>
#include <string>

namespace platform {

struct LocalReply {
    int status = 200;
    std::string body;
    bool truncate = false;  // annonce la longueur entiere mais n'envoie que la moitie, puis ferme (reponse tronquee)
};

class LocalServer {
public:
    LocalServer();
    ~LocalServer();
    LocalServer(const LocalServer&) = delete;
    LocalServer& operator=(const LocalServer&) = delete;
    // Demarre l'ecoute sur un port libre de 127.0.0.1 ; handler(chemin et requete, par exemple « /api/v1/shaders/abc?key=K ») donne la reponse. Renvoie le port, 0 en cas d'echec.
    int start(const std::function<LocalReply(const std::string& target)>& handler);
    void stop();

private:
    struct Impl;
    Impl* impl_ = nullptr;
};

}  // namespace platform
