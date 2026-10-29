<!-- SPDX-License-Identifier: LicenseRef-ShaderToMP4-Proprietary - Copyright (C) 2026 Patrick JAILLET. Tous droits reserves. -->
<!-- Fichier produit par le programme : scripts\make-reference.ps1, ne pas modifier a la main. -->

# Project file format (.s2mproj)

A project is a JSON file written by the program (`ShaderToMP4 --dump-reference=project`). Paths inside the project folder are written relative to it, so the folder can be moved. Example, as the program writes it:

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

| Field | Type | Description |
|---|---|---|
| `format` | string | Always `ShaderToMP4 project`. |
| `version` | number | Format version; a newer file than the program is refused, an older one is migrated. |
| `name` | string | Name of the project. |
| `general` | string[] | The general settings, one `key=value` line each (the same lines as `config.ini`). |
| `shaders` | object[] | The shaders of the list, in rendering order. |
| `shaders[].path` | string | File of the shader (relative when it is inside the project folder). |
| `shaders[].batch` | number | Batch number from 1 to 4; absent: none. |
| `shaders[].priority` | number | `1` high, `-1` low; absent: normal. |
| `shaders[].settings` | string[] | Settings of this shader only ("This shader only"), `key=value` lines. |
| `shaders[].passes` | string[] | Pass files that exist (Buffer A to D, Common, ...). |
| `shaders[].media` | string[] | Images, sounds and videos of the channels `iChannel0` to `iChannel3`. |

Format version written and read by this program: 1.
