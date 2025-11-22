This file contains a historical archive of previous game plans, task lists, etc.

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