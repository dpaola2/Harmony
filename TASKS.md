# TASKS

- [x] [CS1] Scaffold repo structure (`core/`, `platforms/pc/`, `platforms/esp32/`, `hardware/`, `enclosure/`, `tests/`) with stub modules aligned to AGENTS conventions.
- [x] [CS2] Define core types and interfaces in `core/models.py` and `core/interfaces.py` (Track, PlayerState, ButtonEvent, screen identifiers; Screen/AudioBackend/InputSource APIs with type hints).
- [ ] [CS3] Implement minimal `core/player_app.py` state machine for Library ↔ Now Playing ↔ Settings navigation and play/pause handling; remain hardware-agnostic.
- [ ] [CS4] Add pytest coverage in `tests/` for selection movement, play/pause toggles, screen transitions, and end-of-list edge cases.
- [ ] [CS5] Build PC simulator under `platforms/pc/` (console screen renderer, keyboard input mapper, stub/print-only audio backend, `main_pc.py` wiring).
- [ ] [CS6] Document hardware notes in `hardware/` (ESP32-WROVER choice, ST7789 display, rotary encoder plus aux buttons, SD storage; open questions on A2DP source support in MicroPython vs ESP-IDF shim).
- [ ] [CS7] Plan ESP32 adapters under `platforms/esp32/` (stubs for screen/buttons/audio with TODOs on drivers, buffering strategy, and any C-extension needs for Bluetooth audio).
- [ ] [CS8] Add a lightweight top-level pointer in `README`/`PROJECT_OVERVIEW` to the architecture plan and AGENTS rules so contributors follow separation-of-concerns and testing focus.
