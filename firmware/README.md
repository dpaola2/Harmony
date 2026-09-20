# Harmony firmware baseline

On September 14, 2026, the unmodified Tangara ESP32 application, SAMD21 application, and SAMD21 bootloader all built successfully on Dave's Mac. The ESP32/SAMD register maps and control bits match at source level. This removes a build-toolchain uncertainty in the proposed Tangara approach. It does not establish that an assembled Harmony works.

| Build | Source pin | Result |
| --- | --- | --- |
| ESP32 application and IDF bootloader | `c092c5aae83aac241b3756b15d8b9dad9ed2c3fd`; ESP-IDF `8c750b088c7cd857d079c0eeb495da199b359461` | Passed; application 2,684,736 bytes, 36% partition space free |
| SAMD21 application v6.0 | `8066c54bff5d26398fa08955d2bc24e7f05702a2` | Passed; BIN, ELF and UF2 retained |
| Tangara SAMD21 bootloader | `bc1632d9736493467000ba119fd0b16fd46ccbe6` | Passed; raw factory image and existing-device updater retained |

Read the [ESP32 verification](esp32-validation/README.md) and [SAMD21 verification](samd-validation/README.md) for build commands, compiler versions, logs, hashes, and programming requirements. Both source checkouts remain unmodified. Toolchains are isolated under `firmware/toolchains`; no serial-port or flash commands were run. The existing Python simulator was not changed or retested.

Sol subagents built/reviewed the SAMD baseline and reconciled the board interfaces while the primary agent built the ESP32 baseline. The primary review caught and corrected build-script failure handling and checksum regeneration before accepting the SAMD deliverable.

## What this establishes

The ESP32 image checksum is valid; all seven ESP32 flash images fit the configured 16 MiB device without overlap. SAMD v6.0 and the ESP32 driver share I2C address `0x45`, registers 0–5 for version/status/control, and matching shutdown, fast-charge, mass-storage and UF2-reset bits. The SAMD application starts at `0x2000`, after the 8 KiB bootloader region. A blank SAMD still needs initial programming through SWD; the updater UF2 does not replace that step.

Clean builds and an ESP32 script invocation passed. The scripts pin source revisions and preserve the tested configuration. They are not proof of byte-identical clean rebuilds across hosts. The ESP32 build produced 29 compiler warnings, including an ALAC metadata-bounds finding tracked as HARMONY-12; the unmodified baseline retains that finding for a focused review before qualification.

## Hardware preparation

The [board reconciliation](../hardware/procurement/reconciliation/tangara-interface-bom-reconciliation.md) documents battery J7 circuit order, charger requirements, display pinout, and the routed-board component inventory. The old schematic audit contains reference collisions and repeated units and must not be used as an ordering BOM. Display electrical pinout matches, but mechanical drawing overlay remains unresolved. Battery finished dimensions, thermistor characteristics, wiring, and allowable charge rate remain unresolved.

Next engineering work is to turn the routed-board inventory into the reviewed assembly BOM and placement package, obtain the missing display and battery drawings, then prepare the quote with the now-known programming artifacts. No supplier contact, purchase, or fabrication release has occurred. Hardware acceptance still requires actual power/USB checks, playback, Bluetooth pairing and reconnect, touch-wheel operation, pocket reception, and measured runtime. Live work is tracked in HARMONY-9, HARMONY-10, HARMONY-11, and HARMONY-12.

## Local preservation

The [source archive manifest](source-archives/manifest.json) records tar archives of all tracked source files and recursive submodules, including the pinned ESP-IDF sources and upstream licenses. Archives omit Git history, downloaded compiler binaries, caches, and generated build trees. The source archives support local inspection; the supplied build scripts expect Git checkouts and download tools when bootstrapping. They are not an offline installer. Build outputs, logs, configurations, and scripts are preserved separately.

This baseline is also copied into the Harmony vault deliverables as a new dated package. The original R1 case/design snapshot remains unchanged.
