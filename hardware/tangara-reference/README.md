# Tangara electronics reference for Harmony

Proposed hardware foundation, captured September 13, 2026. Read [Harmony's reassessment](../../docs/Harmony-2026-reassessment.md) before treating this as an adopted replacement for the prior hardware plan.

The KiCad schematic, PCB, symbol, and footprint sources are copied from Cool Tech Zone's [tangara-hw repository](https://codeberg.org/cool-tech-zone/tangara-hw), commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`. They are unchanged. Optional 3D libraries, editor state, caches, backup files, and generated XML netlists are omitted. [source-lock.json](source-lock.json) records the source. Retain the upstream [LICENSE](LICENSE), CERN-OHL-S-2.0, with derivatives.

The reference includes the mainboard, faceplate, and touch-cover PCB. The 0.6 mm touch-cover PCB is an insulating face cover; the capacitive electrodes and controller are on the faceplate. The Harmony case also includes a printable cover experiment.

These files are not an approved manufacturing package. No ERC/DRC, component substitution review, fabrication quote, or assembly order has been completed in this session. Generate manufacturing outputs from a reconciled board revision after checking part availability. In May 2026, the original designer supplied production files and noted that some components might have been discontinued. [Manufacturing discussion](https://forum.cooltech.zone/showthread.php?pid=1466)

For an assembly quote, include both boards at the correct stack-up and 1.6 mm nominal thickness, the upstream surface finish, BOM and placement data, display mounting, haptic motor, and programming requirements. The mainboard is a four-copper-layer design in the checked-out PCB. Confirm the faceplate and touch-cover stack-ups independently. Ask the assembler to flag every unavailable component or substituted connector before manufacture. Procurement prices and lead times have not been verified.

The current firmware candidate inspected is [tangara-fw](https://codeberg.org/cool-tech-zone/tangara-fw), commit `c092c5aae83aac241b3756b15d8b9dad9ed2c3fd`. It uses ESP-IDF and native code, with Lua UI scripts. Read its `BUILDING.md` and use its pinned submodules. The separate [SAMD firmware](https://codeberg.org/cool-tech-zone/tangara-samd-fw) must be selected as a compatible pair; this session has not frozen, built, or flashed that pair. USB storage in the inspected UI requires SAMD application version 3 or newer.

New boards need the SAMD bootloader installed through SWD before ordinary USB programming is available. Obtain a compatible SWD programmer and probe, or include initial programming in the assembly quote. Verify both firmware images, audio playback, charging, low-battery behavior, and switch inputs before fitting the printed case.

For current sourcing, use the [Harmony shopping list](../procurement/README.md). It records the battery identifier mismatch in the historical BOM and keeps unverified replacements on hold.

## Cross-references

- [Original BOM](BOM.md), historical names and sourcing gaps retained
- [Complete enclosure fit prototype](../../enclosure/harmony-r1/README.md)
- [Manufacturer electronics description](https://cooltech.zone/tangara/docs/electronic-design/)
- HARMONY-8
