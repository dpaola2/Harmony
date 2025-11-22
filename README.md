# Offline MP3 Player (Harmony2)

Hardware-agnostic MP3 player core with PC simulator and ESP32 target scaffolding. See `AGENTS.md`, `PROJECT_OVERVIEW.md`, and `PLAN.md` for context.

## Environment (macOS)

- Install Homebrew if missing: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`.
- Python: `brew install python` (or `pyenv` if you prefer pinned versions).
- Recommended tooling:
  - `pipx install uv` for fast, isolated installs (or `pip install uv` inside a venv).
  - `pipx install pipx` if you don’t have it yet.
  - `pipx ensurepath` to expose pipx-installed tools.
- Create a virtual environment: `python -m venv .venv && source .venv/bin/activate`.
- Install dev deps (placeholder until requirements are defined): `python -m pip install --upgrade pip uv pytest`.

## Running (PC simulator)

Once the PC simulator is implemented (from repo root):

```bash
source .venv/bin/activate
python -m platforms.pc.main_pc
```

Initial simulator will use an in-memory dummy track list and a print-only audio backend; no real MP3 playback or filesystem scanning yet. You can optionally point it at a local music folder with `--music-dir /path/to/files` (simple filename parsing only).

- Keyboard controls: `w/s` up/down, `a` left, `d` right, `space`/Enter select, `p` play/pause, `b` or `q` back, `x` quit.
- Dependencies: stdlib only (no extra packages needed for the console simulator).

Navigation model (simulator/core):
- Root menu: Library / Now Playing / Settings. `up/down` to highlight, `right/select` to enter, `left/back` no-op at root.
- Library drilldown: Artists → Albums → Tracks. `right/select` drills in, `left/back` goes up. Selecting a track starts playback and auto-jumps to Now Playing; play/pause on a track toggles without leaving Library.

## Testing

Pytest will target the `core/` logic. After real tests are added:

```bash
source .venv/bin/activate
pytest
```

## Repo structure

- `core/` hardware-agnostic logic and models
- `platforms/pc/` PC simulator (console screen, keyboard input, audio stub)
- `platforms/esp32/` ESP32 adapters (screen, buttons, audio)
- `hardware/` wiring/board notes
- `enclosure/` mechanical notes
- `tests/` pytest cases for `core/`
