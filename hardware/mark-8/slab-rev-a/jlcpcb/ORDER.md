# JLCPCB order: Harmony Mark-8 slab, revision A

`verify.py` passes (ERC 0, DRC 0 errors, 0 unconnected). The board has the fixes of the 2026-11-21 pre-order review (README, "Review dispositions, November 21"). The board comes from step C of the touch-wheel re-route: the checked routing from before the touch review, with eight slow switching nets on L3 behind the electrodes and a 0.2 mm VBUS bottleneck as accepted exceptions (README, "Touch-wheel re-route"). The firmware must follow README, "Firmware for the touch wheel", and the firmware changes in README, "Review dispositions".

Upload the files in this folder to JLCPCB and choose the settings below. Nothing has been uploaded or ordered.

## Files to upload

| Step | File |
| --- | --- |
| PCB (Gerber) | `harmony-mark8-slab-gerbers.zip` (10 Gerber layers with Protel names, PTH and NPTH Excellon drill files). The outline is the board in its own frame: 5 mm rails, mouse-bite tabs, three fiducials and four tooling holes. |
| Assembly: BOM | `bom.csv` (Comment, Designator, Footprint, LCSC Part #) |
| Assembly: CPL | `cpl.csv` (Designator, Mid X, Mid Y, Layer, Rotation) |

`rotation-check.csv` lists the source of every footprint and the parts to check in JLC's placement preview. `stock.json` holds the stock check of 2026-11-21. `../review/render-panel.png` shows the frame.

## PCB form

| Field | Choice | Reason |
| --- | --- | --- |
| Base material | FR-4 | |
| Layers | 4 | L1 parts, L2 GND, L3 power and routing, L4 touch electrodes |
| Dimensions | read from the Gerbers: 68.4 x 53.6 mm (the frame) | the board itself is 54.4 x 39.6 mm |
| PCB qty | 5 | minimum; each is one board in its frame |
| Product type | Industrial/Consumer electronics | |
| Different design | 1 | |
| Delivery format | Panel by Customer, 1 x 1 | the Gerbers hold one board with its own rails (review CC-1) |
| Edge rails / fiducials | Added by customer | 5 mm rails on all four sides, three 1 mm fiducials with 2 mm openings, four 2.0 mm NPTH tooling holes. Do not let JLC add more rails |
| PCB thickness | 0.8 mm | SPEC 6 |
| PCB color | Green (recommended) or black | green: JLC's smallest solder-mask dam is 0.10 mm on green and 0.13 mm on black; the smallest pad gap on this board is 0.19 mm, so both work |
| Silkscreen | White | |
| Surface finish | ENIG (1 U") | 0.3 mm pitch screen connector and QFN parts |
| Outer copper weight | 1 oz | |
| Inner copper weight | 0.5 oz | 1 oz inner changes JLC's stack-up and with it the L3-to-electrode spacing the touch design assumes; the VBUS drop this causes is accepted (README, PWR-3) |
| Specify stack-up | No (JLC default for 4 layer, 0.8 mm) | no impedance control needed; USB full speed only. Write down the prepreg thickness the order page shows for this default: L3 sits that far behind the L4 electrodes (review L13) |
| Via covering | Plugged | JLC offers only Plugged (or Epoxy Filled and Capped) on 4-layer boards. Tented is not offered |
| Min via hole size / diameter | 0.3 mm / (0.4/0.45 mm) | vias are 0.3 drill, 0.5 pad |
| Board outline tolerance | +-0.2 mm (regular) | |
| Confirm production file | Yes | lets you see JLC's DFM result before production |
| Remove order number | Specify a location | the silkscreen text `JLCJLCJLCJLC` sits under the microSD socket J3, so the number ends up hidden under the socket |
| Gold fingers, castellated holes, edge plating | No | |

Vias and the Plugged option: 166 of the 274 vias are closer than 0.35 mm to a pad opening, so JLC cannot ink-plug them and will most likely tent them. That is what the design assumed. The only vias inside a pad opening are the nine 0.3 mm GND vias in the ESP32 module's centre pads (U1 pad 49) and the four in the CH9102F exposed pad (U2 pad 25). They stay open on top: solder can wick into them, and both pads are ground and thermal pads with other GND pins, so this is accepted. No other via is within 0.10 mm of another net's pad opening (`verification.json`, `via_mask`). Do not order Epoxy Filled and Capped; it is not needed.

## Assembly form (PCB Assembly: on)

| Field | Choice | Reason |
| --- | --- | --- |
| PCBA type | Standard | Economic assembly does not take this board: 4 layers at 0.8 mm with a 0.3 mm pitch FPC connector, a 0.4 mm pitch QFN, an LGA module and through-hole shell legs on the USB-C receptacle |
| Assembly side | Top side | every part is on L1 |
| PCBA qty | 2 (or 5) | 2 is enough to bring up and keep a spare |
| Tooling holes | Added by customer | four 2.0 mm NPTH, one in each corner of the frame |
| Confirm parts placement | Yes | check the parts listed below in the preview before paying |
| Bake components | Default | U1 is MSL 3; JLC handles it |
| Edge rail removal | No | the rails stay on; cut the tabs yourself (see "When the boards arrive") |

Order remark (paste it into the remark field):

> 1. Vias closer than 0.35 mm to pads may be tented instead of plugged.
> 2. J1 (C165948, USB-C): please solder the 4 shell legs. The paste layer has pin-in-paste openings over the 4 plated slots.
> 3. The edge rails, fiducials and tooling holes are in our Gerbers (1 x 1 panel by customer). Please do not add rails and do not remove the rails after assembly.

After upload JLC matches all 40 BOM lines by LCSC number. Expected result: 40 lines matched, 0 unmatched. The test pads TP1 to TP10, the motor pads M1 and M2, the touch wheel connection pads E1, the locating holes, the press-pad marks, the fiducials, the mouse bites and the tooling holes are not parts and are not in the BOM or CPL.

Stencil: JLC cuts it from `F_Paste`. Three openings differ from plain 1:1 pads on purpose. J1's four shell slots have openings 0.25 mm larger than the pad all round (pin-in-paste, review FP-1). J2's openings follow Hirose's recommended stencil (0.23 wide, 0.70 / 0.56 long, fittings 0.30 x 0.70; review FP-3). U2's exposed pad prints 2.0 x 2.0 on its 2.5 x 2.5 pad (review FP-10). Hirose's J2 pattern assumes a 0.10 mm stencil; if the order page offers a stencil thickness, choose 0.10 mm.

## Extended parts

15 of the 40 BOM lines are JLC extended parts (feeder loading fee): U1 ESP32-PICO-MINI-02, U2 CH9102F, U3 MCP73831, U4 RT9080, U5 MAX17048, U6 MPR121, U7 DRV2605L, U8 USBLC6-2SC6, Q1 UMH3N, J1 TYPE-C-31-M-12, J2 FH35C-15S, J3 DM3AT, J4 XY-S2B-PH-SM4-TB, SW1 SKRTLAE010, BZ1 MLT-5020. The other 25 lines are basic parts (no loading fee). The review fixes added two basic lines (R13 2.2k C25879, C11 4.7 uF C23733) and removed one (150k).

## Stock (2026-11-21, `stock.json`)

All lines in stock. Lowest: U6 MPR121QR2 668, U1 ESP32-PICO-MINI-02-N8R2 1021 (NRND), J4 XY-S2B-PH-SM4-TB 2378, U3 MCP73831 4193. U6 fell from 1014 on November 17. Check U1 and U6 again on the day you order; without either the board cannot be built as drawn.

## Cost

JLC's real quote for this design on 2026-11-21, before the review fixes: $185.82 before shipping for 5 PCBs and 2 assembled boards.

| Item | Quote 2026-11-21 |
| --- | --- |
| Feeder (extended part loading) fees | $60.45 |
| Assembly fixture | $16.54 |
| Setup | $25.75 |
| Stencil | $8.27 |
| Parts | $41.76 |
| PCBs and assembly labour (the rest) | $33.05 |
| Total before shipping and tax | $185.82 |

What the review fixes change: the two new BOM lines are basic parts (no fee, under $0.02 a board). The frame makes the PCB 68.4 x 53.6 mm instead of 54.4 x 39.6 mm, which can raise the PCB price by a few dollars. JLC may add a small through-hole soldering charge for J1's shell legs. Expect about $186 to $200 before shipping and tax. Shipping (DHL about $20 to $25) and import tax come on top. A much higher number usually means a part was matched to a different LCSC number; check the BOM page.

## Check before paying

1. In the placement preview, check the parts flagged in `rotation-check.csv`: J1 opening toward the bottom edge, J2 slot toward the empty ramp area with pin 1 at its lower end in JLC's view, J3 card slot toward the bottom edge, J4 cable entry toward the top edge, SW1 actuator over the right edge, U1 antenna over the right edge, the pin-1 dots of U2, U3, U4, U5, U6, U7, U8 and Q1, the single pin 3 (drain) side of Q2 to Q6, the LED1 cathode and both diodes.
2. In JLC's DFM result, expect: vias within 0.35 mm of pads that cannot be plugged (remark 1), the open vias in the U1 and U2 thermal pads, the SW1 guide-boss holes 0.07 mm from the SW1 pads (Alps' own land pattern), and silkscreen clipped at the board edge. The USB-C and MPR121 pad gaps are 0.20 and 0.19 mm now, so JLC should not flag them. Anything else, stop and look.
3. In the Gerber viewer, check the frame: rails on all four sides, a routed gap round the board, tabs only on the top edge (three) and the left edge (one) in device terms (JLC's viewer shows the component side, so device left is on the right), the three fiducials and the four corner holes.
4. Stock of U1 and U6 on the order day.

## When the boards arrive

Each board sits in its frame on four mouse-bite tabs. Cut every tab with flush cutters, as close to the board edge as the cutter allows, then file the stub flush with the board edge. Never snap a tab off: bending the 0.8 mm board can crack an MLCC near the edge or lift a J4 pad. The board must be flush all round, because the case has only 0.5 mm of clearance at the side walls.
