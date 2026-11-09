---
title: "Harmony D Revision B: direct display harness and taller tray"
type: reference
status: prototype-cad-reviewed
created: 2026-11-07
updated: 2026-11-07
as_of: 2026-11-07
project: harmony
tags: [project/harmony, hardware, design, assembly]
source: "Dave's connector measurements; vendor Feather and Waveshare CAD; revision B validation reports"
---

# Harmony D Revision B

Revision B mounts the spare Feather upright and plugs the existing Waveshare cable directly onto its male pins. The printed tray includes four supports. Two screws through the Feather's actual mounting holes secure it. The two supports near USB carry insertion loads from below.

The enclosure is **112 mm wide and 94 mm deep, with a 44 mm front and 80 mm rear**. It is 16 mm taller than Revision A. The faceplate, display clips, battery cover, touch-board spacers and cable guides retain their previous geometry. The Mark-7 carrier is omitted.

**CAD review passes. Physical assembly remains unqualified.** The measured USB plug clears its opening. The 18 mm socket bodies and the reserved bends clear the tray. Actual cable lengths, the display's mating plug, cushioning and printed tolerances remain physical checks. The first print is a small mount fixture, before another complete tray.

## Visual review

- [Open the illustrated assembly review](d-touch-rev-b-assembly.html)
- [4800-pixel exploded drawing](rev-b-exploded-4800.png)
- [4800-pixel assembled clearance drawing](rev-b-assembled-4800.png)
- [Dimensioned side, USB and top views](rev-b-dimensions.svg)
- [Print and CAD package](d-touch-rev-b-fit-kit.zip)
- [Mount audit](rev-b-mount-validation.json)
- [Mesh and plate audit](rev-b-validation.json)

The exploded drawing uses the exported CAD. Its separation distances are illustrative. Hardware colors identify parts; print all plastic parts in black PLA. Amber blocks reserve connector and wire space. They are not printable parts or a complete routed harness.

## Measurements and clearances

All dimensions below are millimeters. Height coordinates start at the exterior bottom of the tray.

| Feature | Dimension or result | Evidence |
|---|---:|---|
| Case width / depth | 112 / 94 | CAD |
| Front / rear height | 44 / 80 | CAD |
| Face angle | 20.956 degrees | CAD |
| Floor / side walls | 2.4 / 2.2 | CAD |
| Touch skin / other face thickness | 1.2 / 2.0 | CAD; assembled touch still needs testing |
| Feather PCB underside | z = 29.0 | CAD |
| Socket drop from PCB to wire exit | 18.0 | Dave's measurement |
| Socket wire exit | z = 11.0 | Derived from measured drop |
| Bend allowance below exit | 5.5 | Design allowance, not a measured bend radius |
| Lowest bend allowance / floor clearance | z = 5.5 / 3.1 | CAD |
| Feather to display | 14.641 minimum | Vendor geometry distance check |
| USB opening width / height | 15 / 13 | CAD |
| USB body width / thickness / length | 10.17 / 4.45 / 14.45 | Dave's measurements |
| Exposed USB metal length | 6.86 | Dave's measurement |
| USB body clearance per side | 2.415 | CAD |
| USB body clearance below / above | 3.975 / 4.575 | CAD |
| Display module | 92.447 × 61.011 × 10.550 | Vendor STEP |
| Display window | 74.447 × 49.970 | CAD |
| Battery allowance | 50.5 × 62.5 × 8.1 | Existing build allowance |
| Cover underside above battery allowance | 1.5 | CAD; not a swelling qualification |
| Copper pads / center spacing | 12 × 14 / 18 | CAD |

The independent mount audit checks 69 pairs with no volume interference. Feather-to-support contact is intentional. The USB plug body is checked through the rear wall. Its metal tip intentionally occupies the receptacle and is excluded from collision rejection. Connector retention, insertion force and electrical continuity are not CAD results.

## What to print

The final assembly has **15 printed pieces**. The test pieces are additional. The 3MF files contain geometry only, without a printer profile or G-code.

| File or set | Quantity | Purpose |
|---|---:|---|
| `05-feather-usb-fit-first.3mf` | 1 fixture | Print first: 38 × 57 × 40 mm, copied from the final tray |
| `base-tray.stl` | 1 | New tray with direct Feather supports and revised USB opening |
| `sloped-face.stl` | 1 | Faceplate; reuse a finished Revision A face if undamaged |
| `battery-cover.stl` | 1 | Raised cover over the battery |
| `lcd-clip-1.stl` through `lcd-clip-4.stl` | 4 | Display retainers |
| `lcd-clip-spacer-1.stl` through `lcd-clip-spacer-4.stl` | 4 | 2 mm spacers under the clip screw heads |
| `touch-board-spacer-1.stl` and `touch-board-spacer-2.stl` | 2 | 2 mm spacers under MPR121 screw heads |
| `cable-clamp-1.stl` and `cable-clamp-2.stl` | 2 | Cable guides beside the battery |

`02-shell-fit.3mf` contains the tray and face. `03-internals.3mf` contains the 13 other assembly pieces. Do not print old carrier spacers. `01-touch-tests.3mf` and `04-dummies.3mf` remain optional references. Existing successful coupons do not need repeating.

Use a 0.4 mm nozzle, 0.20 mm layers, four walls, four top and bottom layers, and 15% gyroid infill. Print the tray upright and the face outer-side down, as exported. Inspect the rear USB bridge and brass pockets in the slicer. Use only removable local support where Preview requires it. Keep supports out of the touch recess and screw pilots.

## Parts and fasteners

Reuse the headered spare Feather ESP32 V2, Waveshare 3.5-inch display, its 15-wire cable, onboard microSD card, MPR121, white-to-white STEMMA QT cable and battery. Five copper pads and their electrode wires complete the controls. The display connection requires no soldering. The electrode connections still do.

| Hardware | Quantity | Allocation |
|---|---:|---|
| M2 × 6 self-tapping screws | 14 | Feather 2; display clips 4; MPR121 2; battery cover 4; cable guides 2 |
| M2 × 8 machine screws | 4 | Face closure |
| M2 × 10 female/female brass standoffs | 4 | Side-loaded closure pockets |
| Copper pads | 5 | 12 × 14 mm each; electrically join both 6 mm tape strips |
| Battery cushioning | Unconfirmed | 0.5 mm allowance beneath the cell; establish suitable material and retention before powered assembly |

The screw quantities assume the listed thread types and lengths. The printed pilots are 1.7 mm diameter. Machine-screw clearance holes are 2.4 or 2.6 mm as modeled. Do not force a machine screw into a self-tapping pilot. The Feather screws do not use the old carrier spacers.

## Numbered assembly sequence

1. **Check the fixture first.** Disconnect USB and the battery. Attach the ten sockets before lowering the Feather onto the fixture. Leave room for the wires to curve. Secure its two mounting holes with M2 × 6 self-tapping screws. Confirm the rear pads contact the board. Insert the measured USB cable with the other end disconnected. Stop if the PCB bends, sockets lift, or wires press against the floor. This fixture checks the Feather mounting and USB access, not the whole enclosure.
2. **Mount the MPR121 in the final tray.** Use two M2 × 6 screws, with the 2 mm spacers above the PCB under the heads. Connect the QT cable while accessible.
3. **Mount the Feather upright.** Components face upward; header pins and the female sockets point downward. USB faces the rear opening. Use the two front mounting holes. The rear supports have no screws. Rehearse USB insertion again with the complete tray.
4. **Dry-fit the disconnected battery.** Establish the cushioning and lead route before fastening the cover. Keep the lead outside the pouch footprint. Confirm the connector reaches the Feather without tension.
5. **Fit the battery cover.** Use four M2 × 6 screws. The cover must seat on its posts without pressing the cell. Place the two cable guides beside the battery; keep the wires outside the pouch area.
6. **Prepare the face.** Place five copper pads inside the touch recess. Their centers are x = 20, 38, 56, 74 and 92 mm. Keep solder joints inside the recess. Connect E0 through E4 for Back, Up, OK, Down and Play. Secure the leads so movement cannot pull on the electrode holes.
7. **Seat the display.** Place its glass against the face shelf with the visible area centered in the opening. Check the module and connector orientation against the assembled CAD. Inspect any existing orange mounting hardware before fitting; the model uses the vendor module geometry.
8. **Fit the four display clips.** Each screw passes through a 2 mm spacer, then the clip, into the printed boss. Use M2 × 6 self-tapping screws. Tighten only enough to retain the module. Do not load the glass.
9. **Rehearse all cables with power disconnected.** Follow the pin table below. Route the display bundle beside the battery using the guides. Leave enough slack to open the face without pulling sockets or pads. Verify the white display plug, SD access, QT cable and battery lead with the real parts. The diagrams do not establish their cable lengths.
10. **Close only after the dry fit passes.** Insert four brass standoffs into the side pockets. Keep wires clear of their pockets and the rim. Lower the face without force and install four M2 × 8 machine screws. Check all five touch pads again during the later powered test.

## Display cable mapping

This is the recorded working Mark-6 mapping for the same Waveshare display and Feather. Trace the connector pin numbers and board labels. Do not identify a wire by color alone.

| Waveshare 15-pin connector | Signal | Feather silkscreen |
|---|---|---|
| 1 | VCC | 3V |
| 3 | GND | GND |
| 4 | MISO | MI |
| 5 | MOSI | 27 |
| 6 | SCLK | 14 |
| 7 | SD_CS | A1 |
| 8 | LCD_CS | A0 |
| 9 | LCD_DC | 33 |
| 10 | LCD_RST | 32 |
| 11 | LCD_BL | A5 |

Leave pin 2 and pins 12 through 15 disconnected. The MPR121 uses its QT cable. This wiring table does not install the player firmware; the spare currently runs the separate touch test.

## Evidence and remaining limits

Dave supplied the socket and USB measurements on November 7, 2026. The Feather and Waveshare shapes come from the retained vendor STEP files. The pin mapping comes from `hardware/mark-6/feather-sd-bench-20260927/bench-config.json` in the Harmony2 repository.

The battery and QT plug models remain inherited allowances. Socket width is reserved at 3.2 mm. The display's white mating plug, continuous cable routes and service-loop length are not measured models. CAD checks cover the board, socket bodies, local bend volumes and USB opening. They do not establish a fully qualified wired assembly.

Source and individual STEP/STL files: `/Users/dave/projects/Harmony2/enclosure/mark-8/d-touch-rev-b/`. Revision A and the earlier wheel, D and E concepts remain separate, unchanged historical artifacts.

## Cross-References

- [[05-projects/mp3-player/mark-8/design/_index|All Mark-8 design proposals]]
- [[05-projects/mp3-player/mark-8/design/d-capacitive-reuse-proposal|Revision A and touch prototype rationale]]
- [[05-projects/mp3-player/mark-8/design/2026-11-07-owned-parts-audit|Owned-parts evidence]]
- [[03-living-docs/decisions/2026-11-07-harmony-d-capacitive-reuse|Adopted prototype direction and mounting correction]]
- [[05-projects/mp3-player/mark-7/2026-10-31-build-retrospective|Mark-7 assembly lessons]]
