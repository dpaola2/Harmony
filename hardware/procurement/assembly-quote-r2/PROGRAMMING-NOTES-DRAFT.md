# Draft programming package notes

Status: programming quote input only. The images have passed build, layout, and checksum checks, but no Harmony/Tangara assembly has been flashed or tested with them.

## ESP32-WROVER-E-N16R8

Program a 16 MiB ESP32 in DIO mode at 80 MHz with the exact local files, offsets, byte counts, and SHA-256 hashes in `programming/programming-manifest.json`. The seven images are at offsets `0x1000`, `0x8000`, `0xd000`, `0x10000`, `0x810000`, `0xb10000`, and `0xf10000`. Verify the flash contents against those hashes after programming. Do not enable flash encryption, secure boot, or eFuse changes unless a later approved package explicitly requires them.

## ATSAMD21E18A-AF

For a blank device, use 3.3 V SWD and `programming/samd-bootloader-tangara-bc1632d.bin`. Program it at address `0x00000000`, set and verify an 8 KiB BOOTPROT region, then install `programming/samd-tangara-samd-v6.0.bin` at address `0x00002000`. Verify both images. The local application UF2 is only for a device that already has a working Tangara UF2 bootloader.

The SWD footprint J5 exposes pads rather than a populated header. The fixture must reach SWDIO, SWCLK, RESET, ground, and a 3.3 V reference without loading or damaging the board. Fixture pinout and power-source behavior require review before use.

## Acceptance record requested from programmer

Record board serial or lot identifier, programmer and software version, approved package manifest hash, image hashes, programmed addresses, read-back result, BOOTPROT result, ESP32 MAC address, SAMD firmware version observed by the ESP32, USB enumeration, and any failure/rework. Stop on any hash mismatch.

The authoritative build evidence and upstream hash records remain in `../../../firmware/esp32-validation/` and `../../../firmware/samd-validation/`. The package carries the required factory/programming images so a quote attachment can be reviewed as a unit. Uploading them to a supplier portal is a later controlled release step and is not authorized by this draft.
