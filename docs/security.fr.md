<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->

**Français** · [English](security.md)

# Revue de sécurité de ShaderToMP4 4.1.0

Écrite pour la version 4.1.0 le 2026-10-29. Elle dit ce que le programme croit, ce qu'il lit, ce qu'il envoie, et comment chaque lecteur est éprouvé. Ce n'est pas une garantie : les contrôles ci-dessous réduisent le risque, ils ne le suppriment pas.

## Modèle de menace

| Source | De confiance ? | Ce que fait le programme |
|---|---|---|
| Shaders, passes, textures, sons et vidéos que vous choisissez | **Non** : ils peuvent venir de n'importe qui | Le texte d'un shader va au compilateur du pilote graphique et n'est jamais exécuté par le programme. Les médias sont décodés par `ffmpeg` dans un processus séparé. Chaque lecteur de texte et de fichier ci-dessous est fuzzé. Un shader peut quand même être long à rendre ou gourmand en mémoire. |
| Réglages, présélections, projets, file, historique, fichiers de touches | Écrits par le programme, mais peuvent être modifiés ou copiés d'ailleurs | Lus par les mêmes lecteurs fuzzés ; une clé inconnue est ignorée, un fichier abîmé ou trop récent est refusé avec un message. |
| Fichiers 3D, MIDI, données, sous-titres, ICC, LUT, configurations de couleur | **Non** | Lecteurs fuzzés avec limites de taille (par exemple 65536 pixels et 2^28 échantillons pour l'EXR, limite de profondeur du lecteur d'expressions). La configuration OpenColorIO est lue par le programme OpenColorIO, un processus séparé. |
| Le réseau | **Non** | Le programme n'envoie rien que vous n'ayez demandé par une action explicite : vérification des mises à jour, import Shadertoy (avec votre propre clé), téléchargement d'ffmpeg ou de dxc, diffusion en direct vers l'adresse que vous avez saisie. Seules les adresses `https` (ou l'adresse locale pour les essais) sont admises pour les mises à jour ; les fichiers téléchargés sont comparés à une somme SHA-256 publiée. Aucune télémétrie. |
| L'API locale (`--serve`) | Éteinte tant qu'on ne la demande pas | N'écoute que sur 127.0.0.1, jeton de 64 caractères dans `serve.token`, requêtes sans jeton ou avec un mauvais jeton refusées, `Host` étranger ou tout en-tête `Origin` refusés, lecteur de requêtes fuzzé. |
| Entrées en direct (OSC sur UDP, MIDI) | Seulement quand la sortie en direct est lancée | Les paquets sont lus par un lecteur fuzzé ; les valeurs ne pilotent que les paramètres que vous avez déclarés. |
| Le fichier de licence | Signé par l'auteur | Signature Ed25519 vérifiée hors ligne ; un fichier faux, expiré ou d'une autre version majeure ne change que l'état affiché. Fuzzé. |
| Windows, le pilote graphique, `ffmpeg` et les traducteurs | De confiance comme le système | Ce sont des programmes séparés ou des composants du système ; leurs propres défauts sont les leurs. |

Le programme n'écrit que dans son dossier (mode portable). Il ne demande jamais de droits d'administrateur et ne touche pas au registre ; seul l'installeur facultatif écrit des clés de registre et des raccourcis par utilisateur.

## Entrées lues et cible de fuzzing

`ShaderToMP4 --fuzz=<cible> --fuzz-count=N --fuzz-seed=S` abîme des entrées valides (bits retournés, morceaux insérés, supprimés et répétés, nombres piégeux) et exige que le lecteur ne plante pas, ne boucle pas plus de 8 s et ne lève pas d'exception. `--fuzz=list` affiche les cibles, `--fuzz=all` les lance toutes, et l'auto-test les lance toutes avec 500 entrées chacune. Les entrées de départ sont dans le code et dans `tests/fuzz/<cible>/`. Le cas d'auto-test « revue de sécurité » échoue quand un lecteur de ce tableau n'a ni cible ni entrée de départ, et quand une cible manque à ce tableau.

| Entrée | Cible de fuzzing |
|---|---|
| config.ini, présélections de l'utilisateur, commentaires d'un shader (// clé=valeur) | `ini` |
| jobs/*.ini (réglages d'un shader) | `jobs` |
| queue.txt | `queue` |
| fichier de projet (.s2mproj) | `project` |
| keys.ini et texte des raccourcis | `shortcuts` |
| listes d'images clés (souris, clavier) | `keys` |
| history.jsonl | `history` |
| fichier de montage (.montage) | `montage` |
| fichier LUT (.cube, 1D et 3D) | `cube` |
| images OpenEXR relues | `exr` |
| images TIFF flottantes relues | `tifffloat` |
| paramètres déclarés dans un shader (// uniform ...) | `params` |
| expressions des paramètres animés | `expr` |
| courbes de temps et de vitesse | `timemap` |
| chaînes de post-traitement | `post` |
| cibles de livraison (targets.ini) | `targets` |
| liste de --check | `check` |
| JSON de mesure de loudness d'ffmpeg | `loudnorm` |
| messages du compilateur (fichier:ligne) | `location` |
| documents JSON (fichiers de langue, schéma, réponses) | `json` |
| JSON d'export Shadertoy | `shadertoy` |
| réponse de l'API Shadertoy | `shadertoyapi` |
| source de shader au style WebGL 1 / GLSL ES | `portability` |
| source de shader HLSL | `hlsl` |
| source de shader WGSL | `wgsl` |
| source de shader GLSL 4.x | `glslnative` |
| requêtes reçues par l'API locale | `http-request` |
| paquets OSC | `osc` |
| marqueurs de temps et tempo | `beats` |
| description de version de la vérification des mises à jour | `update` |
| fichier de licence (ShaderToMP4.license) | `license` |
| fichiers MIDI | `pro_midi` |
| fichiers de données (CSV, TSV, JSON, capture OSC) | `pro_csv` |
| maillages OBJ | `pro_obj` |
| maillages PLY | `pro_ply` |
| maillages et animations glTF et GLB | `pro_gltf` |
| fichiers de sous-titres (.srt, .vtt, .ass, .ssa) | `pro_subtitles` |
| fichiers de livraison (delivery.ini) | `pro_delivery` |
| profils ICC | `pro_icc` |
| lignes de calques (layer1 ... layer12) | `pro_layers` |
| réglages de scène 3D, de caméra et de guides | `pro_scene` |
| courbe tonale, espace colorimétrique et réglages OpenColorIO | `pro_color` |

Non couverts par une cible du programme, parce qu'un autre composant les lit : images, sons et vidéos (décodés par `ffmpeg`), logos SVG (Direct2D), polices (le système), configurations `.ocio` (OpenColorIO), source GLSL (le compilateur du pilote).

Défauts trouvés par ce travail et corrigés : des limites de taille dans les lecteurs TIFF et EXR, une limite de profondeur dans le lecteur d'expressions, des limites de taille dans les lecteurs de maillages et de données ; en 4.1.0, un fichier de sous-titres ASS dont la ligne `Format:` n'a pas de colonne `Text` lisait hors de sa liste de champs (cible `pro_subtitles`, entrée de départ `tests/fuzz/pro_subtitles/seed_format_without_text.ass`).

## Vulnérabilités connues des composants livrés

`scripts/check-vulnerabilities.ps1` interroge la base nationale des vulnérabilités (NVD) pour chaque composant de `scripts/components.json`. Résultat du 2026-10-29 :

| Composant | Version | Fiches trouvées |
|---|---|---|
| FFmpeg (version essentials de gyan.dev) | 9.0.2 | 7 (6 moyennes, 1 faible : CVE-2025-25468, CVE-2025-25469 et cinq fiches CVE-2026) |
| OpenColorIO (`ociobakelut`) | 2.6.0 | aucune |
| glslang | 16.6.0 | aucune |
| Runtime NSIS | 3.11 | aucune |

Les fiches d'FFmpeg concernent le décodage de fichiers médias fabriqués. Le programme ne passe à `ffmpeg` que les fichiers que vous choisissez, dans un processus séparé ; n'ouvrez pas de médias de sources en lesquelles vous n'avez pas confiance, et mettez ffmpeg à jour quand une version corrigée est publiée (le programme télécharge une version épinglée, listée dans `THIRD_PARTY_NOTICES.fr.md`). La base ne connaît que les versions que les fiches nomment : un résultat vide n'est pas une garantie, et le code du programme lui-même n'y est pas couvert.

## Signaler un problème

Écrivez à ap3x.records@proton.me avec la version (`--version`), l'entrée qui déclenche le problème si vous pouvez la partager, et ce que vous avez vu.
