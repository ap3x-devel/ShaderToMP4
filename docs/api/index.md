<!-- Copyright (C) 2026 Patrick JAILLET - Local API reference -->

**English** · [Français](index.fr.md)

# ShaderToMP4 local API

`ShaderToMP4 --serve[=port]` starts an HTTP / JSON API on `127.0.0.1` (default port 8765). It is **off unless asked** and stops with `POST /api/v1/shutdown`. The shape of every answer is described in [schema.json](schema.json).

## Access

The program writes a 64-character token in `serve.token` next to the program (and the port in `serve.json`); both files are removed when the server stops. Every request needs:

```
Authorization: Bearer <token>
Host: 127.0.0.1:8765        (or localhost)
```

| Case | Answer |
|---|---|
| No token, wrong token | `401` |
| `Host` other than `127.0.0.1` / `localhost`, or an `Origin` header (a web page) | `403` |
| Unknown address, unknown job | `404` |
| Method not allowed on that address | `405` |
| Body not JSON, unknown setting, bad path | `400` (`{"error": "..."}`) |
| Body over 1 MB | `413` |
| Too many jobs waiting, deleting a running job | `409` |

The server never listens on another address of the machine and closes a connection whose remote address is not `127.0.0.1`.

## Endpoints

All under `/api/v1`. Bodies and answers are JSON (UTF-8).

| Request | What it does |
|---|---|
| `GET /status` | `{"program","version","api":1,"state":"idle"|"busy","queued","running","jobs"}` |
| `GET /settings` | every setting of the settings table, as text |
| `PUT /settings` | `{"width": 1280, "fps": 30}`: changes the general settings (strings, numbers or booleans); an unknown key gives `400` and changes nothing |
| `POST /jobs` | `{"path": "C:/shaders/plasma.glsl", "settings": {"duration": 5, "outdir": "C:/videos"}}`: adds a shader (`.glsl`, `.txt`, `.frag`, `.hlsl`, `.wgsl`) to the queue and starts it; the job takes the general settings then its own; answer `201` with the job |
| `GET /jobs` | `{"jobs": [...]}` |
| `GET /jobs/{id}` | the job: `id`, `path`, `state` (`queued`, `running`, `done`, `failed`, `cancelled`), `progress` (`frame`, `total`, `fps`, `remaining_s`), `error`, `outputs`, `log` (the last 60 lines) |
| `GET /jobs/{id}/outputs` | `{"outputs": ["C:/videos/plasma.mp4"]}` |
| `POST /jobs/{id}/cancel` | stops the job (or removes it from the queue) |
| `DELETE /jobs/{id}` | forgets a finished job |
| `POST /shutdown` | stops the server |

Jobs run one after the other, in order.

## Example

```powershell
$token = (Get-Content serve.token).Trim()
$h = @{ Authorization = "Bearer $token" }
$job = Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8765/api/v1/jobs -Headers $h -ContentType application/json `
  -Body '{"path":"C:/shaders/plasma.glsl","settings":{"duration":5,"outdir":"C:/videos"}}'
Invoke-RestMethod -Uri "http://127.0.0.1:8765/api/v1/jobs/$($job.id)" -Headers $h
```

Complete clients that follow the progress: `examples/automation/render.ps1` (PowerShell) and `examples/automation/render.py` (Python, standard library only). The self-test runs both against a real server.

## Other machine-readable outputs

`--progress=json` prints one JSON object per line (`start`, `log`, `progress`, `done`, `error`, `end`), `--report=json` writes `name.report.json` next to each video, and `--diagnostic` prints `key: value` text lines. Their shapes are in [schema.json](schema.json) (definitions `progressEvent` and `renderReport`).

## Exit codes

`0` everything rendered; `1` a render failed (also `--serve` on a port in use); `2` invalid command line; `3` no OpenGL 3.3; `4` ffmpeg not found; `5` benchmark slower than before; `6` `--check` warning; `7` `--compare` / `--golden=verify` / `--verify` difference; `8` newer version available; `9` `--portability` corrections exist.
