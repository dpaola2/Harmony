---
title: "D Touch: owned-parts design and assembly proposal"
type: reference
project: harmony
tags: [project/harmony, hardware, design]
created: 2026-11-07
updated: 2026-11-07
as_of: 2026-11-07
source: "Dave's design discussion and bare-electrode confirmation; owned-parts audit; vendor CAD; generated fit geometry"
---

# D Touch: build the desk wedge around the parts we own

Use the larger Waveshare display, a Feather ESP32 V2, the Mark-7 battery and one MPR121 for five capacitive buttons. No wheel is required. Dave permits taking Mark-7 apart. The MPR121 electrode holes are bare, so the design reserves space for flat wire connections.

The reused socket stack makes this enclosure larger than the earlier custom-board concept. **Revision A measures 112 × 94 mm, with a 28 mm front and 64 mm rear.** These are CAD dimensions, not a physically qualified build.

[Open the visual proposal](d-capacitive-reuse-proposal.html). [Download the CAD and print kit](d-touch-rev-a-fit-kit.zip). The kit is an **unpowered fit candidate**. Start with the touch coupons. Do not transfer the battery into a powered build until its retention and wiring pass inspection.

![Assembled CAD proposal](d-touch-rev-a-assembled.png)

## What this proposal changes

D becomes a prototype we can develop with owned electronics. It retains the working Bluetooth playback platform and the larger Mark-6 display. It replaces the proposed mechanical keys with copper electrodes behind the printed face.

The salvaged iPod wheel remains available for another form. E retains its 2-inch display proposal. The earlier STM32/ESP32 architecture remains a separate option; this design does not require it.

| Requirement | D Touch treatment | Remaining proof |
| --- | --- | --- |
| Music playback | Reuse Feather Bluetooth Classic playback and SD library | Playback while browsing and touching controls |
| Larger screen | Owned Waveshare 29318, 480 × 320 landscape | Driver orientation, active-area alignment and harness access |
| No touchscreen | Ignore the display's touch input; use five separate capacitive pads | Accidental touches and operation while charging |
| Faster navigation | Hold Up/Down to accelerate; preserve list position when returning | Full-library latency; this enclosure adds no compute performance |
| Serviceable wiring | Supplied display harness and STEMMA QT cable | Existing carrier termination and cable bend paths |
| Less soldering | Five short electrode leads; no added tall electrode headers | Ten electrode-lead joints remain; this is not a solder-free build |
| Sleep and wake | Explicit Sleep command; physical Reset for initial wake | Reset access, whole-device current and state restoration |
| USB music transfer or accessible SD | Existing card workflow for the prototype | External SD opening is not yet designed; fast USB storage is not provided |
| Battery percentage | Software estimate remains a candidate | Voltage under load and charge calibration; no fuel gauge is added |
| Thin, durable enclosure | Desk form accepts the reused stack; PLA for cold fit | Final material, thermal behavior and portability remain open |
| Centered screen | Active area centered from vendor CAD | Confirm the actual module revision before closing |

## Measurements checked

Dimensions below distinguish source geometry from design allowances. A successful CAD check cannot verify the installed cables, actual screw heads or battery condition.

| Item | Dimension in mm | Evidence and limit |
| --- | --- | --- |
| Body | 112 W × 94 D × 28–64 H | New parametric CAD; about 21° slope |
| Face | 112 × 100.66 | Derived from the 94 mm depth and 36 mm rise |
| Tray walls / floor | 2.2 / 2.4 | Design choice |
| Main face / touch skin | 2.0 / 1.2 | Skin is provisional; test 0.8, 1.2 and 1.6 coupons |
| Waveshare complete module | 92.447 × 61.011 × 10.550 | Bounding box of the supplied vendor STEP, including glass |
| Active display | 73.447 × 48.970 | Front face extracted from vendor STEP |
| Display aperture | 74.447 × 49.970 | 0.5 mm allowance at each active edge |
| Glass seat | 0.3 lateral clearance per edge; front recessed 1.6 | CAD allowance; confirm the glass and bezel fit |
| LCD clip clearance | About 0.05 at the glass back | Nominal geometry only; do not force clips or preload glass |
| Mark-7 carrier | 53.5 × 28.3 × 1.6 | Existing carrier STEP |
| Carrier to Feather top | 19.77 measured; 20.27 reserved | Dave's prior assembled-stack measurement with 0.5 allowance |
| MPR121 QT PCB | 33.020 × 19.177; 27.94 mount pitch | Adafruit Eagle board outline and mounting holes |
| MPR121 component reserve | 5 above a 1.6 PCB | Assumed envelope; measure the actual board and QT plugs |
| Battery | Published 50 × 60 × 7.3; reserve 50.5 × 62.5 × 8.1 | Prior build allowance; inspect the actual pouch and leads |
| Battery cover clearance | 1.5 above the reserved pouch | Geometric allowance, not a battery swelling specification |
| Touch electrodes | Five 12 × 14 pads, 18 pitch, 6 gaps | Proposed geometry; two joined 6 mm tape strips per pad |
| Closure | Four M2 × 8 screws, M2 × 10 female standoffs | 2.6 clearance holes, 3.3 across-flats pockets with 2 mm retaining roofs |
| Closure screw engagement | Nominal 4.3 | From recessed head seat to standoff; verify actual hardware |
| Rear access window | 14 × 12 | Service allowance only; USB plug and Reset alignment unqualified |

The Feather and MPR121 drawings use populated-volume reserves. Mounting regions are relieved around the spacers. These reliefs require inspection against actual components. They are not detailed PCB models.

The CAD distance check finds **5.153 mm** between the LCD and reserved Feather stack, and **15.723 mm** above the battery cover. These clearances exclude cables. All 26 print meshes are watertight single solids. The four 3MF layouts pass import and plate-bound checks. No intersections remain among the checked parts and component envelopes.

The original 104 × 82 mm D body assumed a different board arrangement. Its 18–58 mm heights do not qualify the reused socket stack. This proposal supersedes those dimensions only for D Touch.

## Controls and electrical plan

| Electrode | Face label | Tap | Hold |
| --- | --- | --- | --- |
| E0 | Back | Return one level | No repeated Back action |
| E1 | Up | Previous item | Accelerated scrolling |
| E2 | OK | Select | Enter volume mode from Now Playing |
| E3 | Down | Next item | Accelerated scrolling |
| E4 | Play | Play/pause | No repeated toggling |

One MPR121 handles all five pads. Seven channels remain unused. The MPR121 uses I²C address `0x5A` by default. Use the Feather's STEMMA QT connection for matching 3.3 V power and I²C. Confirm the firmware's QT power-enable configuration before scanning the bus.

The initial firmware polls the touch status. Leave INT unconnected in this version. Touch-to-wake requires a separate power and interrupt design. If sleep removes sensor power, touching the face cannot wake the player. A dark display alone does not establish low-power sleep.

Use the existing Waveshare 15-pin harness and onboard SD path documented in Mark-6. Do not substitute the unbuilt 18-pin carrier proposal. Retain the known pin mapping from that working build. This enclosure proposal does not establish a new electrical pinout.

### Make the touch panel on the bench

1. Print the three skin coupons on plate 01.
2. Cut five 12 × 14 mm electrodes from the owned 6 mm copper tape.
3. Join each pair of tape strips electrically. Do not assume the adhesive conducts across the seam.
4. Solder each lead to its electrode before attaching the tape to plastic.
5. Solder the other ends through E0–E4 on the bare MPR121 board.
6. Use a fixture to hold each joint. Fit heat shrink before soldering where it must slide over a joint.
7. Meter each electrode for continuity. Check isolation between adjacent pads.
8. Attach the electrodes inside the coupon. Secure the leads so they cannot peel the copper.
9. Connect the MPR121 through STEMMA QT. Test on a spare Feather if available.
10. Compare each skin while resting, holding the enclosure and connecting USB power.

Record baseline readings, reliable tap response, held touches and false detections. Choose the thickest skin that works reliably. Keep the five leads short and separated from noisy display wiring. Do not change thresholds during a held touch without a defined release rule.

Firmware should debounce presses and releases, reject ambiguous combinations, and accelerate scrolling only for Up/Down. Measure touch-to-highlight latency against a proposed 100 ms target. Hold behavior and thresholds remain tuning work.

## Parts and supplies for this variant

Ownership evidence comes from the [[05-projects/mp3-player/mark-8/design/2026-11-07-owned-parts-audit|November 7 audit]]. Purchased quantities do not establish today's loose-stock count.

| Part | Quantity | Source / status |
| --- | --- | --- |
| Headered Feather ESP32 V2, #5900 | 1 | Four purchased; reuse Mark-7 or a verified spare |
| Mark-7 passive carrier and socket strips | 1 assembly | Reuse; inspect soldered harness terminations |
| Waveshare 29318 and supplied 15-pin harness | 1 | Owned Mark-6 hardware; inspect cable condition |
| MPR121 QT #1982 | 1 | Owned; Dave confirms bare electrode holes |
| STEMMA QT cable | 1 | Owned 100 mm cable candidate; routing and slack must fit |
| Copper tape #3483 | Ten 6 × 14 mm strips | Owned 6 mm tape; electrically bond paired strips |
| Insulated electrode wire | 5 short leads | Owned wire; cut after the dry route test |
| Adafruit #328 battery | 1 | Reuse Mark-7; inspect pouch, connector and lead exit |
| microSD and reader | 1 each | Reuse known music card after backup |
| M2 × 10 female/female brass standoffs | 4 | Owned 3 mm across-flats parts; verify stock |
| M2 × 8 machine screws | 4 | Closure screws through clearance holes |
| M2 × 6 self-tapping screws | 16 | Four carrier, two MPR121, four LCD, four cover, two cable guides; verify thread and length |
| Printed parts | 19 | Two shells, one cover, four clips, ten spacers, two cable guides |
| Solder, flux, heat shrink, insulation | As needed | Prior supplies; recount before assembly |
| Battery cushioning / insulating retention material | Fit to measured cell | **Usable stock unresolved.** Do not count the old delivery receipt as proof |
| PLA filament | Fit kit | Existing stock; final powered material requires thermal review |
| Non-slip feet | Optional for fit; desirable in use | Stock unverified; test desk stability |

No new processor, custom PCB, ribbon adapter or wheel controller is required for the first bench test. The missing cushioning and unverified harness fit prevent claiming a complete final-build inventory.

## Numbered assembly proposal

![Exploded CAD assembly study](d-touch-rev-a-exploded.png)

The numbers describe subassemblies. Build the face separately on a protected surface before connecting it to the tray. The illustration omits wires and internal screws for clarity. Translucent blocks show reserved volumes, not exact populated-board shapes.

1. **Prepare the tray.** Check the side-loading standoff coupon first. Slide four brass standoffs sideways into their captive pockets. The retaining roofs resist screw pullout. Temporarily secure the side entries with insulating tape during assembly. Remove print debris. Inspect every pilot and clearance hole.
2. **Install the carrier.** Seat the carrier on its printed posts. Fit four 2 mm spacers above its mounting holes. Use four self-tapping screws. Check component clearance around the spacer positions before tightening. Plug in the Feather and check its full height.
3. **Retain the battery.** First rehearse with the printed dummy. Confirm cushioning, lead exit and clearances with the actual cell disconnected. Install the raised cover with four self-tapping screws. The cover must not compress the pouch. Keep fasteners and wires away from it.
4. **Build the touch assembly.** Install the five electrodes inside the face using the successful coupon geometry. Mount the MPR121 on the tray posts with two under-head spacers and two screws. Leave enough wire slack to open the face. Check the QT connector bend and service loop.
5. **Mount the display.** Seat the glass in the face recess. Fit all four clips and four 2 mm under-head spacers. Start every screw loosely, then check centering. The clips retain the module without bending the glass. Rehearse the supplied harness, SD removal and cable guides with power disconnected.
6. **Close the face.** Check every cable while lowering it onto the tray. Use four M2 × 8 machine screws into the brass standoffs. These screws pass freely through the face; they do not cut threads in plastic. Stop if closure requires force.

The cable guides use two self-tapping screws. Their small underside channels are provisional. They must restrain an insulated lead without crushing it. Adjust them after the actual harness is routed.

Before powering, inspect insulation, polarity and continuity. Confirm that nothing presses on the battery. Test with the case open first. Compare touch behavior, charging temperature and Bluetooth playback again after closing.

## CAD and Bambu print package

The kit contains parametric CadQuery source, per-part STEP and STL files, four unsliced 3MF layouts, high-resolution views and a validation report. All quantities are placed explicitly.

| Plate | Contents | Purpose |
| --- | --- | --- |
| 01-touch-tests | Three skin coupons and one fastener coupon | First print; select skin and verify brass fit |
| 02-shell-fit | Tray and sloped face | Unpowered body fit; face placed outer-side down |
| 03-internals | Cover, four LCD clips, ten spacers, two cable guides | Complete internal printed set |
| 04-dummies | Battery, Feather-stack and MPR121 component envelopes | Cold layout rehearsal; not substitutes for the real parts |

Open the 3MF files as geometry in Bambu Studio. Select the actual printer, build plate and filament. The files contain no sliced toolpaths or printer presets. Their layouts fit within a 256 × 256 mm plate.

Suggested starting profile: 0.4 mm nozzle, 0.20 mm layers, four walls, four top and bottom layers, and 15% gyroid infill. These are prototype settings, not a tested profile. The thin touch region becomes solid where the skin is thinner than the specified shell layers.

Start with supports off. Review the sliced rear window bridge and inclined brass pockets. If the bridge needs support, paint it locally and keep removal access clear. Do not fill the tray or electrode recess with automatic supports. Inspect the first-layer aperture and every pilot hole in Preview. A watertight mesh does not prove support-free printing.

Use the labeled 2 mm spacers from this kit. Do not substitute a visually similar old spacer. Print all four clips and all ten spacers before disassembly.

## Implementation and acceptance

1. Back up the card, current firmware and working wiring record before dismantling Mark-7.
2. Bench-test the touch coupons. Confirm all five inputs and stable release behavior.
3. Bring up the larger screen in landscape with the existing SD and Bluetooth path.
4. Test long artist lists, navigation memory and playback together. Record response times and dropouts.
5. Print the unpowered enclosure. Check the actual boards, clip fit, battery dummy, screw engagement and cables.
6. Resolve the access openings. Confirm USB insertion, Reset reach and a workable SD service path.
7. Complete battery retention and insulation before the powered assembly.
8. Measure playback current, charging temperature and real sleep current with the case closed.

The external SD opening, dedicated wake control, final material and battery percentage remain unfinished requirements. This proposal gives us a testable mechanical and input design. It does not claim those broader Mark-8 goals are already delivered.

## Evidence and files

- [Validation report](d-touch-rev-a-validation.json): generated mesh, plate and intersection checks.
- [CAD source and working directory](/Users/dave/projects/Harmony2/enclosure/mark-8/d-touch-rev-a/build.py).
- [Waveshare vendor STEP](/Users/dave/projects/Harmony2/hardware/mark-6/carrier-rev-a/reference/waveshare-29318/3.5inch_Capacitive_Touch_LCD_3Dand2D/3.5inch_Capacitive_Touch_LCD.step).
- [Mark-7 carrier STEP](/Users/dave/projects/Harmony2/hardware/mark-7/carrier-rev-a/mechanical/carrier.step).
- [Adafruit MPR121 CAD](https://github.com/adafruit/Adafruit-MPR121-PCB): board outline, mount pitch and supplied license.
- [Adafruit MPR121 overview](https://learn.adafruit.com/adafruit-mpr121-12-key-capacitive-touch-sensor-breakout-tutorial/overview): twelve channels and QT interface.
- [Adafruit MPR121 pinouts](https://learn.adafruit.com/adafruit-mpr121-12-key-capacitive-touch-sensor-breakout-tutorial/pinouts): supply, address and interrupt behavior.

## Cross-References

- [[03-living-docs/decisions/2026-11-07-harmony-d-capacitive-reuse|Adopted prototype direction and limits]]
- [[05-projects/mp3-player/mark-8/design/2026-11-07-owned-parts-audit|Owned-parts evidence and counterevidence]]
- [[05-projects/mp3-player/mark-8/design/_index|Design notes and visual artifacts]]
- [[05-projects/mp3-player/mark-8/design/d-desk-wedge|Earlier D custom-board proposal]]
- [[05-projects/mp3-player/mark-8/design/e-side-control-bar|E compact alternative]]
- [[05-projects/mp3-player/mark-8/_index|Mark-8 requirements]]
- [[05-projects/mp3-player/mark-7/2026-10-31-build-retrospective|Mark-7 assembly and software lessons]]

Define Mark-8 from Mark-7 field and assembly lessons ([[HARMONY-22]]) owns work tracking. This note records the design and its evidence.
