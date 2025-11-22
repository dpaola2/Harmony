# TASKS

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

## Navigation Spec (iPod-style hierarchical)

- Root menu (level 0): items `Library`, `Now Playing`, `Settings`.
  - `UP/DOWN`: move highlight among root items.
  - `RIGHT/SELECT`: enter highlighted item.
  - `LEFT/BACK`: no-op at root.
- Library (entered from root):
  - View: list of tracks with a cursor.
  - `UP/DOWN`: move selection (clamped).
  - `RIGHT/SELECT`: start playback of selected track (stop any current), set playing index, auto-jump to Now Playing.
  - `PLAY/PAUSE`: toggle play/pause for the selected track without leaving Library (starting playback if none).
  - `LEFT/BACK`: go up one level to Root (Library remains highlighted there).
- Now Playing (entered from root or via Library auto-jump):
  - View: current track/status; if nothing playing, placeholder.
  - `PLAY/PAUSE`: toggle playback.
  - `LEFT/BACK`: go up one level to Root (Now Playing remains highlighted there).
  - `UP/DOWN/RIGHT/SELECT`: no additional behavior for now.
- Settings (entered from root):
  - View: stub/options (to be defined).
  - `LEFT/BACK`: go up one level to Root (Settings remains highlighted there).
  - `UP/DOWN/RIGHT/SELECT`: TBD (no behavior yet).

## CS5.5 Spec: Library Drilldown and Track Loading

- Models: extend `Track` with `album`, `artist`, `track_number`. `id` remains stable path/UUID.
- Library view: replace flat Library with drilldown:
  - Library root shows list of artists.
  - Selecting an artist shows that artist’s albums.
  - Selecting an album shows tracks (sorted by track number, then title).
  - Selecting a track starts playback (stop current, set playing index, auto-jump to Now Playing).
  - Back/left moves up one level (album → artist → Library root).
- Indexing: introduce a `Library` helper to hold tracks and derived mappings (artist → track indices, (artist, album) → track indices).
- Missing metadata: allow empty/None artist/album; normalize to fallback labels (e.g., "Unknown Artist", "Unknown Album") for grouping so tracks remain reachable. Sort tracks by `track_number` when present, else by title.
- Core remains storage-agnostic: platform code supplies a populated `Library`/track list; core only consumes normalized data and indexes.
- PC loader: optional helper to scan a directory and build `Track` objects (ID3 parsing optional/stub) for the simulator, without baking storage logic into core.
- Edge cases to handle in core/tests:
  - Empty library: render gracefully without crashes at any level.
  - Duplicate album names across artists: key albums by (artist, album) to avoid collisions.
  - Missing track numbers: sort numbered tracks first, then unnumbered by title for stability.
  - Long names: consider truncation/ellipsis in console renderer to avoid wrapping glitches.
  - Unknown buckets: grouping under fallback labels is expected; ensure consistent behavior.
  - Now Playing with no current track: placeholder view; play/pause should no-op safely.
  - Root back/left: remains a no-op.

## CS5.6 Spec: Volume Handling

- Add `volume` to `PlayerState` (0–100, default e.g., 50) and clamp adjustments.
- Extend `AudioBackend` with `set_volume(level: int)`; update stubs/PC backend.
- Handle volume events in `PlayerApp` (e.g., new button events for volume up/down) and update audio backend when changed.
- PC emulator: map additional keys for volume up/down; reflect in docs.
- Tests: cover volume clamping and backend calls when changing volume.
