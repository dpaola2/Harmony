# Harmony Sync

Harmony Sync is the Mac companion to the player. Swinsian remains the library manager. The Python tool reads its database, copies MP3 additions and changes to the SD card, and builds the player's browsing database. It does not modify Swinsian, format cards, transcode music, or remove old music files from the card.

Run from the Harmony2 repository with Python 3.10 or newer. It uses only the standard library and macOS `diskutil`.

```bash
# Read-only inventory, including MP3 count and required space.
python3 tools/harmony_sync.py inspect

# Update an already formatted FAT32 card.
python3 tools/harmony_sync.py sync --volume /Volumes/HARMONY

# Also verify the contents of every unchanged track on the card.
python3 tools/harmony_sync.py sync --volume /Volumes/HARMONY --verify
```

The default source is `~/Library/Application Support/Swinsian/Library.sqlite`. To use another library, put `--library-db PATH` and, if needed, `--music-root PATH` before `inspect` or `sync`. A card already managed for a different Swinsian library is rejected. No graphical interface or automatic device detection is implemented yet.

## Normal use

Add or edit music in Swinsian, insert the card in the Mac, run the sync command, and eject the card before removal. The Mac publishes the new catalog only after all selected music copies succeed. New and changed copies are checked with SHA-256. A quick sync trusts the saved hash when source path, size and modification time match and the destination size still matches. Use `--verify` when you want every unchanged destination hashed too.

If a file was changed outside Harmony Sync, a verified sync stops with a conflict instead of silently replacing it. A failed transfer can be rerun: identical existing copies are verified and adopted. The old catalog remains until the copy phase succeeds. The catalog and manifest are separately replaced files, not a transactional filesystem; an interruption between those writes can require re-verification on the next run.

Tracks removed from Swinsian disappear from the next catalog but remain on the card. There is no deletion option yet. Missing MP3 source files and skipped formats are listed in the report. The first October 9 inventory has no missing MP3s; the 11 missing Swinsian entries are M4A and are skipped with the other non-MP3 files.

## Files on the card

- `HARMONY/`: copied music, normally retaining artist/album folders. Names that cannot safely fit the card/player path rules use stable `_safe/TRACK_ID.mp3` names. The displayed metadata comes from the database.
- `HARMONY/library.hdb`: read-only player catalog, including artist/album groups and sorted song/path indexes.
- `.harmony-sync.json`: ownership and source-file fingerprints used for incremental syncs.
- `harmony-sync-report.json`: latest copy/reuse counts, missing sources and skipped formats.

The player ignores the sync manifest and report. It uses only the music files and `library.hdb`. The [database documentation](music-database.md) describes its format and firmware support.

## Current limits

The database supports 16,384 songs. Swinsian playlists are not exported yet. The display font still uses ASCII, and long display fields are truncated; original metadata remains in the sync manifest. Every MP3 is copied, but the existing decoder only accepts 44.1 kHz stereo MP3. Indexing other rates/channel layouts does not make them playable.

The October 9 native firmware build and host tests pass. Full-card startup time, memory headroom, browsing during Bluetooth playback and sleep/wake still need a hardware test with the prepared card. The new image has been flashed to the verified spare Feather.

## Tests

```bash
python3 -m unittest discover -s tests/tools -p 'test_harmony_sync.py' -v
python3 firmware/mark-6/feather-carrier/tests/verify_database.py
```

The sync tests use temporary libraries/cards. They cover initial and incremental copies, metadata-only changes, changed audio, removed entries, skipped/missing sources, conflicts, same-size corruption, adopting existing copies, preservation of the previous catalog after failure, and path/library isolation.
