# Harmony UI prototype

Run from the repository root:

```sh
python3 -m platforms.pc.ui_server
```

Open http://127.0.0.1:8766. The server binds to this computer only. Stop it with Ctrl-C.

Scroll over the player or drag around the wheel to move the highlight. Click the center to select. MENU goes back. The bottom button pauses or resumes. Left and right skip songs. On Now Playing, the wheel adjusts volume.

Keyboard controls: Up/Down scroll, Enter selects, Escape goes back, Space pauses, and Left/Right skip. Rows are also clickable.

The fixture contains the 45 trial tracks' titles, paths, and durations. It contains no audio or private source paths. Playback time and Bluetooth outcomes are simulated. The device firmware is unchanged.

Artist, album, song, and playlist browsing work. The model retains the playback queue while browsing. Bluetooth supports simulated pairing, switching, disconnecting, and confirmed forgetting. Repeat works; shuffle and display timeout are marked deferred. Preferences reset when the server restarts.

The hardware-independent model is in `core/ui_prototype.py`. The HTTP adapter lives in `platforms/pc/ui_server.py`. The existing console simulator is preserved.

Validation: 43 Python tests passed, including 13 prototype behavior tests. Browser checks covered artist/album/song navigation, returning to the selected song, pause, volume, and simulated pairing/forgetting. The compact layout was visually inspected.

Related: [UI requirements](../../../docs/Harmony-player-ui-requirements.md), Harmony Mark-6: Bluetooth bench player (HARMONY-17).
