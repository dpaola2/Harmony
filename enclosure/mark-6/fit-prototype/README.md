# Mark 6 hollow fit prototype

September 26: the physical trial found a recessed control and excessive wheel clearance. Use the [revision B candidate and assembly plan](../fit-rev-b/README.md) for the next print. The original print files remain unchanged for comparison.

September 22 update: Dave reports that the printed tray, front, carrier gauge and spacers are received. The display has shipped. These reports confirm procurement progress; physical fit remains unverified. Use the [arrival checklist](../../../hardware/mark-6/carrier-rev-a/arrival-checklist.md) for the dry fit.

Prepared September 22, 2026 after Dave accepted the 74 × 178 × 28 mm solid size dummy. This is an unpowered fit shell for the current carrier geometry. The updated front fits the selected Waveshare 29318 vendor geometry. See the [display selection](../../../hardware/mark-6/carrier-rev-a/display-sourcing.md).

## Print files

The [prepared A1 plates](slicing/README.md) contain the shells together and an optional second plate with the carrier gauge and four spacers. Both projects have been sliced locally with Bambu PLA Basic, a 0.4 mm nozzle and Textured PEI Plate. Estimated total: 116 minutes and 80 g. Confirm the installed nozzle, plate and filament before printing. No job was sent.

Print one [tray](print/harmony-mark6-tray.3mf) and one [front](print/harmony-mark6-front.3mf). Both files already lie flat on the bed: tray floor down, front outside face down. Use 100% scale, millimetres. The 3MF files contain geometry only, with no printer profile or toolpaths.

Start with PLA, a 0.4 mm nozzle and 0.2 mm layers. The nominal 1.6 mm walls suit four 0.4 mm extrusion widths. The prepared projects use four walls, 15% gyroid and no supports. Deposited-path review confirms the display bezel occupies the first two layers, with a wider recess from layer three. The card opening requires a roughly 20 mm bridge. Physical bridge quality and fit remain unverified.

The optional [carrier gauge](print/harmony-mark6-carrier-gauge.3mf) reproduces the board outline and eight mounting holes. It has no contacts. Print four copies of the [12 mm ANO spacer](print/harmony-mark6-ano-spacer-12mm.3mf) when checking the controls stack. STL equivalents are in `print/`; editable STEP exports are in `cad/`.

## What to check

1. Dry-fit the empty tray and front. The alignment lip has 0.25 mm radial clearance. It is not a snap latch; use tape for the trial.
2. Set the carrier gauge on the four posts. Carrier bottom is 6.5 mm above the outside rear face. The 2.1 mm blind pilot holes are a starting point for M2.5 screws cutting threads in plastic; establish fit gently before tightening. Choose screw length from the actual stack, without bottoming in the roughly 5.5 mm pilot depth.
3. Check the Feather with its actual factory headers and Samtec sockets once available. The model assumes a 2.54 mm male-header body, giving only 0.88 mm nominal clearance below the front. The gauge cannot validate electrical mating or header insertion depth.
4. Check the ANO board on 12 mm spacers. The wheel opening is 35.4 mm. Its rotation, click travel and cable exit need a physical check. The firmware initially reports raw inputs; button direction labels must be checked against this rotated mounting.
5. Check USB plug reach and microSD removal through the generous side openings. Keep USB unplugged from power during this mechanical trial. The plug needs room outside the Feather connector, which is recessed from the case edge.
6. Trial the display and ribbon with the selected Waveshare 29318. The current recess clears the 61.011 × 92.447 mm glass bounds from the vendor STEP; its deepest rear feature makes total thickness 10.550 mm. Its 0.4 mm bezel is a sacrificial fit feature, with no permanent display fasteners. Support the display by hand and do not force the front closed.

The battery reservation remains empty and unconnected. The shell does not establish battery retention, thermal clearance or swelling allowance. There are no validated final enclosure fasteners or display retainers yet.

## Validation

`validation.json` records one valid solid per part, watertight meshes, consistent winding, flat bed placement, 3MF round-trip dimensions and file hashes. All four part types fit within a 256 mm square bed. Nominal tray/front intersections with the vendor Feather and ANO solids, vendor display solids and reserved battery volume are zero. This checks the modeled geometry; it does not establish tolerances or physical fit.

Rebuild with:

```sh
uv run --with cadquery==2.8.0 --with trimesh --with matplotlib --with networkx --with lxml python build.py
uv run --with cadquery==2.8.0 --with trimesh --with matplotlib --with networkx --with lxml python render_preview.py
```

The [preview](preview/hollow-fit.png) is rendered from the delivered STL meshes. Related work: HARMONY-17 and the [carrier mechanical review](../../../hardware/mark-6/carrier-rev-a/mechanical-review.md).
