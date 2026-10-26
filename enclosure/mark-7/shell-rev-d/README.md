# Mark-7 matched shell, revision D

Superseded by [revision E](../shell-rev-e/README.md), which uses captive brass standoffs and machine screws. Use the revision E fit coupons before printing the matching shells. Revision D remains a historical self-tapping closure candidate.

Revision D replaces both the old rear tray and the faceplate that lacks closure columns. It keeps the accepted screen and ANO positions and the 64 × 105 × 34 mm body. The front and back perimeter edges now use a 1.2 mm radius instead of a 1 mm chamfer. The corners in plan remain at 5 mm radius.

Dave confirmed on October 25, 2026 that the purchased sockets and Feather fit the carrier PCB. He measured 19.77 mm from the carrier underside to the highest Feather point, and 14 mm to the USB metal housing's bottom. He also confirmed that his printed faceplate lacks closure columns and a locating lip. These are user measurements; soldering of the carrier sockets has not been confirmed.

## Changes in this revision

- The USB opening and Reset service notch move 7.20 mm above their positions in rear revision C. This includes the carrier change and a further 0.75 mm from the measured assembly.
- The USB opening remains 12 mm wide and 8 mm high. Its center is 19.40 mm above the outside rear surface.
- Four low supports mount the fabricated carrier, using four 2 mm spacers under the screw heads.
- The new front has four blind closure columns and the locating lip. It replaces the existing front; its screen and ANO openings and mount coordinates stay unchanged.
- Both screen screw supports grow from 4.2 to 4.9 mm diameter. Their pilots grow from 1.6 to 1.7 mm diameter.
- Closure screws change from M2 × 8 to M2 × 6. Their pilots grow from 1.6 to 1.7 mm diameter. Nominal thread engagement is 4.4 mm, with 0.8 mm of pilot depth beyond the tip.
- The existing screen clips, screen and ANO spacers, and battery cover remain reusable. The battery cover is also included in the new shell plate.

The shorter closure screw and revised pilots are candidates for a physical fit test. They address the previously tight insertion and split screen support; modeled clearance does not prove printed thread strength.

## Thickness and service access

The measured Feather top is at z = 15.07 mm. The lowest modeled display component is at z = 17.719 mm. The resulting 2.649 mm gap must also accommodate wiring. The fit check reserves another 0.5 mm above the measured stack. Revision D keeps the 34 mm body rather than reducing this space.

The SD card remains internal. Remove the rear closure screws and open the shell to reach it. Leave enough display-wire slack to separate the shells without pulling the solder joints. This revision does not add an external SD slot or USB music transfer. Current music updates use the Mac card reader and [Harmony Sync](../../../docs/harmony-sync.md).

## Print and check

The files in `print/` are bed-oriented geometry, not sliced jobs. Use the established printer and material profile. No printer job has been sent.

1. Print `mark7-shell-d-fit-checks.3mf` first. It contains a port-fit section, two screw coupons with matching tabs, a screen spacer, and four carrier spacers.
2. Test the closure coupon with its 1.6 mm tab and one M2 × 6 self-tapping screw. The coupon post is rectangular.
3. Test the screen coupon with its 1.57 mm tab, 1.4 mm spacer, and one M2 × 6 screw. Its post is round.
4. Seat each screw gently, then remove and reinstall once. Stop if the post cracks or the screw needs excessive force.
5. With power disconnected, place the carrier on the port-fit section's two supports. Use two 2 mm spacers and M2 × 6 screws. Support the overhanging carrier without tilting it.
6. Fit the Feather and check the real USB plug and Reset access. Check actual socket tails and solder clearance above the floor.
7. After those checks, print `mark7-shell-d-shell-kit.3mf`. It contains the new front, rear tray, and battery cover. Individual files are also supplied.
8. Check the empty shell closure, then transfer the screen and ANO with their existing clips and spacers. Route the wires before closing the populated case.

The front prints exterior face down. The tray prints exterior back down. Inspect the perimeter fillets, USB bridge, recessed screw holes, and tall front columns in the slicer. Keep support material out of the pilots. Use the same material and settings for coupons and shells.

| Screws | Quantity | Use |
| --- | ---: | --- |
| M2 × 6 self-tapping | 8 | Existing screen and ANO mounts |
| M2 × 6 self-tapping | 4 | Carrier, with 2 mm spacers |
| M2 × 6 self-tapping | 4 | Battery cover |
| M2 × 6 self-tapping | 4 | Revised rear closure |

This revision needs 20 M2 × 6 screws in total. Use the existing steel assortment; verify that four additional short screws are available for closure. Do not use the old M2 × 8 closure screws in the shorter blind pilots.

## Evidence and remaining checks

`validation.json` records assembly intersections and measurement inputs. `print/validation.json` records solid and mesh validity, bed placement, source hashes, and 3MF object counts. These are geometric checks, not physical acceptance.

The USB model has a 4.2 mm metal housing height. Both user measurements place the vendor Feather model 0.75 mm above the earlier carrier model. The socket body envelope is inferred from that position; individual socket dimensions and tail protrusion remain unmeasured. The modeled tails have 0.66 mm floor clearance before solder.

Cable bends, plug insertion, Reset tool travel, pilot grip, battery restraint, charging temperature, and closed-case Bluetooth still need physical checks. Preserve the battery cushioning and rigid cover clearance.

## Rebuild and references

Run `build.py`, then `prepare_print.py`, with Python 3.11, CadQuery 2.8.0, trimesh, scipy, networkx, and lxml. Run `render.py` with VTK for the review image. The build reads existing vendor CAD and the accepted mounting geometry; it writes only revision D outputs.

- [Carrier revision A](../../../hardware/mark-7/carrier-rev-a/README.md)
- [Accepted screen and ANO mounting](../ano-mount-rev-b/README.md)
- [Previous rear design](../rear-review-c/README.md)
- Build Mark-7 portable Bluetooth player (HARMONY-19) tracks physical acceptance.
