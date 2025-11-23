# TASKS

> Doc map: see `docs/README.md` for where to place plans, tasks, and platform notes.

- [x] [CS1] Scaffold repo structure (`core/`, `platforms/pc/`, `platforms/esp32/`, `hardware/`, `enclosure/`, `tests/`) with stub modules aligned to AGENTS conventions.
- [x] [CS2] Define core types and interfaces in `core/models.py` and `core/interfaces.py` (Track, PlayerState, ButtonEvent, screen identifiers; Screen/AudioBackend/InputSource APIs with type hints).
- [x] [CS3] Implement minimal `core/player_app.py` state machine for Library ↔ Now Playing ↔ Settings navigation and play/pause handling; remain hardware-agnostic.
- [x] [CS4] Add pytest coverage in `tests/` for selection movement, play/pause toggles, screen transitions, and end-of-list edge cases.
- [x] [CS5] Build PC simulator under `platforms/pc/` (console screen renderer, keyboard input mapper, stub/print-only audio backend, `main_pc.py` wiring).
- [x] [CS5.1] Add library drilldown (Artists → Albums → Tracks) support and a PC loader that can build Track data from a directory (keeping core storage-agnostic).
- [x] [CS5.6] Add volume to `PlayerState` with clamped adjustments, integrate volume controls in core, map PC emulator keys, and cover with tests.
- [ ] [PA1] Prototype 1 wiring plan: ESP32-S3 DevKitC-1 v1.1, SD SPI breakout, ST7789V2 (240x280), basic buttons (no rotary/battery); pin map + wiring notes.
- [ ] [PA2] Prototype 1 BOM: parts for the breadboard build (S3 dev kit, SD breakout, ST7789V2, buttons, jumpers, breadboard).
- [ ] [PA3] ESP32 adapters plan: outline `platforms/esp32` stubs (screen/buttons/audio) and note A2DP/source support approach.
- [ ] [PB1] Prototype 2 / Production plan: WROVER DevKitC (PSRAM, classic BT), rotary encoder, full button set, battery/power (LiPo + TP4056), optional I2S DAC/amp, enclosure mounting notes.

## Prototype 1 Plan (ESP32-S3 DevKitC-1 v1.1)

- Wiring diagram: map SPI for SD breakout (MOSI/MISO/SCK/CS) and ST7789V2 (MOSI/SCK/CS/DC/RES/BL) on the S3 DevKitC-1 v1.1; assign GPIOs for buttons (up/down/left/right/select/back/play-pause/volume +/-); USB power only.
- SD filesystem: FAT32 with folder convention `Artist/Album/Track.ext` at root; align loader with PC behavior.
- MicroPython implementation:
  - `platforms/esp32` stubs for ST7789V2 screen, GPIO button input, SD-based track loader using the folder convention.
  - Main script: mount SD, build track list, instantiate `PlayerApp`, poll inputs → handle_button, render to ST7789; no audio backend on S3 WROOM.
  - Volume: support button-based volume up/down; stub `set_volume` in audio backend to keep state consistent.
- Notes: No A2DP/audio in this phase; focus on UI, storage, and input. Port pin map and code to Prototype 2 (WROVER) for audio once hardware arrives.

## Gameplans (moved to docs/gameplans)

- Navigation spec: `docs/gameplans/NAV.md`
- CS5.5 Library drilldown: `docs/gameplans/CS5.5.md`
- CS5.6 Volume handling: `docs/gameplans/CS5.6.md`
- Prototype 1 display UI plan: `docs/gameplans/PA-UI.md`
- Prototype 1 UI refresh plan: `docs/gameplans/PA-UI-Refresh.md`
