# Mark-6 Bluetooth MP3 bench test

HARMONY-17. Extends the verified IDF tone experiment with a pinned minimp3
decoder and the verified HW-125 SD wiring. `bash build.sh build` compiles.
Uses the existing pinned IDF toolchain, 240 MHz CPU and tested-at-boot PSRAM.

On boot, mount the SD card with sector writes blocked, decode
`/HARMONY/HIGHER.MP3`, prefill a 128 KiB PCM stream buffer, find SoundCore 2,
and play once at -24 dB digital attenuation. Speaker volume stays under the
listener's control. Only 44.1 kHz stereo MP3 is accepted in this experiment.

Decoding and file reads run on core 1. The Bluetooth callback copies ready
PCM without waiting; missing data becomes silence and increments the underrun
counter. EOF drains the buffer, then the heartbeat suspends and disconnects.
Unexpected disconnection stops playback. A 400-second streaming limit also
stops the test. Reset replays the song; this is temporary bench behavior.

The shared reader was checked on the Mac with ASan/UBSan against the complete
song (27,938,304 samples), invalid input and an unsupported 48 kHz file.
The native verifier is `tools/verify_mark6_decoder.c`. Hardware results,
configuration and hashes belong in `hardware/mark-6/`.

September 21 startup fix: the powered card returned CMD52 CRC errors across
ESP32 resets. The storage adapter now sends IDF's two-CMD0 reset sequence
before the normal initialization probe. Mount and Bluetooth playback then
started successfully. This resets card protocol state; it does not write data.

The first longer playback run overflowed the shared timer task's 2 KiB stack
at 262 seconds uptime while logging diagnostics. The timer now only queues a
heartbeat. Diagnostics run on the Bluetooth application task with a 6 KiB
stack; the log reports minimum remaining stack for both tasks. Keep the failed
run alongside the repeat test when evaluating reliability.

Display integration uses separate software-SPI pins and the reused Mark-5 ST7789.
The recovered minimal reset/init sequence and CS held through each rectangle
follow the successful standalone white test; hardware SPI is not the verified
display transport. The SD reader continues to use hardware SPI3.
The screen shows the single fixture's title, artist/album, receiver, playback
state, elapsed/total time and progress. Metadata and duration are fixed to
Higher for this bench test. A low-priority task on core 0 updates changed fields
about once per second; only the newly filled portion of the progress bar is
drawn. It logs update time and stack margin. SD/decode remains on core 1 and
the Bluetooth callback performs no display work. Display startup failure
stops this integration test before Bluetooth starts. Physical controls and
album playback are not implemented here.
