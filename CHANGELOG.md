# Changelog

Human-readable changes are recorded here alongside Git commits and linked WCP work items. This log starts September 27, 2026; earlier history remains in Git and the dated hardware evidence directories. No numbered firmware release has been declared.

## 2026-09-28

- Adopted [Mark-7 portable scope](docs/mark-7-portable-scope.md), tracked by Build Mark-7 portable Bluetooth player (HARMONY-19). Reuse the Feather, LCD/SD, ANO controls and one battery; use secured perfboard wiring. Internal SD access is sufficient. Speaker and DAC are excluded.
- Recorded inventory, adapter/heat-shrink purchase, charger compatibility questions, power control and measured-runtime requirements. No battery connection, charging or Mark-7 print occurred.
- Added asynchronous Bluetooth remote-name lookup for existing bonds. Fourteen policy scenarios pass. The final source checkpoint builds for bench and carrier; all four host verifier suites pass without native compiler warnings.
- Preserved [uploaded-versus-built evidence](hardware/mark-6/feather-complete-ui-bench-20260927/README.md), rollback details and a separately hashed unflashed checkpoint binary. The latest name change is not yet on the device. Open device-detail subtitle refresh and physical acceptance remain.

## 2026-09-27

### Complete UI implementation (HARMONY-18)

- Added real native volume control with mute and a short gain ramp, shuffle, repeat, display timeout and device-stored preferences. Startup and reconnect remain paused; initial volume is capped at the prior quiet level.
- Replaced Bluetooth placeholders with saved devices, discovery, explicit pairing, switching, cancel/errors, disconnect and confirmed Forget. Reconnect targets only the last selected receiver.
- Added Songs and M3U playlists, read-only metadata indexing with explicit 512-track capacity, disc/track ordering and known duration extraction.
- Added missing/empty storage and track-error recovery, long-label scrolling, and cached list indices to avoid repeated sorting during drawing.
- Added sanitized host coverage for audio modes/gain, Bluetooth event policy, library bounds/malformed tags, menu actions and wake-only input. Both native targets build without compiler warnings. Physical validation is tracked separately in the [complete UI bench record](hardware/mark-6/feather-complete-ui-bench-20260927/).
- Preserved the previously accepted firmware for rollback. Custom Bluetooth PIN entry, full-album endurance and second-receiver compatibility remain open.

### Added

- Interactive desktop UI with the 45-track trial library, music tree, Now Playing, wheel interaction and simulated Bluetooth management (`1a3990b`, HARMONY-17).
- Native Feather music tree, album-scoped playback queues, restored browsing position, physical playback controls and cream-and-green Now Playing (`b433aff`, HARMONY-17).
- Native renderer with proportional fonts, cached frames, incremental highlight redraw and bounded LCD transfers. Host checks cover navigation, queue behavior, rendering equivalence and transfer cleanup (`b433aff`).
- Full Mark-6 UI scope and remaining acceptance tracked as Complete Mark-6 player UI (HARMONY-18).
- Mark-7 visual reference preserved at tag `mark7-visual-reference-20260927` (`1a3990b`), including Dave's capacitive wheel and battery design direction.

### Fixed and verified

- Corrected mirrored LCD orientation; Dave confirmed normal text and color order (`c3c6179`).
- Verified rotary/button input and SD playlist playback on the shared LCD bus (`183a690` through `c3c471b`).
- Fixed Bluetooth playback contention silence; Dave confirmed clean audio and correct display (`3215421`, `13d4de0`).
- Fixed missed center selection by raising input scheduling priority and avoiding unnecessary screen redraws. Corrected bench capture recorded 12 accepted center presses and zero audio underrun/contention bytes; Dave reports “much better!” (`b433aff`).
- Native UI validation: existing carrier checks, UI/render/audio queue tests with ASan/UBSan, board/display checks, two native builds without compiler warnings, and verified application flash checksum. See [bench evidence](hardware/mark-6/feather-ui-bench-20260927/).

### Earlier first-UI limits (superseded by complete implementation above)

- Adjustable volume, real Bluetooth device management, Songs/Playlists and metadata indexing, settings, persistence, recovery and full-album/reconnect acceptance. See [requirements and status](docs/Harmony-player-ui-requirements.md).
- The native player still uses fixed -24 dB attenuation and the SoundCore 2 receiver. Bluetooth/Settings screens are placeholders. Browser behavior is simulated.
- Carrier power, assembly, battery and final enclosure/RF qualification are separate from this USB bench result.

## 2026-09-26 to 2026-09-27: retained preparation

- Prepared Mark-6 enclosure fit revision and carrier quote package (`91a0eab`, `86f4c52`).
- Recorded PCBWay carrier review submission (`2f87043`); submission is not a manufacturing purchase or release.
- Preserved Feather flash/memory diagnostics and successful bring-up evidence (`90f4b23` through `fe4ea27`).
