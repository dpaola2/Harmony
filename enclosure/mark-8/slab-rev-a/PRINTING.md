# Harmony Mark-8 slab rev A: printing

Printer: Bambu P2S Combo with AMS 2 Pro, 0.4 mm hardened steel nozzle, textured PEI plate. One Bambu Studio project prints all four parts on one plate in two colours. The AMS changes the colour. You do not swap filament by hand.

## The plate

| File | Parts | Filament | Time | Filament used |
| --- | --- | --- | --- | --- |
| `print/mark8-slab-p2s.3mf` (project) and `print/mark8-slab-p2s.gcode.3mf` (the same plate, sliced) | Front shell, back plate, button cap | Filament 1: Bambu PLA Basic, Jade White | 55 min for the plate | 20.5 g |
| | Wheel disc | Filament 2: Bambu PLA Basic, Black | | 1.9 g |

Bambu Studio 2.09 gave these numbers on 21 November 2026, after the fixes from the exploded diagram check (54.6 min, 20.52 g and 1.94 g). The 22.5 g total includes 3.6 g of waste from the colour changes (see "Colour changes" below).

The project does not set AMS slot numbers. Load Jade White and Black in any two AMS slots. Map them in the print dialog (step 4 below).

## Print the plate

1. Open `print/mark8-slab-p2s.3mf` in Bambu Studio.
2. Check the settings at the top left. Printer: "Bambu Lab P2S 0.4 nozzle". Plate type: "Textured PEI Plate". Filament 1 is white and filament 2 is black, both "Bambu PLA Basic @BBL P2S". Process: "0.20mm Standard @BBL P2S", shown as modified.
3. Click "Slice plate". In the preview, check that the disc is black and the other three parts are white. A brim is only around the button cap. The prime tower is in the back left corner.
4. Click "Print plate". In the dialog, map filament 1 to the AMS slot with Jade White. Map filament 2 to the slot with Black. Keep bed levelling on. Send the job.

To skip slicing, open `print/mark8-slab-p2s.gcode.3mf` and start at step 4. If Bambu Studio offers to sync the filaments from the AMS, check after the sync that the disc is still black and the other parts are still white.

Keep the plate clean and free of glue, so the front face comes out even.

## Material

Bambu PLA Basic, Jade White for the case and Black for the wheel disc. PLA gives the cleanest window chamfer, pins and labels. PLA softens at about 55 C, so do not leave the player on a car dashboard. Heat-set insert temperature depends on the material (ASSEMBLY.md step 1).

## Settings per part

The project holds every value below. Each part carries its own values as object settings, so they stay with the part if the process preset changes.

| Part | Orientation | Filament | Layer | Walls | Top / bottom | Infill | Other |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Front shell (1) | Front face down | 1, Jade White | 0.2 (first layer 0.2) | 4 | 5 / 5 | 25 % gyroid | Elephant foot compensation 0.15. No brim. No supports |
| Back plate (10) | Outer face down | 1, Jade White | 0.2 | 4, Arachne | 5 / 5 | 25 % gyroid | Elephant foot compensation 0.15. No brim. No supports |
| Wheel disc (2) | Back face down (flange on the plate), front face up | 2, Black | 0.2 | 3 | solid | 100 % | Ironing on the topmost surface (the front face). Elephant foot compensation 0.075. No brim. No supports |
| Button cap (3) | Lying flat, as exported | 1, Jade White | 0.2 | 3, Arachne | solid | 100 % | Brim 3 mm, outside only. Elephant foot compensation 0.075. No supports |

Whole plate: seam aligned, walls inner then outer, infill after the walls, top surfaces monotonic line with one wall, bottom surfaces monotonic, prime tower on. The P2S defaults already match PRINTING.md for the seam, the wall order and the top surfaces, so the project keeps them.

## Changes from the A1 version

| Setting | A1 version | P2S project |
| --- | --- | --- |
| Printer | Bambu A1, no AMS | Bambu P2S Combo, AMS 2 Pro |
| Plates | Two: the case colour parts, then the disc | One plate with all four parts |
| Layer height of the disc and the button cap | 0.1 | 0.2 (Decision 2) |
| Button cap and back plate walls | Not set (classic) | Arachne (Decision 5) |
| Elephant foot compensation, disc and button cap | A1 default 0.075 | 0.075. The P2S default is 0.15, so the project sets it |
| Ironing on the disc | "On for the top surface" | Topmost surface only (Decision 6) |
| Prime tower | None | 35 mm wide, back left corner, first 5 layers |
| Flush volumes | None | 670 mm³ black to white, 190 mm³ white to black, multiplier 1 |
| Speeds and accelerations | A1 "0.20mm Standard" | P2S "0.20mm Standard" defaults, not changed |

The project also overrides these P2S defaults: plate type (default Cool Plate), brim (default auto), walls (default 2), bottom layers (default 3) and infill (default 15 % grid).

## Decisions

1. **One plate for all four parts.** Dave chose this on 21 November 2026, so he prints the whole case in one job. The back plate now prints before the screen cable dry-fit. If the cable fold does not fit when the screens arrive, reprint the back plate alone ("Reprint the back plate" below).
2. **One layer height, 0.2, for all parts.** Bambu Studio refuses mixed layer heights with a prime tower ("The prime tower requires that all objects have the same layer heights"). The slicer gave these numbers for the options:

   | Option | Time | Colour changes | Waste |
   | --- | --- | --- | --- |
   | 0.2 for all, prime tower (chosen) | 54 min | 5 | 3.6 g |
   | 0.2 shell and back plate, 0.1 disc and cap, no prime tower | 60 min | 9 | 5.2 g |
   | 0.1 for all, prime tower | 83 min | 9 | 6.1 g |

   What 0.2 costs in detail: the disc flange top (0.4), the label floors (0.6) and the front face (1.0) all fall on layer boundaries. The labels keep their full 0.4 depth. The line width sets the letter outlines, not the layer height. The two USB-C leg pockets on the back of the disc print 0.6 deep instead of 0.5, so the plastic over them is 0.4 instead of 0.5. The disc edge shows 5 layer lines instead of 9. The button cap is a straight 2.6 mm extrusion, so all its details lie flat on the plate. At 0.2 its sides only show coarser layer lines.
3. **Prime tower on.** It wipes the nozzle after each colour change, in the layers that make the white front faces. Without it, Bambu Studio allows mixed heights, but the plate then needs 9 changes and more waste.
4. **Flush volumes from Bambu Studio's colour calculation**, multiplier 1. If the white front face shows grey streaks, raise the flush multiplier to 1.2 (Bambu Studio, "Flushing volumes") and slice again.
5. **Arachne walls on the button cap and the back plate.** With classic walls, the slicer left two gaps of about 0.3 mm² in the thin flange of the button cap on every layer (94 % of the section filled). Arachne fills 98 %. The back plate changed on 21 November: the neck of the LED light tube is now a 0.45 wall (README, conflict 11). Classic walls lay two loops 0.07 mm apart there, about 45 % more plastic than the wall holds, which would thicken the tube toward J1 and J3. Arachne lays one 0.4 mm bead (checked in the G-code). It adds about 10 s to the plate. The front shell keeps classic walls; it fills more than 99 % of each layer checked.
6. **Ironing on the topmost surface only.** It irons the disc front face and not the floors of the labels.
7. **Elephant foot compensation 0.075 on the disc and the button cap.** The A1 plan used 0.15 only on the shell and the back plate, and the A1 default (0.075) elsewhere. The project keeps that.
8. **Layout.** No part is rotated; every file is already in print orientation. The shell and the back plate are side by side. The disc and the button cap are on the right. Bambu Studio put the prime tower in the back left corner.
9. **No AMS slot numbers in the project.** You map the slots in the print dialog.

## Colour changes

Layers 1 to 5 (up to 1.0 mm, the height of the disc) have black and white in the same layer. The AMS changes the filament once in each of these layers: 5 changes. Each change flushes the nozzle into the purge chute: 670 mm³ from black to white (3 times) and 190 mm³ from white to black (2 times), about 3.0 g in total. The prime tower uses about 0.6 g. Above 1.0 mm, the plate prints white only.

## Reprint the back plate

Open `print/mark8-slab-p2s.3mf`. Delete the front shell, the button cap and the wheel disc. Slice and print. The back plate keeps its settings. With one filament, there is no prime tower and no colour change. The single-part files `print/back-plate.3mf` and `print/back-plate.stl` stay in the folder.

If a fix changes the back plate geometry, run `build.py` first. Then right-click the back plate in Bambu Studio, choose "Replace with STL" and pick the new `print/back-plate.stl`. Or run `p2s_print.py` to make the whole project again.

## Make the project again

`python3 p2s_print.py` reads the STL files in `print/` and writes `print/mark8-slab-p2s.3mf` and `print/mark8-slab-p2s.gcode.3mf`. It uses the Bambu Studio command line and the P2S system profiles. It prints the time, the filament weights and the number of colour changes. Run it after `build.py` changes a part.

`print/case-colour-plate.3mf` is the old A1 plate. `build.py` still writes it. You do not need it for the P2S.

## What to expect

- **Front face.** The shell prints face down on the textured PEI plate, so the whole front face, including the bezel around the window, gets the plate's texture. The 1.0 edge round on the front edge sits on the plate. Its lowest 0.3 mm is steeper than 45 degrees; on PEI this prints with at most a slight lip. The back plate's outer face and edge round print the same way.
- **Window chamfer.** The 0.4 x 45 degree chamfer on the window's front edge is in the first two layers. It prints without support.
- **Bridges, no supports needed:** the top of the USB-C opening and its port recess, the top of the card slot and its scallop (the scallop is 46 degrees at most), the top of the side button slot and its pocket, and the ring-shaped ceiling of each screw counterbore in the back plate. The disc has two small bridges over the USB-C leg pockets on its back face.
- **Top boss shelves.** The two bosses under the screen's top corners start 3.6 mm above the plate and hang about 3 mm out from the corner walls. They print as a corner overhang. Their underside faces the back of the screen with a 0.45 gap, so a little sag does no harm. If they sag badly, paint a support enforcer on those two spots only, and scrape the support marks off the bezel area under the screen corners.
- **Thin spots by design** (all listed with numbers in README.md "Printability"): the skin is 0.6 over the disc flange recess and 0.5 over the two USB-C leg reliefs; the bottom wall is 0.7 behind the port recess and the card scallop; the disc flange is 0.4 thick; the button cap flange is 0.4 in front of the switch and 0.6 at the ears; the LED light tube wall is 0.65 at its base and 0.45 at its neck, where it passes J1 and J3 (README, conflict 11); there is 0.7 of plastic under each screw head and 0.6 over each top insert hole.
- **Heights that are not a multiple of 0.2.** The slicer moves them to a layer boundary. So every height that sets a fit is a whole number of layers above its part's bed: the shell rim 8.4, the boss faces 7.8, the post tips 8.0, the screw pads 1.8, the LED tube 6.6, and the USB-C opening 1.6 to 5.4. That is why the case is 9.6 thick, not 9.5. Until November 21 the rim (8.3) and the boss faces (7.7) printed at 8.4 and 7.8, so the printed case was 9.6 anyway and the press posts lost their planned press (exploded diagram G-code check). Heights that set no fit still move. The floor of the USB-C leg reliefs in the shell (0.5) prints at 0.6, so the skin there is 0.6 and the reliefs are 0.1 shallower. The screw counterbore ceilings in the back plate (1.1) print at 1.0, so a 1.1 mm screw head stands about 0.1 proud of the back face. The card slot (2.24 to 4.04 from the front face) prints at 2.2 to 4.0, still 1.8 tall.

## After printing

1. Remove the brim from the button cap.
2. Remove any stringing from the window, the wheel opening and the card slot.
3. Look at the white front faces for grey streaks from the colour changes (Decision 4).
4. Test-fit the disc in the shell (step 2 of ASSEMBLY.md). The gap should be an even, thin ring. If it binds, sand the disc edge lightly.
5. Test-fit the screen without the board. It should drop in with very little play. If it is tight at the sides, scrape the two side walls of the pocket lightly.
6. Test the button cap in its slot: it should slide freely and stop on the outside pocket floor.
7. Check that both locating pins are complete and straight.
8. Check that the LED light tube on the inside of the back plate (near the USB-C end) is complete and straight, and that the three small standoffs on the inside of the shell's bottom wall printed.
