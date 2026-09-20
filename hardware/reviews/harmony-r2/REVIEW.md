# Harmony R2 independent circuit review

September 14, 2026. Sol implemented the correction; Codex reviewed the source changes and ran separate native KiCad checks. Tracking: HARMONY-14. Remaining release work: HARMONY-15.

**The schematic/PCB net mismatch is fixed. Fabrication remains on hold.** All 459 mainboard and 108 faceplate electrical pin/net assignments now agree. Both routed PCB files remain byte-identical to the pinned reference. This revision changes schematic and library definitions, not the printed case or board layout.

U1 and U9 had hidden power-input pins with the same name, EP. KiCad implicitly joined them, despite their drawn connections to different rails. Making those pins visible preserves the explicit connections. C23 pin 2 and U9's exposed pad now resolve to GND; U1's exposed pad and negative supply remain on -5VA. The [TI INA1620 datasheet](sources/INA1620.pdf), pages 3 and 28, and [NXP PCA8575 datasheet](sources/PCA8575.pdf), page 5, support that intended separation.

The WM8523 library incorrectly labeled many inputs and supply pins as outputs. Those definitions were corrected in both the schematic cache and local library. Independent review rejected proposed passive charge-pump pins and an open-collector zero flag, and restored bidirectional clock pins. All 20 final pin types match the reviewed model based on the [Cirrus datasheet](sources/WM8523.pdf), pages 4 and 15. No drawn wire, pin number, component position, or copper connection was changed.

| Mainboard check | Baseline | R2 |
|---|---:|---:|
| Schematic/PCB net conflicts | 30 | 0 |
| ERC errors | 28 | 10 |
| ERC warnings | 96 | 95 |
| Physical DRC errors | 38 | 38 |
| Physical DRC warnings | 45 | 45 |
| Other parity warnings | 10 | 10 |

Faceplate counts remain 6 DRC errors, 13 DRC warnings, 2 ERC errors, 24 ERC warnings, and 9 non-net parity warnings. Neither board reports unconnected PCB items. The [complete finding register](finding-dispositions.json) retains all 252 remaining findings with an action and no waivers.

## Remaining engineering and fabrication work

The next electrical cleanup is the TPS65133 and INA1620 enable-pin models, followed by external power-source annotations and library/bus-entry differences. Correct these from pin tables and proven power paths. Do not suppress rules or automatically synchronize the PCB to clear reports.

The physical review identified three areas needing explicit treatment:

- USB J6: twelve pads meet the connector cutout. The [native copper detail](usb-cutout-detail.svg.png) confirms this geometry. The manufacturer's drawing retrieval failed; obtain that drawing and a specific CAM/DFM disposition before changing the cutout or accepting zero edge clearance.
- Audio jack J1: eight annular-width findings include two 0.1034 mm rings. Native slots are 1.2 by 0.7 mm; the [manufacturer's drawing](sources/SJ-3506-SMT-TR.pdf), page 2, specifies 1.1 by 0.7 mm. Review finished-hole tolerance, pad shape and soldering fit together. A generic claim that these are rounding errors would be wrong.
- Faceplate: five touch electrodes are drawn with netless copper graphics contacting pads. Review their intended nets and isolation before accepting the clearance findings. The LED-enable via, copper sliver, artwork and library discrepancies also remain recorded.

Battery finished dimensions, charge/NTC/harness specifications, display FPC mechanics, and hardware firmware qualification remain open. Dave's slightly loose R1 coupons remain accepted; this correction does not justify a new case print.

## Evidence and reproduction

- [Source correction and implementer's report](../../revisions/harmony-r2/VALIDATION.md)
- [Independent native pin/net verification](independent-native-verification.json)
- [Independent symbol checks](symbol-verification.json)
- [Native commands, output and source hashes](native-check-run.json)
- [Revised assembly quote package](../../procurement/assembly-quote-r2/README.md)
- [Downloaded primary-source provenance](sources/manifest.json)

Run `run_native_checks.py --kicad-cli /absolute/path/to/kicad-cli`, then `verify_revision.py` with KiCad 8.0.9's bundled Python. Run `verify_symbols.py` and `catalog_findings.py` with Python 3. The native checks preserve source files. The net verifier checks every electrical pad and permits only the expected -5VA-to-GND correction relative to the baseline netlist.

The corrected sources and refreshed quote files remain local review artifacts. No supplier received them, no board order was placed, and no physical device has been qualified.
