# JLCPCB order: Harmony Mark-8 slab, revision A

`verify.py` passes (ERC 0, DRC 0 errors, 0 unconnected). The board comes from step C of the touch-wheel re-route: the checked routing from before the touch review, with seven slow switching nets on L3 behind the electrodes and a 0.2 mm VBUS bottleneck as accepted exceptions (README, "Touch-wheel re-route"). The firmware must follow README, "Firmware for the touch wheel".

Upload the files in this folder to JLCPCB and choose the settings below. Nothing has been uploaded or ordered.

## Files to upload

| Step | File |
| --- | --- |
| PCB (Gerber) | `harmony-mark8-slab-gerbers.zip` (10 Gerber layers with Protel names, PTH and NPTH Excellon drill files) |
| Assembly: BOM | `bom.csv` (Comment, Designator, Footprint, LCSC Part #) |
| Assembly: CPL | `cpl.csv` (Designator, Mid X, Mid Y, Layer, Rotation) |

`rotation-check.csv` lists the source of every footprint and the parts to check in JLC's placement preview. `stock.json` holds the stock check of 2026-11-17.

## PCB form

| Field | Choice | Reason |
| --- | --- | --- |
| Base material | FR-4 | |
| Layers | 4 | L1 parts, L2 GND, L3 power and routing, L4 touch electrodes |
| Dimensions | read from the Gerbers (about 54.4 x 39.6 mm) | |
| PCB qty | 5 | minimum |
| Product type | Industrial/Consumer electronics | |
| Different design | 1 | |
| Delivery format | Single PCB | no panel: the board edge carries the USB-C, microSD and side button |
| PCB thickness | 0.8 mm | SPEC 6 |
| PCB color | Black or green | either; black hides the electrodes under a black wheel disc better, green is faster |
| Silkscreen | White | |
| Surface finish | ENIG (1 U") | 0.3 mm pitch screen connector and QFN parts |
| Outer copper weight | 1 oz | |
| Inner copper weight | 0.5 oz | |
| Specify stack-up | No (JLC default for 4 layer, 0.8 mm) | no impedance control needed; USB full speed only |
| Via covering | Tented | no via-in-pad filling ordered (see "Via in pad" below) |
| Min via hole size / diameter | 0.3 mm / (0.4/0.45 mm) | vias are 0.3 drill, 0.5 pad |
| Board outline tolerance | +-0.2 mm (regular) | |
| Confirm production file | Yes | lets you see JLC's DFM result before production |
| Remove order number | Specify a location | the silkscreen text `JLCJLCJLCJLC` sits under the microSD socket J3, so the number ends up hidden under the socket |
| Gold fingers, castellated holes, edge plating | No | |

Via in pad: nine 0.3 mm GND vias sit in the ESP32 module's centre pads (U1 pad 49) and four in the CH9102F exposed pad (U2 pad 25). They are open (not filled). Solder can wick into them; both pads are ground and thermal pads, and the pins carry the connections, so this is accepted. Do not order "Epoxy filled and capped" for this board; it is not needed.

## Assembly form (PCB Assembly: on)

| Field | Choice | Reason |
| --- | --- | --- |
| PCBA type | Standard | Economic assembly does not take this board: 4 layers at 0.8 mm with a 0.3 mm pitch FPC connector, a 0.4 mm pitch QFN, an LGA module and through-hole shell legs on the USB-C receptacle |
| Assembly side | Top side | every part is on L1 |
| PCBA qty | 2 (or 5) | 2 is enough to bring up and keep a spare; 5 costs about 3 x $19 parts more but no extra fees |
| Tooling holes | Added by JLC | no tooling holes are on the board; JLC adds rails or uses fixtures |
| Confirm parts placement | Yes | check the parts listed below in the preview before paying |
| Bake components | Default | U1 is MSL 3; JLC handles it |

After upload JLC matches all 39 BOM lines by LCSC number. Expected result: 39 lines matched, 0 unmatched. The test pads TP1 to TP10, the motor pads M1 and M2, the touch wheel connection pads E1, the locating holes and the press-pad marks are not parts and are not in the BOM or CPL.

## Extended parts

15 of the 39 BOM lines are JLC extended parts (feeder loading fee, about $3 each): U1 ESP32-PICO-MINI-02, U2 CH9102F, U3 MCP73831, U4 RT9080, U5 MAX17048, U6 MPR121, U7 DRV2605L, U8 USBLC6-2SC6, Q1 UMH3N, J1 TYPE-C-31-M-12, J2 FH35C-15S, J3 DM3AT, J4 XY-S2B-PH-SM4-TB, SW1 SKRTLAE010, BZ1 MLT-5020. The other 24 lines are basic parts (no loading fee).

## Stock (2026-11-17, `stock.json`)

All lines in stock. Lowest: U1 ESP32-PICO-MINI-02-N8R2 892 (NRND), U6 MPR121QR2 1014, J4 XY-S2B-PH-SM4-TB 2946. Check U1 again on the day you order; if it is gone the board cannot be built as drawn.

## Cost estimate (not a quote)

| Item | 2 boards assembled | 5 boards assembled |
| --- | --- | --- |
| 5 PCBs, 4 layer, 0.8 mm, ENIG | about $15 to $25 | same |
| Assembly setup and stencil | about $33 | same |
| Extended part loading fees (15 x $3) | about $45 | same |
| Parts (about $19 per board, U1 $5.61, U6 $2.69, U5 $1.95) | about $40 | about $95 |
| Assembly labour (about 410 joints per board) | about $3 | about $8 |
| Total before shipping and tax | about $135 to $145 | about $195 to $205 |

Prices are JLC list prices read on 2026-11-17 for the parts, and typical JLC fees for the board and assembly. Shipping (DHL about $20 to $25) and import tax come on top. JLC's quote page gives the real number before payment.

## Check before paying

1. In the placement preview, check the parts flagged in `rotation-check.csv`: J1 opening toward the bottom edge, J2 slot toward the empty ramp area with pin 1 at its lower end in JLC's view, J3 card slot toward the bottom edge, J4 cable entry toward the top edge, SW1 actuator over the right edge, U1 antenna over the right edge, pin-1 dots of U2, U5, U6, U7, Q1, LED1 cathode and both diodes.
2. In JLC's DFM result, the 0.09 mm pad gaps inside the USB-C and MPR121 land patterns are expected (JLC's 4-layer minimum is 0.09 mm).
3. Stock of U1 on the order day.
