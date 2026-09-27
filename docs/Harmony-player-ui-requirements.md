# Harmony player UI requirements
Date: 2026-09-27
Status: draft for discussion
Tracking: Harmony Mark-6: Bluetooth bench player (HARMONY-17)

Build the first usable interface around music browsing, playback, volume, and Bluetooth device management. The verified temporary bench can support UI development while carrier qualification continues.

Dave requested these features after confirming clean audio, the display, pause/resume, track selection, and previous/next controls. The detailed behavior below is proposed, except where identified as existing.

## Existing requirements and implementation

The historical library plan specifies Artists → Albums → Tracks, metadata fallbacks, and ordered tracks. The Python simulator implements that hierarchy and a 0–100 volume state. Settings remains a placeholder.

The current native ESP-IDF firmware has a flat playlist capped at 64 tracks, filename titles, fixed -24 dB attenuation, and one configured receiver. It does not use the Python UI. Bluetooth device browsing and unpairing need new requirements and implementation.

Sources: [library plan](gameplans/CS5.5.md), [navigation plan](gameplans/NAV.md), [volume plan](gameplans/CS5.6.md), [Python app](../core/player_app.py), and [native player](../firmware/mark-6/feather-carrier/README.md).

## Proposed menu tree

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

## Proposed controls

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

Reconnect to the last selected saved receiver. Never switch to an arbitrary discovered device. Pause after an unexpected disconnect and require resume after reconnection. This proposed behavior replaces the bench's automatic playback continuation.

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

## Development order

1. Prototype the menu layout and control behavior on the desktop.
2. Implement Artists → Albums → Songs and Now Playing on the verified Feather bench.
3. Add adjustable volume.
4. Add saved devices, discovery, pairing, disconnect, and forget.
5. Add queue settings and persistence, then complete endurance and reconnect tests.

Keep the current working firmware available for rollback. Carrier power, ribbon, enclosure, and RF qualification remain separate from UI acceptance.

