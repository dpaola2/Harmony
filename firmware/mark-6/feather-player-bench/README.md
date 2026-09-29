# Feather player UI bench

The native ESP-IDF player runs on the temporary Adafruit ESP32 Feather V2 harness with the ST7796S LCD, its SD slot and ANO controls. The carrier hardware remains separately unqualified.

## Music and controls

Music offers Artists, Albums, Songs and Playlists. Select a song to start its displayed album, all-song list or playlist at that song. Back restores the prior highlight and scroll position. Browsing leaves the playback queue unchanged. Album identities include the artist. Long labels scroll after a short pause.

| Control | Menus | Now Playing |
| --- | --- | --- |
| Wheel | Move selection | Change volume 0–100 |
| Center | Open/select | Pause/resume |
| Top / MENU | Back | Return to browsing |
| Bottom | Pause/resume | Pause/resume |
| Left / right | Previous/next in queue | Previous/next in queue |

Volume 40 equals the earlier -24.08 dB bench gain; 0 is mute and 100 is unity digital gain. Changes ramp over 10 ms. Saved volume above 40 is capped to 40 at startup. Receiver volume remains independent. Startup and reconnect stay paused.

Settings offers shuffle, repeat Off/All/One and display timeout Always on/30/60/120 seconds. The first input after timeout wakes the screen without executing its normal action. Device NVS stores settings and the last playing song after roughly 2–4 seconds without changes. On restart, the song is restored in its album queue, paused; elapsed position and a custom playlist queue are not restored.

## Bluetooth

Saved devices shows local bonds. Find devices searches for receivers in pairing mode and pauses playback. Select a result, then Pair / connect. Device details also offers Disconnect and a confirmed Forget action. Names are shown alongside addresses so duplicate names are distinct. Forget removes this player's bond and applicable reconnect preference; the speaker may retain its own pairing record.

The selected receiver is remembered for later restarts. An unexpected drop pauses playback and attempts the last selected receiver; resuming requires Play. Cancel stops a pending scan or connection. Only one receiver is active. The limits are eight saved and sixteen discovered devices, with visible limit/error messages.

Current pairing supports normal Bluetooth Just Works and the retained legacy PIN 1234. Custom PIN/passkey entry is not implemented; receivers that require it report a failure. RF behavior and receiver compatibility require physical checks beyond host policy tests.

## Library and recovery

The card stays read-only. The player indexes MP3 files under `/HARMONY`, up to 512 songs, sixteen M3U/M3U8 playlists, 512 entries per playlist, 128 directories and eight directory levels. It reports an error instead of presenting a truncated library. Paths are limited to 191 bytes; displayed metadata fields are bounded (127-byte titles, 95-byte artist/album names). M3U paths must stay beneath HARMONY and resolve relative to their playlist directory.

ID3v2.3/v2.4 and ID3v1 supply title/artist/album/disc/track data; folders and filenames provide fallbacks. Albums sort by disc and track. Known TLEN/Xing/VBRI durations or exact trial-fixture durations show progress; other files show elapsed time. Characters outside the current font use readable fallback. Audio remains 44.1 kHz stereo MP3.

Missing/empty storage and invalid libraries leave menus available with restart guidance. Unsupported or unreadable tracks show a skip/select-another recovery message. Hot card insertion/rescan is not supported: insert the card and restart.

## Build and verification

Run from the repository root:

```sh
bash firmware/mark-6/feather-player-bench/build.sh build
python3 firmware/mark-6/feather-carrier/tests/verify.py
python3 firmware/mark-6/feather-carrier/tests/verify_player_ui.py
python3 firmware/mark-6/feather-carrier/tests/verify_audio_features.py
python3 firmware/mark-6/feather-carrier/tests/verify_library.py
```

The UI verifier also compiles `tests/test_player_bluetooth.c` with ASan/UBSan. [The full UI bench evidence](../../../hardware/mark-6/feather-complete-ui-bench-20260927/) records build hashes, flash and actual checks separately from remaining acceptance.

The display uses antialiased Montserrat glyphs and two PSRAM framebuffers. Cached views and list indices avoid repeated work. Eight-row DMA transfers release the shared LCD/SD bus between writes. Controls have higher priority than drawing; Bluetooth and preference writes use separate tasks.

The accepted pre-completion firmware is backed up at `/Users/dave/Downloads/harmony-mark6-backups/pre-complete-ui-20260927/` (source b433aff). This target reuses carrier sources through an isolated board/storage adapter. The production carrier retains its power-good guard.

Related: [requirements](../../../docs/Harmony-player-ui-requirements.md), [changelog](../../../CHANGELOG.md), Complete Mark-6 player UI (HARMONY-18), under Harmony Mark-6: Bluetooth bench player (HARMONY-17).
