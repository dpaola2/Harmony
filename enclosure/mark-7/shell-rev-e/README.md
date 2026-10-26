# Mark-7 matched shell, revision E

Revision E uses four captive brass standoffs and machine screws for repeated opening. Remove only the four rear screws to reach the SD card. The four visible front screws stay installed and retain the standoffs. This replaces revision D's self-tapping closure. Physical fit and repeated opening remain untested.

The body remains 64 × 105 × 34 mm. The 1.2 mm perimeter rounding, corrected USB/Reset openings, wider screen supports, and accepted display/ANO positions carry forward from [revision D](../shell-rev-d/README.md). Both the front and rear shells must be replaced. Existing screen clips, screen/ANO spacers and battery cover can be reused.

## Hardware to buy

Amazon listings checked October 25, 2026. Prices and delivery estimates can change. All three packs are in Dave’s Amazon cart; checkout has not been completed.

| Item | Needed | Selected pack | Price | Delivery shown |
| --- | ---: | --- | ---: | --- |
| Brass M2 × 10 mm female/female hex standoff, 3 mm across flats | 4 | [uxcell, 50 pieces, B08LCXRH7H](https://www.amazon.com/dp/B08LCXRH7H) | $9.99 | October 28 |
| Stainless M2 Phillips pan-head machine screws | 4 × 16 mm and 4 × 6 mm | [cSeao M2 assortment, B0BD2CXW7D](https://www.amazon.com/dp/B0BD2CXW7D) | $8.99 | October 27 |
| Flexible 28 AWG silicone-insulated stranded tinned-copper wire | Ten short display/SD leads | [BNTECHGO, 10 colors × 10 ft, B01M5EY57C](https://www.amazon.com/dp/B01M5EY57C) | $9.98 | October 27 |

Total: $28.96 before tax. Select the **M2** screw kit and **M2 × 10 mm** standoffs. Other diameter or hex-width variants do not match these pockets. The listing's screw drawing specifies a 3.2 mm head diameter and 1.3 mm head height. The design uses plain screw heads without washers. No heat-set inserts, installation tip, glue, or separate nuts are needed for this closure.

Dave's IMG_8076 shows a COMRUN 350-piece **M2 nylon** kit. It includes 6/10/15/20 mm female/female spacers, matching male/female spacers, washers, nuts and 6/8/12 mm screws. Keep it as spare spacing hardware. It does not contain the metal threads or 16 mm screws selected for this closure.

## Remaining assembly inventory

| Part or supply | Quantity/use | Recorded status |
| --- | --- | --- |
| M2 × 6 steel self-tapping screws | 8 screen/ANO, 4 carrier, 4 battery cover; 16 total | Existing steel assortment; check remaining count |
| Printed carrier spacers | 4, 2 mm high | Included in fit-check plate |
| Screen clips and screen/ANO spacers | Existing accepted mounting kit | Reuse |
| Carrier PCB, 12- and 16-position female sockets, Feather | 1 assembly | Arrived; dry fit confirmed; carrier socket soldering unconfirmed |
| Display/SD, ANO and QT cable, battery and power leads | Existing working player | Reuse |
| Insulated flexible wire | Ten display/SD connections, with enough slack to open case | Dave clarified he has only jumper wires. Selected hookup wire is in cart; not purchased. |
| Foam and heat-shrink | Existing cushioning and wire insulation | Recorded as owned |
| Electronics solder, iron, cutters/strippers, small Phillips screwdriver | Assembly tools | Iron, solder, wire strippers and small Phillips screwdriver confirmed owned; flush cutters not separately confirmed |
| Filament | Same material/profile for coupon and shells | Existing printing setup |

Do not put self-tapping screws into the brass standoffs. The internal plastic pilots still need the existing self-tapping screws; the new machine-screw kit does not replace them. Mark-7's present Reset-wake configuration needs no new resistor. Optional ANO interrupt wake needs one 10k resistor and a separate INT wire. Mark-8's wheel still needs its two 10k resistors; that separate purchase remains unconfirmed.

The selected hookup wire has 16 strands of 0.08 mm tinned copper and a listed 1.2 mm insulation diameter. Use it for short display/SD connections with a service loop; retain the existing battery and QT leads. Check that the wire stripper supports 28 AWG.

## Closure geometry

Each brass standoff sits at z = 2.2 to 12.2 mm. A 3.25 mm across-flat hex pocket opens from the inside of the faceplate column and ends at a shoulder at z = 12.2. Its flats prevent rotation. A 2.3 mm screw clearance bore continues through the faceplate.

The front M2 × 16 screw seats at z = 26 and engages 2.2 mm of brass. The rear M2 × 6 screw seats at z = -1 and engages 2.8 mm. Their tips remain 5 mm apart. These are nominal dimensions; verify actual screws and threads before assembly. Front heads project 1.3 mm beyond the nominal body.

Top columns are 6 × 4 mm with screw centers at (20, 102.1) and (44, 102.1). The hex pocket leaves only 0.375 mm at its thinnest side walls. Those walls locate the standoff; the upper shoulder carries the screw load. This is a cold slip fit, not a press fit. Do not force the brass into an undersized pocket. A full-height coupon tests the actual narrow column before committing to a shell print.

## Print and assemble

1. Print `print/mark7-shell-e-fit-checks.3mf` using the intended shell material and settings. These files are bed-oriented geometry, not sliced printer jobs.
2. Insert one brass standoff into the closure-column coupon from its open end. Use one M2 × 16 screw through the opposite, flat face to draw the standoff gently against the shoulder. It must slide without splitting the pocket walls.
3. Place the 1.6 mm coupon tab against the column end. Fit one M2 × 6 screw through the tab into the exposed brass end. Tighten lightly. Remove and reinstall this rear screw several times, checking for rotation, cracks and looseness. Leave the front screw installed.
4. Test the screen coupon with its tab, 1.4 mm spacer and an existing M2 × 6 self-tapping screw. Check the wider support for cracking.
5. With battery and USB disconnected, use the port-fit section to check the measured carrier/Feather stack, actual USB plug, Reset access and socket-tail/solder clearance. Support the overhanging board.
6. After the coupons pass, print `print/mark7-shell-e-shell-kit.3mf`. It contains the matching front, tray and battery cover. Inspect the face-down front, hex-pocket transition, USB bridge and tall columns in the slicer. Keep supports out of pockets and bores.
7. Install all four brass standoffs using the four front screws. Test the empty shell with the four rear screws before transferring electronics.
8. Reuse screen/ANO mounts, fit carrier spacers and retain battery cushioning. Route the display wires with enough slack to open the case without loading solder joints. Check the populated shell before tightening.

Routine SD access: disconnect USB, remove the four rear screws, lift the front carefully and disconnect the battery before manipulating internal wiring. Do not remove the front screws or disassemble the control mounts. Music transfer still uses the Mac SD reader and [Harmony Sync](../../../docs/harmony-sync.md).

## Validation and limits

All 3,633 modeled intersection comparisons pass. The ten-object fit plate and three-object shell plate pass watertightness, solid-count, bed-placement and 3MF reload checks.

`validation.json` records modeled intersections and the measured 19.77 mm carrier-to-Feather stack and 14 mm carrier-to-USB-bottom height. `print/validation.json` records watertight meshes, single solids, bed placement and 3MF round trips. Geometry checks do not qualify printed strength or actual hardware tolerances.

The measured stack has about 2.65 mm clearance below the lowest display component before wiring. No depth reduction is made in this revision. Socket dimensions, solder protrusion, cable bends, plug insertion, Reset access, battery restraint, charging temperature and closed-case Bluetooth still need physical checks. No full-shell print or hardware purchase has been confirmed.

Run `build.py`, `prepare_print.py`, then `render.py` with Python 3.11, CadQuery 2.8.0, trimesh, scipy, networkx, lxml and VTK. All outputs stay in revision E.

## References

- [Carrier revision A](../../../hardware/mark-7/carrier-rev-a/README.md)
- [Accepted screen and ANO mounts](../ano-mount-rev-b/README.md)
- [Measured shell revision D](../shell-rev-d/README.md)
- Build Mark-7 portable Bluetooth player (HARMONY-19) tracks hardware arrival and physical acceptance.
