# TASKS

- [x] [CS1] Scaffold repo structure (`core/`, `platforms/pc/`, `platforms/esp32/`, `hardware/`, `enclosure/`, `tests/`) with stub modules aligned to AGENTS conventions.
- [x] [CS2] Define core types and interfaces in `core/models.py` and `core/interfaces.py` (Track, PlayerState, ButtonEvent, screen identifiers; Screen/AudioBackend/InputSource APIs with type hints).
- [x] [CS3] Implement minimal `core/player_app.py` state machine for Library ↔ Now Playing ↔ Settings navigation and play/pause handling; remain hardware-agnostic.
- [x] [CS4] Add pytest coverage in `tests/` for selection movement, play/pause toggles, screen transitions, and end-of-list edge cases.
- [x] [CS5] Build PC simulator under `platforms/pc/` (console screen renderer, keyboard input mapper, stub/print-only audio backend, `main_pc.py` wiring).
- [ ] [CS6] Document hardware notes in `hardware/` (ESP32-WROVER choice, ST7789 display, rotary encoder plus aux buttons, SD storage; open questions on A2DP source support in MicroPython vs ESP-IDF shim).
- [ ] [CS7] Plan ESP32 adapters under `platforms/esp32/` (stubs for screen/buttons/audio with TODOs on drivers, buffering strategy, and any C-extension needs for Bluetooth audio).
- [ ] [CS8] Add a lightweight top-level pointer in `README`/`PROJECT_OVERVIEW` to the architecture plan and AGENTS rules so contributors follow separation-of-concerns and testing focus.

## CS3 Gameplan

- Shape PlayerApp API: `handle_button(event) -> None`, `render()`, with injected `Screen` and `AudioBackend`.
- Navigation rules:
  - Library: UP/DOWN change `selected_index` (clamp, maybe wrap? decide), SELECT/RIGHT → Now Playing (set `current_screen=NOW_PLAYING`, sync selected to playing if needed), PLAY_PAUSE toggles playback for selected track.
  - Now Playing: LEFT/BACK → Library, PLAY_PAUSE toggles current track, LEFT/RIGHT could map to prev/next track (or defer), UP/DOWN maybe volume later.
  - Settings: BACK returns to previous (likely Library), SELECT navigates options (stub for now).
- Playback state: maintain `playing_index`, `is_playing`; `play_selected()` calls `audio_backend.play(track)` and updates state; `pause/resume()` map to backend methods; avoid auto-stop on screen transitions unless explicit.
- Rendering: `render()` calls `screen.clear()`, draws per-screen (text-only placeholders), then `screen.refresh()`.
- Edge cases: handle empty `tracks`, clamp `selected_index`, avoid index errors if list changes; decide clamp vs wrap at end of list.
- Minimal defaults: non-wrapping selection, BACK from Now Playing → Library, play/pause toggles only if `playing_index` set; else start playing selected. Add TODOs where behavior is pending.

## CS5 Gameplan

- Console screen: implement a minimal `ConsoleScreen` that clears the terminal and renders text lines from `PlayerApp.render()`. Consider basic scrolling if the library exceeds terminal height (optional initial TODO).
- Keyboard input: map keys to `ButtonEvent` (e.g., w/s/a/d = up/down/left/right, space/enter = select, p = play/pause, b/q = back). Provide a non-blocking read loop if feasible; otherwise simple blocking input is acceptable for a first pass.
- Audio backend: stub/print-only backend that logs play/pause/resume/stop calls and the track title to stdout. Keep interface parity with `AudioBackend`.
- Main loop: `platforms/pc/main_pc.py` should create tracks (sample data), instantiate `PlayerApp` with console screen and audio backend, render initial screen, then loop reading keyboard events and passing them to `handle_button`.
- Quit handling: allow a key (e.g., `x`) to exit the simulator cleanly.
- Minimal dependencies: stick to stdlib (avoid curses to keep portability) unless you want richer UI; document any choice.
- Tracks/audio data: start with an in-memory dummy track list and print-only audio backend; no real MP3 playback or filesystem scanning in the initial simulator.

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
