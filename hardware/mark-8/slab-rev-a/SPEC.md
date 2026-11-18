# Harmony Mark-8 "slab" revision A: design spec

This spec is the single source for the Mark-8 slab board, the printed enclosure and the board firmware. The board, the enclosure and the firmware are built from it in that order. When a build step finds that a value here cannot work, it records the change in the "Changes from spec" section of its own README and keeps every other value.

Decision record: assistant vault `03-living-docs/decisions/2026-11-17-harmony-mark-8-sudo-slab.md`. The look follows the Sudo SP-01 music player (New Matter): a thin slab, a square screen above a fixed touch wheel. Build it for personal use. Put no New Matter or Sudo name or logo on any part.

Goal for revision A: Dave orders one JLCPCB order with every part on the board installed, buys the screen and battery, prints the enclosure on his Bambu A1, then only flashes, tests and assembles. No soldering is required. One optional upgrade (the vibration motor) needs two solder joints.

## 1. Coordinate system

All positions in this spec use device coordinates in millimeters.

- Origin: the center of the body outline, on the outer front face.
- +X: to the right when you look at the front of the device.
- +Y: toward the top of the device (the screen end).
- +Z: out of the front face. The body occupies z from 0 (front face) to -T (back face).

The board is assembled with its components facing the back plate (see section 6). KiCad shows the board from the component side, so KiCad X and Y are mirrored relative to the device front view: device_x = -(kicad_x - x0), device_y = -(kicad_y - y0), where (x0, y0) is the KiCad position of the device origin. Every build script keeps this transform in one function, and every verification step reports positions in device coordinates.

## 2. Body (printed revision A)

| Item | Value |
| --- | --- |
| Outline | 58.6 (X) by 103.5 (Y), plan corner radius 6.5 |
| Thickness T | 9.5 (printed revision A). A later aluminum version targets about 8.4 |
| Edge round | 1.0 on the front and back edges |
| Side wall | 1.6 |
| Front skin | 1.0 (z 0 to -1.0) |
| Back plate | 1.2 thick, its inner face at z = -8.3 |
| Closure | 4 x M2 screws through the back plate into M2 heat-set inserts in corner bosses at (+-24.7, +-47.15) |
| Material | PLA or PETG on a Bambu A1 (no AMS) |

Interior: x from -27.7 to +27.7, y from -50.15 to +50.15, z from -1.0 to -8.3.

## 3. Screen

Part: DLC Display DLC-T2.7DDS#1, 2.73 inch, 320 x 320 IPS, ST7365P controller, 4-line SPI, no touch. Files in `reference/`: datasheet, initial code, STEP model, 400 dpi drawing.

| Item | Value |
| --- | --- |
| Outline | 53.36 x 57.49 x 2.15 |
| Active area | 48.96 x 48.96. Active area top edge is 2.20 below the outline top edge, so the active area sits 6.33 above the outline bottom edge |
| Position | Outline centered in X (x from -26.68 to +26.68). Outline top edge at y = +49.65, outline bottom edge at y = -7.84. Active area x from -24.48 to +24.48, y from -1.51 to +47.45 |
| Depth | Display glass front against the back of the front skin: display from z = -1.0 to z = -3.15 |
| Window in the front skin | Active area plus 0.3 on each side, corner radius 1.5 |
| Supply | VCC 2.4 to 3.3 V, IOVCC 1.65 to 3.3 V. Both run from the switched 3.3 V rail |
| Backlight | 10 white LEDs in parallel, 200 mA maximum total, VF 2.7 to 3.3 V |
| FPC | 15 contacts, 0.3 pitch, FPC thickness 0.20, tail width 4.80, contacts on the front face of the FPC when it lies flat as drawn |

FPC pinout: 1 LEDK, 2 GND, 3 FMARK (tearing effect), 4 SDA (MOSI), 5 SCLK, 6 RS (D/C), 7 CS, 8 RESET, 9 IOVCC, 10 VCC, 11 VCC, 12 GND, 13 GND, 14 LEDA, 15 LEDA.

### 3.1 FPC route (measured from the vendor STEP)

Laid flat in the screen plane, the FPC leaves the screen's bottom edge and forms an L. In device coordinates (screen in its final position):

- Bonded wide section: x from -13.2 to +14.7 (+18.0 where a small part sits at x +15.5 to +17.7), from the screen edge at y = -7.84 down to y = -18.6. The band just below the screen edge is the "single area", designed for bending.
- Vertical leg: x from -13.2 to -7.2, from y = -18.6 down to y = -45.1.
- Tail: y from -46.0 to -50.8 (4.8 wide), from x = -13.0 to the tip at x = +43.93. Contacts at x +41.4 to +43.6. Pin 1 is at the -Y edge of the tail, pin 15 at the +Y edge. The contacts face +Z.

The flat tail ends 16 mm outside the right wall, so the FPC is routed as follows:

1. Bend the FPC down (-Z) just below the screen edge, in the 2.16 mm gap between the screen (y = -7.84) and the board top edge (y = -10.0).
2. Run it in the -Y direction under the board, flat against the back plate, z from about -8.2 to -7.4. The drop to the back plate uses about 3 to 5 mm of FPC length, so the tail ends near y = -39 to -44 instead of -46 to -51.
3. Fold the tail 180 degrees back on itself about a line parallel to Y, near x = +21, so the folded part runs in the -X direction on top of the first layer.
4. The folded tail rises to the board and enters the screen connector, which sits on the component side with its slot facing +X.

After the fold the contacts face the board's component side, and pin 1 is still at the -Y edge. The connector is dual-contact (it contacts either FPC face), so the contact face does not matter. The pin order does: the connector pin 1 must be at the -Y end of the slot.

FPC zones for the board and the enclosure (device coordinates, rounded outward):

- Dive zone: y from -7.8 to -10.0, x from -14 to +19. Keep it open from z -1.0 to -8.3. No ribs, no board.
- Run zone: wide section x -13.7 to +18.5, y -10 to -18.8; leg x -13.7 to -6.7, y -18.6 to -44; tail band x -13.5 to +27.2, y -37 to -47. Parts on the board above the run zone must stay at or above z = -6.7 (at most 4.9 tall from the board surface at z = -1.8).
- Ramp zone: from the connector slot (x_c) to x_c + 18, y_c +-3. The folded tail rises from the back plate to the connector here. Keep this rectangle free of parts taller than 0.6.

## 4. Touch wheel

| Item | Value |
| --- | --- |
| Center | (0, -27.75) |
| Wheel disc | Diameter 34.0. A separate printed part, black, set into a round opening in the front skin, flush with the front face |
| Ring electrodes | 8 equal sectors from r = 7.8 to r = 16.6, 0.4 gaps, with interlocking chevron or sawtooth edges between neighbors (better position interpolation) |
| Center electrode | Disc r <= 7.0 |
| Labels (Sudo layout) | HOME at the top (12 o'clock), previous at 9 o'clock, next at 3 o'clock, play/pause at 6 o'clock, debossed in the disc |
| Controller | NXP MPR121, 9 of 12 channels (ELE0 = center, ELE1 to ELE8 = ring sectors clockwise from 12 o'clock as seen from the front) |

The electrodes are copper on the board's touch side, directly behind the 1.0 mm printed wheel disc. Touch through 1.6 mm PLA is already proven on the MPR121 bench (`hardware/mark-8/mpr121-bench-20261107`).

## 5. Electronics

### 5.1 Blocks and parts (all JLCPCB-stocked on 2026-11-17)

| Ref | Block | Part | LCSC | Notes |
| --- | --- | --- | --- | --- |
| U1 | Processor | ESP32-PICO-MINI-02-N8R2 | C2980306 | Same module as the Feather ESP32 V2: 8 MB flash, 2 MB PSRAM, PCB antenna. NRND but 892 in stock |
| U2 | USB to serial | CH9102F | C2858418 | As on the Feather V2. Power it from VBUS so it draws nothing on battery. 1 k series resistors on TXD and RXD |
| Q1 | Auto-reset | UMH3N (dual pre-biased NPN) | C62892 | Standard DTR/RTS to EN/IO0 circuit |
| U3 | Charger | MCP73831T-2ACI/OT | C424093 | PROG 2.7 k (about 370 mA). STAT drives a red LED from VBUS |
| U4 | 3.3 V regulator | RT9080-33GJ5 | C841192 | 600 mA, 2 uA quiescent. EN tied to VSYS |
| U5 | Fuel gauge | MAX17048G+T10 | C2682616 | I2C 0x36. CELL and VDD on VBAT. QSTRT and CTG to GND |
| U6 | Touch | MPR121QR2 | C91322 | I2C 0x5B (ADDR to VDD). REXT 75 k. IRQ open drain |
| U7 | Haptic driver | DRV2605LDGSR | C527464 | I2C 0x5A (fixed). VDD = VSYS. EN to 3V3 through 10 k. IN/TRIG to GND. Output to two motor pads |
| U8 | USB ESD | USBLC6-2SC6 | C7519 or C2827654 | On D+, D- and VBUS |
| J1 | USB-C | HRO TYPE-C-31-M-12 | C165948 | 16-pin USB 2.0. CC1 and CC2 each 5.1 k to GND |
| J2 | Screen connector | Hirose FH35C-15S-0.3SHW(50) | C2889267 | 0.3 pitch, 0.88 tall, dual contact, accepts 0.2 FPC |
| J3 | microSD | Hirose DM3AT-SF-PEJM5 | C114218 | Push-push, card detect switch, 1.68 tall |
| J4 | Battery | JST PH 2-pin side entry, S2B-PH-SM4-TB or the XYECONN clone | C54582899 | About 5.5 tall. Silkscreen + and - plainly |
| SW1 | Side button | Alps SKRTLAE010 (side push) | C110293 | Actuator points +X through the right wall |
| SW2, SW3 | BOOT, RESET | TS-1088-AR02016 | C720477 | On the component side, reachable with the back plate off |
| BZ1 | Click buzzer | MLT-5020 (5 x 5 x 2.5, 4 kHz, magnetic) | C94598 | VSYS through 33 ohm, low-side N-MOSFET, flyback diode |
| Q2 | Battery reverse protection | AO3401A | C15127 | P-MOSFET: drain to the battery + pin, source to VBAT, gate to GND |
| Q3 | Load sharing | AO3401A | C15127 | Drain to VBAT, source to VSYS, gate to VBUS with 100 k to GND |
| D1 | VBUS to VSYS | B5819W SL | C8598 | |
| Q4 | Peripheral power | AO3401A | C15127 | Source 3V3, drain 3V3_PERIPH. Gate on PERIPH_EN_N with 100 k pull-up and a 10 k / 100 nF slow turn-on |
| Q5 | Backlight | AO3400A | C20917 | LEDK to drain. LEDA (pins 14 and 15) to VSYS through 10 ohm 1206. Gate 100 ohm series, 100 k pull-down |
| Q6 | Buzzer | AO3400A | C20917 | Gate 100 ohm series, 100 k pull-down |
| D2 | Buzzer flyback | B5819W SL | C8598 | Across the buzzer |
| LED1 | Charge LED | Red 0603 | JLC basic | Through 1 k to VBUS, cathode to STAT |

Use JLC basic parts for every resistor and capacitor where a basic part exists. Use 0402 for passives except where power or capacitance needs 0603, 0805 or 1206.

### 5.2 Power

- VBUS (USB 5 V) feeds the charger, CH9102F and, through D1, VSYS.
- The battery connects through Q2 to VBAT. Q3 connects VBAT to VSYS when VBUS is absent.
- VSYS feeds U4 (3V3), the backlight resistor, the buzzer and U7.
- 3V3 feeds U1, U5, U6 and Q4. Q4 makes 3V3_PERIPH for the screen (VCC and IOVCC) and the microSD card.
- Bulk capacitance: 10 uF on VBUS, 10 uF on VBAT, 22 uF on VSYS, 22 uF and 100 nF at U1's 3V3 pin, 10 uF and 100 nF on 3V3_PERIPH at the screen connector and at the card socket.
- Deep sleep target: below 100 uA total with the screen and card off (Q4 off), U6 in stop mode, U7 in standby and U2 unpowered.

### 5.3 ESP32 pin map

| GPIO | Net | Notes |
| --- | --- | --- |
| EN | ESP_EN | 10 k to 3V3, 1 uF to GND, RESET button, auto-reset |
| 0 | BOOT | 10 k to 3V3, BOOT button, auto-reset |
| 1 (TXD0) | U0TXD | To U2 RXD through 1 k |
| 3 (RXD0) | U0RXD | From U2 TXD through 1 k |
| 14 | LCD_SCK | HSPI clock, as on Mark-7 |
| 27 | LCD_MOSI | Screen SDA, as on Mark-7 |
| 26 | LCD_CS | As on Mark-7 |
| 33 | LCD_DC | Screen RS, as on Mark-7 |
| 32 | LCD_RST | As on Mark-7 |
| 4 | LCD_BL | Backlight PWM, as on Mark-7 |
| 39 | LCD_TE | Screen FMARK, input only |
| 5 | SD_SCK | VSPI. A separate bus from the screen, so screen drawing and card reads do not share a bus |
| 19 | SD_MOSI | |
| 21 | SD_MISO | 10 k pull-up |
| 25 | SD_CS | 10 k pull-up |
| 15 | SD_CD | Card detect switch to GND, 100 k pull-up. MTDO strapping pin: a card in the slot only silences the boot log |
| 22 | I2C_SDA | 4.7 k pull-up. U5, U6, U7 |
| 20 | I2C_SCL | 4.7 k pull-up |
| 34 | TOUCH_IRQ | U6 IRQ, 10 k pull-up, deep sleep wake (ext1) |
| 38 | SIDE_BTN | SW1 to GND, 100 k pull-up, 100 nF, deep sleep wake (ext0) |
| 13 | PERIPH_EN_N | Q4 gate. Low turns the screen and card on |
| 2 | BUZZER | Q6 gate. Its pull-down keeps the GPIO2 strapping pin low at boot |
| 35 | VBAT_SENSE | VBAT through 1 M / 1 M, 100 nF at the pin |
| 36 | VBUS_SENSE | VBUS through 100 k / 150 k |
| 7, 8, 12, 37 | Unused | 7 and 8 to test pads. Leave 12 (MTDI strapping) unconnected |

The SD data lines DAT1 and DAT2 get 10 k pull-ups. In SPI mode, DAT3 is CS, CMD is MOSI, DAT0 is MISO.

Firmware must drive every line to the screen and card low (or set it as an input) before it turns Q4 off. Otherwise the ESP32 back-powers the screen and card through their input protection.

## 6. Board

| Item | Value |
| --- | --- |
| Layers | 4. L1 = component side, L2 = solid GND, L3 = power and routing, L4 = touch side |
| Thickness | 0.8 |
| Finish | ENIG (0.3 pitch connector, QFN parts) |
| Assembly | JLCPCB, one side, all parts on L1 ("top" in KiCad) |
| Orientation in the device | Touch side (L4) against the front skin at z = -1.0. Component side faces the back plate. Board occupies z -1.0 to -1.8 |
| Outline | x from -27.2 to +27.2, y from -10.0 to -49.6. Keep the board edge at least 2.9 from the boss centers (+-24.7, -47.15) |
| Rules | Track and space 0.127 minimum, 0.15 preferred. Vias 0.3 drill, 0.5 pad. Board edge clearance 0.3 |

Placement constraints (device coordinates):

- J1 USB-C on the bottom edge, centered at x = 0, mating face at y = -50.4 +- 0.2 (it overhangs the board edge). Report its z center line.
- J3 microSD on the bottom edge, card entry facing -Y, center near x = -15. Report the card slot z range.
- SW1 on the right edge near y = -15, actuator pointing +X. Report the actuator tip position.
- U1 with its antenna end at the right board edge (x = +27.2), body toward -X, centered near y = -32. No copper on any layer under the antenna or within the vendor keep-out. The antenna region must not overlap the wheel electrodes or their ground hatch.
- J2 screen connector on the component side, slot facing +X, pin 1 at the -Y end. Slot center line y_c from -42 to -38 (target -40). Slot mouth x_c from -6 to +6 (target 0). Section 3.1 explains why.
- J4 battery connector near the top-left (around x = -21, y = -14), cable entry facing +Y. Keep it out of the FPC run zone. It is the tallest part.
- BZ1 anywhere outside the FPC zones. Report its center, so the back plate gets a sound grille there.
- LED1 near the bottom edge. Report its center, so the back plate gets a 1 mm light hole there.
- Component height limits from the component side: 5.6 in general, 4.9 above the FPC run zone, 0.6 in the ramp zone.
- Wheel electrodes on L4 as in section 4. Under the wheel, L2 is a 25 percent GND hatch instead of a solid plane. Route the electrode traces on L3 or L1 and keep them short and apart.
- Leave L4 flat outside the wheel: GND pour and nothing else. No parts and no silkscreen on L4.
- Two NPTH locating holes, 1.6 diameter, far apart and outside the wheel. The front skin gets matching pins.
- Four press pads, 4.0 diameter, free of parts and outside the FPC zones. Posts on the back plate press there to hold the board against the front skin.
- Motor pads M+ and M- (2.0 x 1.5) near a board edge, with silkscreen labels.
- Test pads on L1: 3V3, VSYS, VBAT, GND, U0TXD, U0RXD, GPIO7, GPIO8, I2C_SDA, I2C_SCL.

## 7. Fabrication outputs

In `hardware/mark-8/slab-rev-a/jlcpcb/`: Gerber and drill zip, BOM CSV (Comment, Designator, Footprint, LCSC Part #), CPL CSV (Designator, Mid X, Mid Y, Layer, Rotation), the board STEP with parts, and an order README with the exact JLCPCB form choices. Check every part's rotation against its JLC footprint orientation, and record the result.

## 8. Enclosure

In `enclosure/mark-8/slab-rev-a/`, built with CadQuery from the board STEP and the screen STEP:

- Front shell: front skin with the screen window and the wheel opening, side walls, corner bosses for heat-set inserts, a screen pocket, locating pins for the board, and openings for USB-C, microSD and the side button at the positions the board reports.
- Wheel disc: a separate black part, 34.0 diameter, with a back flange so it drops in from the inside and the board holds it. Debossed labels: HOME, previous, next, play/pause.
- Side button cap: a separate part captured by the wall.
- Back plate: screw counterbores, battery pocket ribs, press posts for the board, a buzzer grille and a charge-LED hole.
- Assembly check: board, screen, battery block (52 x 54 x 4.8 maximum), FPC path (section 3.1) and every printed part, with an interference report.
- Exploded assembly diagram from the real CAD: an isometric exploded render and a side-section exploded view, every part numbered, with a numbered step list (heat-set inserts, wheel disc, button cap, screen, FPC fold and connector latch, board, battery, optional motor, back plate and screws). Also one assembled render from the front and one from the back.
- Print files (3MF and STL) with orientation notes for the Bambu A1, and a README.

## 9. Firmware

In `firmware/mark-8/`: a board bring-up test and the slab player. Reuse the Mark-7 player sources the way `firmware/mark-7/pocket-player` does. Do not edit `firmware/mark-6` or `firmware/mark-7` files; copy a file into `firmware/mark-8` when it needs a change. Note: the Mark-7 working tree holds uncommitted October 9 changes, which are the version flashed on Dave's Mark-7.

- Bring-up test: prints a pass or fail line for each block over serial and shows it on the screen. I2C scan (0x36, 0x5A, 0x5B), screen color bars and orientation, card mount and read speed, wheel raw counts and position, side button, buzzer, haptic driver, battery voltage and percent, VBUS, peripheral power switch, deep sleep and wake.
- Player: Mark-7 behavior on the new pins, the ST7365P screen at 320 x 320 (init sequence in `reference/DLC-T2.7DDS1-initial-code.txt`, RGB565), the wheel for scrolling and the four labeled zones plus center, buzzer clicks, battery percent from the MAX17048, backlight PWM compensated for VSYS, and deep sleep with side-button and touch wake.

## 10. Bought separately

| Item | Source | Notes |
| --- | --- | --- |
| Screen DLC-T2.7DDS#1 | DigiKey | About $31. Buy two |
| LiPo battery, 1S, protected, JST PH 2.0 | Any | At most 4.8 x 50 x 52. A 404050 (1100 to 1300 mAh) fits. Check the polarity against the board silkscreen before you plug it in |
| M2 heat-set inserts, 4 | Any | M2 x 3 long, about 3.2 outer diameter |
| M2 screws, 4 | Any | M2 x 4 or x 5, low head |
| microSD card | Owned | |
| Vibration motor (optional) | LCSC C2759984 | LCM1027A2445F, 10 x 2.7 coin, two solder joints to M+ and M- |

## 11. Known risks

- The FPC fold and the connector position are designed from the vendor STEP, not tried on a real part.
- The touch-tap feel (taps with a buzzer click, no mechanical click) is not tested.
- The 320 x 320 screen moves 33 percent more pixels than Mark-7's screen over SPI.
- The ESP32-PICO-MINI-02 is NRND. Buy spare boards.
- The aluminum version needs the external-antenna module (-02U) and a radio window. Revision A is printed plastic only.
