<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->
<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->

# Ligne de commande

Les options de `ShaderToMP4`, écrites par le programme lui-même (`ShaderToMP4 --dump-reference=cli`) ; ce sont les lignes de `--help`. Tout réglage de la référence des réglages peut être donné sous la forme `--clé=valeur`.

| Option | Description |
|---|---|
| `fichiers shader` | Ajoute les fichiers et lance le rendu tout de suite |
| `--selftest` | Rend les shaders de référence et les compare (voir tests/) |
| `--update` | Avec --selftest : réécrit les images de référence |
| `--render` | Rend les fichiers sans fenêtre (tous les systèmes, voir plus bas) |
| `--quiet` | Aucune boîte de message (--selftest, --get-ffmpeg) |
| `--get-ffmpeg` | Télécharge et installe ffmpeg, sans fenêtre |
| `--version` | Affiche la version, le copyright et la licence |
| `--help` | Affiche cette aide |
| `--clé=valeur` | Tout réglage du tableau des réglages (--width=1280 --codec=h265 --container=mp4 --crf=18 --outdir=C:\sortie ...) |
| `--profile=f` | Applique un profil .ini (les options --clé=valeur passent après) |
| `--progress=json\|text\|none` | Lignes JSON (start, progress, log, done, error, end) ou une ligne tous les 10 % |
| `--png` | Rend une seule image PNG au temps de départ |
| `--thumb[=s]` | Une vignette de couverture PNG (1280 pixels de large au plus) à la seconde s, par défaut au milieu de la plage |
| `--verify` | Relit des vidéos terminées : durée, cadence, nombre d'images, SHA-256, et les compare au rapport de rendu ; code de sortie 7 en cas de différence |
| `--beats[=list\|clear] son...` | analyse le tempo, les temps, les mesures et les sections de fichiers son (écrit <son>.beats.json à côté de chacun ; list affiche les instants, clear retire les corrections faites à la main) |
| `--parallel=N, --farm=dossier, --farm-status dossier` | rend les parties d'une vidéo avec N contextes OpenGL, ou avec plusieurs ordinateurs sur un dossier partagé (la même commande sur chacun ; --farm-status liste les parties faites, en cours et libres) ; demande --chunk ; --benchmark --parallel mesure le gain |
| `--source=fichier\|dossier\|img_%04d.png, --source2=fichier` | applique le shader à une vidéo, une image, une séquence ou à chaque fichier d'un dossier (iChannel0 ; la deuxième source est iChannel1 et iProgress va de 0 à 1 pour les transitions) ; taille, cadence, durée, son, sous-titres et chapitres viennent de la source (--sourcematch=..., --sourceaudio=0), --reverse=1 joue à l'envers |
| `--aov=depth=bufferB.r;normal=bufferC.rgb;alpha;motion, --exrcompression=none\|zips\|zip, --exrprecision=half\|float, --alphamode=straight\|premult, --depthrange=proche:loin, --tifffloat=1` | OpenEXR multicouche écrit par le programme (conteneur exr) ; --exr-info fichier\|dossier liste les couches, --depthmap fichier\|dossier [--depthinvert] écrit une carte de profondeur 16 bits |
| `--reproduce` | Extrait la source embarquée dans une vidéo (embed=1) et la rend de nouveau dans <vidéo>_reproduced/ |
| `--export-html` | Écrit une page HTML autonome (WebGL 2) à partir du shader et de ses passes au lieu d'une vidéo |
| `--cache-purge` | Vide le cache des maîtres sans perte (cache/ à côté du programme) |
| `--check[=liste]` | Contrôle qualité sans rendu : flash, nan, flicker, alias, portability (tout par défaut) ; code de sortie 6 si quelque chose est trouvé |
| `--compare a b` | Compare deux shaders (--compare-video=sbs\|curtain\|diff, --tolerance=N) ; code de sortie 7 s'ils diffèrent |
| `--golden=record\|verify` | Garde des images de référence d'un shader dans golden/ ou vérifie qu'elles n'ont pas changé (code de sortie 7 si elles changent) |
| `--dry-run` | Estime le temps de rendu (quelques secondes mesurées par fichier) sans écrire la vidéo |
| `--png=best` | Vignette intelligente : les trois images les plus riches de la plage, écrites en nom_thumb.png, nom_thumb2.png, nom_thumb3.png |
| `--cubefaces[=n]` | Les six faces (n x n pixels) d'une cubemap d'un shader mainVR : nom_px.png, _nx, _py, _ny, _pz, _nz |
| `--heatmap[=CxR]` | Carte du coût : le temps GPU de chaque zone de l'écran (16x9 par défaut) en nom_heat.png |
| `--samples=N` | Avec --png : moyenne de N échantillons indépendants du même instant (shaders à tracé de chemin) |
| `--find-loop[=s]` | Cherche la période du shader sur s secondes (sans rendu) et affiche le duration= / loop= à utiliser |
| `--sheet=CxL` | Une planche-contact PNG de C x L vignettes tirées à intervalles égaux sur la durée (--sheet=4x3) |
| `--param=nom=valeur` | Règle un paramètre du shader (// uniform) : --param=vitesse=2.5 ou des images clés --param="vitesse=smooth 0:1 ; 4:3" |
| `--watch=dossier` | Reste actif et rend chaque .glsl / .txt qui apparaît dans le dossier (Ctrl+C pour arrêter ; --watch-count=N arrête après N rendus) |
| `--watch-move` | Avec --watch : déplace chaque shader (et ses passes) vers done/ ou failed/ après son rendu ; un profile.ini dans le dossier ou un sous-dossier règle ses paramètres |
| `--log=fichier` | Écrit aussi tout ce qui est affiché, horodaté, dans ce fichier (ajout en fin de fichier) |
| `--report=json\|text` | Écrit un rapport de rendu (durée, cadence, goulot, taille, avertissements) à côté de chaque vidéo |
| `un fichier .json` | Export d'un shader Shadertoy (bouton Export de la page) : importé dans le dossier « shadertoy », puis rendu. Ni compte ni clé nécessaires |
| `--diagnostic` | Affiche système, carte graphique, OpenGL, ffmpeg et encodeurs (sans chemin ni donnée personnelle) pour un rapport de bug |
| `--benchmark` | Mesure les images par seconde par résolution et par encodeur (--seconds=N, --quick, --full, --json, --compare=file, --max-drop=N) |
| `--live` | Sortie en direct dans une fenêtre sans bordure sur un écran (--live-monitor=N, --live-monitors, --live-window[=LxH], --live-seconds=N, --live-fps=N, --live-record=fichier.mkv, --live-stream=srt://... ou rtmp://..., --live-bitrate=kb/s, --live-json) |
| `--license-info` | Affiche l'état de la licence et le fichier attendu à côté du programme |
| `--check-update[=url] [--download]` | Demande à GitHub la dernière version (seulement quand vous lancez cette commande) ; code de sortie 8 si une plus récente existe ; --download enregistre l'installeur dans updates/ après contrôle SHA-256, sans rien installer |

Codes de sortie : 0 tout est fait, 1 un rendu a échoué, 2 ligne de commande invalide, 3 pas d'OpenGL 3.3, 4 ffmpeg introuvable, 5 régression du benchmark, 6 --check a trouvé quelque chose, 7 --compare / --golden a trouvé une différence
