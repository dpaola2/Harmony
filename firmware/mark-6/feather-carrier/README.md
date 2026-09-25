# Mark 6 Feather carrier firmware preparation

Prepared September 22, 2026 for HARMONY-17. This separate ESP-IDF project extends the native Mark 6 Bluetooth bench to carrier Rev A and the factory-headered Adafruit ESP32 Feather V2 #5900. The original WROVER project is preserved. Nothing in this project has been flashed or tested on physical hardware.

The intended Feather uses original ESP32 silicon with Bluetooth Classic, 8 MB flash and 2 MB PSRAM. The native target is `esp32`, with BR/EDR and A2DP enabled. This is an A2DP source sending decoded MP3 audio to SoundCore 2. It is not an ESP32-S3/C3 BLE-only build.

## What is prepared

- Read-only microSD on SPI3 at 4 MHz. The existing card-reset workaround, blocked sector writes, MP3 decoder, PSRAM buffer and quiet test volume are retained.
- Waveshare 29318 ST7796S display on SPI2 at 4 MHz, 320 × 480 portrait. It uses the retained Waveshare initialization sequence and the existing licensed bitmap font. Changed fields update every 250 ms; elapsed time changes once a second.
- ANO #6310 inputs on I2C at 100 kHz, with firmware-ID checks, 40 ms button debounce and encoder jump rejection.
- Ordered album playback, track browsing, pause/resume, previous/next and speaker reconnection. The display shows the current track, elapsed time, connection state and selected track.
- A display-only pattern option before SD, controls or Bluetooth initialization. Enable `CARRIER_DISPLAY_ONLY` for the first visual test.

## Album and controls

Place `ALBUM.M3U` inside the card's `HARMONY` directory. List relative MP3 paths in playback order, one per line:

```text
#EXTM3U
Human Clay/01 Are You Ready.mp3
Human Clay/02 What If.mp3
Human Clay/03 Beautiful.mp3
```

This is a format example, not a prepared album. Supply the corresponding files. The firmware accepts up to 64 tracks, UTF-8 filenames and M3U comments. Each path must fit within 191 bytes. Absolute paths, URLs, directory traversal, oversized entries and empty playlists are rejected. Titles come from filenames; the current font replaces non-ASCII characters with question marks. ID3 metadata and M3U duration hints are not displayed.

The decoder still requires **44.1 kHz stereo MP3**. A missing or unsupported track stops playback at that entry. It does not silently skip the track. Select another track to recover. If `ALBUM.M3U` is absent, the player uses the original `/sd/HARMONY/HIGHER.MP3` fixture. An invalid existing playlist does not trigger that fallback.

| Control | Action |
| --- | --- |
| Wheel or up/down | Browse tracks without interrupting playback |
| Center | Play the selected track; otherwise toggle play/pause |
| Left/right | Previous/next track, retaining the pause state |
| Center after album completion | Replay the selected track |

Selection clamps at both ends. The last track finishes without wrapping. Audio drains before advancing, but transitions are not guaranteed gapless. Volume remains at the bench's fixed -24 dB digital attenuation; use the speaker's volume control.

`CARRIER_ANO_ROTATION=1` provides a provisional clockwise quarter-turn mapping for the rotated board. Confirm all directions on the delivered assembly. `CARRIER_ENCODER_REVERSE` changes wheel direction if required. Disable `CARRIER_CONTROLS_ACTIONS` to inspect raw inputs without playback actions. Held startup keys do not generate a press; simultaneous button events are ignored.

A speaker disconnect stops PCM consumption and preserves the queue and pause state. Connection attempts retry after each ten-second heartbeat. The connection watchdog requests cancellation after three intervals. Successful reconnection resumes the queued audio when media starts. Audio already handed to the Bluetooth stack may be lost during a disconnect. Speaker-side pause and track commands are not implemented.

The old 400-second cutoff is removed. Album completion keeps the connection and controls available, sending silence until another selection starts. The read-only card remains mounted for replay. Fatal display failure or explicit player shutdown stops audio and unmounts storage.

## Playback implementation and limits

The producer owns SD reads and MP3 decoding. A 128 KiB PSRAM queue holds PCM; each track prefills half the queue unless EOF arrives first. A generation counter rejects decoded audio from a track skipped during an SD read. Queue operations and state changes share a mutex. No file I/O, decoding, logging or drawing occurs while that mutex is held.

The Bluetooth callback attempts the mutex without waiting. If busy, it returns silence and records `contention` bytes. `underrun` records missing PCM during active playback. Both counters must be checked during hardware qualification. Pause, disconnect and initial buffering intentionally produce silence without consuming queued music.

Host tests establish software behavior under mocks. They do not establish SD latency, Bluetooth timing, sound quality or RF performance. Dave's earlier clean Higher result applies to the WROVER bench. The full album and this new carrier remain untested on hardware.

The prior single-song carrier sources and verification record are preserved in `reference/single-song-carrier/`.

[Waveshare 29318 is selected](../../../hardware/mark-6/carrier-rev-a/display-sourcing.md) in place of the unavailable #5846. The firmware now uses the ST7796S controller. Its 18-pin connector preserves the carrier pin assignment. The previous HX8357 implementation and verification record are archived in `reference/hx8357-original-bench/`.

## Carrier map

These are ESP32 GPIO numbers, not header positions. `components/carrier_board/carrier_pins.h` is the firmware source of truth. The verifier traces all 13 signals through the carrier socket nets to MCU pins in Adafruit's Eagle schematic.

| Function | GPIO |
|---|---|
| SD SCK / MOSI / MISO / CS | 5 / 19 / 21 / 25 |
| Display SCK / MOSI / CS | 14 / 27 / 26 |
| Display DC / RST / LITE | 33 / 32 / 4 |
| ANO SCL / SDA | 20 / 22 |
| Peripheral power-good input | 34 |

GPIO20 is present on this PICO-based Feather V2 and is its SCL signal. The map is not applicable to the old WROVER wiring. GPIO12 and GPIO15 remain unused. Display MISO and touch are unused; storage is the dedicated carrier socket.

## Startup and commissioning

`CARRIER_EXPECTED_MAC` is empty by default. Application startup prints the Wi-Fi station MAC and returns before changing peripheral GPIO unless it exactly matches the configured identity. A later hardware session must identify the physical #5900 and record its MAC before commissioning. No replacement MAC has been assumed.

After identity and 8 MB flash / 2 MB PSRAM checks, startup requires ten consecutive high power-good samples, 5 ms apart, within a two-second timeout. Only then does it preload inactive chip selects, hold the backlight off and enable peripheral outputs. The display backlight comes on after its initialization and black clear complete. New display transactions and ANO reads reject a low power-good state.

These checks govern application sequencing. They cannot diagnose a short or replace the staged electrical measurements in the [power review](../../../hardware/mark-6/carrier-rev-a/power-review.md). Boot ROM/IDF activity happens before this application guard; SD transactions already in progress have no new power-loss interlock. The carrier's damaged predecessors remain unpowered.

## Build and verify

From this directory:

```sh
bash build.sh build
python3 tests/verify.py
```

The script uses the existing local ESP-IDF toolchain, pinned to commit `8c750b088c7cd857d079c0eeb495da199b359461`, and forces target `esp32`. It accepts build/configuration actions only and rejects `flash` and other hardware actions. The default build stays uncommissioned. `bash build.sh menuconfig` exposes the later test options.

`verification.json` records the binary size, hash and source hashes. Tests run with address and undefined-behavior sanitizers:

- Startup and display tests compile the actual implementations against GPIO/SPI mocks. They check identity, memory, power-good sequencing, display bounds and transport failures.
- Playback tests compare 100,000 randomized transfers with an independent reference stream. They also check EOF drain, stale generations, pause, disconnect, errors and album boundaries.
- The actual audio producer and callback run concurrently using pthread-backed RTOS mocks and synthetic decoder output. Tests require exact sample counts across three tracks.
- Bluetooth tests compile the actual state-handler bodies against event stubs. They check timeout, late connection, retry and shutdown-event ordering. They also simulate 60 heartbeats to check removal of the old cutoff.
- Playlist and input tests check malformed paths, capacity, debounce, held keys, rotation and counter wrap.

Independent checks trace all 13 GPIOs through carrier and vendor schematics. They also verify pinned references, Classic Bluetooth configuration, component selection and flash-command rejection. These tests do not simulate the LCD, seesaw firmware, Bluetooth stack or electrical behavior.

The isolated project supplies its own `bench_storage` and `bench_display`; only `bench_mp3` and `minimp3` are reused from the shared Mark 6 components. Retained Waveshare source, pinned Adafruit references and attribution are in `reference/`; the font's original license and source hashes are retained under `components/bench_display/`.

Related: [carrier review](../../../hardware/mark-6/carrier-rev-a/README.md), [fit prototype](../../../enclosure/mark-6/fit-prototype/README.md), and HARMONY-17.
