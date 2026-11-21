# Build Harmony Mark-8 slab, revision A: start here

Everything for the first build is ready. Order the assembled board from JLCPCB, buy the screen, the battery and some hardware, and print four parts. Then you only flash, test and assemble. Nothing has been ordered, printed or flashed yet, so revision A is not tested on a real part.

Work in this order. Each step links to the document that has the details.

| Step | What you do | Details |
| --- | --- | --- |
| 1 | Order 5 boards, 2 assembled, from JLCPCB | [ORDER.md](../hardware/mark-8/slab-rev-a/jlcpcb/ORDER.md) |
| 2 | Buy the screen, the battery, inserts and screws | "Parts to buy" below |
| 3 | Print the case and the wheel disc | [PRINTING.md](../enclosure/mark-8/slab-rev-a/PRINTING.md) |
| 4 | Dry-fit the screen cable | "Dry-fit the screen cable" below |
| 5 | Cut the board out of its frame | "Cut the board out of its frame" below |
| 6 | Assemble up to step 13 with the back open | [ASSEMBLY.md](../enclosure/mark-8/slab-rev-a/ASSEMBLY.md) |
| 7 | Flash the bring-up test, then the player | [firmware README, section 2](../firmware/mark-8/README.md) |
| 8 | Close the back plate | ASSEMBLY.md step 15 |

The board README has a "Review dispositions, November 21" table. It lists the firmware changes and the bring-up checks that the pre-order review asked for.

## 1. Order the board

Upload three files from `hardware/mark-8/slab-rev-a/jlcpcb/`: the Gerber zip, `bom.csv` and `cpl.csv`. ORDER.md has every form setting. The settings that matter most:

- 4 layers, 0.8 mm thick, ENIG.
- Delivery format Panel by Customer (1 x 1), edge rails and fiducials added by customer: the Gerbers already hold the board in its own frame.
- Via covering Plugged (JLC does not offer Tented on 4 layers).
- Standard PCBA (Economic assembly does not take this board).
- Top side only, 2 assembled (or 5).
- Paste the three-line order remark from ORDER.md.

Expect 40 of 40 BOM lines matched and 15 extended parts. JLC quoted $185.82 before shipping for this design on November 21, before the review fixes; expect about $186 to $200 now. JLC's quote page gives the real price.

On the order day, do these checks:

1. Check the stock of U1 (ESP32-PICO-MINI-02-N8R2, NRND, 1021 on November 21) and U6 (MPR121QR2, 668 on November 21). If either is gone, the board cannot be built as drawn.
2. In JLC's placement preview, check the parts that `rotation-check.csv` lists.
3. In JLC's DFM result, expect a comment on vias that cannot be plugged; ORDER.md lists the expected comments.

## 2. Parts to buy

| Part | Qty | Source | Note |
| --- | --- | --- | --- |
| Screen DLC-T2.7DDS#1 (2.73 in, 320 x 320) | 2 | DigiKey, about $31 each | Small stock and a 12-week factory lead time. Order it first |
| LiPo cell, 1S, protected, JST PH 2.0 plug, 404050 or 403450 | 1 | Any | J4 pin 2 is +. Packs come wired both ways |
| Heat-set insert M2, 3 mm long, about 3.2 mm OD | 4 | Any | |
| Screw M2 x 4, button head (ISO 7380) | 4 | Any | Not M2 x 5: it bottoms out in the top bosses |
| 1 mm double-sided foam tape | 1 piece, 35 x 45 mm | Any | For the battery |
| Vibration motor LCM1027A2445F | 1 | LCSC C2759984 | Optional. You can add it to the JLC order |

You also need a microSD card (FAT32) with the Harmony music folder, a USB-C cable, a multimeter, and a soldering iron for the inserts. The Mark-7 card works as it is. To fill a new card, run `tools/harmony_sync.py` ([harmony-sync.md](harmony-sync.md)). It also writes `HARMONY/library.hdb`, the index the player needs for more than 512 tracks.

## 3. Print

The Bambu P2S prints all four parts on one plate, without supports. The AMS changes between the two colours. Open `print/mark8-slab-p2s.3mf` in Bambu Studio:

- Filament 1, Bambu PLA Basic Jade White: the front shell, the back plate and the button cap.
- Filament 2, Bambu PLA Basic Black: the wheel disc.

In the print dialog, map filament 1 to the AMS slot with Jade White and filament 2 to the slot with Black. The plate takes about 54 minutes and uses 20.6 g of Jade White and 1.9 g of Black. PRINTING.md has the steps and the settings.

After the print, check:

- the two thin top corners of the screen pocket
- the two shelves at the top screw posts, for sag

## 4. Dry-fit the screen cable

The back plate prints with the other parts in step 3. The screen cable fold comes from the vendor's 3D model, not from a real screen. When the screen arrives, dry-fit it with the board in the printed front shell:

1. Fold the cable 25.2 mm from the contact end.
2. Make one soft loop for the extra 7 mm.

If the fold does not fit, tell the assistant. If the fix changes the back plate, reprint the back plate alone (PRINTING.md, "Reprint the back plate"). Also try the thickest USB-C cable you have in the port.

## 5. Cut the board out of its frame

The board arrives in a frame of rails, held by four mouse-bite tabs (three on the top edge, one on the left edge, seen from the front). Cut every tab with flush cutters, close to the board edge, then file the stub flush. Never snap a tab off: bending the 0.8 mm board can crack a capacitor near the edge or lift a pad of the battery connector. The edge must be flush, because the case has only 0.5 mm of clearance at the side walls.

Before the first USB plug-in, measure VBUS to GND with a meter at C1 (it must not read as a short), and check that the four USB-C shell legs are soldered from both sides.

## 6. Assemble with the back open

Follow ASSEMBLY.md steps 1 to 13. Check the battery polarity with a meter before you connect it (step 11). With USB unplugged, the board blocks a reversed pack. With USB connected, a reversed pack is slowly discharged (about 37 mA) and the charge LED stays on, so never leave a reversed pack on USB. For the first power-up, leave the battery out.

## 7. Flash and test

Section 2 of the firmware README has the full procedure. In short:

1. Plug in USB-C without the battery, and find the new `/dev/cu.usbserial-*` port.
2. Source the pinned ESP-IDF (the README gives the commands).
3. In `firmware/mark-8/slab-bringup`, run `idf.py -p <port> flash monitor`. The repository's `build.sh` builds only and refuses `flash`.
4. Follow the prompts. The test prints one PASS or FAIL line for each block, and it shows the same list on the screen. It asks you to:
   - press the side button
   - confirm the screen picture and the beeps
   - touch every wheel sector, turn once clockwise and tap the centre
   - wake the player twice
5. The README table gives the most likely cause of each FAIL on this board.
6. Connect the battery and run the bring-up again. Then flash `firmware/mark-8/slab-player`.

The bring-up measures the touch noise with the backlight at 100% duty and at three PWM frequencies. It saves the quietest setting and the touch thresholds, and the player uses them. Keep your hands off the wheel during that part (about 45 s).

## 8. Close it

Do ASSEMBLY.md step 15. Tighten the four M2 x 4 screws in a cross pattern until each head sits in its counterbore, and no more.

## Not tested yet

These are design estimates. The first board and the first print will show if they are correct.

- The screen cable fold and its length.
- Touch noise from the seven signals and the backlight line that run behind the wheel pads.
- Touch through the 1.0 mm printed disc.
- The 40 MHz screen clock. The screen data sheet gives 15 MHz. If the picture shows noise, lower `CONFIG_SLAB_LCD_SPI_HZ`.
- Screen orientation, colour order and memory offsets. The bring-up screen shows each of them.
- Card reads at 20 MHz over the long card traces.
- Bluetooth range in the closed case. The antenna has 4.5 mm of copper-free board beyond its open end; Espressif asks for more. Test A2DP with the player in a pocket.
- Audio dropouts while you scroll.
- Sleep current. The firmware README gives estimates only.
- How far a thick USB-C plug goes into the port.

## Where the files are

| Folder | Contents |
| --- | --- |
| `hardware/mark-8/slab-rev-a/` | Board design (KiCad 8), SPEC.md, README.md (pin map, power, touch wheel), `verify.py` |
| `hardware/mark-8/slab-rev-a/jlcpcb/` | The JLCPCB order package and ORDER.md |
| `enclosure/mark-8/slab-rev-a/` | Case CAD (`build.py`), print files, STEP files, renders, ASSEMBLY.md and PRINTING.md |
| `firmware/mark-8/` | `slab-bringup/`, `slab-player/`, shared `components/`, host tests, UI previews |

The design note in Dave's vault (`05-projects/mp3-player/mark-8/design/2026-11-17-sudo-slab-and-custom-board.md`) has the reasons for the choices.
