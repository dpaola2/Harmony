# Harmony player UI requirements
Date: 2026-09-27
Status: accepted Mark-6 scope; implementation incomplete
Tracking: Complete Mark-6 player UI (HARMONY-18), under Harmony Mark-6: Bluetooth bench player (HARMONY-17)

Build the first usable interface around music browsing, playback, volume, and Bluetooth device management. The verified temporary bench can support UI development while carrier qualification continues.

Dave requested these features after confirming clean audio, the display, pause/resume, track selection, and previous/next controls. On September 27, Dave requested the full requirements for Mark-6. The remaining implementation is tracked in HARMONY-18. Mark-7 preserves the desktop visual direction for future hardware; it does not defer this UI scope.

## Existing requirements and implementation

The historical library plan specifies Artists → Albums → Tracks, metadata fallbacks, and ordered tracks. The Python simulator implements that hierarchy and a 0–100 volume state. Settings remains a placeholder.

The current native ESP-IDF firmware implements artist/album/song navigation, album queues, selection restoration, playback controls and Now Playing. It uses folder/filename metadata and a playlist capped at 64 tracks, fixed -24 dB attenuation, and one configured receiver. Bluetooth and Settings remain explanatory placeholders. The browser prototype simulates additional features; those are not proof of device implementation.

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

Artist browsing is the first implementation. Albums, Songs, and existing M3U playlists follow. Playlist editing and text search are deferred.

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

| Area | On the Feather | Remaining for Mark-6 |
| --- | --- | --- |
| Music | Artists, Albums, album songs and album playback queues | All Songs, M3U playlists, metadata-first index, disc/track order, long-name access and an explicit library capacity beyond 64 entries |
| Now Playing | Title, artist, album, elapsed time and trial-library duration/progress | Adjustable volume, live receiver information and duration discovery for general files |
| Controls/rendering | Wheel navigation, center select, back, pause and skip; incremental highlight redraw | Continue responsiveness checks as all menus are added |
| Volume | Fixed quiet -24 dB attenuation | 0–100 digital gain, mute, startup ceiling and persistence |
| Bluetooth | SoundCore 2 bench connection | Saved/discovered lists, explicit pairing, cancel/errors, switching, disconnect, confirmed Forget and paused reconnect |
| Settings | Placeholder | Shuffle, repeat off/all/one and display timeout |
| Persistence/recovery | Bench startup automatically plays | Saved preferences/selection, paused cold boot, usable storage/file/connection recovery |
| Acceptance | Dave reports corrected UI is “much better”; short bench capture has zero underrun/contention bytes | Second receiver, restart/reconnect and full-album use with finished menus |

Album art, seeking, gapless playback, text search, playlist editing and additional codecs remain outside this first UI release. The physical carrier and battery qualification have separate acceptance criteria.

## Development order

1. Prototype the menu layout and control behavior on the desktop.
2. Implement Artists → Albums → Songs and Now Playing on the verified Feather bench.
3. Add adjustable volume.
4. Add saved devices, discovery, pairing, disconnect, and forget.
5. Complete Songs/Playlists, metadata indexing and Now Playing details.
6. Add queue settings, display timeout, persistence and recovery, then complete endurance and reconnect tests.

Keep the current working firmware available for rollback. Carrier power, ribbon, enclosure, and RF qualification remain separate from UI acceptance.

