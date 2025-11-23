# [PA-UI] Prototype 1 Display UI Plan (ST7789V2)

- Screens to implement on-device: Root menu (Library/Now Playing/Settings), Library drilldown (artist → album → tracks), Now Playing (track metadata + play state + volume), and a placeholder Settings; mirror current core state machine and PC console behaviors.
- Layout approach: simple text UI with highlighted row; reserve top status line for playback state/icon + volume, body for list items with scroll window, footer hint for buttons (e.g., Back/Play-Pause). Use ellipsis/truncation for long labels; keep 6–8 visible rows. Add safe insets (e.g., 4–6 px) to avoid the ST7789’s rounded corners.
- Rendering strategy: double-buffer-ish redraw by clearing only changed regions per tick; minimal font and monochrome-style colors for clarity (e.g., black background, white text, accent highlight bar).
- Input mapping: wire existing button events (up/down/left/right/select/back/play_pause/volume) from GPIO to `PlayerApp.handle_button`; no new core events needed.
- Data flow: platform screen adapter pulls `PlayerState` and current view data from `PlayerApp` render helpers (similar to console screen), notifies on state changes, and formats strings; keep any string formatting inside platform layer to avoid core coupling to fonts/pixels.
- Performance/refresh: poll loop ~20–30 Hz, debounce inputs in platform layer, and throttle full-screen clears; keep SPI at existing display-test speed unless ghosting/flicker requires tuning.
