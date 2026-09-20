# Harmony R2 schematic correction

Status: engineering revision for HARMONY-14. It is not released for fabrication or purchasing.

## Source and cause

This revision derives from the pinned Tangara hardware commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`. The source lock records that derivation. The mainboard and faceplate PCB files are byte-identical to the pinned reference.

U1, an INA1620, and U9, a PCA8575BS, both used hidden power-input pins named `EP`. KiCad connects hidden power pins by name. U1's exposed pad was explicitly colocated with its `V-` connection to `-5VA`, while U9's exposed pad was explicitly placed on `GND`. Their common hidden name merged those two rails in the generated schematic netlist. The merge assigned 30 routed `GND` pads, including C23 pin 2, to schematic net `-5VA`.

The INA1620 datasheet requires its thermal pad to connect to the most negative supply, VEE. The PCA8575BS datasheet identifies the exposed center pad as die ground connected to VSS. This establishes the intended U1 EP to `-5VA` and U9 EP to `GND` topology.

## Patch

- Removed the hidden attribute from U1 pin 25 in `audio.kicad_sch` and from the project-local INA1620 definition in `symbols.kicad_sym`. The already drawn connection colocates pin 25 with pin 5, `V-`, on `-5VA`.
- Removed the hidden attribute from U9 pin 25 in `peripherals.kicad_sch` and from the project-local PCA8575BS definition in `symbols.kicad_sym`. The already placed GND symbol explicitly connects pin 25 to `GND`.
- Corrected the WM8523 electrical pin types in both the cached schematic symbol and `symbols.kicad_sym` from the manufacturer's pin table. Supply and ground pins are power inputs; DACDAT, MCLK, SCLK, chip-select/mute, and CIFMODE are inputs; BCLK, LRCLK, SDA, and SDOUT/DEEMPH are bidirectional. CPCA, CPCB, ZFLAG, the analog outputs, VMID, and CPVOUTN remain outputs. No pin number, name, connection, PCB net, or geometry changed.

## Native KiCad 8.0.9 results

Checks used `/Users/dave/projects/Harmony2/firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli` with the copied isolated configuration under `verification/isolated-config` and severity `all`. No violations were excluded or waived.

| Check | Pinned reference | Harmony R2 |
| --- | ---: | ---: |
| ERC errors | 28 | 10 |
| ERC warnings | 96 | 95 |
| DRC errors | 38 | 38 |
| DRC warnings | 45 | 45 |
| Schematic parity warnings | 40 | 10 |
| Unconnected PCB items | 0 | 0 |

The native R2 netlist proves C23 pin 2 and U9 pin 25 are on `GND`; U1 pins 5 and 25 are on `-5VA`. All 30 net-conflict parity findings are gone. The physical DRC count is unchanged, which is expected because the PCB was not modified.

## Unresolved findings

The ten remaining parity warnings are four duplicate and five extra anonymous `REF**` PCB structures, plus the J2 value difference `FP Connector` versus `MB Connector`. They do not report a remaining net mismatch. The anonymous structures need identity and intended board-only status established before annotation or deletion. J2 has matching pins and nets; its perspective-dependent value text needs an explicit naming decision before synchronization.

The remaining ERC findings are 89 library-symbol warnings, six power-not-driven errors, three pin-type findings, four multiple-net-name warnings, and three dangling bus-entry errors. Several are likely symbol metadata issues. In particular, the TPS65133 symbol types VNEG as an ordinary output, GND as an output, and AVIN/PVIN as bidirectional, which accounts for the U1 `V-` power-not-driven error, the GND-to-FLT error, and two warnings. Those types were not changed in this bounded correction. The other power-not-driven items are J3 GND, J6 VBUS, U10 IN, U1 EN, and U1 V+. The multiple-name findings are VBUS/VBUS_RAW, GND/SHELL_GND, KEY_LOCK/SYS_PWR_EN_SW, and GND/VSS. No remaining item is waived by this revision.

The generated evidence is `verification/mainboard-native-netlist.xml`, `verification/mainboard-erc.json`, and `verification/mainboard-drc.json`.
