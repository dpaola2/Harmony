# CS3 Gameplan (Navigation + PlayerApp shape)

- Shape PlayerApp API: `handle_button(event) -> None`, `render()`, with injected `Screen` and `AudioBackend`.
- Navigation rules:
  - Library: UP/DOWN change `selected_index` (clamp, maybe wrap? decide), SELECT/RIGHT → Now Playing (set `current_screen=NOW_PLAYING`, sync selected to playing if needed), PLAY_PAUSE toggles playback for selected track.
  - Now Playing: LEFT/BACK → Library, PLAY_PAUSE toggles current track, LEFT/RIGHT could map to prev/next track (or defer), UP/DOWN maybe volume later.
  - Settings: BACK returns to previous (likely Library), SELECT navigates options (stub for now).
- Playback state: maintain `playing_index`, `is_playing`; `play_selected()` calls `audio_backend.play(track)` and updates state; `pause/resume()` map to backend methods; avoid auto-stop on screen transitions unless explicit.
- Rendering: `render()` calls `screen.clear()`, draws per-screen (text-only placeholders), then `screen.refresh()`.
- Edge cases: handle empty `tracks`, clamp `selected_index`, avoid index errors if list changes; decide clamp vs wrap at end of list.
- Minimal defaults: non-wrapping selection, BACK from Now Playing → Library, play/pause toggles only if `playing_index` set; else start playing selected. Add TODOs where behavior is pending.
