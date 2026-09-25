# Mark-6 Bluetooth tone test

HARMONY-17. Adapted from Espressif's A2DP source example at ESP-IDF commit
`8c750b088c7cd857d079c0eeb495da199b359461`; upstream SPDX notices retained.
Uses the existing local IDF 5.5 toolchain. No SD, display or button wiring.

`bash build.sh build` compiles without flashing. The spare has 4 MiB flash;
base MAC `5c:01:3b:89:24:04`. Verify that identity before flashing.

The firmware finds SoundCore 2 by name, pairs, and transmits 500 Hz stereo
beeps at approximately -36 dBFS for 30 seconds, alternating one second on/off.
It then sends silence, suspends media and disconnects. Reset starts another
test. Speaker volume remains under the listener's control.

Changes from upstream: bounded quiet tone replaces noise; automatic speaker
volume increases removed; controller-only AVRCP setup corrected; case-insensitive
name matching with missing-name rejection; heap and PCM-frame logging added.

The full flash backup and test logs are in
`/Users/dave/Downloads/harmony-mark6-backups/`. Configuration and hashes are in
`hardware/mark-6/` at the repository root. A tone pass establishes Bluetooth
audio only. MP3 decoding, SD integration and album endurance remain separate.
