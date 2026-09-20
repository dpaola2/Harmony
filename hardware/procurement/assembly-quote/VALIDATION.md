# Package validation record

Validation date: 2026-09-14. Tool: official KiCad CLI 8.0.9. Hardware source pin: `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`.

## Coverage and quantity checks

The routed sources contain 170 footprints: 124 on the mainboard and 46 on the faceplate. This package classifies them without loss:

| Board | Routed footprints | Purchased/fitted placements | DNP or non-purchased structures | BOM groups | Native raw position rows | Supplier position rows |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Mainboard | 124 | 92 | 32 | 35 | 97 | 92 |
| Faceplate | 46 | 19 | 27 | 10 | 22 | 19 |
| Total | 170 | 111 | 59 | 45 | 119 | 111 |

For each board, the sum of `qty_per_board` equals the supplier position count and the purchase-classified reference set matches exactly. Every 1, 2, and 5 quantity column equals the per-board quantity multiplied by its stated board quantity. Reference identifiers are unique within each board. LCD1 occurs once on the faceplate as the held ER-TFT018-4 candidate. The haptic motor occurs once per complete set in the external addendum, while J1/J2 remain classified as faceplate solder pads.

The raw KiCad position export includes DNP or non-purchased footprints that are not excluded from position files in the upstream PCB metadata. The supplier file filters those rows using the explicit purchasing classification; it does not change KiCad's X, Y, side, or rotation fields.

## Native fabrication outputs

KiCad exported the standard fabrication layer set and Excellon drill file without modifying or refilling the stored PCB zones. The mainboard export has four copper layers; the faceplate export has two. Both include top/bottom mask, paste, silkscreen, Edge.Cuts, drill, and Gerber job files. The generator intentionally omits user, courtyard, fabrication-drawing, margin, and adhesive layers from the supplier fabrication folder.

The source specifies mainboard thickness 1.60252 mm and faceplate thickness 1.6 mm. It does not specify a copper finish. ENIG is a quote preference from the upstream production notes, not a property proven by these PCB files. The supplier must state the proposed ENIG specification and stack-up before release.

## DRC and ERC results

All checks used severity `all`; DRC also enabled schematic parity and returned exit code 5 because violations exist. No violation has been waived.

| Check | Errors | Warnings | Additional parity warnings | Unconnected items |
| --- | ---: | ---: | ---: | ---: |
| Mainboard DRC | 38 | 45 | 40 | 0 |
| Faceplate DRC | 6 | 13 | 9 | 0 |
| Mainboard ERC | 28 | 96 | n/a | n/a |
| Faceplate ERC | 2 | 24 | n/a | n/a |

Mainboard DRC errors comprise 24 copper-to-edge clearance, 8 annular-width, and 6 footprint-type findings. Faceplate DRC errors comprise 5 clearance and 1 footprint-type finding. DRC warnings also include library-footprint differences, silkscreen rules, text height, one faceplate copper sliver, and one faceplate dangling via. These may reflect upstream design intent or library drift, but each requires disposition against the board house's rules and the original designer's evidence.

ERC ran with an isolated KiCad configuration and the official KiCad 8 symbol/footprint directories, without reading or changing the user's global KiCad configuration. The remaining results include mainboard 89 and faceplate 22 library-symbol issues, plus pin-to-pin, power-not-driven, multiple-net-name, and dangling-wire findings. Library issues are not treated as electrical proof, and the other findings are not silently dismissed. The JSON reports preserve every item for review.

Independent native netlist comparison confirmed at least one material mainboard parity mismatch: C23 pin 2 is on schematic net `-5VA` and routed PCB net `GND`. Although the schematic `-5VA` net also includes several ground-like pins, this package does not infer that the mismatch is cosmetic. It remains a source-circuit-review hold.

The native reports contain their own generation date and tool metadata, so byte hashes of those reports and Gerbers need not remain stable across regeneration. The generated BOM, classification, review placement, supplier-filtered placement, external addendum, and pin JSON are deterministic for fixed inputs and KiCad native position output.

## Source immutability

The generator reads the two pinned PCB files and writes only under `hardware/procurement/assembly-quote/`. DRC/ERC were read-only invocations. Source hashes are recorded in `manifest.json`; the originals remained unchanged during generation and validation.
