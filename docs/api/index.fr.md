<!-- Copyright (C) 2026 Patrick JAILLET - Référence de l'API locale -->

[English](index.md) · **Français**

# API locale de ShaderToMP4

`ShaderToMP4 --serve[=port]` démarre une API HTTP / JSON sur `127.0.0.1` (port 8765 par défaut). Elle est **inactive tant qu'on ne la demande pas** et s'arrête par `POST /api/v1/shutdown`. La forme de chaque réponse est décrite dans [schema.json](schema.json).

## Accès

Le programme écrit un jeton de 64 caractères dans `serve.token` à côté du programme (et le port dans `serve.json`) ; les deux fichiers sont retirés à l'arrêt du serveur. Chaque requête doit porter :

```
Authorization: Bearer <jeton>
Host: 127.0.0.1:8765        (ou localhost)
```

| Cas | Réponse |
|---|---|
| Pas de jeton, mauvais jeton | `401` |
| `Host` autre que `127.0.0.1` / `localhost`, ou en-tête `Origin` (une page web) | `403` |
| Adresse inconnue, travail inconnu | `404` |
| Méthode non permise sur cette adresse | `405` |
| Corps qui n'est pas du JSON, réglage inconnu, mauvais chemin | `400` (`{"error": "..."}`) |
| Corps de plus de 1 Mo | `413` |
| Trop de travaux en attente, suppression d'un travail en cours | `409` |

Le serveur n'écoute jamais sur une autre adresse de la machine et ferme toute connexion dont l'adresse distante n'est pas `127.0.0.1`.

## Adresses

Toutes sous `/api/v1`. Les corps et les réponses sont du JSON (UTF-8).

| Requête | Effet |
|---|---|
| `GET /status` | `{"program","version","api":1,"state":"idle"|"busy","queued","running","jobs"}` |
| `GET /settings` | tous les réglages du tableau des réglages, en texte |
| `PUT /settings` | `{"width": 1280, "fps": 30}` : change les réglages généraux (chaînes, nombres ou booléens) ; une clé inconnue donne `400` et ne change rien |
| `POST /jobs` | `{"path": "C:/shaders/plasma.glsl", "settings": {"duration": 5, "outdir": "C:/videos"}}` : ajoute un shader (`.glsl`, `.txt`, `.frag`, `.hlsl`, `.wgsl`) à la file et la lance ; le travail prend les réglages généraux puis les siens ; réponse `201` avec le travail |
| `GET /jobs` | `{"jobs": [...]}` |
| `GET /jobs/{id}` | le travail : `id`, `path`, `state` (`queued`, `running`, `done`, `failed`, `cancelled`), `progress` (`frame`, `total`, `fps`, `remaining_s`), `error`, `outputs`, `log` (les 60 dernières lignes) |
| `GET /jobs/{id}/outputs` | `{"outputs": ["C:/videos/plasma.mp4"]}` |
| `POST /jobs/{id}/cancel` | arrête le travail (ou le retire de la file) |
| `DELETE /jobs/{id}` | oublie un travail terminé |
| `POST /shutdown` | arrête le serveur |

Les travaux s'exécutent l'un après l'autre, dans l'ordre.

## Exemple

```powershell
$token = (Get-Content serve.token).Trim()
$h = @{ Authorization = "Bearer $token" }
$job = Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8765/api/v1/jobs -Headers $h -ContentType application/json `
  -Body '{"path":"C:/shaders/plasma.glsl","settings":{"duration":5,"outdir":"C:/videos"}}'
Invoke-RestMethod -Uri "http://127.0.0.1:8765/api/v1/jobs/$($job.id)" -Headers $h
```

Clients complets qui suivent la progression : `examples/automation/render.ps1` (PowerShell) et `examples/automation/render.py` (Python, bibliothèque standard seulement). L'auto-test lance les deux contre un vrai serveur.

## Autres sorties lisibles par un programme

`--progress=json` écrit un objet JSON par ligne (`start`, `log`, `progress`, `done`, `error`, `end`), `--report=json` écrit `nom.report.json` à côté de chaque vidéo, et `--diagnostic` écrit des lignes de texte `clé : valeur`. Leurs formes sont dans [schema.json](schema.json) (définitions `progressEvent` et `renderReport`).

## Codes de sortie

`0` tout est rendu ; `1` un rendu a échoué (aussi `--serve` sur un port pris) ; `2` ligne de commande invalide ; `3` pas d'OpenGL 3.3 ; `4` ffmpeg introuvable ; `5` banc d'essai plus lent qu'avant ; `6` avertissement de `--check` ; `7` différence de `--compare` / `--golden=verify` / `--verify` ; `8` version plus récente disponible ; `9` corrections possibles de `--portability`.
