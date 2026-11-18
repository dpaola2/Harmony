# Harmony Mark-8 slab rev A: printing

Printer: Bambu A1, 0.4 nozzle, no AMS. Every file in `print/` is already in its print orientation and centred on the plate. Import the 3MF into Bambu Studio and slice. The STL files are the same parts in the same orientation.

## Plates

| Plate | File | Colour | Notes |
| --- | --- | --- | --- |
| Case | `print/case-colour-plate.3mf` (front shell, back plate, button cap) | Your choice. The renders use a warm off-white | One colour, so they share a plate |
| Wheel | `print/wheel-disc.3mf` | Black | Own plate, because there is no AMS |

Single parts: `front-shell`, `back-plate`, `button-cap`, `wheel-disc` (`.3mf` and `.stl`).

## Material

PLA or PETG. PLA gives the cleanest window chamfer, pins and labels. PLA softens at about 55 C, so do not leave the player on a car dashboard. PETG survives heat better but strings more; dry it first. Use the same material for the shell and the back plate. Heat-set insert temperature depends on the material (ASSEMBLY.md step 1).

## Settings per part

| Part | Orientation | Plate | Layer | Walls | Top / bottom | Infill | Supports |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Front shell (1) | Front face down | Textured PEI | 0.2 (first layer 0.2) | 4 | 5 / 5 | 25 % gyroid | None (see the two top boss shelves below) |
| Back plate (10) | Outer face down | Textured PEI | 0.2 | 4 | 5 / 5 | 25 % gyroid | None |
| Wheel disc (2) | Back face down (flange on the plate), front face up | Smooth PEI or textured | 0.1 | 3 | solid | 100 % | None. Ironing on for the top surface |
| Button cap (3) | Lying flat, as exported | Textured PEI | 0.1 | 3 | solid | 100 % | None |

Other settings: elephant foot compensation 0.15 on the shell and the back plate (the window and wheel opening sit on the plate). Seam position: back or aligned. No brim on the shell and plate. Use a brim (3 mm) on the button cap: it is small. Keep the plate clean and free of glue so the front face comes out even.

## What to expect

- **Front face.** The shell prints face down on the textured PEI plate, so the whole front face, including the bezel around the window, gets the plate's texture. The 1.0 edge round on the front edge sits on the plate. Its lowest 0.3 mm is steeper than 45 degrees; on PEI this prints with at most a slight lip. The back plate's outer face and edge round print the same way.
- **Window chamfer.** The 0.4 x 45 degree chamfer on the window's front edge is in the first two layers. It prints without support.
- **Bridges, no supports needed:** the top of the USB-C opening and its port recess, the top of the card slot and its scallop (the scallop is 46 degrees at most), the top of the side button slot and its pocket, and the ring-shaped ceiling of each screw counterbore in the back plate. The disc has two small bridges over the USB-C leg pockets on its back face.
- **Top boss shelves.** The two bosses under the screen's top corners start 3.6 mm above the plate and hang about 3 mm out from the corner walls. They print as a corner overhang. Their underside faces the back of the screen with a 0.45 gap, so a little sag does no harm. If they sag badly, paint a support enforcer on those two spots only, and scrape the support marks off the bezel area under the screen corners.
- **Thin spots by design** (all listed with numbers in README.md "Printability"): the skin is 0.6 over the disc flange recess and 0.5 over the two USB-C leg reliefs; the bottom wall is 0.7 behind the port recess and the card scallop; the disc flange is 0.4 thick; the button cap flange is 0.4 in front of the switch and 0.6 at the ears; the LED shroud tube wall is 0.65; there is 0.7 of plastic under each screw head and 0.5 over each top insert hole.

## After printing

1. Remove any stringing from the window, the wheel opening and the card slot.
2. Test-fit the disc in the shell (step 2 of ASSEMBLY.md). The gap should be an even, thin ring. If it binds, sand the disc edge lightly.
3. Test-fit the screen without the board. It should drop in with very little play. If it is tight at the sides, scrape the two side walls of the pocket lightly.
4. Test the button cap in its slot: it should slide freely and stop on the outside pocket floor.
5. Check that both locating pins are complete and straight.
