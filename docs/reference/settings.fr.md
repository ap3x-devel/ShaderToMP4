<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->
<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->

# Référence des réglages

Écrit par le programme lui-même (`ShaderToMP4 --dump-reference=settings`) : toutes les clés que `config.ini` peut contenir, avec leur valeur par défaut. Une clé s'écrit dans `config.ini`, dans un commentaire `// clé=valeur` d'un shader et sur la ligne de commande sous la forme `--clé=valeur`.

| Clé | Défaut | Description |
|---|---|---|
| `width` | `1920` | largeur de l'image en pixels, 16 à 16384 (arrondie à un nombre pair) |
| `height` | `1080` | hauteur de l'image en pixels, 16 à 16384 (arrondie à un nombre pair) |
| `fps` | `60` | images par seconde, 1 à 240 |
| `duration` | `90` | secondes (90 = une boucle complète de ce shader) |
| `start` | `0` | temps de départ (iTime) en secondes |
| `crf` | `12` | qualité : 0 = sans perte, 12 = quasi parfait, 18 = très bon |
| `preset` | `slow` | ultrafast ... medium ... slow ... veryslow (plus lent = fichier plus petit) |
| `codec` | `h264` | h264, h265, vp9 ou av1 |
| `container` | `mp4` | mp4, mov, mkv ou webm |
| `ss` | `1` | lissage (supersampling) : 1 = aucun, 2 = x2, 3 = x3, 4 = x4 |
| `outdir` | *vide* | dossier de sortie (vide = à côté du shader) |
| `bitrate` | `0` | kb/s ; 0 = qualité constante (crf) |
| `color` | `bt709` | bt709, bt709full (pleine plage), srgb ou bt601 |
| `blur` | `1` | flou de mouvement : sous-images par image (1 = aucun, 4, 8, 16) |
| `shutter` | `0.5` | obturateur du flou, en fraction d'une image (0.5 = 180 degrés) |
| `loop` | `0` | période du shader en secondes : la durée devient un multiple entier (0 = libre) |
| `audio` | *vide* | fichier son mixé dans la vidéo, aligné sur l'instant de début (vide = aucun) |
| `fadein` | `0` | fondu d'entrée en secondes (image et son) |
| `fadeout` | `0` | fondu de sortie en secondes |
| `encoder` | `cpu` | cpu, auto, nvenc, amf ou qsv (encodage matériel si disponible) |
| `pbo` | `3` | profondeur de la file de lecture GPU (2 à 8) |
| `depth` | `8` | 8 ou 10 (bits par canal ; 10 pour H.265, AV1, VP9, ProRes, PNG/TIFF en 16 bits) |
| `name` | *vide* | modèle du nom de sortie : {shader} {w} {h} {fps} {date} {codec} |
| `exists` | `overwrite` | si la sortie existe déjà : overwrite (écraser), number (numéroter) ou skip (ignorer) |
| `gpu` | `default` | carte graphique sur un PC à deux GPU (Linux) : default, high (la puissante) ou low (l'intégrée) ; demande un redémarrage |
| `endaction` | `none` | après un lot réussi : none, folder (montrer le dernier fichier) ou sleep (veille) |
| `chunk` | `30` | rendu par parties de N secondes, reprenable après interruption (0 = jamais) |
| `warmup` | `0` | chauffe : images simulées avant la première (les tampons sont chauffés, iFrame démarre à N), 0 = aucune |
| `vr` | `auto` | shader mainVR : auto (quand il n'y a pas de mainImage), off, mono ou stereo (360° équirectangulaire, stereo = œil gauche en haut) |
| `vripd` | `0.064` | distance entre les deux yeux du rendu VR stéréo, en unités du shader (0.064 par défaut) |
| `metadata` | `1` | 1 = écrire titre et commentaire dans le fichier vidéo, 0 = aucun |
| `loopmode` | *écrite seulement quand elle n'a plus sa valeur par défaut* | boucle sans couture : none \| crossfade \| pingpong |
| `loopfade` | *écrite seulement quand elle n'a plus sa valeur par défaut* | durée du fondu de la boucle en secondes |
| `timemap` | *écrite seulement quand elle n'a plus sa valeur par défaut* | courbe de temps `vidéo:shader` en secondes, par exemple `0:0;4:1;8:5` (vide = temps réel) |
| `speed` | *écrite seulement quand elle n'a plus sa valeur par défaut* | vitesse du temps du shader (0.25 = quatre fois plus lent) |
| `audiofollow` | *écrite seulement quand elle n'a plus sa valeur par défaut* | le son suit la vitesse constante (tempo, hauteur conservée) |
| `iChannel0` | *écrite seulement quand elle n'a plus sa valeur par défaut* | texture de iChannel0-3 : chemin d'image, noise ou grid (+ .filter nearest\|linear\|mipmap, .wrap clamp\|repeat, .vflip 0\|1) |
| `bufferA` | *écrite seulement quand elle n'a plus sa valeur par défaut* | taille des Buffer A à D : `bufferA.scale` (fraction de la taille du rendu) ou `bufferA.size` (pixels `LxH`) |
| `date` | *écrite seulement quand elle n'a plus sa valeur par défaut* | iDate fixe : AAAA-MM-JJ ou AAAA-MM-JJTHH:MM:SS (rendu reproductible), ajouter +rate=R pour R secondes de date par seconde de vidéo (1 par défaut, 0 = figée) |
| `variant` | *écrite seulement quand elle n'a plus sa valeur par défaut* | rendu supplémentaire du même shader : nom:clé=valeur\|clé=valeur (ex. 720p:width=1280\|height=720\|crf=23) ; une ligne par variante |
| `report` | *écrite seulement quand elle n'a plus sa valeur par défaut* | rapport de rendu à côté de la vidéo : json ou text (off = aucun) |
| `samples` | *écrite seulement quand elle n'a plus sa valeur par défaut* | image fixe : échantillons moyennés (1 = un seul) |
| `precheck` | *écrite seulement quand elle n'a plus sa valeur par défaut* | contrôle qualité avant chaque rendu vidéo (flashs, valeurs invalides) |
| `target` | *écrite seulement quand elle n'a plus sa valeur par défaut* | destination de publication : youtube-shorts, tiktok, instagram-reel, discord, x, ... (voir presets/targets.ini), règle taille, durée, codec et poids |
| `targetsize` | *écrite seulement quand elle n'a plus sa valeur par défaut* | poids cible du fichier, par ex. 8MB ou 25MB : le débit est calculé et corrigé jusqu'à ce que le fichier tienne (h264, h265, vp9, av1) |
| `crop` | *écrite seulement quand elle n'a plus sa valeur par défaut* | recadrage après rendu : L:H, L:H:X:Y ou un rapport comme 9:16 (centré) ; le shader est rendu en entier |
| `mastercache` | *écrite seulement quand elle n'a plus sa valeur par défaut* | 1 = garde un maître sans perte dans cache/ et en tire chaque format sans refaire le rendu |
| `cachemax` | *écrite seulement quand elle n'a plus sa valeur par défaut* | taille maximale de cache/ en Go (les maîtres les plus anciens partent en premier) |
| `embed` | *écrite seulement quand elle n'a plus sa valeur par défaut* | 1 = embarque le shader, ses passes et les réglages dans la balise de la vidéo pour que --reproduce puisse la refaire |
| `animpreview` | *écrite seulement quand elle n'a plus sa valeur par défaut* | aperçu animé de la vidéo terminée : off, gif ou webp (une courte boucle à côté de la vidéo) |
| `source` | *écrite seulement quand elle n'a plus sa valeur par défaut* | mode effet : une vidéo, une image, une séquence (`img_%04d.png`) ou un dossier, lus comme `iChannel0` ; taille, cadence, durée et son la suivent |
| `source2` | *écrite seulement quand elle n'a plus sa valeur par défaut* | deuxième source, `iChannel1` : avec un shader qui lit `iProgress`, une transition de `source` vers `source2` |
| `sourcematch` | *écrite seulement quand elle n'a plus sa valeur par défaut* | ce que la source impose quand `source` est réglé : size, fps, duration (une liste) ou none |
| `sourceaudio` | *écrite seulement quand elle n'a plus sa valeur par défaut* | 1 = reprendre le son de la source (défaut), 0 = garder le réglage audio |
| `reverse` | *écrite seulement quand elle n'a plus sa valeur par défaut* | 1 = jouer la plage de temps à l'envers |
| `sourcefps` | *écrite seulement quand elle n'a plus sa valeur par défaut* | cadence d'une séquence d'images utilisée comme source, en images par seconde (0 = 25) |
| `transitionduration` | *écrite seulement quand elle n'a plus sa valeur par défaut* | durée de la transition entre source et source2, en secondes |
| `transitionoffset` | *écrite seulement quand elle n'a plus sa valeur par défaut* | décale le début de la transition, en secondes (positif = plus tard) |
| `parallel` | *écrite seulement quand elle n'a plus sa valeur par défaut* | parties rendues en même temps par autant de contextes OpenGL (1 à 16 ; demande chunk, le rendu par parties) |
| `farm` | *écrite seulement quand elle n'a plus sa valeur par défaut* | dossier partagé d'une ferme de rendu : plusieurs ordinateurs rendent les parties d'une même vidéo (demande `chunk`) |
| `farmtimeout` | *écrite seulement quand elle n'a plus sa valeur par défaut* | secondes sans signe de vie après lesquelles le verrou d'une partie de la ferme est repris (ordinateur éteint) |
| `bpm` | *écrite seulement quand elle n'a plus sa valeur par défaut* | tempo imposé à l'analyse du son, en temps par minute (0 ou absent = détecté) |
| `beatsperbar` | *écrite seulement quand elle n'a plus sa valeur par défaut* | temps par mesure (2 à 12), pour les mesures et les sections |
| `markers` | *écrite seulement quand elle n'a plus sa valeur par défaut* | repères tirés du rythme du son : off, chapters (sections en chapitres du fichier), file (fichiers de repères) ou all |
| `beatsync` | *écrite seulement quand elle n'a plus sa valeur par défaut* | montage : coupes posées sur la musique : off, beat (temps), bar (mesures) ou section |
| `autocredit` | *écrite seulement quand elle n'a plus sa valeur par défaut* | 1 = écrit le titre et l'auteur du shader sur les premières secondes de la vidéo |
| `stillformat` | *écrite seulement quand elle n'a plus sa valeur par défaut* | format de l'image fixe : png \| tiff (16 bits par canal avec depth=10) |
| `aov` | *écrite seulement quand elle n'a plus sa valeur par défaut* | passes de sortie écrites dans une séquence EXR : nom=bufferB.r;normal=bufferC.rgb;alpha;motion (`off` efface) |
| `exrcompression` | *écrite seulement quand elle n'a plus sa valeur par défaut* | compression EXR : none, zips (une ligne par bloc) ou zip (seize lignes, défaut) |
| `exrprecision` | *écrite seulement quand elle n'a plus sa valeur par défaut* | précision de la couleur EXR : half (16 bits, défaut) ou float (32 bits) ; la profondeur et les identifiants sont toujours en 32 bits |
| `alphamode` | *écrite seulement quand elle n'a plus sa valeur par défaut* | alpha écrit dans les PNG, TIFF, DPX et EXR : straight (droit, défaut) ou premult (couleur multipliée par l'alpha) |
| `depthrange` | *écrite seulement quand elle n'a plus sa valeur par défaut* | bornes de la profondeur proche:loin : le canal depth.Z est écrit normalisé entre elles et les bornes sont déclarées dans l'en-tête EXR (vide : valeurs brutes) |
| `tifffloat` | *écrite seulement quand elle n'a plus sa valeur par défaut* | 1 = séquences TIFF écrites par le programme en virgule flottante 32 bits (RGB ou RGBA) |
| `vectorblur` | *écrite seulement quand elle n'a plus sa valeur par défaut* | flou de mouvement vectoriel de la sortie EXR : part du déplacement entre deux images (0 = aucun, 1 = tout) ; demande une passe de mouvement |
| `tile` | *écrite seulement quand elle n'a plus sa valeur par défaut* | image fixe : côté des tuiles en pixels (0 = automatique) |
| `printdpi` | *écrite seulement quand elle n'a plus sa valeur par défaut* | image fixe PNG : résolution écrite dans le fichier (points par pouce) |
| `alpha` | *écrite seulement quand elle n'a plus sa valeur par défaut* | `1` garde le canal alpha du shader (ProRes 4444, VP9 WebM, WebP, PNG, TIFF, EXR) |
| `hdr` | *écrite seulement quand elle n'a plus sa valeur par défaut* | sortie HDR : `pq` (HDR10) ou `hlg` ; `off` pour aucune |
| `hdrpeak` | *écrite seulement quand elle n'a plus sa valeur par défaut* | MaxCLL déclaré en cd/m² (1000 par défaut) |
| `hdrfall` | *écrite seulement quand elle n'a plus sa valeur par défaut* | MaxFALL déclaré en cd/m² (400 par défaut) |
| `hdrwhite` | *écrite seulement quand elle n'a plus sa valeur par défaut* | luminance en cd/m² d'un blanc de shader à 1,0 (203 par défaut) |
| `interp` | *écrite seulement quand elle n'a plus sa valeur par défaut* | cadence de sortie par interpolation (0 = aucune) ; le rendu se fait à `fps` |
| `scale` | *écrite seulement quand elle n'a plus sa valeur par défaut* | taille de sortie : `1920x1080`, un facteur (`2`, `0.5x`) ; vide = la taille du rendu |
| `scalefilter` | *écrite seulement quand elle n'a plus sa valeur par défaut* | filtre de mise à l'échelle : `lanczos`, `bicubic`, `bilinear`, `area` ou `neighbor` |
| `loudnorm` | *écrite seulement quand elle n'a plus sa valeur par défaut* | normalisation du son en LUFS, par exemple `-16` (0 ou `off` = aucune) |
| `title` | *écrite seulement quand elle n'a plus sa valeur par défaut* | texte dessiné au milieu de l'image pendant les premières secondes |
| `credit` | *écrite seulement quand elle n'a plus sa valeur par défaut* | texte dessiné en bas à gauche pendant les premières secondes |
| `titledur` | *écrite seulement quand elle n'a plus sa valeur par défaut* | durée en secondes de `title` et `credit` (3 par défaut) |
| `post` | *écrite seulement quand elle n'a plus sa valeur par défaut* | effets de post-traitement, par ex. bloom:0.4,grain,vignette (sharpen chroma bloom contrast saturation hue vignette grain ; quantité après les deux-points) |
| `lut` | *écrite seulement quand elle n'a plus sa valeur par défaut* | LUT couleur au format .cube appliquée après les effets (1D ou 3D, chemin relatif au shader) |

L'édition Pro ajoute ses propres clés (scène 3D, signaux et données, couleur et qualité, habillage et diffusion, performance) : elles sont listées dans la fenêtre des réglages Pro, un champ par clé.
