# [PA-UI-Refresh] Prototype 1 UI Refresh Plan

- Goals: keep monospace for a retro tech look, increase font size for readability, use highlight bars instead of `>` markers, and polish spacing/colors; show a simple loading screen for ~5s on first boot.
- Visual tweaks: bump font scale (larger bitmap font or doubled glyphs), use a contrasting highlight bar for the selected row, maintain safe insets for rounded corners, refine spacing (line height, margins).
- Colors/themes: light or dark background with consistent accent color; ensure volume/status lines remain legible.
- Loading screen: on startup, render a static logo/title card with a brief delay before entering the main loop.
- Data flow: reuse existing `PlayerApp` navigation; UI polish lives in the ESP32 screen renderer (no core data structure changes expected). If font scaling requires a custom glyph blitter, keep it in `EspScreen`.
