# Harmony player UI requirements
Date: 2026-09-28
Status: implemented for bench validation; hardware acceptance incomplete
Tracking: Complete Mark-6 player UI (HARMONY-18), under Harmony Mark-6: Bluetooth bench player (HARMONY-17)

Build the first usable interface around music browsing, playback, volume, and Bluetooth device management. The verified temporary bench can support UI development while carrier qualification continues.

Dave requested these features after confirming clean audio, the display, pause/resume, track selection, and previous/next controls. On September 27, Dave requested the full requirements for Mark-6. Implementation and remaining acceptance are tracked in HARMONY-18. Mark-7 preserves the desktop visual direction for future hardware; it does not defer this UI scope.

## September 28 handoff

Implementation carries into Build Mark-7 portable Bluetooth player (HARMONY-19). Hardware expansion of Mark-6 stops; the software requirements remain. Both native builds and host verifier suites pass. The [bench record](../hardware/mark-6/feather-complete-ui-bench-20260927/README.md) separates two uploaded builds from the later source checkpoint. Automatic remote-name lookup is built and tested but not flashed. An open device-detail subtitle may retain a copied MAC until reopened. Full menu, audible volume/mute, full-album and second-receiver acceptance remain incomplete.

## Existing requirements and implementation

The historical library plan specifies Artists → Albums → Tracks, metadata fallbacks, and ordered tracks. The Python simulator implements that hierarchy and a 0–100 volume state. Settings remains a placeholder.

The native ESP-IDF firmware now implements music browsing, volume, Bluetooth management, settings and device preferences. The first complete build is undergoing bench validation. Host checks establish behavior under mocks; receiver compatibility, physical controls and endurance need hardware evidence. The browser remains a separate simulated design reference.

Sources: [library plan](gameplans/CS5.5.md), [navigation plan](gameplans/NAV.md), [volume plan](gameplans/CS5.6.md), [Python app](../core/player_app.py), and [native player](../firmware/mark-6/feather-carrier/README.md).

## Required menu tree

```text
Music
  Artists → Artist → Albums → Album → Songs
  Albums → Album → Songs
  Songs
  Playlists → Playlist → Songs
Now Playing
Bluetooth
  Saved devices → Device → Connect / Disconnect / Forget
  Find devices → Device → Pair and connect
Settings
  Shuffle: Off / On
  Repeat: Off / All / One
  Display timeout
```

Artist, album, song and existing M3U playlist browsing are implemented for bench validation. Playlist editing and text search are deferred.

## Required controls

Directions refer to the front of the finished enclosure. Verify the physical mapping separately.

| Control | Lists and menus | Now Playing |
| --- | --- | --- |
| Wheel | Move the highlight | Adjust volume |
| Center | Open the item or play the song | Pause/resume |
| Top | Go back one level | Return to the previous browsing screen |
| Bottom | Pause/resume the current song | Pause/resume |
| Left/right | Previous/next song without losing the browsing position | Previous/next song |

At the root, Back does nothing. Returning to a list restores its highlight and scroll position. A selected row and a playing song have distinct indicators.

Selecting a song creates a queue from the visible album or playlist and starts at that song. Browsing does not change the queue. Playback continues while menus are open. With repeat off, playback stops at the queue end.

## Music and Now Playing

Show the title, artist, album, elapsed time, duration when known, play state, volume, and connected receiver. Long names must remain accessible. Provide readable character fallback until the font supports the library's characters.

Prefer track metadata. Use folder and filename information when metadata is missing. Keep albums with identical names under different artists distinct. Preserve disc and track order.

The first version may use the prepared 45-track library and its existing paths. Label that limit explicitly. A general library must not silently truncate at the bench's 64-track limit. Set a supported library size before implementing the full index.

Keep album art, seeking, gapless playback, and additional codecs outside the first release. The current audio format remains 44.1 kHz stereo MP3.

## Volume

Provide a visible 0–100 level, mute at zero, and gradual changes without clipping. Start the first UI test at the existing quiet level. Remember volume across normal restarts.

Local digital volume must work without receiver volume support. Receiver volume synchronization is a separate compatibility feature. Define the gain curve and startup ceiling before changing the current attenuation.

## Bluetooth

Show saved devices separately from discovery results. Display connection, pairing, disconnected, and failure states. Distinguish devices with duplicate names.

Pair only after the user selects a device. Support connection cancellation and timeout or pairing errors with recovery instructions. Keep one audio receiver connected at a time.

Disconnect retains the saved pairing. Forget requires confirmation and removes the local bond and reconnect preference. It cannot promise to clear the receiver's own pairing record.

Reconnect to the last selected saved receiver. Never switch to an arbitrary discovered device. Pause after an unexpected disconnect and require resume after reconnection. This required behavior replaces the bench's automatic playback continuation.

If discovery interrupts audio, pause deliberately and show that state. Do not conceal interference as playback glitches. Verify discovery behavior on hardware before promising uninterrupted playback during a scan.

## Reliability and acceptance

- Browse into an album, play a song, return to browsing, and recover the same list position.
- Change songs and volume without a reset, audible glitch, or callback underrun.
- Pair with a second receiver, switch receivers, disconnect, and forget a saved device.
- Restart and verify saved volume and device preferences. Restore the last selection in a paused state.
- Handle missing storage, an empty library, unsupported audio, and a failed connection with readable recovery actions.
- Test shuffle and repeat against the current queue.
- Run the deferred full-album test while using the finished menus.

Preferences belong in device storage; the music card stays read-only. Library scanning, Bluetooth events, rendering, and audio must not block one another.

## Implementation status, September 27

| Area | Implemented in native firmware | Acceptance remaining |
| --- | --- | --- |
| Music | Artists, Albums, Songs, M3U playlists; metadata/fallback; ordered album queues; 512-track explicit capacity | Check the trial card and broader metadata/library fixtures on device |
| Now Playing | Track metadata, elapsed/known duration, volume and live receiver name | Visual/listening confirmation with the complete build |
| Controls/rendering | Navigation/playback, cached lists, incremental highlight redraw and slow long-label scrolling | Responsiveness under final menu/scan load |
| Volume | 0–100 digital gain, mute, 10 ms ramp; default/startup ceiling 40 (-24.08 dB) | Audible sweep/mute and persisted restart on hardware |
| Bluetooth | Saved/found lists, explicit pairing, switching, disconnect, confirmed Forget, cancel/errors and paused last-selected reconnect | Actual discovery, second receiver, forgetting and drop/reconnect |
| Settings | Shuffle, repeat off/all/one, display timeout with wake-only first input | Physical behavior and restart persistence |
| Persistence/recovery | NVS preferences and last song; paused cold boot; storage/file/connection recovery messages | Power-cycle, missing-card and unreadable-file device checks |
| Endurance | Host regression/sanitizer checks and native builds | Full-album playback while using finished menus |

Current limits: Just Works and legacy PIN 1234 pairing; custom PIN/passkey input is not implemented. Restart restores the last song within its album, not elapsed position or the prior playlist queue. Unknown durations show elapsed only. Displayed metadata and library sizes are bounded; see the [bench README](../firmware/mark-6/feather-player-bench/README.md). The first input after display timeout wakes only. Settings save after roughly 2–4 quiet seconds. Missing-card recovery requires inserting the card and restarting.

Album art, seeking, gapless playback, text search, playlist editing and additional codecs remain outside this first UI release. The physical carrier and battery qualification have separate acceptance criteria.

## Development order

1. Prototype the menu layout and control behavior on the desktop.
2. Implement Artists → Albums → Songs and Now Playing on the verified Feather bench.
3. Add adjustable volume.
4. Add saved devices, discovery, pairing, disconnect, and forget.
5. Complete Songs/Playlists, metadata indexing and Now Playing details.
6. Add queue settings, display timeout, persistence and recovery, then complete endurance and reconnect tests.

Keep the current working firmware available for rollback. Carrier power, ribbon, enclosure, and RF qualification remain separate from UI acceptance.

