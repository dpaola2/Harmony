# Tangara SAMD21 baseline validation

## Result

Both official Tangara SAMD21 images compile successfully on macOS arm64. This is a build validation only. No board was connected, flashed, or exercised, so USB, charging, power control, SD-card multiplexing, and ESP32-to-SAMD I2C behavior remain unverified on hardware.

## Pinned sources

- Application: `https://codeberg.org/cool-tech-zone/tangara-samd-fw.git` at `8066c54bff5d26398fa08955d2bc24e7f05702a2`, tagged `v6.0`.
- Bootloader: `https://git.sr.ht/~jacqueline/tangara-samd-bootloader` at `bc1632d9736493467000ba119fd0b16fd46ccbe6`.
- Compiler: Arm GNU Toolchain `14.3.Rel1`, `arm-none-eabi-gcc 14.3.1 20250623`, unpacked under `firmware/toolchains/samd`.
- Application submodules: TinyUSB `5217cee5de4cd555018da90f9f1bcc87fb1c1d3a`; Microsoft UF2 `35842c770bf553ce01a48ded68f3763e5e140a1e`; HIDAPI `a6a622ffb680c55da0de787ff93b80280498330f`.
- Bootloader submodules: Microsoft UF2 and HIDAPI at the same revisions above.

The application revision is the current Codeberg `main` and `v6.0` tag as checked on 2026-09-14. The bootloader has no release tag; its exact commit is pinned.

## Reproduce

On macOS arm64, run from the Harmony2 repository root:

```sh
firmware/samd-validation/build-samd.sh
```

The script clones both upstream repositories when absent, checks out the exact revisions, initializes recursive submodules, downloads the compiler archive when absent, verifies its SHA-256, and extracts it under `firmware/toolchains/samd`. The compiler archive URL is:

`https://developer.arm.com/-/media/Files/downloads/gnu/14.3.rel1/binrel/arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi.tar.xz`

Its SHA-256 is `30f4d08b219190a37cded6aa796f4549504902c53cfc3c7e044a8490b6eba1f7`.

Before compiling, the script checks both top-level revisions, requires pristine tracked source trees, and verifies every recursive submodule revision. It produces application ELF/BIN/UF2 files, the raw factory bootloader ELF/BIN, a bootloader self-update UF2, logs, compiler size output, and `artifacts/SHA256SUMS`. Bash `pipefail` ensures a compiler failure cannot be hidden by log capture.

## Compatibility with the pinned ESP32 firmware

The ESP32 pin is `c092c5aae83aac241b3756b15d8b9dad9ed2c3fd`. Its SAMD driver reads two bytes beginning at I2C register 0 as major/minor, and for major 6 or newer maps charge status, USB status, power control, and USB control to registers 2 through 5. The application pin declares version `6.0`, exposes exactly six registers at those indexes, and uses the same control bits: power-down bit 0, fast-charge bit 1, USB MSC bit 0, and UF2 reset bit 2. The ESP32 UI also permits USB mass storage for major versions 3 and newer.

The pair is therefore source-compatible at the I2C protocol and flash-layout level. This evidence does not establish electrical or runtime compatibility. That requires a Tangara-compatible board test covering enumeration, mass-storage reads and writes, charge states, shutdown, fast-charge control, and the UF2 reset path.

## Flash and recovery path

The bootloader occupies flash `0x00000000` through `0x00001fff`; the application linker origin and UF2 start address are `0x00002000`. A factory-fresh ATSAMD21E18A needs the Tangara bootloader installed first through the mainboard's SWD pads (`SWDIO`, `SWCLK`, `RESET`, and ground/power reference) with a compatible debugger.

Upstream documents a Black Magic Probe flow using GDB: load the bootloader ELF, run `monitor swdp_scan`, `attach 1`, `load`, and `compare-sections`. The bootloader repository also generates a J-Link command file through its `jlink-flash` target. Its README warns that OpenOCD's `at91samd bootloader` fuse command is buggy and supplies `scripts/fuses.tcl` for setting the SAMD21 BOOTPROT fuse safely. Factory bring-up must include the 8 KiB BOOTPROT setting and verification.

Once the bootloader is installed, copy `tangara-samd-v6.0.uf2` to the mounted `TANGARA UF2` volume. Existing firmware can request the bootloader from Settings > Firmware Update or the ESP32 app console command `samd flash`. A double reset of the SAMD reset pad is the physical recovery entry described by upstream.

The raw bootloader BIN is the factory/SWD artifact. `update-bootloader-tangara-bc1632d.uf2` is for updating a device that already has a working UF2 bootloader and is not a substitute for first programming a blank SAMD21.

Upstream factory and recovery documentation: <https://cooltech.zone/tangara/docs/samd21/>.
