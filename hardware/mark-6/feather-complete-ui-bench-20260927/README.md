# Complete native UI bench evidence

September 27–28, 2026. Complete Mark-6 player UI (HARMONY-18), under Harmony Mark-6: Bluetooth bench player (HARMONY-17).

The complete native menus built and ran on the USB-powered Feather bench. The captures establish short playback, navigation and restart evidence. They do not establish full-album endurance, complete UI acceptance, second-receiver compatibility or battery operation.

## Physical configuration

- Adafruit ESP32 Feather V2, original ESP32 PICO-V3-02 rev 3.1, 8 MiB flash and 2 MiB PSRAM.
- Base MAC `14:33:5c:99:1a:28`; Bluetooth MAC `14:33:5c:99:1a:2a`.
- Port `/dev/cu.usbserial-5B1E0643571` during the captured tests.
- Waveshare 29318 ST7796S LCD, 320 × 480 portrait, using its SD slot.
- Shared SPI2, 4 MHz: MISO21, MOSI27, SCLK14, SD-CS25, LCD-CS26, DC33, RST32, backlight4. LCD supply is Feather 3V on this harness.
- ANO seesaw address `0x49`, SDA22, SCL20, STEMMA power GPIO2.
- Receiver SoundCore 2, `f4:2b:7d:5a:35:43`.
- No battery or custom carrier connected. The bench pin map is not the carrier pin map.

## Two uploaded builds

`flash-initial.log`, `serial-initial.log` and `build-manifest-initial.json` record the first integrated build. It indexed 46 tracks, including the 45-track trial set and an older root Higher fixture. It restored selection and started paused. The capture shows connection, Creed/Third Eye Blind playback, menu actions and settings interaction.

At 236382 ms uptime, counters report 7,068,160 PCM frames produced, 131,072 bytes queued, zero underrun bytes and zero contention bytes. The maximum recorded full redraw was about 1.39 seconds. That is not an incremental-highlight redraw measurement. Stack-watermark reports showed remaining worker/display space.

`flash.log`, `serial-final.log` and `build-manifest.json` record the second uploaded build. Its application SHA-256 is `27bf447d71933f878da8da5ea1db252b0c9640bb53a3738d1b6fbcac77411b6f` (1,242,768 bytes). Flash verification passed. It restored the Third Eye Blind selection and volume 40, reconnected SoundCore 2, and remained paused. The 45-second capture does not contain an audible volume/mute acceptance result.

The second build reduced the controls-task delay from 20 ms to 5 ms while preserving 40 ms debounce. Observed polling improved to roughly 17–23 ms. Earlier 50–60 ms taps could miss the debounce window at the previous polling cadence.

## Source checkpoint at wrap

The September 28 source adds asynchronous remote-name lookup when an existing Bluetooth bond connects. Fourteen Bluetooth policy scenarios cover stale, failed, forgotten and long-name responses. Both native targets and all four host verifier scripts passed at wrap. Their logs start with `checkpoint-`.

`checkpoint-not-flashed.bin` and `checkpoint-manifest.json` preserve the resulting application and source hashes. This binary was not uploaded. The device therefore still has the preceding uploaded build as far as this session knows. Do not apply the old flash capture to the new source checkpoint.

A remaining name-display detail is known: an already-open device/Forget page copies its subtitle when opened. It may retain a MAC until reopened. Live receiver and saved/found names use the updated snapshot. Finish this detail and physically verify name retrieval before declaring the reported bug closed.

## Recovery and validation limits

The earlier accepted native UI is preserved at commit `b433aff` and in `/Users/dave/Downloads/harmony-mark6-backups/pre-complete-ui-20260927/`. Its application SHA-256 is `69a045d1bf826be0ac968510962aa186092bd0b65b7f684270c2774db7d86755`. That backup predates the complete menus. Keep the board-specific configuration and approved application-only flash procedure when restoring.

Host tests cover menu state, rendered bounds, volume/mute ramp, queue membership, shuffle/repeat, metadata/path bounds, recovery, Bluetooth policy and carrier safeguards. Mocks do not establish radio compatibility or audible behavior. No battery tests occurred. Custom Bluetooth PIN/passkey entry remains unsupported. Cold restart restores selection, not elapsed position or the complete previous playlist queue.

Next acceptance includes the final name fix, audible volume/mute, a full album, second receiver, disconnect/reconnect, power interruption, storage recovery and the complete menu set. These carry into [Mark-7](../../../docs/mark-7-portable-scope.md); they were not converted into passes when hardware scope changed.

## Cross-references

- [Requirements](../../../docs/Harmony-player-ui-requirements.md)
- [Native firmware instructions](../../../firmware/mark-6/feather-player-bench/README.md)
- [Lessons and power distinctions](../../../docs/mark-6-lessons-and-portable-next-step.md)
- [Preserved web appearance](../../../docs/mark-7-design-reference.md)
