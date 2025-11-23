# [CS5.6] Volume Handling

- Add `volume` to `PlayerState` (0–100, default e.g., 50) and clamp adjustments.
- Extend `AudioBackend` with `set_volume(level: int)`; update stubs/PC backend.
- Handle volume events in `PlayerApp` (e.g., new button events for volume up/down) and update audio backend when changed.
- PC emulator: map additional keys for volume up/down; reflect in docs.
- Tests: cover volume clamping and backend calls when changing volume.
