# Tangara interface and BOM reconciliation

Review date: 2026-09-14  
Pinned hardware source: Cool Tech Zone `tangara-hw` commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`

This is evidence for an assembly quote, not a released manufacturing BOM. It reconciles the battery and display interfaces and records BOM defects that could change an assembly quotation. It does not clear substitutions, fabrication, or purchasing.

## Battery connector J7

The populated board header is JST **S3B-PH-K-S(LF)(SN)**, a side-entry, through-hole, three-circuit PH-series header on the mainboard back. The PCB footprint and official JST drawing agree on 2.0 mm pitch. JST's drawing identifies the mating housing family as PHR and numbers circuit 1 from the marked end when viewed from the connector mounting surface.

The routed PCB, rather than wire color convention, is authoritative for the required pack harness:

| J7 circuit | Board net | Required pack lead |
| --- | --- | --- |
| 1, marked end | `/Power/NTC` | Thermistor sense |
| 2, center | `GND` | Cell negative and thermistor return |
| 3 | `Net-(J7-Pin_3)`, connected to MCP73871 `VBAT` and `VBAT_SENSE` | Protected cell positive |

The selected three-wire pack must therefore terminate **NTC / negative / positive** at J7 circuits **1 / 2 / 3**. A claim that a pack has a PHR-3 connector is insufficient without a drawing or continuity check proving this circuit order. Harness wire colors are not an acceptable release criterion.

Power-sheet R1 is a 10 kΩ 0603 resistor explicitly marked DNP and annotated for two-pin batteries only. With a real pack thermistor, R1 remains unpopulated. Populating it in parallel with the pack thermistor would distort the effective NTC resistance and therefore the charger's temperature-qualification thresholds. Used alone with a two-wire pack, it intentionally substitutes a fixed in-range resistance and removes actual cell-temperature sensing.

The charger is MCP73871-2CCI/ML. Microchip specifies an internal 50 µA THERM bias intended for common 10 kΩ NTC thermistors and typical qualification thresholds of 1.24 V and 0.25 V. The datasheet also permits a fixed 10 kΩ THERM-to-VSS resistor only when temperature monitoring is not required. Harmony's quote requires real pack sensing, so the thermistor's **R25, beta or full resistance-temperature table, mounting to the cell, lead insulation, and qualified charging window** must be supplied and electrically reviewed.

The power sheet fits R39 = 1 kΩ on PROG1 and annotates `I_REG = 1000V / R_PROG1`, which programs approximately **1 A maximum fast-charge current**. Microchip gives 900 to 1100 mA for PROG1 = 1 kΩ. This is a configured ceiling, not the current used for every USB source. In the pinned ESP32 firmware, an unset NVS `fastchg` value defaults to enabled and is sent to SAMD firmware version 4 or newer. The SAMD reads the USB-C current advertisement: detached selects the 100 mA USB setting; a 500 mA source selects the 500 mA USB setting; 1.5 A or 3 A sources select the 500 mA USB setting unless fast charge is enabled, in which case SEL chooses the adapter path whose current remains capped by PROG1 at approximately 1 A. Thus a new board with compatible v4 SAMD and default ESP32 settings can request the 1 A path when a capable source is detected, but it is not always at 1 A. The LP574459 candidate cannot be released until its finished-pack specification explicitly permits this charge current, or the PCBA charge-current setting is revised and verified. Nominal 2,000 mAh capacity alone does not establish an allowable 1 A charge rate.

## Historical battery mismatch

The upstream prose BOM line combines three attributes: “3-pin 2200mAh 604560” and “EcoCell LIP2-001.” Current procurement research shows those identifiers diverge: LIP2-001 is listed as a 2,000 mAh 113450 three-wire pack, while the 2,200 mAh 604560 is LIP2-200 and is listed with two wires and no thermistor. Neither identity is an exact, currently verified source part for J7.

LP574459 is therefore a candidate pack specification rather than an approved substitution. Before quote release obtain a dimensioned **finished-pack** drawing, protection-circuit limits, maximum continuous charge current, NTC curve, PHR-3 housing/contact details, cable length and exit, and an explicit 1/2/3 circuit-order drawing. The advertised 5.7 × 44 × 59 mm cell dimensions do not prove enclosure fit after protection PCB, seams, cable, and tolerances.

## Display interface

The faceplate PCB directly solders LCD1 to fourteen 0.8 mm-pitch pads. The PCB assigns:

| LCD pad | Board connection |
| --- | --- |
| 1 | No connection |
| 2 | GND |
| 3 | LED cathode, switched by the faceplate backlight transistor |
| 4 | LED anode, +3.3 V |
| 5 | GND |
| 6 | RESET |
| 7 | RS/DC |
| 8 | DATA, SPI controller input (`PICO`) |
| 9 | CLOCK (`SCLK`) |
| 10 | +3.3 V |
| 11 | +3.3 V |
| 12 | chip select (`CS`) |
| 13 | GND |
| 14 | No connection |

The custom footprint's fourteen pads are spaced 0.8001 mm nominally. Its drawing contains a 28.000 × 35.000 mm rectangle. That closely matches EastRising's published 28.03 × 35.04 mm active area, so the footprint graphic appears to encode the active area rather than the complete glass/FPC envelope. It must not be used as a full mechanical drawing.

EastRising's official ER-TFT018-4 datasheet confirms the exact fourteen-pin functional order in the table above, including NC at pins 1 and 14, both grounds, backlight polarity, SPI signals, VCC, IOVCC, and CS. It specifies VCC and IOVCC operating maxima of 3.3 V, so the board's +3.3 V connections to pins 10 and 11 are within the published range. The product page confirms 128 × 160 pixels, ST7735S, four-wire SPI, soldering FPC, 34.74 × 46.70 × 2.3 mm outline, 28.03 × 35.04 mm active area, typical 2.8 V supply, and 40 mA backlight. Electrical pin order is reconciled. A full-scale mechanical overlay of the datasheet outline/FPC copper geometry against the PCB and case has not been completed and remains a release hold.

The schematic calls LCD1 `JD-T1800` and has no MPN or datasheet. The prose BOM says production uses ER-TFT018-4 and also names Adafruit JFT-1800 as compatible. The quote should identify **ER-TFT018-4** explicitly and require the assembler to reconcile its current manufacturer drawing against the table above and the faceplate land pattern. “Any ST7735 display” is not an acceptable substitution because controller compatibility does not establish flex pinout or mechanical fit. Do not quote a breakout-board module.

## BOM and audit discrepancies relevant to quoting

The routed-board extractor in `extract_pcb_inventory.py` produces `pcb-physical-inventory.json`, with one record per footprint and the PCB's DNP, exclude-from-BOM, and exclude-from-position flags retained. It finds 124 mainboard footprints: 92 fitted, 5 carrying DNP, and 29 excluded from BOM. Two of the five DNP footprints, debug connectors J3 and J5, are also excluded from BOM; the quote-relevant unpopulated footprints are C17, C19, and battery-emulation R1. It finds 46 faceplate footprints: 37 fitted and 9 excluded from BOM. Ordinary annotated references are unique within each board; repeated placeholder references such as `G***` and `REF**` belong to excluded graphics.

The current `schematic-parts-audit.json` is not quantity-safe. It records repeated units and same-reference symbols from hierarchical sheets as separate physical rows. Examples include seven rows for U1 INA1620, five for U9 74CBTLV3257, four for R17 10 kΩ, and duplicate C11/C30/Q1 identities. Some repeated references also carry different values or MPNs because references are local to child sheets. Material examples are PCB U9 = PCA8575BS,118 while the audit assigns the U9 mux MPN, and PCB SW1/SW2 are respectively JS102011SAQN and EVQ-P40B3M while the audit reverses them. PCB C23 is 1 µF / GRM216R61C105KA88D while the audit's reference collision assigns a 10 µF part. Four other apparent MPN differences are trailing-space defects, not component changes. The generated PCB inventory retains every audit MPN candidate for each board/reference comparison, but the audit file must not be uploaded as an assembly BOM or counted by reference alone.

Every fitted mainboard footprint has an MPN field in the routed PCB. The faceplate reports 19 fitted footprints without MPNs, but 18 are board geometry or test structures: four plated mounting holes, two haptic wire pads, three capacitive electrodes, and nine test points. LCD1 is the only fitted, separately procured faceplate item lacking a PCB MPN. Its quote identity must be supplied as ER-TFT018-4 subject to the drawing overlay hold; it must not be inferred from the `JD-T1800` schematic value alone.

LCD1 has an empty schematic MPN even though procurement proposes ER-TFT018-4. Power-sheet DNP R1 has the malformed MPN field `0.1W 5%`, which is a rating/tolerance description rather than a manufacturer part number. Both need explicit treatment in a generated manufacturing BOM: LCD1 resolved by approved display drawing; R1 marked DNP with a valid alternate only if a two-wire battery design is deliberately adopted.

## Release holds

1. Archive the current ER-TFT018-4 dimensioned drawing and perform a full-scale overlay of its complete FPC copper and outline geometry against the faceplate footprint and case datum. The fourteen-pin electrical order is verified.
2. Obtain LP574459 finished-pack and harness drawings and electrical data. Verify J7 order NTC / GND / BAT+ at circuits 1 / 2 / 3 by drawing and incoming continuity inspection.
3. Confirm the pack accepts the fitted approximately 1 A charge setting, or approve and validate a new PROG1 resistor.
4. Generate a flat PCB-derived BOM and placement list that resolves hierarchical references and multi-unit symbols. Reconcile it to both routed PCBs; do not promote `schematic-parts-audit.json` into the RFQ.
5. Keep power-sheet R1 DNP for the required three-wire thermistor pack. Any two-wire fallback is a separate electrical decision and loses real cell-temperature qualification.

## Primary sources

- Pinned KiCad PCB and schematic files in `hardware/tangara-reference`, source lock above.
- [EastRising ER-TFT018-4 product page](https://www.buydisplay.com/1-8-inch-128x160-tft-lcd-display-4-wire-spi-st7735s-soldering-type-fpc), retrieved 2026-09-14.
- [EastRising ER-TFT018-4 datasheet, revision 1.0](https://www.buydisplay.com/download/manual/ER-TFT018-4_Datasheet.pdf), dated 2024-02-24 and inspected 2026-09-14.
- [JST PH connector manufacturer drawing](https://www.jst-mfg.com/product/pdf/eng/ePH.pdf), retrieved 2026-09-14.
- [Microchip MCP73871 data sheet DS20002090F](https://ww1.microchip.com/downloads/aemDocuments/documents/APID/ProductDocuments/DataSheets/MCP73871-Data-Sheet-DS20002090F.pdf), retrieved 2026-09-14.
- Upstream `BOM.md` and current `hardware/procurement/README.md` for the historical battery identity and proposed candidate.
