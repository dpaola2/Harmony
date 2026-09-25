# Mark-6 SD probe

HW-125 adapter: CS=25, SCK=18, MOSI=23, MISO=19, VCC=USB 5V, GND=GND.
Board identity is checked before GPIO changes. The shared `bench_storage`
component rejects sector writes and never formats a card.

`bash build.sh build` compiles the probe. It mounts at 4 MHz, lists HARMONY,
reads and hashes HIGHER.MP3, checks the saved size/hash, then unmounts.
September 21: passed, 5,070,386 bytes in 16.656 seconds. Log and configuration
are under `hardware/mark-6/` at the repository root. HARMONY-17 owns follow-up.
