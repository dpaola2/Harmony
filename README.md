# Offline MP3 Player (Harmony2)

Hardware-agnostic MP3 player core with a PC simulator and ESP32 targets. See `docs/README.md` for the doc map; hardware bring-up for Prototype 1 is in `hardware/prototype1/README.md`.

## Architecture & Goals
- Core app logic in Python, shared by PC simulator and MicroPython on ESP32.
- iPod-style UI: Library → Now Playing → Settings with tactile buttons (no touch).
- Portable storage (SD) and Bluetooth audio on hardware targets; PC sim for fast iteration.
- More context: `PROJECT_OVERVIEW.md` (goals/constraints) and `PLAN.md` (roadmap).

## Development
- **Environment (macOS)**:
  - Install Homebrew if missing: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`.
  - Python: `brew install python` (or `pyenv` if you prefer pinned versions).
  - Recommended tooling: `pipx install uv` (or `pip install uv` in a venv); `pipx ensurepath`.
  - Create venv: `python -m venv .venv && source .venv/bin/activate`.
  - Install dev deps: `python -m pip install --upgrade pip uv pytest`.

- **Run PC simulator** (console UI):
  ```bash
  source .venv/bin/activate
  python -m platforms.pc.main_pc [--music-dir /path/to/Artist/Album/Track.ext]
  ```
  Controls: `w/s` up/down, `a` left, `d` right, `space`/Enter select, `p` play/pause, `b` or `q` back, `x` quit, `+`/`=` volume up, `-` volume down. Defaults to an in-memory demo library.

- **Tests**:
  ```bash
  source .venv/bin/activate
  pytest
  ```
  (Targets `core/` behavior.)

- **ESP32 Prototype 1 upload (demo UI, no buttons required)**:
  - See `hardware/prototype1/README.md` for wiring and flashing details.
  - Convenience script from repo root:
    ```bash
    scripts/upload_proto1_demo.sh /dev/tty.usbmodem*   # adjust port as needed
    ```
    It copies `core/`, `platforms/esp32/*.py`, and `main_esp32.py` to the board and keeps `main.py` as entrypoint.

## Repo structure
- `core/` hardware-agnostic logic and models
- `platforms/pc/` PC simulator (console screen, keyboard input, audio backend)
- `platforms/esp32/` ESP32 adapters (screen, buttons, audio)
- `hardware/` wiring/board notes (prototype phases)
- `enclosure/` mechanical notes
- `tests/` pytest cases for `core/`
