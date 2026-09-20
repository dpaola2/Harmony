# Harmony Tangara assembly quote review package

Status: **quote review only; not released for fabrication, purchasing, substitution, or programming.**

This package derives one quantity-safe BOM per routed board from the pinned Tangara hardware at commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`. Quote quantities are one, two, and five complete sets. One set is one mainboard, one faceplate, one interconnect FFC, and the external items explicitly listed in the addendum.

## Review order

1. Review `RELEASE-HOLDS.md`. The display mechanics, battery, DRC, and all real-hardware programming and functional tests remain gates.
2. Review `mainboard-bom.csv` and `faceplate-bom.csv`. `qty_per_board` is the authoritative installed quantity for one board. The 1, 2, and 5 columns are arithmetic extensions and must remain distinct in a quote.
3. Review `dnp-and-non-purchased-structures.csv`. It explicitly removes DNP parts, copper electrodes, test pads, mounting holes, logos, and programming footprints from procurement.
4. Review `external-parts-addendum.csv`. The haptic motor appears here once per set; faceplate J1/J2 are only its solder pads.
5. Use the `*-placement-supplier.csv` files for supplier import when present. They retain native KiCad coordinates and rotations but filter out source rows classified as DNP or non-purchased. The `*-placement-kicad-raw.csv` files are untouched native exports for audit. The `*-placement-review.csv` files expose source coordinates for reconciliation only.
6. Review `fabrication/`, `logs/`, and `manifest.json` before attaching native fabrication outputs to any quote.
7. Review `programming/programming-manifest.json` with `PROGRAMMING-NOTES-DRAFT.md`. The directory contains the exact seven ESP32 flash images plus the SAMD factory bootloader BIN/ELF and application BIN/UF2; the large ESP32 debug ELF is intentionally omitted.

## Placement convention

All placement units are millimetres. Native `*-placement-kicad-raw.csv` exports use KiCad 8's position-file convention. In these source boards KiCad's default position export uses absolute board coordinates, negates Y, and reports bottom-side rotation in the native convention. The supplier CSV preserves those native numeric fields. Side and rotation must be validated in the assembler preview, especially bottom-side transformations and polarized or asymmetric parts. The review CSV preserves the routed PCB's absolute footprint `(at X Y rotation)` and `F.Cu`/`B.Cu` side without inventing a manufacturing rotation correction. Its `SOURCE_ORIENTATION_REVIEW_ONLY` marker is intentional.

## Deterministic regeneration

Run from the repository root:

```sh
python3 hardware/procurement/assembly-quote/generate_quote_package.py --kicad-cli /absolute/path/to/kicad-cli
```

Omit `--kicad-cli` only for BOM and source-coordinate review. Native Gerber, drill, and supplier position outputs then remain absent. The generator deletes and recreates only its own `fabrication/` directory when native export is requested. `manifest.json` records source and output hashes. The generator's CSVs are deterministic; KiCad may embed its own generation metadata in native outputs.

The upstream PCB files are KiCad 8.0 format. Use the pinned KiCad 8 tool recorded in the manifest for quote reproduction; do not silently resave the source in a newer editor.
