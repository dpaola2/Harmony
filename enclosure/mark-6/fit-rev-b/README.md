# Mark 6 mechanical revision B

Print the wheel-check plate first. This revision raises the control, reduces its opening, and adds removable fasteners and display supports. It needs physical qualification before carrier procurement proceeds.

The September 26 dry fit passed the empty shell, carrier gauge and LCD alignment checks. The rotary control fitted, but its top was nearly flush and its surrounding gap exposed the board. Loose spacers made the trial difficult.

## Adopted dimensions and evidence

| Feature | First prototype | Revision B candidate |
| --- | --- | --- |
| ANO spacer height | 12 mm | 14 mm |
| Circular opening | 35.4 mm | 33.0 mm |
| Measured outer control ring | 31.83 mm | Same delivered part |
| Centered radial clearance | About 1.79 mm | About 0.59 mm |
| Highest control surface relative to face | 0.53 mm recessed | 1.47 mm proud |

The ring measurement comes from `evidence/IMG_7704.HEIC`. The other three original photos show the gauge, spacers and assembled control. Dimensions of the printed opening still need measurement. CAD places the lower 34 mm flange below the faceplate; verify its clearance through full directional-button travel.

Dave authorized this revision and a stored assembly plan on September 26. He has not accepted its printed fit. No carrier order or powered test follows from this record.

## First print and test

1. Open `slicing/wheel-check/harmony-m6-b-wheel-check-a1.3mf` in Bambu Studio.
2. Confirm the A1, 0.4 mm nozzle, PLA and Textured PEI Plate match your printer.
3. Print the plate at 100% scale.
4. Keep the electronics disconnected.
5. Put the small square wheel coupon over the rotary control.
6. Align its four underside feet with the board's mounting holes.
7. Let the feet rest on the board without forcing the ring through the opening.
8. Support the board and coupon together. Check rotation, center press and all four directional presses.
9. Confirm that the raised ring feels comfortable and does not rub or stick.

The coupon reproduces the revised faceplate height relative to the rotary board. It avoids balancing the entire enclosure. Keep the four printed 14 mm spacers for full assembly. The pilot coupon is for screw trials after fasteners arrive. Its holes are 6 mm deep. Test only 3 mm of screw engagement; do not seat a screw head against this coupon.

Do not print the complete replacement shells until the wheel coupon passes. Revision B front and tray form a matched pair. Preserve the first prototype for comparison.

## How the assembly holds together

### Rotary control

Use four M2.5 x 20 mm pan-head machine screws and four matching nuts. Prefer insulating nylon fasteners for this trial. Pass each screw through the rotary board, a 14 mm spacer, and the carrier. Fit its nut below the carrier before fastening the carrier into the tray.

The modeled stack below each screw head is 17.17 mm. A 20 mm screw leaves about 2.83 mm below the carrier. Use nuts no thicker than 2 mm. The nominal screw tip clears the tray floor by 2.07 mm. Head diameter must not exceed 4.5 mm; head height must not exceed 2.5 mm. Nut corner diameter must not exceed 6.4 mm. These envelopes require physical checks. Do not add washers without recalculating engagement and clearance.

The spacer holes remain unthreaded. The screws and nuts clamp the stack. Check the carrier's actual traces and components around all mounting holes before installation.

### Carrier and Feather

Use four nominal M2.5 x 6 mm screws suited to forming threads in printed plastic. The existing tray pilots are 2.1 mm. A nominal 1.6 mm carrier leaves 4.4 mm engagement. Trial the actual screw in the pilot coupon before using a tray post. Stop if the plastic cracks or the screw binds. Pilot diameter can change without changing the carrier.

The Feather plugs into factory-installed Samtec SSW-116-01-G-S and SSW-112-01-G-S sockets. Both sockets are already in the carrier assembly BOM. Do not buy loose sockets for this assembly. The printed gauge cannot verify socket insertion or Feather height.

### Display supports

Four separate retainers reach under the display's rear metal mounting feet. Two are left-handed and two are right-handed. Four matching columns are part of the revised front. Their pilot holes accept nominal M2 x 8 mm screws suited to printed plastic.

Each screw passes through a retainer and engages its front column by about 6 mm. Retainer holes are plain clearance holes. The front columns have 1.6 mm pilots and unpierced outer faces. Trial the actual screw in the pilot coupon first.

Place one 0.5 mm thick nonconductive foam pad on each retainer's circular support. Keep pads within the 5 mm support diameter. The CAD leaves 0.3 mm below each metal foot before padding. Pad compression and module movement need a physical check. Tighten only until each retainer seats against its column. Do not use screw force to bend the display or close a case gap.

These supports do not use the metal feet's internal holes. The design therefore makes no claim about their thread size. It also leaves the ribbon latch and the display's rear components accessible.

### Case closure

Three nominal M2.5 x 6 mm screws pass through the front into new tray posts. Two sit near the top corners. One sits at the lower left, away from the antenna end of the Feather. Their 2.1 mm pilots start below the front seam. The alignment lip locates the front; the screws retain it.

Both shells need replacement to use these closure screws. Keep screws and nuts away from the antenna reservation. The display bezel remains 0.4 mm thick and needs gentle handling.

## Assembly order after the fit checks

1. Test the selected screws in the pilot coupon.
2. Secure the rotary board, spacers and carrier with through-screws and nuts.
3. Inspect the carrier underside and screw-tip clearance.
4. Fasten the carrier into the tray.
5. Seat the Feather in its factory-installed sockets.
6. Seat the LCD in the front recess, with the front supported on a soft cloth.
7. Fit the padded display retainers.
8. Check the ribbon and QT cable routes with all power disconnected.
9. Lower the front without trapping cables.
10. Fit the three closure screws without forcing the seam.

The real carrier, exact screw fit, cable orientation, Feather seating and populated case still need physical checks. Battery space remains unused. Supplier DFM and staged power qualification remain separate release conditions.

## Fastener quantities

| Item | Quantity | Use |
| --- | --- | --- |
| M2.5 x 20 mm pan-head machine screw | 4 | Rotary board through-bolts |
| M2.5 nut, at most 2 mm thick | 4 | Rotary board through-bolts |
| M2.5 x 6 mm screw for printed plastic | 7 | Four carrier posts and three closure posts |
| M2 x 8 mm screw for printed plastic | 4 | Display retainers |
| Nonconductive foam, 0.5 mm thick | Four 5 mm pads | Display feet |

This is a dimensional specification, not a verified supplier cart. Match the head envelopes and test pilot fit before ordering bulk quantities. No purchase occurred.

## Verification and sources

`validation.json` records solid, mesh, size and interference checks. `slicing/verification.json` records the prepared plates and deposited-path review. These checks do not establish print quality, screw holding strength or physical acceptance.

The source geometry and earlier prints remain in [fit-prototype](../fit-prototype/README.md). The [carrier arrival checklist](../../../hardware/mark-6/carrier-rev-a/arrival-checklist.md) owns staged qualification. The [carrier mechanical review](../../../hardware/mark-6/carrier-rev-a/mechanical-review.md) records the original stack. This revision supersedes its 12 mm spacer height for the candidate enclosure only. Carrier electrical files are unchanged.

Tracking: Harmony Mark-6: Bluetooth bench player (HARMONY-17). Vault entry: `/Users/dave/projects/assistant/05-projects/mp3-player/mark-6/_index.md`.
