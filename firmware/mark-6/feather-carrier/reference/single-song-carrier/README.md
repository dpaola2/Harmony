# Mark 6 Feather carrier firmware preparation

Prepared September 22, 2026 for HARMONY-17. This separate ESP-IDF project adapts the native Mark 6 single-song Bluetooth bench to carrier Rev A and the factory-headered Adafruit ESP32 Feather V2 #5900. The original WROVER project is preserved. Nothing in this project has been flashed or tested on physical hardware.

The intended Feather uses original ESP32 silicon with Bluetooth Classic, 8 MB flash and 2 MB PSRAM. The native target is `esp32`, with BR/EDR and A2DP enabled. This is an A2DP source sending decoded MP3 audio to SoundCore 2. It is not an ESP32-S3/C3 BLE-only build.

## What is prepared

- Read-only microSD on SPI3 at 4 MHz. The existing card-reset workaround, blocked sector writes, MP3 decoder, PSRAM buffer and quiet test volume are retained.
- Waveshare 29318 ST7796S display on SPI2 at 4 MHz, 320 × 480 portrait. It uses the retained Waveshare initialization sequence and the existing licensed bitmap font. Track, time, state and progress fields update once a second.
- ANO #6310 input diagnostics on I2C at 100 kHz. The reader checks seesaw firmware ID 5740 at address 0x49, then logs encoder position and button changes. These are raw board labels; physical orientation mapping, debounce and playback/navigation actions remain to be implemented after delivery.
- A display-only pattern option for the first visual test, before initializing SD or Bluetooth. Enable `CARRIER_DISPLAY_ONLY` in menuconfig for that later test; disable the ANO diagnostic too if testing only the display.

The single-song fixture is `/sd/HIGHER.MP3`, 44.1 kHz stereo, with 13,969,152 decoded frames. Metadata and duration are fixed for this bench. The existing stream time limit remains. Album progression, general library UI and reconnection qualification are outside this preparation. Dave's earlier clean Higher result applies to the WROVER audio bench, not this new carrier. The old display attempt had no confirmed visual pass.

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

`verification.json` records the binary size/hash and source hashes. Host tests compile the actual startup and display implementations with mocked GPIO/SPI, address sanitizer and undefined-behavior sanitizer. They check identity/memory rejection, low/chattering PG, output-latch ordering, display RAM bounds, text clipping, RGB565 byte order, backlight sequencing, transport failure and PG loss. They also cross-check the vendor/carrier pin mapping, reference hashes, selected components, Classic Bluetooth configuration and flash-command rejection. These tests do not simulate the LCD, I2C timing, Bluetooth RF or electrical behavior.

The isolated project supplies its own `bench_storage` and `bench_display`; only `bench_mp3` and `minimp3` are reused from the shared Mark 6 components. Retained Waveshare source, pinned Adafruit references and attribution are in `reference/`; the font's original license and source hashes are retained under `components/bench_display/`.

Related: [carrier review](../../../hardware/mark-6/carrier-rev-a/README.md), [fit prototype](../../../enclosure/mark-6/fit-prototype/README.md), and HARMONY-17.
