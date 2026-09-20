# ESP32 baseline build verification

The unmodified Tangara ESP32 application and its ESP-IDF bootloader built successfully on September 14, 2026. The resulting application is 2,684,736 bytes and fits the 4 MiB application partition with about 36% free. Esptool validated the image checksum and appended hash. The seven generated flash images do not overlap and fit the configured 16 MiB flash.

This establishes that the pinned source can compile and link on this machine. It does not establish playback, Bluetooth compatibility, charging behavior, USB storage reliability, or battery runtime. No device was connected or flashed.

## Sources and build environment

| Input | Verified value |
| --- | --- |
| Tangara source | `https://codeberg.org/cool-tech-zone/tangara-fw.git` |
| Tangara commit | `c092c5aae83aac241b3756b15d8b9dad9ed2c3fd` |
| Application version | `2.1.0`, declared by upstream CMake |
| ESP-IDF commit | `8c750b088c7cd857d079c0eeb495da199b359461`, reporting 5.5.0 |
| Compiler | Xtensa GCC 14.2.0, `esp-14.2.0_20241119` |
| Python | 3.12.11, isolated IDF environment |
| Build tools | CMake 3.30.5; Ninja 1.12.1 |
| Host | macOS 26.6.2, Apple arm64 |
| Source modifications | None |

[Submodule pins](configuration/submodules.txt), [resolved Python packages](configuration/python-packages.txt), and [generated sdkconfig](configuration/sdkconfig) are preserved. The upstream defaults select classic Bluetooth/A2DP, external RAM, and 16 MiB flash. This is a Tangara/WROVER baseline, not an ESP32-S3 build.

## Rebuild

From the live Harmony2 repository, with Python 3.12, Git, CMake, and Ninja available:

```sh
bash firmware/esp32-validation/bootstrap.sh
bash firmware/esp32-validation/build.sh
```

The bootstrap downloads the pinned source/submodules and installs the ESP32 compiler and Python environment under `firmware/toolchains/esp-idf`. The build script checks source revisions and tracked changes, rejects `sdkconfig.local`, and checks an existing sdkconfig against the saved baseline. The scripts do not flash hardware. The initial clean build and a subsequent invocation through the build script both succeeded. A second clean, byte-identical build has not been demonstrated; build timestamps, absolute debug paths, and dependency resolution can affect future outputs. The Python package snapshot records what was used; bootstrap uses upstream dependency constraints rather than a sealed offline package environment.

Tool setup follows the pinned source's BUILDING.md and [Espressif's ESP-IDF 5.5 setup documentation](https://docs.espressif.com/projects/esp-idf/en/v5.5/esp32/get-started/linux-macos-setup.html).

## Artifacts and limits

[validation.json](validation.json) records the checks. [Flash layout](artifacts/flash-layout.json) lists the offsets, lengths, and SHA-256 values of the bootloader, partition table, initial OTA data, application, collation data, Lua filesystem, and REPL filesystem. These are validation artifacts, not a factory release. The application ELF and linker map are included for later debugging.

The [first build log](logs/build-first.log) contains 29 compiler warnings and one CMake warning. Most concern deprecated APIs, unused code, or fallthrough. Three warnings concern possible null dereferences in the upstream ALAC parser (`src/codecs/alac.cpp:129–131`); inspection finds unchecked cookie indexing after a file-derived length. This is an unresolved parser robustness finding, not a demonstrated hardware failure. Preserve the unmodified baseline and track a focused parser review before qualification. CMake also could not determine the vendored Opus package version. None prevented linking. These warnings must not be described as a warning-free build.

Upstream tests require an actual device according to TESTING.md. They were not executed. The next physical check is the matched SAMD/ESP32 pair on assembled boards; [SAMD build and recovery evidence](../samd-validation/README.md) describes the companion firmware.
