# Harmony R2 assembly quote review

**Quote review only. Fabrication remains on hold.** This package uses the Harmony R2 schematic correction derived from Tangara hardware commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52`. The routed PCBs are unchanged. The source manifest covers the derived sources, including the corrected schematic and library definitions.

Read the [independent circuit review](../../reviews/harmony-r2/REVIEW.md), [validation](VALIDATION.md), and [release holds](RELEASE-HOLDS.md) before using these files. Earlier September 14 packages remain preserved as baseline evidence.

The mainboard and faceplate BOMs carry quantities for one, two and five boards. The external addendum lists the ribbon cable, motor and candidate battery separately. Use the supplier-filtered placement CSVs for quote preview. Coordinates and rotations preserve native KiCad conventions and still require assembler preview approval. Raw placement exports are retained for comparison.

Gerbers and drills are regenerated with KiCad 8.0.9 from the unchanged routed PCBs. Programming images are the same hardware-unqualified baseline as R1. No pricing response, material procurement, programming service or physical test is implied by this package.

Regenerate from the live repository or preserved archive root:

```sh
python3 hardware/procurement/assembly-quote-r2/generate_quote_package.py --kicad-cli /absolute/path/to/kicad-cli
```

The generator does not run circuit checks. Rerun the review's native-check script before regeneration after any source change. `manifest.json` hashes the derived sources and delivered outputs. The unsent supplier questions identify the battery, display and fabrication inputs still needed.
