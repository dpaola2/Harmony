# Independent assembly package review

Reviewed September 14, 2026 by Codex, independently of the Sol package author. Tracking: HARMONY-13; circuit follow-up: HARMONY-14.

**The package reconciles and is suitable for quote review. Fabrication remains on hold.** No supplier has received these files and no quote, purchase, or hardware qualification has been completed.

## Verified

The reviewer loaded both unchanged boards with KiCad 8.0.9's native `pcbnew` API. This extraction does not use Sol's text parser or validator. `verify_quote_package.py` compares that inventory to the delivered CSVs and hash manifest.

| Board | Native footprints | Purchased/fitted | DNP or PCB structures | BOM groups | Copper layers |
|---|---:|---:|---:|---:|---:|
| Mainboard | 124 | 92 | 32 | 35 | 4 |
| Faceplate | 46 | 19 | 27 | 10 | 2 |

Every fitted reference appears exactly once. MPN, value, footprint, side, native position and rotation agree, with the explicitly held LCD candidate as the sole MPN exception. Quantities for one, two and five boards multiply correctly. All 59 exclusions reconcile, including duplicate logo references. The haptic motor is listed once externally; its solder pads are excluded from component purchasing. Supplier position files are exact filtered native exports. No assembler rotation correction was invented.

All 79 manifest outputs match their SHA-256 and size. All 11 programming files match the preserved firmware builds. The seven ESP32 images do not overlap and fit in 16 MiB. Native copper export counts match the boards. PCB hashes match both the manifest and the original R1 vault snapshot. The source boards were not modified or resaved.

During review, incorrect programming-document paths were fixed and the actual programming images were added to the package. The mainboard finish is unset in the source: ENIG is a quote preference, not a recovered source requirement. Native board thickness is 1.60252 mm mainboard and 1.6 mm faceplate; nominal 1.6 mm is proposed for quoting.

## Findings that prevent fabrication release

| Native KiCad check | Mainboard | Faceplate |
|---|---|---|
| DRC | 38 errors, 45 warnings | 6 errors, 13 warnings |
| Schematic parity | 40 warnings | 9 warnings |
| ERC | 28 errors, 96 warnings | 2 errors, 24 warnings |
| Unconnected items | 0 | 0 |

These results use isolated KiCad library configuration. Missing global-library configuration was corrected before the final run. Remaining library-symbol warnings are not automatically waived. Zero unconnected items does not clear other checks. Examples include mainboard copper-to-edge clearance, slightly undersized connector annular rings, footprint-type metadata, and faceplate touch-electrode clearances. Each needs an engineering or fabrication disposition.

**Confirmed circuit discrepancy:** native schematic netlist assigns C23 pin 2 to `-5VA`; native PCB assigns it to `GND`. Evidence is in `mainboard-native-netlist.xml`, `native-inventory.json`, and `circuit-check-evidence.json`. ERC also reports hidden EP pins on U1 and U9 attached to differently named rails. A plausible explanation is implicit connectivity through hidden power-input pins. KiCad documents this behavior in [Hidden Power Pins](https://docs.kicad.org/8.0/en/eeschema/eeschema.html#hidden_power_pins). This is a hypothesis to investigate, not proof of a physical PCB short or permission to synchronize the PCB. HARMONY-14 is the next engineering task.

**Mechanical and supplier inputs:** the LP574459 listing gives nominal cell dimensions, not guaranteed finished-pack maxima. The pack's NTC curve, three-wire mating-view drawing, protection limits and permission for the approximately 1 A configured charge ceiling remain unconfirmed. The ER-TFT018-4 electrical candidate still needs a controlled FPC drawing and full-scale enclosure/faceplate overlay. The attempted direct PDF retrieval returned HTTP 403; no error page was retained as a datasheet. Draft requests are in `../assembly-quote/VENDOR-QUESTIONS-DRAFT.md`.

## Limits and next steps

This review checks package consistency and independently confirms the reported circuit discrepancy. It is not a complete electrical design review, CAM/DFM sign-off, supplier placement-preview approval, component availability confirmation, or physical test. Firmware builds are hardware-unqualified; the ALAC parser finding remains HARMONY-12.

Start HARMONY-14 by tracing U1/U9 hidden EP connectivity in a separate working copy, proving the intended power nets, and rerunning native netlist/ERC/parity checks. Keep the pinned source and this delivery snapshot unchanged. Obtain the battery and display drawings in parallel once supplier outreach is authorized. Print the full fit case after those dimensions are reconciled; it can precede board arrival, but final fit requires physical parts. Dave's slightly loose R1 coupons remain accepted and no clearance change is justified yet.

Reproduce reconciliation with `python3 hardware/procurement/assembly-verification/verify_quote_package.py` from the live repository or the archive root. Native inventory regeneration requires KiCad 8.0.9's bundled Python and the preserved hardware sources. The quote generator and native tool pins are in the sibling package.
