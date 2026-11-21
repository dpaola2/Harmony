# Music database for the native player

The Mac builds `HARMONY/library.hdb` from the Swinsian copy plan. The player loads navigation tables and reads individual records as needed. It does not open every MP3 at startup when this file is present. The October 9 library contains 7,743 MP3 files; the catalog is 4,190,628 bytes, with 265 artist groups and 638 album groups after display-text normalization.

The database supports up to 16,384 tracks. This explicit bound limits queue memory; it is not an unlimited library. The legacy folder scanner remains available for cards without `library.hdb` and retains its 512-track, 128-folder and 16-playlist limits. A present but invalid database produces a library error instead of falling back to a long scan. Database version 1 does not import Swinsian playlists.

Use [Harmony Sync](harmony-sync.md) for normal library updates. It inventories Swinsian, copies additions/changes and invokes the exporter below.

## Build and transfer

`python3 tools/build_music_index.py COPY_PLAN.json OUTPUT/library.hdb`

The plan's `tracks` array supplies `destination` (under `HARMONY/`), `title`, `artist`, `album`, `discnumber`, `tracknumber`, and `length` in seconds. The exporter includes only MP3 entries. Its input is the audited snapshot, so only copied tracks should be published in the final index. Swinsian remains unchanged.

Paths are UTF-8, relative to `HARMONY`, and limited to 191 bytes. The October 9 transfer assigns safe short paths to 156 entries whose names contain FAT-reserved characters, end in dots/spaces, or whose paths exceed that limit. Display metadata remains separate from filenames. Display text is normalized to ASCII for the current font and truncated to the existing field sizes; original metadata remains in the transfer report. Artist and album grouping uses these display strings, so names that normalize to the same value share a group.

Create the index locally, finish and verify the music copy, then install the index. Regenerate it when the library changes. It is not an automatic sync database: files added after export are not indexed, and missing files fail when selected. Checksums detect database corruption but do not establish that every indexed MP3 is present. The transfer separately verifies MP3 SHA-256 hashes.

## Runtime behavior

The catalog keeps artist/album ranges, title-sorted song IDs and path-sorted IDs in memory. Sixteen full track records are cached. Artist and album queries use precomputed ranges without record reads. Group names are loaded once into an immutable PSRAM cache, using 96 bytes per artist or album (86,688 bytes for the October 9 library). This optional cache is limited to 256 KiB; larger catalogs or allocation failure retain paged label reads. Song lists still page full records. Songs display in title order; album queues retain disc/track order. Last-track restoration uses a binary search of the path index. Each database read copies into caller-owned storage. A separate mutex protects the cache; SD access never holds the audio callback mutex.

The three audio queue arrays and one UI ID array live in PSRAM on the ESP32, with 65,536 bytes per array at the current bound. Full track metadata stays on the card. The legacy library allocation remains about 284 KB for compatibility; it does not grow with database size. Existing decoder, PCM and frame buffers remain additional memory users. Hardware boot time, browsing latency during Bluetooth audio, and peak memory still need measurement on the player.

Each full-record cache miss opens, seeks, reads and closes the catalog. There is no persistent database file handle to close before sleep. Filesystem failure or a corrupt record returns a read error; a track with unreadable metadata does not reach the decoder. A corrupt database header/table or incorrect file size prevents catalog loading.

## Version 1 file layout

All integers are unsigned little-endian. CRCs use standard CRC-32, compatible with Python `zlib.crc32`.

| Offset in 64-byte header | Value |
| --- | --- |
| 0 | Eight bytes `HARMDB01` |
| 8 | Version, currently 1 |
| 12, 16, 20 | Track, artist and album counts |
| 24 | Record size, 532 bytes |
| 28, 32, 36, 40, 44 | Offsets for artist, album, song-order, path-order and record tables |
| 48 | Exact file size |
| 52 | CRC-32 of all navigation tables |
| 56 | Reserved, zero |
| 60 | CRC-32 of header bytes 0–59 |

Artist rows are four 32-bit integers: first track, track count, first album, album count. Album rows contain first track and track count. Song-order and path-order tables each contain one 32-bit track ID per track. Records are ordered by artist, album, disc, track number and path. The song-order table sorts titles; the path-order table supports restoring a saved filename.

Each 532-byte record contains four NUL-terminated, padded fields: path (192 bytes), title (128), artist (96), album (96). They are followed by 16-bit disc and track numbers, 32-bit duration, artist ID and album ID, then a CRC-32 over the preceding 528 bytes. The reader checks termination, safe relative MP3 paths and group membership before using a record.

## Verification and limits

`python3 firmware/mark-6/feather-carrier/tests/verify_database.py` exercises 16,384 records, artist/album ranges, sorted songs, path lookup, concurrent cache reads, truncated/corrupt data, UI selection beyond track 512, full-library queues and paused album restoration. Existing library, UI, rendering and audio runtime regressions also pass. The native Mark-7 build passes. Dave confirmed playback with the full card, but reported audio interruptions while scrolling artists. The October 9 follow-up caches group labels and makes Mark-7 display work defer below half of the 128 KiB PCM buffer. Host tests confirm label/query access with the catalog unavailable and refill gating during a stalled producer, pause, reconnect and recovery. The audible result of this follow-up remains to be tested.

The current decoder accepts 44.1 kHz stereo MP3 only. The card retains other MP3 rates/channel layouts for volume testing; indexing them does not add decoder support. No source files are transcoded. See `hardware/mark-7/full-library-20261009/decoder-compatibility.json` for the Swinsian-metadata-based inventory.

## Mark-7 responsiveness trial, October 9

The display now runs at 16 MHz; SD remains at 4 MHz. Rendering and display sources use compiler optimization. Tiny display commands use polling, while pixel DMA remains interrupt driven. The display releases the bus between eight-row strips, checks audio refill needs, and abandons stale screen updates when new input is queued. Timing logs measure detected input to completed display transfers; physical polling delay and panel scanout are not included.

Dave reports a substantial responsiveness improvement. The 200 ms target is not met consistently: the final trial includes early 138–196 ms updates, later artist/album navigation around 237–485 ms, and uncached song-list opening up to 1,906 ms. The same capture records 1,024 audio underrun bytes. Song metadata caching remains deferred at Dave’s request. Evidence: `hardware/mark-7/responsiveness-20261009/verification.json`.
