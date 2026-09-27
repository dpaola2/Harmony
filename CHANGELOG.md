# Changelog

Human-readable changes are recorded here alongside Git commits and linked WCP work items. This log starts September 27, 2026; earlier history remains in Git and the dated hardware evidence directories. No numbered firmware release has been declared.

## 2026-09-27

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

### Remaining

- Adjustable volume, real Bluetooth device management, Songs/Playlists and metadata indexing, settings, persistence, recovery and full-album/reconnect acceptance. See [requirements and status](docs/Harmony-player-ui-requirements.md).
- The native player still uses fixed -24 dB attenuation and the SoundCore 2 receiver. Bluetooth/Settings screens are placeholders. Browser behavior is simulated.
- Carrier power, assembly, battery and final enclosure/RF qualification are separate from this USB bench result.

## 2026-09-26 to 2026-09-27: retained preparation

- Prepared Mark-6 enclosure fit revision and carrier quote package (`91a0eab`, `86f4c52`).
- Recorded PCBWay carrier review submission (`2f87043`); submission is not a manufacturing purchase or release.
- Preserved Feather flash/memory diagnostics and successful bring-up evidence (`90f4b23` through `fe4ea27`).
