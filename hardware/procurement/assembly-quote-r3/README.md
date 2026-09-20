# Harmony R3 assembly quote review

**Engineering and quote review only; fabrication remains on hold.** R3 includes corrected power symbols, source annotations, net-aware touch electrodes, a faceplate GND refill, and a revised audio-jack footprint. It derives from Tangara hardware commit `9853b4a1dc8a0e3ea3ec75450522e42df12eaa52` through Harmony R2. Both PCB files now differ from upstream. The manifest identifies every derived source file.

Read the [independent review](../../reviews/harmony-r3/REVIEW.md), [validation](VALIDATION.md), and [release holds](RELEASE-HOLDS.md). [Draft supplier questions](DFM-QUESTIONS-DRAFT.md) are prepared for review and have not been sent.

BOM quantities cover one, two and five boards: 92 fitted components on each mainboard and 19 on each faceplate. The external addendum separately lists the motor, ribbon cable and candidate battery. Use supplier-filtered placement CSVs for quote preview; native coordinates and rotations require assembler preview approval.

KiCad 8.0.9 regenerated Gerbers, drills and placements from R3. The 11 programming images retain the previous build hashes and have not been qualified on hardware. Earlier dated packages remain preserved.

Regenerate from the live repository or preserved archive root:

```sh
python3 hardware/reviews/harmony-r3/run_native_checks.py --kicad-cli /absolute/path/to/kicad-cli
python3 hardware/procurement/assembly-quote-r3/generate_quote_package.py --kicad-cli /absolute/path/to/kicad-cli
```

Copy the four fresh native check JSON reports from the review directory into this package before regenerating. The generator exports manufacturing data; it does not clear design findings. No supplier submission, pricing response, purchase or physical test is implied.
