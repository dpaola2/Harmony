# CS5 Gameplan (PC simulator bring-up)

- Console screen: implement a minimal `ConsoleScreen` that clears the terminal and renders text lines from `PlayerApp.render()`. Consider basic scrolling if the library exceeds terminal height (optional initial TODO).
- Keyboard input: map keys to `ButtonEvent` (e.g., w/s/a/d = up/down/left/right, space/enter = select, p = play/pause, b/q = back). Provide a non-blocking read loop if feasible; otherwise simple blocking input is acceptable for a first pass.
- Audio backend: stub/print-only backend that logs play/pause/resume/stop calls and the track title to stdout. Keep interface parity with `AudioBackend`.
- Main loop: `platforms/pc/main_pc.py` should create tracks (sample data), instantiate `PlayerApp` with console screen and audio backend, render initial screen, then loop reading keyboard events and passing them to `handle_button`.
- Quit handling: allow a key (e.g., `x`) to exit the simulator cleanly.
- Minimal dependencies: stick to stdlib (avoid curses to keep portability) unless you want richer UI; document any choice.
- Tracks/audio data: start with an in-memory dummy track list and print-only audio backend; no real MP3 playback or filesystem scanning in the initial simulator.
