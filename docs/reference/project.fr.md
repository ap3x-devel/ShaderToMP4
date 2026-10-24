<!-- SPDX-License-Identifier: GPL-3.0-or-later - Copyright (C) 2026 Patrick JAILLET -->
<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->

# Format du fichier projet (.s2mproj)

Un projet est un fichier JSON écrit par le programme (`ShaderToMP4 --dump-reference=project`). Les chemins situés dans le dossier du projet y sont relatifs : le dossier peut être déplacé. Exemple, tel que le programme l'écrit :

```json
{
  "format": "ShaderToMP4 project",
  "version": 1,
  "name": "example",
  "general": [
    "width=1920",
    "fps=30"
  ],
  "shaders": [
    {
      "path": "clip.glsl",
      "batch": 1,
      "priority": 1,
      "settings": [
        "fps=60"
      ],
      "passes": [
        "clip.bufferA.glsl"
      ],
      "media": [
        "texture.png"
      ]
    }
  ]
}
```

| Champ | Type | Description |
|---|---|---|
| `format` | string | Toujours `ShaderToMP4 project`. |
| `version` | number | Version du format ; un fichier plus récent que le programme est refusé, un plus ancien est migré. |
| `name` | string | Nom du projet. |
| `general` | string[] | Les réglages généraux, une ligne `clé=valeur` chacun (les mêmes lignes que `config.ini`). |
| `shaders` | object[] | Les shaders de la liste, dans l'ordre de rendu. |
| `shaders[].path` | string | Fichier du shader (relatif quand il est dans le dossier du projet). |
| `shaders[].batch` | number | Numéro de lot de 1 à 4 ; absent : aucun. |
| `shaders[].priority` | number | `1` haute, `-1` basse ; absent : normale. |
| `shaders[].settings` | string[] | Réglages de ce shader seulement (« Ce shader seul »), lignes `clé=valeur`. |
| `shaders[].passes` | string[] | Fichiers des passes qui existent (Buffer A à D, Common, ...). |
| `shaders[].media` | string[] | Images, sons et vidéos des canaux `iChannel0` à `iChannel3`. |

Version du format écrite et lue par ce programme : 1.
