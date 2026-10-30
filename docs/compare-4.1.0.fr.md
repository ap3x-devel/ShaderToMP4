<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->

**Français** · [English](compare-4.1.0.md)

# ShaderToMP4 4.1.0 contre 3.0.0 : compatibilité et performances

Mesuré le 2026-10-29 sur le PC du mainteneur (Windows 11, graphisme Intel UHD, pas de carte NVIDIA), avec la 3.0.0 publiée construite depuis son étiquette et la 4.1.0 de ce dépôt, toutes deux **sans fichier de licence** (la 4.1.0 dessine donc son filigrane d'essai, qui fait partie de son coût). Rien n'a été réglé entre les mesures ; les chiffres décrivent cette machine seulement, voir [hardware.fr.md](hardware.fr.md) pour la façon de les lire.

## Compatibilité Shadertoy

Le corpus est formé des 113 shaders autovérifiés de `tests/compat` (styles WebGL 1 et GLSL ES, macros anciennes, redéclarations d'uniformes, noms de fonctions de texture, fonctions de pack, erreurs voulues). Chacun est rendu en 64x48 avec `--render` ; 104 doivent se rendre, 9 doivent être refusés avec un message.

| Version | Shaders rendus | Parmi les 104 attendus |
|---|---|---|
| 3.0.0 | 91 | 91 |
| 4.1.0 | 104 | **104** |

Tous les shaders que la 3.0.0 rendait se rendent encore, et 13 de plus se rendent. Le travail de compatibilité après la 3.0.0 (lecture WebGL 1 / GLSL ES, fonctions de pack, noms des fonctions de texture) vise justement ce genre de shader ; la cause de chacun des 13 n'a pas été recherchée.

## Performances

`--benchmark --full --seconds=2`, trois passes de chaque version l'une après l'autre, médiane des trois, images par seconde (plus haut = mieux).

| Cas | 3.0.0 | 4.1.0 | Écart |
|---|---|---|---|
| 1280x720, x264 sur le processeur | 224,7 | 202,5 | -9,9 % |
| 1920x1080, x264 sur le processeur | 99,2 | 103,9 | +4,7 % |
| 1920x1080, Intel Quick Sync | 106,5 | 106,4 | -0,1 % |
| 3840x2160, x264 sur le processeur | 29,8 | 29,5 | -1,0 % |
| 1920x1080, Intel Quick Sync (second cas) | 102,2 | 105,3 | +3,0 % |
| 1920x1080, en parties (chunks) | 143,4 | 130,7 | -8,9 % |
| 1920x1080, avec un canal vidéo | 92,9 | 90,0 | -3,1 % |

La baisse la plus forte est de 9,9 %, sous la limite de 15 % fixée pour cette version. Le cas 720p varie de plusieurs pour cent d'une passe à l'autre sur cette machine.

## Démarrage et mémoire

| Mesure | 3.0.0 | 4.1.0 |
|---|---|---|
| `--version` (du lancement à la sortie), trois passes | 165, 92, 95 ms | 94, 97, 96 ms |
| Pic mémoire d'un rendu 1080p de 3 s, trois passes | 119, 120, 119 Mo | 121, 118, 118 Mo |

## Pour refaire les mesures

```
ShaderToMP4 --benchmark --full --seconds=2 --json
ShaderToMP4 --selftest-compat
```
