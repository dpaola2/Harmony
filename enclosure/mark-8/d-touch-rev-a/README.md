# Harmony D Touch revision A

Status: UNPOWERED FIT CANDIDATE. November 7, 2026.

This is a complete geometric study and cold-fit kit, not a qualified powered assembly.
Body: 112 W × 94 D mm; 28 mm front, 64 mm rear; 20.956° face.

## Start here

Print `print/01-touch-tests.3mf` first. Compare 0.8, 1.2 and 1.6 mm skins with the actual MPR121, tape and wires. The fourth object tests the side-loaded brass pocket and M2 clearance.

Read `proposal.md` for the BOM, source measurements, assembly sequence and unresolved requirements. The full enclosure assumes a 1.2 mm touch skin. A different coupon result requires regenerating the face.

## Contents

- `build.py`: parametric CadQuery geometry and export checks.
- `audit_clearance.py`: additional minimum-distance measurements from the exported STEP files.
- `render.py`: 3600 × 2600 assembled and exploded views from the actual CAD.
- `cad/*-print.step`: individual parts in printing orientation.
- Other `cad/*.step`: parts and component references in assembled coordinates.
- `print/*.stl`: bed-aligned single-part meshes in mm.
- `print/01-touch-tests.3mf`: three touch coupons and one fastener coupon.
- `print/02-shell-fit.3mf`: tray and sloped face.
- `print/03-internals.3mf`: 17 objects, including all clips and spacers.
- `print/04-dummies.3mf`: three reserved-volume fit dummies.
- `preview/`: assembled-coordinate meshes and high-resolution images.
- `validation.json`: mesh checks, plate checks, intersection results and selected minimum distances.
- `reference/`: source footprint and provenance records.

The 3MF files contain geometry only. Select the real printer, plate and material in Bambu Studio before slicing. No G-code is supplied.

## Print settings to evaluate

Use a 0.4 mm nozzle and 0.20 mm layers. Start with four walls, four top/bottom layers and 15% gyroid infill. PLA is suitable for the cold-fit study. The face is outer-side down. The touch skin is continuous and solid.

Start with supports off, then inspect Preview. The rear access bridge and side-loaded brass pockets need particular attention. Add only removable local support if required. Do not fill the tray or touch recess with automatic support. Review holes and thin skin layer by layer.

## Complete printed assembly

- Tray: 1
- Face: 1
- Battery cover: 1
- LCD edge clips: 4
- LCD under-head spacers, 2 mm: 4
- Carrier under-head spacers, 2 mm: 4
- MPR121 under-head spacers, 2 mm: 2
- Cable guides: 2

Total: 19 parts. The seven test/dummy pieces are additional.

## Fasteners

Four M2 × 8 machine screws close the face into four M2 × 10 female/female brass standoffs. The standoffs enter sideways beneath 2 mm retaining roofs. Temporarily secure the side entries with insulating tape during handling. Check the actual hardware in the coupon first.

Sixteen M2 × 6 self-tapping screws secure the carrier (4), MPR121 (2), display clips (4), battery cover (4) and cable guides (2). Confirm actual thread type, length, head diameter and engagement. Do not force machine screws into self-tapping pilots.

## Known limits

Cables, connector overhangs, actual populated-board details, internal screws, and battery leads are not fully modeled. PCB mounting reliefs within the component envelopes require physical inspection. The LCD clip gap is nominally about 0.05 mm; adjust it if printing tolerance creates glass pressure.

The rear window does not establish USB or Reset alignment. No external SD slot has been cut. Battery cushioning stock is unresolved. Do not compress the pouch or assume a 1.5 mm cover gap qualifies swelling accommodation. Perform the layout with the dummy and disconnected cell first.

The electronic scope is the existing Feather, Waveshare harness and one MPR121. Firmware changes, low-power wake and fast USB music transfer are not supplied by this CAD package.

## Reproduce

Use Python 3.12 with cadquery, trimesh, numpy, scipy, networkx, lxml and VTK. Run `python build.py`, `python audit_clearance.py`, then `python render.py`.

The Waveshare source STEP is retained at its existing Harmony2 repository location and in `reference/waveshare-vendor-original.step`. `build.py` uses the bundled copy when the original checkout is unavailable. The kit also includes the transformed vendor model at `cad/waveshare-vendor-module.step`; exported prints can be used without rebuilding. Adafruit footprint attribution and license are retained in `reference/`.
