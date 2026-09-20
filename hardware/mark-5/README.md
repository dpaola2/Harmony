# Mark-5 album player

The current assembly plays one album described by `album.json` on the microSD
card. The Mac extracts tags with ffprobe and copies MP3s without transcoding.
The player reads the manifest once, orders tracks by disc and track number,
and streams each file from the card. It does not scan the Swinsian library or
maintain a database. The complete wiring and test history are in `bench-config.json`.

## Prepare an album

With the WROVER unplugged, move the card to the Mac's reader. From the repository:

```sh
python3 tools/prepare_mark5_album.py "/path/to/Artist/Album" "/Volumes/MIYOO/HARMONY/ALBUM"
```

The tool requires tagged MP3s and ffprobe. It copies files using disc/track
filenames, verifies SHA256, and writes the manifest. A conflicting existing file
causes an error; existing card contents are preserved. Eject the card before
returning it to the unpowered VS1053, then connect USB.

`HARMONY/HUMANCLAY/album.json` currently describes 12 tracks, including the bonus
track “Young Grow Old,” totaling approximately 61 minutes. The host copy is
`albums/human-clay.json`. The earlier `HARMONY/HIGHER.MP3` is also retained.

## Run from the Mac

Use Python with pyserial installed:

```sh
python3 tools/run_mark5.py --manifest /sd/HARMONY/HUMANCLAY/album.json --seconds 4500
```

On Dave's Mac, the working Python is
`/Users/dave/.espressif/python_env/idf5.3_py3.13_env/bin/python`.
Pinned SD/display/font sources and their licenses are in
`platforms/esp32/mark5_vendor/`; the loader no longer depends on temporary clones.

The loader checks the WROVER's unique ID before changing GPIOs. The player starts
silent at Ready, volume 58. Play/pause controls playback; Next/Previous wrap
through the album and preserve a paused state. Track endings advance
automatically. The last track ends the album without repeating it. This bench
runner exits after album completion or its time limit; reload it for another
session. No automatic boot script is installed.

The screen shows the title, artist/album, position, elapsed/total time and volume.
Startup checks the manifest and every file's size. Completed tracks must match
their expected SHA256. The card is mounted read-only during playback. The log
records completed tracks, button events, decoder time and free heap. A deliberate
skip does not count as a completed or checksum-verified track. Resetting the
decoder between tracks may introduce a short gap; gapless playback is not promised.

## Verification

```sh
.venv/bin/python -m pytest -q tests
python3 tools/run_mark5.py --transition-test
```

The transition test requires the three short excerpts and manifest already
prepared under `HARMONY/TESTALBM`. It starts automatically at mute, verifies all
three complete files and decoder progress, and checks automatic advancement and
the final stopped state. It passed on September 19. It does not replace a full
album run. Faint SD-related clicks remain accepted for this prototype.
