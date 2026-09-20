# Harmony R4 quote package

**Engineering and pricing only. Not released for fabrication, component purchasing, assembly or programming.** R4 replaces the proposed R3 board geometry with the unmodified current Tangara reference boards. The sent R3 files remain historical; R4 has not been sent.

Quote 1, 2 and 5 complete sets: each has a four-layer mainboard with 92 fitted parts and a two-layer faceplate with 19 fitted parts, nominal 1.6 mm FR4 and ENIG. Prefer standard green soldermask. Exact costs and quantities require review before ordering.

## Changes from R3

- Restore upstream audio-jack slots, lands and cutout and both boards' original copper fills. Both routed source files are byte-identical to Tangara commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`.
- Retain that upstream revision's G-Switch connector replacement and R3's schematic corrections.
- Complete three order codes through [documented BOM overrides](bom-order-code-overrides.json). BOM/placement-review MPNs take precedence over abbreviated CAD properties; no unapproved alternative parts.
- Keep ER-TFT018-4 and EVQ-P40B3M volume buttons. The original factory BOM excluded display placement; R4 requests it explicitly.

## Supplier scope

Please quote turnkey procurement and assembly, display soldering/mounting, haptic motor soldering/mounting, and programming both ESP32 and SAMD processors. Show any manual work, tooling, testing, freight and taxes separately. Confirm connector orientation and placement previews before assembly. State lead time, stock allocation and any minimum assembly quantity.

Review the inherited USB copper-to-cutout termination, jack annuli/slots, touch artwork etching and assembly tolerances against the supplied source. The original Tangara production package is comparison evidence, not a replacement BOM or alternate manufacturing input. Submit proposed CAM changes/substitutions for approval; do not silently refill zones or update footprints.

Battery is unselected and outside this board quote. Quote the FFC and haptic motor in the external addendum separately; the three battery quantities are planning placeholders, not purchase instructions. Firmware builds are validated but have not run on our physical hardware. Confirm the factory's SAMD SWD programming path and test scope before release. Obtain approval before charging engineering fees.

## Contents

- `*-bom.csv`: fitted components; `dnp-and-non-purchased-structures.csv`: explicit exclusions
- `*-placement-supplier.csv`: native filtered placements; `*-placement-review.csv`: readable reference and MPN cross-check
- `fabrication/`: native KiCad Gerbers, drills and board jobs
- `programming/`: pinned images and hashes; assembly/programming instructions accompany the submission
- `manifest.json`: source and output sizes/hashes; `source-and-tool-pins.json`: exact versions
- [Engineering review](../../reviews/harmony-r4/REVIEW.md)

No purchase or release follows from this draft. HARMONY-9 and HARMONY-15 hold current task state.
