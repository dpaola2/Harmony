# Harmony Mark-8 "slab" board, revision A

This is the main board of the Mark-8 slab music player, built from `SPEC.md`. It is a 4-layer, 0.8 mm board of 54.4 x 39.6 mm. Every part is on one side and JLCPCB places all of them. When the boards arrive, Dave only flashes them, then adds the screen, the battery and the printed case. No soldering is needed, except for the optional vibration motor (two joints).

**Status: ready to order, with accepted exceptions.** The fixes of the 2026-11-21 pre-order review and of the change review that checked them are in (see "Review dispositions, November 21", its "Change review" table and "Decisions"). ERC 0 errors, 0 warnings; DRC 0 errors, 0 unconnected, 32 silkscreen warnings; `verify.py` passes. The board comes from step C of the touch-wheel re-route: it keeps the checked routing from before the touch review, with the review's layout fixes applied on top by `review_fixes.py`. Eight slow switching nets keep their L3 track behind the touch electrodes, and the two main VBUS paths keep a 0.2 mm bottleneck. Both are accepted exceptions with caps in `design.py`, and the firmware must follow "Firmware for the touch wheel" (see "Touch-wheel re-route"). JLC receives the board in its own frame with rails (`jlcpcb/ORDER.md`). Nothing has been uploaded or ordered.

![Component side](review/render-top.png)

## What is on the board

```
USB-C J1 ──ESD U8──┬─ D+/D- ── CH9102F U2 ── TXD/RXD (1k) ── ESP32 U1 (UART0)
                   │                   └─ DTR/RTS ── UMH3N Q1 ── EN / IO0
                   ├─ VBUS ── B5819W D1 ───────────────┐
                   ├─ VBUS ── MCP73831 U3 ── VBAT ──────┤
                   └─ CC1/CC2 5.1k to GND              │
JST PH J4 ── AO3401A Q2 (reverse battery) ── VBAT ── AO3401A Q3 (off while VBUS) ── VSYS
                                               │                                    │
                                     MAX17048 U5 (I2C 0x36)      RT9080 U4 ── 3V3 ──┼── ESP32 U1, MPR121 U6, MAX17048 U5 logic
                                                                                    │      └─ AO3401A Q4 ── 3V3_PERIPH ── screen J2, microSD J3
                                                    VSYS ── 10R ── screen LEDA; LEDK ── AO3400A Q5 ── GND (IO4 PWM)
                                                    VSYS ── 33R ── buzzer BZ1 ── AO3400A Q6 (IO2)
                                                    VSYS ── DRV2605L U7 (I2C 0x5A) ── motor pads M+ M-
ESP32 HSPI (14/27/26/33/32, TE 39) ── FH35C J2 (screen)      ESP32 VSPI (5/19/21/25, CD 15) ── DM3AT J3 (microSD)
ESP32 I2C (22/20) ── U5 0x36, U6 0x5B, U7 0x5A               MPR121 U6 ── 9 electrodes on L4 (E1)
```

| Ref | Part | LCSC |
| --- | --- | --- |
| U1 | ESP32-PICO-MINI-02-N8R2 | C2980306 |
| U2 | CH9102F USB to serial | C2858418 |
| U3 | MCP73831T-2ACI/OT charger, PROG 2.7k (about 370 mA) | C424093 |
| U4 | RT9080-33GJ5 3.3 V regulator | C841192 |
| U5 | MAX17048G+T10 fuel gauge | C2682616 |
| U6 | MPR121QR2 touch controller | C91322 |
| U7 | DRV2605LDGSR haptic driver | C527464 |
| U8 | USBLC6-2SC6 USB ESD | C7519 |
| J1 | HRO TYPE-C-31-M-12 USB-C | C165948 |
| J2 | Hirose FH35C-15S-0.3SHW(50) screen FPC | C2889267 |
| J3 | Hirose DM3AT-SF-PEJM5 microSD | C114218 |
| J4 | XYECONN XY-S2B-PH-SM4-TB (JST PH 2.0 side entry) | C54582899 |
| SW1 | Alps SKRTLAE010 side button | C110293 |
| SW2, SW3 | TS-1088-AR02016 BOOT, RESET | C720477 |
| BZ1 | MLT-5020 magnetic buzzer | C94598 |
| Q1 | UMH3N auto-reset | C62892 |
| Q2, Q3, Q4 | AO3401A | C15127 |
| Q5, Q6 | AO3400A | C20917 |
| D1, D2 | B5819W SL | C8598 |
| LED1 | KT-0603R red | C2286 |

The full BOM (40 lines) is `jlcpcb/bom.csv`; the netlist is `netlist.xml`; the schematic is `harmony-mark8-slab.kicad_sch` and `review/schematic.pdf`.

## ESP32 pin map

| GPIO | Module pin | Net | Connects to |
| --- | --- | --- | --- |
| EN | 8 | ESP_EN | 10k to 3V3 (R5), 1 uF (C4), RESET SW3, Q1 |
| 0 | 23 | BOOT | 10k to 3V3 (R6), BOOT SW2, Q1 |
| 1 TXD0 | 31 | U0TXD | 1k R3 to U2 RXD; test pad TP5 |
| 3 RXD0 | 30 | U0RXD | 1k R4 from U2 TXD; test pad TP6 |
| 14 | 18 | LCD_SCK | J2 pin 5 SCLK |
| 27 | 17 | LCD_MOSI | J2 pin 4 SDA |
| 26 | 16 | LCD_CS | J2 pin 7 |
| 33 | 13 | LCD_DC | J2 pin 6 RS |
| 32 | 12 | LCD_RST | J2 pin 8 |
| 4 | 24 | LCD_BL | 100R R15 to Q5 gate, 100k R16 pull-down |
| 39 | 7 | LCD_TE | J2 pin 3 FMARK |
| 5 | 29 | SD_SCK | J3 pin 5 CLK |
| 19 | 33 | SD_MOSI | J3 pin 3 CMD |
| 21 | 35 | SD_MISO | J3 pin 7 DAT0, 10k R21 to 3V3_PERIPH |
| 25 | 15 | SD_CS | J3 pin 2 DAT3, 10k R22 to 3V3_PERIPH |
| 15 | 21 | SD_CD | J3 card-detect switch to GND, 1M R25 to 3V3 |
| 22 | 34 | I2C_SDA | 4.7k R31; U5, U6, U7; test pad TP9 |
| 20 | 26 | I2C_SCL | 4.7k R32; U5, U6, U7; test pad TP10 |
| 34 | 9 | TOUCH_IRQ | U6 IRQ, 10k R11 |
| 38 | 6 | SIDE_BTN | SW1 to GND, 100k R26, 100 nF C23 |
| 13 | 20 | PERIPH_EN_N | 1k R14 to PERIPH_DIV (2.2k R13 to 3V3), 4.7k R34 on to the Q4 gate (1 uF C18 gate to source, 100 nF C26 gate to drain) |
| 2 | 22 | BUZZER | 100R R19 to Q6 gate, 100k R20 pull-down |
| 35 | 10 | VBAT_SENSE | VBAT through 1M R27 / 1M R28, 100 nF C24 |
| 36 | 4 | VBUS_SENSE | VBUS through 100k R29 / 75k R30 (VBUS = pin x 175 / 75) |
| 7, 8 | 27, 28 | GPIO7, GPIO8 | test pads TP7, TP8 |
| 12, 37 | 19, 5 | not connected | IO12 is the MTDI strap |

SD DAT1 and DAT2 have 10k pull-ups (R23, R24) to 3V3_PERIPH. J4: pin 2 is battery +, pin 1 is battery -, marked + and - on the silkscreen.

## Power

- USB VBUS feeds the charger U3, the CH9102F U2 (VDD5 and its VBUS sense) and, through D1, VSYS. C1 10 uF at J1, C7 4.7 uF at U3, C25 100 nF at U2.
- The battery connects through Q2 (P-MOSFET, drain on the J4 + pin, source on VBAT, gate on GND) to VBAT, which has C8 10 uF. Q3 (drain VBAT, source VSYS, gate on VBUS with R9 10k to GND) connects VBAT to VSYS while VBUS is absent. R9 is 10k (it was 100k) so that VBUS bleeds down in tens of milliseconds after an unplug: until it does, VSYS runs on Q3's body diode and 3V3 can sag (review PWR-5). It costs 0.5 mA while USB is plugged in.
- Q2 blocks a reversed pack only while USB is unplugged. With USB plugged in, the charger's preconditioning current turns Q2 on and slowly discharges a reversed pack (about 37 mA) while the charge LED shows charging (review PWR-2). Check the pack polarity with a meter before you connect it.
- VSYS (C9 22 uF) feeds U4 (RT9080, EN on VSYS, C10 1 uF in, C11 4.7 uF out), the 10 R backlight resistor R17, the 33 R buzzer resistor R18 and U7. C11 is a 4.7 uF 10 V X5R 0402 (about 2 uF at 3.3 V; the RT9080 needs more than 1 uF effective at the pin, review PWR-7). The 22 uF C5 at U1 sits behind about 0.22 ohm of track.
- 3V3 feeds U1 (C5 22 uF + C6 100 nF at pin 3), U5 logic side through the I2C pull-ups, U6, the I2C and button pull-ups, U2 VIO and Q4.
- Q4 switches 3V3 to 3V3_PERIPH (screen VCC and IOVCC, microSD VDD, the SD pull-ups). GPIO13 low turns it on, GPIO13 high turns it off. The gate network (review PWR-1, ESP32-2, FW-HW-1; `q4_gate_sim.py`, results in `review/q4-gate-sim.json`):
  - R13 2.2k (3V3 to PERIPH_DIV) and R14 1k (GPIO13 to PERIPH_DIV) form a divider. Driven low, it puts about 1 V on the gate (VGS -2.2 V, Q4 fully on; it draws 1 mA from 3V3 while the rail is on). While EN is low GPIO13 floats and R13 holds the gate at 3V3. After reset release GPIO13 has only its internal pull-down (45k typical, no limits given; simulated 30k to 80k), and the divider holds VGS at -0.09 to -0.22 V, below the AO3401A's -0.5 V minimum threshold: Q4 stays off from reset release until firmware drives GPIO13 low, also in download mode. Leakage at -0.22 V is about 0.2 uA (2.4 uA for a hot part at the threshold minimum).
  - Off means that Q4 does not conduct. It does not mean that 3V3_PERIPH is at 0 V. Until firmware runs, and all the time in download mode, the ESP32's reset pull-ups on GPIO5 (SD_SCK) and GPIO14 (LCD_SCK) feed the unpowered card and screen through their input clamps, so 3V3_PERIPH can sit at about 1 to 2.5 V (change review, Q4 missed item). The current is tens of microamps and harms nothing. To check Q4 at bring-up, hold the board in download mode and measure 3V3 minus PERIPH_GATE: it must be 0.25 V or less. 3V3_PERIPH under 0.1 V is a valid check only with the screen and the card removed.
  - R34 4.7k (PERIPH_DIV to PERIPH_GATE) and C26 100 nF (gate to drain) set the turn-on ramp: on the Miller plateau the gate current through R34 flows through C26, so the drain rises at a controlled rate. C18 1 uF (gate to source) keeps the gate on 3V3 while 3V3 itself powers up: VGS stays above about -0.37 V (with C18 15 percent low and C26 10 percent high), and the rail stays below 0.04 V.
  - Simulated across VGS(th) -0.5 to -1.3 V, K 5 to 18 A/V2, 10 to 30 uF and 0 to 100 mA on 3V3_PERIPH, the RT9080 at its 610 mA minimum current limit, C11 at 1.3 uF (the low end for the 4.7 uF 0402 at 3.3 V) and 250 mA for the ESP32: 3V3_PERIPH reaches 90 percent 3.3 to 10.1 ms after GPIO13 goes low (10 to 90 percent in 1.0 to 3.2 ms), Q4 peaks at 161 mA (100 mA of it the resistive load), and 3V3 at U1 stays at 3.22 V or more. The 3.22 V figure assumes the RT9080's nominal 3.30 V and a full battery. With the set point 2 percent low it is about 3.16 V, and with a low battery (VSYS 3.45 V, the RT9080 in dropout) about 3.03 to 3.09 V. The turn-on itself costs 10 mV or less (55 mV or less in dropout). The old network (100k, 10k, 100 nF) gave 0.36 to 1.0 ms, up to 0.96 A and 3V3 down to 1.74 V in the same model. Q4 stops conducting 3.5 to 10.6 ms after GPIO13 goes high at 25 C (up to about 21 ms for a hot part); the rail then drains slowly through its loads. After a reset, Q4 turns off up to about 20 ms after reset release (change review Q4-4).
  - C19 10 uF + C20 100 nF at J2, C21 10 uF + C22 100 nF at J3.
- U2 CH9102F: VDD5 and VBUS from USB VBUS, V3 decoupled by C2, VIO on 3V3 with C3. This is WCH's dual-supply scheme: on battery VDD5 is at 0 V, VIO draws about 2 uA and the chip does not back-feed (CH9102 datasheet 5.2).
- Deep-sleep estimate with Q4 off, U2 unpowered, U6 in stop mode, U7 in standby: ESP32-PICO-MINI-02 about 10 uA, U5 3 to 23 uA (hibernate or active), U6 about 3 uA, U7 about 4 uA, U4 2 uA, VBAT divider 2.1 uA, U3 reverse current under 2 uA, D1 reverse leakage 6 to 15 uA (review PWR-11): about 36 to 65 uA. With touch wake on (the player default), U6 runs a slow scan instead of stop mode: about 11 uA instead of 3. With a card in J3, the card-detect switch also draws 3.3 uA through R25 (3.3 V / 1M; it was 33 uA with 100k). All are under the 100 uA target.

Firmware notes that follow from the hardware:
1. Drive every screen and card line low, or make it an input, before setting GPIO13 high (Q4 off), or the ESP32 back-powers the screen and card through their input protection (SPEC 5.3).
2. Touch wake needs the MPR121 running (a slow scan), not stop mode. The 100 uA budget above assumes stop mode; measure the run-mode current before relying on touch wake.
3. The backlight runs from VSYS through 10 R: about 120 mA at 4.2 V battery and about 170 mA on USB (VSYS 4.7 V) at 100 percent duty, up to about 220 mA with a low-VF panel on a 5.25 V port (review PERIPH-2). R17 is a 1206 rated 0.25 W; keep the duty cycle at or below 80 percent on USB, and compute the R17 power cap from a worst-case model (VF 2.7 V, 10 ohm), not the brightness model.
4. GPIO15 (SD_CD) is the MTDO strap: a card in the slot silences the ROM boot log. GPIO2 (BUZZER) has R20 100k to GND, so the strap stays low at boot. R25 is 1M, so read SD_CD twice a few milliseconds apart before acting on a change.
5. The microSD lines are long and cross the touch wheel on L1 behind the L2 hatch (they do not go around it): SD_MOSI 88 mm, SD_SCK 82 mm (35 mm of it over the hatch), SD_MISO 77 mm, SD_CS 33 mm; the screen lines are 17 to 45 mm. SD_SCK has no series resistor: set the card's GPIOs to drive strength 0 or 1 before mounting (review L6). Start the card at 20 MHz SPI and drop to 10 MHz if reads fail.
6. Wait at least 20 ms after driving GPIO13 low before driving any screen or card line high (`SLAB_PERIPH_RAMP_MS`, see "Power"). After driving GPIO13 high, the rail needs about 0.4 s to drain below 0.5 V through its loads, so a real card power cycle needs that wait (review CC-2).
7. VBUS_SENSE is VBUS x 75 / 175: 5.0 V gives 2.14 V and 5.25 V gives 2.25 V at GPIO36, inside the ADC's calibrated range up to 5.7 V. `SLAB_VBUS_DIVIDER_X1000` is 2333; the 4300 mV present threshold is 1.84 V at the pin. GPIO36 has no filter capacitor (Espressif asks for 0.1 uF; the source is 43 kOhm), so average several ADC samples for each VBUS reading (change review Q4-5). Revision B adds 100 nF from GPIO36 to GND.

## Layout

The board sits behind the wheel, touch side (L4) against the front skin, component side toward the back plate. KiCad shows the component side, so left and right are swapped against the device front view. Every position in this README and in `mechanical-interface.json` is in device coordinates (SPEC 1); `design.py` holds the transform (`to_kicad`, `to_device`).

| Area (device) | What is there |
| --- | --- |
| Top left | J4 battery connector (cable to +Y), Q2, charger U3, Q3, D1, regulator U4, fuel gauge U5, bulk caps |
| Left edge, lower | haptic driver U7 and motor pads M+ M- |
| Behind the left part of the wheel (FPC leg zone) | Q4 and its gate network (R13, R14, R34, C18, C26) |
| Right edge | U1 with its antenna end flush with x = +27.2; SW1 side button above it, actuator through the right wall |
| Top right | BOOT SW2, RESET SW3, side-button RC, I2C pull-up R31 in the top strip; R32 just below the top buses, behind the wheel. Nothing in the antenna's open-end clearance below SW1 |
| Behind the wheel centre | MPR121 U6 with its parts, buzzer BZ1 and its driver, the J2 decoupling |
| Right of centre, just above the ramp zone | backlight switch Q5 (its body ends 0.05 above the ramp zone); its gate resistors R15 and R16 sit in the ramp zone (0402, 0.35 tall, under the 0.6 limit) |
| Bottom centre | USB-C J1 (mating face y = -50.4), screen connector J2 just above it (slot toward +X, into the empty ramp) |
| Bottom left | microSD J3 (card enters from -Y), its pull-ups in one row above the contacts, charge LED1 between J3 and J1 |
| Bottom right | ESD U8, CH9102F U2, auto-reset Q1, CC resistors, VBUS and VBAT sense dividers, EN RC |

### Touch wheel

- L4 carries nine copper zones: a centre disc r <= 7.0 and eight ring sectors from r 7.8 to 16.6, each boundary a three-tooth sawtooth (0.9 mm tangential half-amplitude) offset 0.2 each side, so neighbours are exactly 0.4 apart (checked by `verify.py`). ELE1 is at 12 o'clock seen from the front, then clockwise (`wheel.py`). Each electrode connects through one plated pad of E1 to an MPR121 pin, by an L1 track where one fits and otherwise partly on L3.
- L2 under the wheel is a 25 percent GND hatch (0.2 mm lines, 1.3 mm gaps, 45 degrees) out to r 17.6. The L4 GND pour and the L1 GND pour stop at r 17.6.
- L3 lies about 0.1 mm behind the L4 electrodes, with no ground between them. A track there couples into the electrode above it (about 0.5 pF per 10 mm of 0.15 mm track), and one edge during an MPR121 charge window can shift a reading by about as much as a touch (NXP AN3863: keep other signals on the far side of the ground layer). So inside the electrode disc plus 0.5 mm (r <= 17.1, `WHEEL_KEEPOUT_R`) only DC and static nets and the electrode lines may run on L3 or place vias: 3V3, 3V3_PERIPH, VBUS, VSYS, VBAT, BAT_P, LCD_RST, PERIPH_EN_N, PERIPH_DIV, PERIPH_GATE, SD_CD, SIDE_BTN, TOUCH_IRQ, BOOT, ESP_EN, CHG_STAT, VBAT_SENSE, VBUS_SENSE, GND and ELE0 to ELE8 (`WHEEL_TOLERANT_NETS` in `design.py`). BOOT, ESP_EN, PERIPH_DIV, PERIPH_GATE, CHG_STAT and the two sense dividers are not on the list the touch review gave; they only change at reset, at power switching or on a charge state change, never during a scan. LCD_LEDA is not static: with no capacitor on it, it swings 1.2 to 2.2 V at the backlight PWM rate (review PERIPH-1). Since 2026-11-21 it is an accepted exception like the seven below, not a DC net. VBUS (charger and adapter ripple while plugged in) and 3V3_PERIPH (card current spikes) also carry some AC, so log the touch noise while charging from a cheap adapter and during card read bursts too (review L10).
- Every other net (I2C, the screen and card SPI lines, the screen's DC, CS and TE, the card's CS, the buzzer gate and drain, the backlight PWM and LEDK, UART, USB) must cross the disc on L1 behind the L2 hatch, or go around it. The routing in this folder meets this rule except for eight nets that keep the L3 track of the routing made before the touch review: I2C_SDA, LCD_DC, LCD_TE, SD_CS, LCD_CS, I2C_SCL, BZ_GATE and LCD_LEDA (`DISC_L3_ACCEPTED` in `design.py`, see "Touch-wheel re-route").
- L3 has no ground pour under the wheel: the L3 pour stops at r 17.6, like the L1 and L4 pours. Under the wheel the ground is the L2 hatch; L3 there holds tracks only.
- `verify.py` checks these rules. It fails if I2C_SDA, I2C_SCL, LCD_DC, LCD_CS, LCD_TE, SD_CS, BZ_GATE, LCD_SCK, LCD_MOSI, SD_SCK, SD_MOSI, SD_MISO, LCD_BL or LCD_LEDK (or any other net outside the list above) has L3 track inside r 17.1 or a via centred inside it, or if any L3 zone has copper inside the disc. A net in `DISC_L3_ACCEPTED` may keep L3 track and vias there, but never more than its cap (the measured length and via count of this routing). `verification.json` lists the L3 length inside the disc for every net.

### Antenna

U1's antenna end is flush with the right board edge. A rule area keeps copper off every layer from x 21.8 to 27.2 and y -37.9 to -18.2: the antenna region (y -35.9 to -22.7), 2.0 mm beyond the feed end and 4.5 mm beyond the open end (the inverted-F antenna's high-field end), up to 0.1 mm short of SW1's GND guide pad. It stays outside the wheel hatch (r 17.6). The 4.5 mm holds in the antenna's own column (x 21.8 to 27.2). Beside the module, the ground under the module body starts about 0.9 mm from the open-end tip, as in Espressif's reference layout (change review ANT-1). Before the 2026-11-21 review the open-end clearance was 0.9 mm on all four layers (review ESP32-1); R31 and R32 moved away and I2C_SDA, VBUS and ESP_EN were re-routed left of x 21.8 to make room.

This still does not meet Espressif's guidance in full: the hardware design guide (section 1.4.8) asks for the antenna outside the board or the board cut away beside and below it, with 15 mm of clearance. That needs a new outline and case, so it is a revision B item. Test Bluetooth A2DP range with the player in a pocket on the first boards. The case must keep screws, inserts, the battery and metal ribs away from the right wall near y -36 to -10.

### USB

The USB-C pinout interleaves D+ and D-, so the pair cannot leave the connector without one change of layer. D- joins behind the pads on L1; D+ joins under the receptacle, drops to L3 outside the wheel keep-out and comes back up next to U8. U8's channel 1 carries D- and channel 2 carries D+, so from U8 to U2 the two lines run side by side (0.2 mm tracks, 0.3 mm gap) with no further crossing. These tracks are hand-placed in `build_pcb.py` and locked. Full speed USB (12 Mbit/s) does not need impedance control.

### Routing

The routing in `routing-final.json` (restored by `rebuild.sh`) was made before the touch review, under the earlier rule that let I2C, the buzzer gate and the screen's and card's chip selects, DC and TE cross the wheel on L3. It is complete and DRC-clean. On 2026-11-17 its VBUS tracks were widened in place, to 0.4 mm where DRC allows and to 0.3 mm elsewhere. It meets the new disc rule except for the accepted exceptions (see "Touch-wheel re-route"). The scripts implement the new rule for any new routing (`ROUTE=1`):

1. `build_pcb.py` places the parts, draws the outline, zones and keep-outs, and adds the hand routes: the USB pair, CC, VBUS (0.4 mm) and shell links at J1, U8 pin 5 to VBUS, the U1 centre-pad vias, two links under the MPR121, ELE2 out of the MPR121 through a via, ELE4 to ELE7 dropping to L3 through four staggered vias just below the MPR121, the two DRV2605L supply pins and its GND via, the backlight return LEDK from J2 pin 1 along the bottom of the ramp zone to Q5, the microSD pull-up supply pins with their vias and L3 bus, GPIO7 to its test pad, the CH9102F VIO pin to C3, the MAX17048 SCL pin to a via, the two screen LEDA pins joined under the connector, and the MAX17048, Q4-gate and MPR121 local links. Then every GND pad gets its own via to L2 (GND fan-out, 0.25 mm stub; inside the wheel the via must land on an L2 hatch line), plus four vias in U2's exposed pad.
2. `late_routes.py` adds the late hand routes in `late-routes.json` before any router runs: CC1 from R1 to J1, and the DTR and U2_TXD exits from the CH9102F bottom row. `hand-routes.json` lists every hand route; no later step moves them.
3. `route.sh` runs Freerouting 2.4.1 twice. Phase S routes every net outside `WHEEL_TOLERANT_NETS` (the switching nets) with the disc (r 17.1) as a keep-out for L3 tracks and vias; it tries a list of router settings and keeps the best. Phase P routes only the DC and static nets and the electrode lines, with L3 free under the wheel. `export_dsn.py R` is a repair pass of phase P on a routed board with the DC copper unlocked.
4. `strip_wheel_violations.py` removes the routed copper of any net that breaks the disc rule (hand routes stay).
5. `finish_pcb.py` widens Freerouting's 0.112 mm neck-downs to the 0.127 minimum and adds the L1 and L3 GND pours, both outside r 17.6. `fixups.py` adds a GND via beside every GND pad the pours do not reach, and one in every L1 pour island.
6. `close_open.sh` is a repair loop, up to 16 rounds. `drc_clean.py` deletes routed copper that DRC objects to (never pads, zones or hand routes) and the dangling leftovers of nets with no open connection. `maze.py`, a grid router (0.05 mm grid, L1 and L3, through vias), routes every open connection with 0.16 mm clearance, 0.36 mm to the edge, the antenna keep-out and the disc rule; VSYS, VBAT, 3V3 and VBUS get 0.4 mm first. Ordinary rounds may rip up only GND stubs and stitching vias. When two rounds change nothing, a rescue round may push aside routed copper: the first two only DC and static copper, later ones any copper except hand routes. The loop keeps the board of its best round.
7. `routing_snapshot.py save` writes every track and via to `routing-final.json`; `refill.py` refills the zones before DRC (kicad-cli 8.0.9 has no `--refill-zones`).
8. `review_fixes.py` (only after `routing_snapshot.py restore`, the default rebuild) applies the layout fixes of the 2026-11-21 pre-order review and of the change review of the same day to the restored routing: it removes 38 track segments and 13 vias that each must match exactly, re-nets one segment, and adds 51 segments and 15 vias. The change review added one fix: the L3 VBUS run above J1's pad 1 slot moves 0.06 mm away from it (USBC-1). So `routing-final.json` stays the checked routing of 2026-11-17, and the review's changes are readable code. A new routing run (`ROUTE=1` or `ROUTE=loop`) does not run it: it routes the moved and new parts from `build_pcb.py`'s hand routes and the new keep-outs.

## Touch-wheel re-route

This board comes from step C: the checked routing from before the touch review, with accepted exceptions. Steps A and B did not close within their time limits (2026-11-17, about 2 hours and 1 hour). Steps A, B and C are the decision of the touch review; each step is described below.

The review rule: I2C_SDA, I2C_SCL, LCD_DC, LCD_CS, LCD_TE, SD_CS, BZ_GATE (and the SPI, backlight and LEDK lines) run on no L3 inside the electrode disc plus 0.5 mm (r <= 17.1, centre (0, -27.75)), and the VBUS paths J1 to D1 and J1 to U3 are at least 0.4 mm wide.

### Step A: new pin map and small part moves (not adopted)

- Pin map tried: on U1's left row, bottom to top, LCD_BL IO32, LCD_TE IO33, LCD_SCK IO25, LCD_CS IO26, LCD_MOSI IO27, LCD_RST IO14, LCD_DC IO12, SD_MISO IO13, PERIPH_EN_N IO15, SD_SCK IO2, BOOT IO0, SD_MOSI IO4; on the top row SD_CS IO20, I2C_SDA IO19, I2C_SCL IO22, BUZZER IO21; SD_CD IO39. Each switching line then leaves U1 in the order of the pins it goes to. The straps hold: IO12 and IO2 drive inputs with no pull-up, so the internal pull-downs keep them low at reset; IO15 has 110 k to the always-on 3V3 through R14 and R13; IO5 is unused.
- Parts moved: Q6, R19 and R20 next to BZ1; C14, R15, R16, R18, R6, SW3 and TP7 to TP10 out of the new line paths.
- Result: Freerouting routed every switching net to the full disc rule in three variants, and the screen lines became short (17 to 27 mm). But the DC phase and the repair loop left DC connections open: 1 in the best run (LCD_RST), 2 in the next (ELE8, and VBUS from D1 to the charger), up to 8 in others.
- Cause: I2C must still reach U5 and U7 on the far left. The only way that keeps it off L3 inside the disc runs across the top of the disc and down through the power section (J4, U3, Q2, Q3, D1, C9). Each crossing there takes L3 space that the power nets need.
- The best step A board is `review/reroute-stepA.kicad_pcb` (its own pin map; one connection open).

### Step B: I2C and LCD_DC allowed 8 mm of L3 (not adopted)

With I2C_SDA, I2C_SCL and LCD_DC allowed up to 8 mm of L3 at any radius inside r 16.6, the I2C routes of the step A board were removed and `maze.py` routed them again with L3 allowed (at a cost). I2C_SCL routed straight through the disc, but the I2C_SDA branches from U6 to U5 did not: they must cross SCL at U6, and L3 around U6 is full of DC and electrode lines. 3 to 4 connections stayed open. `verify.py` supports this mode (`DISC_EDGE_CROSS_NETS` with `DISC_EDGE_CROSS_R = 0`); it is not used.

### Step C: the checked routing with accepted exceptions (this board)

- The routing is the one in `routing-final.json` from before the touch review, with the original pin map (SPEC 5.3) and placement.
- The L3 ground pour stops at r 17.6. Before the review it filled the whole wheel area (solid copper 0.1 mm behind every electrode, tens of pF each). `verify.py` checks that no L3 zone has copper inside the disc.
- Accepted exceptions (`DISC_L3_ACCEPTED` in `design.py`). The caps are the measured values, so `verify.py` fails if a later re-route makes any of them worse:

| Net | L3 inside r 16.6 (mm) | L3 inside r 17.1 (mm), cap | Vias inside r 17.1, cap | How often it switches |
| --- | --- | --- | --- | --- |
| I2C_SDA | 34.5 | 36.31 | 2 | MPR121, MAX17048 and DRV2605L reads |
| LCD_DC | 23.1 | 23.06 | 6 | every screen command |
| LCD_TE | 22.9 | 22.90 | 4 | 60 Hz frame pulse (input) |
| SD_CS | 12.6 | 13.12 | 10 | every card transfer |
| LCD_CS | 11.8 | 11.85 | 2 | every screen transfer, unless held low |
| I2C_SCL | 7.0 | 7.03 | 2 | as I2C_SDA |
| BZ_GATE | 4.1 | 4.08 | 3 | buzzer PWM |
| LCD_LEDA | 11.9 | 11.92 | 2 | backlight PWM (1.2 to 2.2 V swing); added 2026-11-21 (review PERIPH-1) |

SD_CS's cap was 12.75 until 2026-11-21. Moving its via out of the J3 card-detect column (review CONN-1) lengthens its L3 hop under ELE6 by 0.37 mm, to 13.11 (cap 13.12). See "Decisions".

- VBUS: widened in place, 35 of 57 narrow segments to 0.4 mm and 17 more to 0.3 mm. The rest would break DRC at 0.3. Both paths (J1 to D1 and J1 to U3 VIN) share one trunk and narrow to 0.2 mm. Track narrower than 0.4 mm on the path with the least such track, pin neck-downs not counted:

| Layer and width | J1 to D1 (mm) | J1 to U3 VIN (mm) |
| --- | --- | --- |
| L1, 0.2 mm | 9.57 (7.23 from (11.35, -41.55) to (18.55, -42.15), 2.35 from (18.55, -42.15) to (20.9, -42.15)) | 9.57 (the same two segments) |
| L1, 0.3 mm | 21.37 | 21.37 |
| L3, 0.2 mm | 0 (52.4 before widening) | 0 |
| L3, 0.3 mm | 13.88 | 13.88 |

  `VBUS_PATH_ACCEPTED` in `design.py` holds these numbers as caps (the L1 0.3 mm length fell from 22.66 to 21.37 mm on 2026-11-21, when the VBUS drop to L3 moved out of the antenna clearance). The narrow track alone adds about 0.1 ohm, but the whole path is longer: about 0.35 ohm from J1 to U3 VIN and 0.32 ohm from J1 to D1, most of it 63 mm of 0.4 mm track on L3 in 0.5 oz copper (review PWR-3, L7). The current is not capped at 500 mA either: the charger takes 370 mA and the VSYS load comes through D1 on USB, 0.6 to 0.7 A in all. So expect 0.15 to 0.25 V of drop at 0.5 to 0.7 A: VSYS on USB is about 4.3 to 4.4 V, and from a weak 4.75 V port U3 runs slightly below its 4.5 V minimum VDD. It still charges, with less headroom in constant-voltage mode. Inner copper stays 0.5 oz (1 oz changes JLC's stack-up and the L3-to-electrode spacing). On the first board, measure VBUS at U3 pin 4 while charging with the backlight at full brightness.

### Firmware for the touch wheel

The accepted L3 lines sit 0.1 mm behind the electrodes. Firmware keeps their edges away from the MPR121 measurements:

1. Hold LCD_CS low all the time. The screen is the only device on its SPI bus, so configure the bus with `spics_io_num = -1` and drive GPIO26 low once, after the screen has power.
2. Leave TE off (no tear-effect output command, GPIO39 not used as an interrupt) unless the display code needs it.
3. Read the MPR121 only when TOUCH_IRQ falls, not by polling, so I2C runs only after a measurement is complete.
4. Start the MPR121 with debounce DT 2 and DR 2 (register 0x5B = 0x22), FFI 18 samples (0x5C bits 7:6 = 10), SFI 6 samples and ESI 16 ms (0x5D: SFI 01, ESI 100), and the baseline filter values of NXP's quick-start guide (AN3944): MHDR 0x01, NHDR 0x01, NCLR 0x0E, FDLR 0x00, MHDF 0x01, NHDF 0x05, NCLF 0x01, FDLF 0x00, NHDT 0x00, NCLT 0x00, FDLT 0x00. Use autoconfig for the charge current and time (0x7B = 0x8B, its FFI bits equal to those in 0x5C; USL 0xC9, LSL 0x82, TL 0xB5 for 3.3 V).
5. Before setting the touch and release thresholds, log the filtered data of every electrode with nothing touching it while the screen scrolls, the card reads continuously and the buzzer plays. Set each touch threshold at least 3 times the peak-to-peak noise seen then; start at touch 12 and release 6 if the noise allows.

## Mechanical interface

`verify.py` re-derives these from the saved board and writes them, with every part's footprint, height and zone, to `mechanical-interface.json` (the enclosure is built from that file). All values in mm, device coordinates.

| Item | Device coordinates (mm) |
| --- | --- |
| USB-C J1 | mating face y -50.4 (SPEC -50.4 +-0.2), centre x 0, opening z -2.16 to -4.76, z centre line -3.46 (datasheet -3.43) |
| microSD J3 | card enters along -Y at y -49.09; slot x -19.2 to -8.2, slot z -3.68 to -2.6 (card plane z -3.14); eject stroke 5.6 beyond the body |
| Side button SW1 | actuator tip (27.46, -15.6, -3.5), axis +X, 2.0 dia, 0.2 travel |
| Screen connector J2 | slot faces +X; mouth x_c -2.24; slot centre line y_c -39; pin 1 at (-2.47, -41.1), the -Y end; FPC entry z -2.2 |
| Ramp zone | x -2.24 to 15.76, y -42 to -36, parts at most 0.6 tall |
| Antenna U1 | antenna end x 27.2; module x 10.6 to 27.2, y -35.9 to -22.7; copper keep-out x 21.8 to 27.2, y -37.9 to -18.2 (2.0 beyond the feed end, 4.5 beyond the open end) |
| Battery J4 | cable enters along +Y at y -10.53; body x -24.95 to -17.05, y -19.13 to -10.53; top z -7.3 |
| Buzzer BZ1 | centre (-3.6, -21.6), top z -3.81; grille here |
| Charge LED1 | centre (-5.9, -48), top z -2.5; 1.0 light hole |
| Motor pads | M+ (-22.2, -40.9), M- (-22.2, -43.2), 1.5 x 2.0 |
| Locating holes | H1 (-12, -11.4) 1.6 NPTH; H2 (24.6, -40.6) 1.6 NPTH |
| Press pads | PP1 (-24.9, -33); PP2 (-3.6, -30.7); PP3 (6.2, -31); PP4 (6.8, -21.4) |
| Lowest part | J4, z -7.3 (limit -7.4 for 5.6 above the board) |

Changes on 2026-11-21 for the case check: R31 moved from (24.4, -19.3) to (15.5, -12.1) and R32 from (24.4, -20.5) to (13.3, -18.6), both 0402, 0.35 tall, now in the FPC run zone (limit 4.9). New parts: R34 (-13.85, -24.3), 0402, 0.35 tall, FPC run zone; C26 (-14.36, -25.7), 0402, 0.5 tall, general zone. The J1 shell-leg pads are 0.9 wide instead of 1.2 (`touch_side_protrusions`), so the front-skin reliefs derived from the old pads are 0.15 larger than needed on each side. No other part moved or changed height; the outline is unchanged.

Heights: the tallest part is J4 at 5.5 above the component surface (z = -7.3). The tallest part under the FPC run zone is J1 at 3.25 (limit 4.9). Inside the ramp zone there are only R15 and R16 (0402, 0.35 tall, limit 0.6) and flat copper. `verify.py` checks every part against its zone limit.

## Rebuild

```sh
./rebuild.sh             # libraries, schematic, ERC, board, routing restored from routing-final.json, DRC, verify, STEP, renders, JLC package (only when verify passes)
ROUTE=loop ./rebuild.sh  # replay the saved Freerouting sessions (from before the touch review) under the new rule, then the repair loop (about an hour; does not close)
ROUTE=1 ./rebuild.sh     # route again under the new rule with Freerouting first (results vary run to run; has not closed)
STOCK=1 ./rebuild.sh     # also re-check JLCPCB stock
uv run --with numpy --with scipy --with matplotlib python q4_gate_sim.py   # Q4 gate-network simulation (not in rebuild.sh)
```

Tools: KiCad 8.0.9 and Freerouting in `firmware/toolchains/`, Java 25 or newer for Freerouting 2.4.1 (Homebrew `openjdk`), and `uv` (CadQuery, numpy, scipy, matplotlib). `import_lcsc.sh` re-imports the LCSC parts with easyeda2kicad when a part changes; `make_lib.py` turns them into `lib/Harmony8.pretty` and `lib/Harmony8.3dshapes`.

### 3D model alignment

easyeda2kicad offsets only the WRL models, so the STEP files it downloads sit in the wrong place. `make_lib.py` sets each STEP's rotation and offset (table `MODEL_FIX`). The values come from slicing each STEP at the board plane and matching the legs to the pads, and were checked against the vendor drawings: USB-C front face 0.35 beyond the recommended board edge (drawing 0.40), DM3AT card centre 3.2 from contact 1, FH35C actuator at the rear with the FPC slot over the contact-1 row and the fittings, SKRTLAE010 actuator over the mounting tabs.

## Verification

| Check | Result |
| --- | --- |
| verify.py overall | PASS |
| ERC errors / warnings | 0 / 0 |
| DRC errors / warnings / unconnected | 0 / 32 / 0 |
| Netlist parity (pads checked against netlist.xml; netlist.xml checked against design.py) | 370 pads |
| Electrode gaps | 1-2 0.4, 2-3 0.4, 3-4 0.4, 4-5 0.4, 5-6 0.4, 6-7 0.4, 7-8 0.4, 8-1 0.4 |
| Sector centroid angles (deg) | 1 89.74, 2 44.74, 3 -0.26, 4 -45.26, 5 -90.26, 6 -135.26, 7 179.74, 8 134.74 |
| L2 hatch copper fraction under the wheel | 0.36 |
| Power net minimum width (mm) | VBUS 0.2, VSYS 0.2, VBAT 0.25, BAT_P 0.4, 3V3 0.15, 3V3_PERIPH 0.25 (the C26 stub), LCD_LEDA 0.3, LCD_LEDK 0.2 |
| Narrower than 0.4 outside pin neck-downs and signal taps (mm) | VSYS 0, VBAT 0, 3V3 0, LCD_LEDA 0, LCD_LEDK 0 |
| USB D+ / D- length (mm) | 15.9 / 14.91 |
| Track segments / vias | 1233 / 274 |
| Vias inside the wheel, by net | 3V3 5, 3V3_PERIPH 8, BZ_GATE 3, ELE2 1, ELE8 2, GND 31, I2C_SCL 2, I2C_SDA 2, LCD_CS 2, LCD_DC 6, LCD_LEDA 2, LCD_RST 2, LCD_TE 4, PERIPH_EN_N 4, SD_CD 2, SD_CS 10, TOUCH_IRQ 2, VBAT 3, VBUS 6, VSYS 3 |
| L3 track inside the electrode disc r <= 16.6 / disc plus 0.5 r <= 17.1 (mm), by net | 3V3 41.23 / 45.25, 3V3_PERIPH 28.2 / 28.2, BZ_GATE 4.07 / 4.07, CHG_STAT 0 / 4.73, ELE2 12.78 / 12.78, ELE8 18.37 / 18.37, I2C_SCL 7.03 / 7.03, I2C_SDA 34.52 / 36.31, LCD_CS 11.84 / 11.84, LCD_DC 23.06 / 23.06, LCD_LEDA 11.91 / 11.91, LCD_RST 15.38 / 15.38, LCD_TE 22.9 / 22.9, PERIPH_EN_N 12.39 / 12.39, SD_CD 7.79 / 7.79, SD_CS 12.58 / 13.11, SIDE_BTN 10.79 / 13.56, TOUCH_IRQ 23.89 / 23.89, VBAT 25.65 / 26.69 (the VBAT bridge moved off J3's bar C), VBAT_SENSE 0 / 0.25, VBUS 40.81 / 42.42, VSYS 23.5 / 23.63 |
| Listed switching nets on L3 inside r 17.1 | only the eight accepted nets, each at or under its cap (see "Touch-wheel re-route") |
| L3 zone copper inside the disc | none |
| VBUS widest path, J1 to D1 / J1 to U3 VIN (mm, away from the pins) | 0.2 / 0.2, accepted; track below 0.4 mm on each path: L1 0.2 mm 9.57, L1 0.3 mm 21.37, L3 0.3 mm 13.88, L3 0.2 mm 0 |
| Copper beyond the antenna's open end (all four layers) | 4.5 mm in the antenna's own column (0.9 mm before 2026-11-21); beside the module, ground about 0.9 mm from the open-end tip |
| Makers' no-copper areas (`no_copper_areas`) | J3 bar C, strip B, area D: none. J3 column A: SD_CD track (about 2.6 mm) and J3 pin 10's own GND, allowed by a custom DRC rule. SW1 area: none |
| Vias against pad openings (`via_mask`) | in a pad opening: only the 9 U1 and 4 U2 thermal-pad vias; closest via to another net's opening 0.133 mm (HAPTIC_EN to U7 pin 10); 166 of 274 vias closer than 0.35 mm to an opening |
| Smallest pad gap inside J1 / U6 | 0.20 / 0.188 mm (0.10 / 0.138 before the stroke fix) |
| J1 shell slots to other-net copper (custom DRC rule, 0.32 mm) | 0.32 mm or more on every layer: L1 0.36 (LCD_MOSI), L2 0.44 (CHG_STAT via), L3 0.34 (VBUS), L4 0.32 (ELE5); measured on the Gerbers and drill file |
| J1 paste openings over the shell slots (`j1_paste_clearance`) | 2.91, 2.60, 2.66 and 3.06 mm2 (pads 1 to 4); each 0.16 mm or more from other-net L1 copper, via rings and other paste openings |
| U2 exposed-pad paste | nine windows, 2.96 mm2 (47 percent of the pad), 0.11 mm or more from the four via lands |
| JLC panel (`jlcpcb/package.json`) | 68.4 x 53.6 mm frame, 3 routed slots, 3 tabs with 14 mouse bites, 3 fiducials, 4 tooling holes; panel DRC 0 errors, 0 unconnected |
| Q4 gate network (`review/q4-gate-sim.json`) | off after reset release: yes; 3V3 at U1 never below 3.0 V: yes (3.22 V minimum at the nominal set point and a full battery); off while 3V3 powers up: yes |

## Changes from spec

Each change is the smallest one that makes the design work. Spec values not listed here are built as written.

| Spec | Built | Why |
| --- | --- | --- |
| U1 "centered near y = -32" (SPEC 6) | U1 centre y -29.3 (module y -35.9 to -22.7) | At y -32 the 2.4 mm module would reach y -38.6, into the ramp zone (y -42 to -36, parts at most 0.6 tall). -29.3 keeps its lower edge 0.1 above the ramp. The antenna end is still flush with x = +27.2. |
| J2 slot centre line y_c "target -40", mouth x_c "target 0" (SPEC 6) | y_c -39.0, x_c -2.24 | Both inside the allowed ranges (-42 to -38, -6 to +6). The connector body has to clear the J1 rear pads and the USB pair behind them; -2.24 / -39.0 is the nearest spot that does. The fold line moves toward -X by up to 2.2 mm; check it against the real FPC (see "Check before paying"). |
| J3 card centre "near x = -15" (SPEC 6) | x -13.7 | Keeps the board edge 2.9 from the boss at (-24.7, -47.15) with the socket's body on the board. |
| "0402 for passives" (SPEC 5.1) | R7 2.7k, R10 75k and R30 75k in 0603; R18 33R in 0805 | JLC has no basic 0402 part for these values (2.7k, 75k), and the buzzer resistor dissipates about 0.1 W at short clicks. Every resistor and capacitor is still a JLC basic part. |
| "Track and space 0.127 minimum, 0.15 preferred" (SPEC 6) | Routed at 0.13 space (DRC checks 0.127); tracks 0.15 or wider, except 141 mm of 0.127 track (7 percent of 2157 mm) where the routers needed it | With the wheel rules, 0.15 space does not fit around the ESP32 module, the QFN parts and the microSD row. 0.13 keeps a small margin over the minimum. |
| "Track and space 0.127 minimum" (SPEC 6) | SW1 guide holes 0.07 from the SW1 pads | Alps' own land pattern. A custom rule in `harmony-mark8-slab.kicad_dru` allows exactly these pairs. The J1 (0.09) and U6 (0.12) exceptions are gone since 2026-11-21: those gaps were not HRO's or NXP's land patterns but easyeda2kicad keeping EasyEDA's 0.1 mm outline stroke on custom pads (review L1, FP-2, FP-8). `make_lib.py` now redraws every custom pad without the stroke: J1's GND and VBUS pads are HRO's 0.60 wide (gaps 0.20), U6's corner pads 0.224 wide (gaps 0.188). |
| Q4 "gate on PERIPH_EN_N with 100 k pull-up and a 10 k / 100 nF slow turn-on" (SPEC 5.1) | R13 2.2k and R14 1k divider, R34 4.7k into the gate, C18 1 uF gate to source, C26 100 nF gate to drain | The SPEC network let GPIO13's internal pull-down turn Q4 on at every reset, and the 100 nF only delayed a 0.1 ms, up to 1 A turn-on (review PWR-1, ESP32-2). See "Power" and `q4_gate_sim.py`. |
| Q3 "gate to VBUS with 100 k to GND" (SPEC 5.1) | R9 10k | VBUS bleeds down in tens of milliseconds after an unplug (review PWR-5). |
| SD_CD "100 k pull-up" (SPEC 5.3) | R25 1M | 3.3 uA instead of 33 uA in deep sleep with a card in (review PWR-11). |
| VBUS_SENSE "100 k / 150 k" (SPEC 5.3) | 100k / 75k | 5.25 V gives 2.25 V, inside the ESP32 ADC's calibrated range (review BN-2, ESP32-4). |
| "No copper ... within the vendor keep-out" (SPEC 6) | copper keep-out 4.5 mm beyond the antenna's open end and 2.0 mm beyond the feed end, on every layer; no board cut-out | Espressif's guide asks for the antenna outside the board or a cut-out with 15 mm clearance; that needs a new outline (review ESP32-1, MECH-4). Accepted for revision A, see "Antenna". |
| Delivery as a single PCB (ORDER.md) | the board in its own 1 x 1 frame with rails, fiducials and tooling holes for JLC | JLC needs rails for Standard PCBA; parts sit 0 to 1.4 mm from every edge (review CC-1). The board outline itself is unchanged. |
| CH9102F "power it from VBUS" (SPEC 5.1) | VDD5 and VBUS from USB VBUS, VIO from 3V3 | WCH's dual-supply scheme. VIO sets the UART logic level to the ESP32's 3.3 V and stops the unpowered chip from clamping the UART lines on battery. It draws about 2 uA from 3V3 when VBUS is absent. |
| Outline "x from -27.2 to +27.2, y from -10.0 to -49.6" (SPEC 6) | Same extents, top corners rounded to r 1.0, bottom corners notched (r 2.9 about the bosses) | The notches keep the edge 2.9 from the boss centres as SPEC 6 asks; the 1.0 corners only remove sharp points. |

## Remaining DRC warnings

All 32 are silkscreen warnings. JLC clips silkscreen at the board edge and removes it from exposed copper, so none of them changes the copper, the mask or the assembly.

| Type | Count | Where and why |
| --- | --- | --- |
| silk_edge_clearance | 15 | Outlines of parts that reach the board edge by design: J1 (USB-C face over the bottom edge), SW1 (actuator over the right edge), U1 (module flush with the right edge), J3 (card socket on the bottom edge) and LED1 near the bottom edge. |
| silk_overlap | 11 | LED1's marks touch the right side of J3's outline (LED1 sits between J3 and J1; their courtyards do not overlap). The JLC order-number text sits inside J3's outline on purpose, so the number ends up under the socket. The `M+` label touches the M1 pad ring and the J2 pin-1 `1` label touches its pin-1 dot. |
| silk_over_copper | 6 | The `M+` label, the U5 pin-1 dot, the BZ1 `-` label, part of J3's outline and LED1's marks lie over pads or the GND pour. |

The DRC of the JLC frame (`package_jlc.py`, `jlcpcb/package.json`) has 0 errors and 0 unconnected. It shows the same silkscreen warnings plus `lib_footprint_issues` for the frame's mouse bites, fiducials and tooling holes, which are drawn in place and are not library footprints.

## Check before paying

1. **U1 and U6 stock.** ESP32-PICO-MINI-02-N8R2 (C2980306) is not recommended for new designs and had 1021 in stock on 2026-11-21. MPR121 U6 had 668 (1014 on November 17), battery connector J4 2378, MCP73831 U3 4193; every other line has more than 8000. Check U1 and U6 on the order day; without either the board cannot be built as drawn.
2. **JLC placement preview.** Check every part flagged in `jlcpcb/rotation-check.csv`: J1 opening toward the bottom edge, J2 slot facing the empty ramp area with pin 1 at its -Y end, J3 card slot toward the bottom edge, J4 cable entry toward the top edge, SW1 actuator and U1 antenna over the device right edge (the left edge in JLC's view), the pin-1 marks of U2, U3, U4, U5, U6, U7, U8 and Q1, the single pin of Q2 to Q6, the LED1 cathode and both diodes.
3. **JLC DFM result.** Expect it to mention vias closer than 0.35 mm to pads that cannot be ink-plugged (the order remark allows tenting them), the 0.3 mm GND vias in U1's centre pads and U2's exposed pad (open vias in a pad, accepted, see `jlcpcb/ORDER.md`), the SW1 guide-boss holes 0.07 mm from the SW1 pads, J1's 0.15 mm slot rings (HRO's own land pattern; the slots keep 0.32 mm to other copper), and silkscreen clipped at the board edge. The USB-C and MPR121 pad gaps are 0.20 and 0.188 mm now. Anything else, stop and look.
4. **Screen FPC fold.** The connector sits at x_c -2.24, y_c -39.0 instead of the 0 / -40 targets (inside the allowed ranges). Hold the real screen FPC against a 1:1 print of `review/render-top.png` and check that the folded tail reaches the slot with pin 1 at the -Y end before the enclosure is printed.
5. **Battery polarity.** J4 pin 2 is + (silkscreen + and -). LiPo packs with JST PH plugs come wired both ways; check the pack before plugging it in. Q2 blocks a reversed pack on battery power only: with USB connected, a reversed pack is slowly discharged (about 37 mA) and the charge LED stays on (review PWR-2).
6. **Touch wheel.** Eight slow switching nets cross the wheel on L3 as accepted exceptions ("Touch-wheel re-route", step C), and ELE2 and ELE8 run partly on L3. The firmware must follow "Firmware for the touch wheel". On the first board, measure the touch noise with the screen scrolling and the card reading before setting thresholds, and pick a backlight PWM frequency that does not show up as touch noise.
7. **Cost.** JLC quoted $208.06 before shipping for 5 PCBs and 2 assembled boards on 2026-11-21 for revision A.2 ($185.82 before the review fixes; the frame adds a $25 Panel by Customer engineering fee). JLC may add a charge for soldering J1's shell legs after review. A much higher number usually means a part was matched to a different LCSC number; check the BOM page.
8. **The frame.** The Gerbers hold the board in its own frame (`review/render-panel.png`): order it as "Panel by Customer", 1 x 1, edge rails added by JLCPCB (the form asks for sides over 70 mm, so JLC's rails go outside our frame), and paste the two remarks from `jlcpcb/ORDER.md`. When the boards arrive, cut the three tabs with flush cutters along the hole line, file each nub flush with the board edge and deburr it; never snap a tab (Decision 10).

## Files

| Path | What it is |
| --- | --- |
| `SPEC.md` | the input spec |
| `design.py`, `wheel.py` | parts, nets, placement, rules, wheel geometry (the single source for every script) |
| `make_lib.py`, `import_lcsc.sh`, `measure_models.py` | footprint, symbol and 3D model library in `lib/` |
| `build_schematic.py` | writes `harmony-mark8-slab.kicad_sch` |
| `build_pcb.py` | writes the board: outline, placement, zones, keep-outs, hand routes, GND fan-out |
| `export_dsn.py`, `route.sh`, `import_ses.py`, `routing-s.ses`, `routing-p.ses` | Freerouting phases S and P and their saved sessions |
| `late_routes.py`, `late-routes.json` | the late hand routes |
| `strip_wheel_violations.py`, `finish_pcb.py`, `fixups.py` | wheel-rule strip, GND pours, GND stitching |
| `close_open.sh`, `drc_clean.py`, `route_dump.py`, `maze.py`, `apply_routes.py` | the repair loop |
| `routing_snapshot.py`, `routing-final.json` | the checked routing (save and restore) |
| `refill.py`, `verify.py` | zone refill, checks; write `verification.json` and `mechanical-interface.json` |
| `review_fixes.py` | the layout fixes of the 2026-11-21 pre-order review, applied to the restored routing |
| `q4_gate_sim.py` | Q4 gate-network simulation; writes `review/q4-gate-sim.json` and `review/q4-gate-sim.png` (run with uv: numpy, scipy, matplotlib; not part of `rebuild.sh`) |
| `export_3d.py`, `render.sh` | `board-device-coords.step`, `review/render-*.png`, `review/step-check.json` |
| `check_stock.py`, `package_jlc.py` | `jlcpcb/stock.json`; the JLC frame (built in memory from `design.PANEL`), Gerbers and drill files from it, BOM, CPL, rotation check, `review/render-panel.png`, `jlcpcb/package.json` |
| `rebuild.sh` | runs all of the above |
| `harmony-mark8-slab.kicad_*`, `netlist.xml`, `erc.json`, `drc.json`, `hand-routes.json` | the KiCad 8 project and its check results |
| `jlcpcb/` | `harmony-mark8-slab-gerbers.zip` and `gerbers/`, `bom.csv`, `cpl.csv`, `rotation-check.csv`, `stock.json`, `package.json`, `ORDER.md`, `harmony-mark8-slab.step` (KiCad coordinates) |
| `review/` | the 2026-11-21 pre-order review (`2026-11-21-preorder-review.md` and `.json`) and the change review of its fixes (`2026-11-21-change-review.json`), the Q4 simulation results, schematic PDF, renders of L1, L2, L3, the bottom and the JLC frame, DRC report, Freerouting logs, `reroute-attempt.kicad_pcb` (first re-route to the new disc rule with the original pin map: switching nets compliant, 20 DC connections open), `reroute-stepA.kicad_pcb` (best step A re-route with the step A pin map: one connection open) |
| `reference/` | datasheets and drawings used for the footprints and model checks |

Large binary files (STEP over 1 MB and the zip) need Git LFS rules: `board-device-coords.step` (77 MB), `jlcpcb/harmony-mark8-slab.step` (26 MB), `lib/Harmony8.3dshapes/*.step` (43 MB in all, most over 1 MB), `lib/easyeda/**/*.step` (47 MB in all), the Gerber zip (0.3 MB), and `reference/esp32-pico-mini-02-datasheet-v1.8.pdf` (1.1 MB, already in the folder before this build). Other files over 1 MB: `harmony-mark8-slab.kicad_pcb` (2.0 MB), `review/render-top.png` (1.4 MB), `review/render-l2.png` (1.4 MB), `review/reroute-attempt.kicad_pcb` (2.0 MB) and `review/reroute-stepA.kicad_pcb` (1.6 MB).

## Decisions

Decisions taken on 2026-11-21 while fixing the pre-order review findings, without stopping for questions. Decisions 10 to 13 changed and 18 and 19 were added after the change review of the same day. Each one can be changed in `design.py` or the named script and rebuilt.

1. **Q4 gate network.** Topology: a divider (R13 to 3V3, R14 to GPIO13) holds the gate off against GPIO13's reset pull-down, and a separate RC (R34 into C26, gate to drain) sets the ramp, so the two goals no longer fight. A gate-to-drain capacitor straight on the divider would also need a gate-to-source capacitor ten times larger to keep Q4 off while 3V3 powers up. Values: R13 2.2k (new basic part C25879) rather than 2.7k 0603 (on the BOM): 0.22 V instead of 0.26 V of VGS at a 30k pull-down, and it keeps the 0402 footprint. R13 1k with R14 100R would use only BOM parts but draws 3 mA while the rail is on, against 1 mA. R34 4.7k, C18 1 uF and C26 100 nF are already on the BOM.
2. **R30 75k, not 68k.** 75k (C23242) is already on the BOM for R10. 5.25 V gives 2.25 V at GPIO36, inside the requested 2.1 to 2.4 V; the ADC's 2.45 V calibrated limit is reached at 5.72 V.
3. **C11 4.7 uF 0402 (C23733, new basic part).** The 10 uF 0603 already on the BOM does not fit at C11: its pads would touch the VSYS track from U4 pin 1. A 2.2 uF 0402 keeps only about 1 uF at 3.3 V.
4. **R9 10k and R25 1M.** Not in the requested list, but both are value swaps with no layout change and parts on the BOM. R9 shortens the post-unplug window on Q3's body diode (PWR-5); R25 cuts the card-detect sleep current from 33 to 3.3 uA (PWR-11). Firmware reads SD_CD twice before it acts.
5. **No SD_MOSI pull-up (CONN-2) in revision A.** No 0402 fits in or beside the R21 to R25 row without moving C12 or the pull-ups. The only free spots where SD_MOSI and 3V3_PERIPH are both near need a new SD_MOSI via inside the wheel, which the touch rule forbids. The firmware already drives MOSI before the rail comes up.
6. **Decoupling moves (BN-1, PERIPH-4) deferred.** Moving C15 and C16 next to U7's supply pins, or adding a capacitor at U3 pin 3, needs a re-route of the crowded left column. The motor is optional and the default build has none; the finding lists two bodges for the first board.
7. **Antenna clearance to y -18.2.** That is 0.1 mm short of SW1's GND guide pad, the most the layout allows without moving SW1. The full fix (antenna overhang or a cut-out with 15 mm of clearance) changes the outline and the case: revision B.
8. **SD_CS L3 cap raised from 12.75 to 13.12 mm.** Moving the SD_CS via out of the J3 card-detect column lengthens its L3 hop under ELE6 by 0.37 mm (3 percent). A via of another net under the detect spring is the worse risk.
9. **J3 hatched areas.** `J3_NO_TRACE_LOCAL` takes the union of the two reviewers' scaled readings, except for area D's outer edge, where it uses the 900 dpi reading so that J3 pin 13's GND fan-out via stays outside. Area A (the card-detect column) allows SD_CD and GND track, because the metal above it is the SD_CD detect spring or the GND shell; about 2.6 mm of SD_CD track stays there.
10. **The JLC frame.** Rails on all four sides (5 mm), a 2.0 mm routed gap and three mouse-bite tabs (moved after the change review, FAB-1, FAB-2, FAB-5): one on the left edge at y -15.5 (2.1 mm from the J4 pads), one at the right end of the top edge (x 22.1 to 26.1, 4.0 mm wide, so it stays 1.2 mm from the SW2 pads and ends before the corner radius) and one on the right edge below the antenna (y -45.4 to -40.6, 2.7 mm below the antenna keep-out and 1.8 mm from locating hole H2). No tab is in the screen FPC's dive zone (top edge, x -14 to +19), no tab is near H1, and the board hangs at three corners instead of from its top edge. No tab fits on the top edge left of the dive zone (the J4 pads are 0.3 mm and TP1 is 0.9 mm from it, and only 2.9 mm is free between J4 and the dive zone), on the bottom edge (J1, J3, LED1, R1, C1, TP5 and TP6 within 1 mm of it) or beside the antenna and SW1. The holes are 0.6 mm at 0.95 mm pitch (JLC's mouse-bite guide): five in a 4.8 mm tab, four in the 4.0 mm tab. Their row is 0.35 mm outside the board edge and the holes stop 0.05 mm short of it, so the weakest line is 0.35 mm outside the edge, not at it. A cut along the hole line leaves a nub 0.05 to 0.35 mm proud, with half-hole scallops, that must be filed flush and deburred. A hole row on the edge would put scallops into the board edge and needs the ground pours pulled back on all four layers; a filed nub costs less. Three 1 mm fiducials with 2 mm openings, 3.85 mm from the frame edge; four 2.0 mm NPTH tooling holes (JLC's SMT page; JLC's FAQ also names 1.152 mm, for Economic assembly). The frame exists only in the Gerbers: the board file, its STEP and `mechanical-interface.json` stay the bare board.
11. **J1 pin-in-paste.** A paste-only opening over each shell slot, up to 0.25 mm larger than its pad and cut back to stay 0.15 mm (0.16 drawn) from other-net copper, via rings and other paste openings (change review REG-1, USBC-3): beside pad 1 (LCD_MOSI and the B1A12 opening), pad 2 (the tented CHG_STAT and VBUS vias and the VBUS track) and pad 4 (the A1B12 opening). The openings are 2.91, 2.60, 2.66 and 3.06 mm2 (pads 1 to 4); `verify.py` checks them against the routed board. JLC chooses the stencil for PCBA, usually 0.10 or 0.12 mm. Paste times 0.51 (the metal share of SAC305 paste) against the free slot around the leg, 0.8 mm deep, gives about 30 to 32 percent fill at 0.10 mm and 36 to 39 percent at 0.12 mm. That makes a top-side fillet around each leg, not a full barrel. The order remark also asks JLC to solder the legs.
12. **J2 paste.** Hirose's recommended stencil (EDC3-338903-01 sheet 1, measured on the 400 ppi scan at 157.5 px/mm): contact-1 openings 0.23 x 0.65 and contact-2 openings 0.23 x 0.55, each flush with its pad's outer edge, so the pull-back is on the inner side and the rows are 2.40 apart; fitting openings 0.30 x 0.70 at the fitting pad's outer corner (flush with its outer end and its contact-1 side). KiCad's paste margin is centred on the pad, so `make_lib.py` draws these as paste-only pads. Until the change review the openings were centred and the contact-1 row was 0.70 long (USBC-2). The fitting pads stay at x +-2.76 (Hirose 2.80, 0.04 mm), and their openings follow the pads.
13. **U2 exposed-pad paste.** Nine windows on a 3 x 3 grid with 0.2 mm webs through the four GND vias, each window at least 0.1 mm off a via land and 0.1 mm inside the pad: 2.96 mm2, 47 percent of the 2.5 x 2.5 pad. The webs keep paste off the open via barrels (change review USBC-4; it was one 2.0 x 2.0 opening over all four vias). U1's centre pads stay at 100 percent: the related claim (ESP32-5) was refuted.
14. **Inner copper stays 0.5 oz** and **via covering is Plugged**, with no epoxy fill: see `jlcpcb/ORDER.md`.
15. **`review_fixes.py` runs after the restore** and `routing-final.json` keeps the 2026-11-17 routing, so the review's layout changes stay readable as code.
16. **LCD_LEDA** is an accepted exception (cap 11.92 mm, 2 vias) instead of a DC net, so `verify.py` guards it (PERIPH-1).
17. **Stock.** `check_stock.py` was rerun in full on 2026-11-21, because two LCSC numbers were new; `stock.json` holds that check.
18. **J1 slot clearance** (change review USBC-1). A `.kicad_dru` rule (written by `build_pcb.py`) keeps 0.32 mm between J1's plated slots and other-net copper on every layer. JLC asks for 0.30 mm on the inner layers; the extra 0.02 mm keeps the zone fills off that figure. The L3 VBUS run above pad 1 moved 0.06 mm, and the ELE5 electrode on L4 gives up a 0.04 mm band around pads 1 and 4. The slots, pads and 0.15 mm rings stay as HRO draws them.
19. **Q4 simulation.** `q4_gate_sim.py` models C11 at 1.3 uF, the low end for the 4.7 uF 0402 at 3.3 V (it said 5 uF). The re-run gives the same results as before at the precision of `review/q4-gate-sim.json`: only the C11 assumption in that file changed (change review Q4-4).

## Review dispositions, November 21

One row per finding of `review/2026-11-21-preorder-review.md`. "Fixed" means fixed in this revision A and checked by DRC, ERC and `verify.py`. "Firmware", "Enclosure" and "Bring-up" name the later pass that owns the item. "Rev B" items wait for the next board.

### Firmware changes this revision needs

1. `SLAB_PERIPH_RAMP_MS` (slab_power_seq.h) from 5 to 20 ms. The new Q4 network brings 3V3_PERIPH to 90 percent 3.3 to 10.1 ms after GPIO13 goes low. Correct the header comment: there is no 1 ms ramp, and Q4 is now held off from reset release until firmware drives GPIO13 low (the GPIO13 polarity is unchanged).
2. `SLAB_VBUS_DIVIDER_X1000` from 1667 to 2333 (R29 100k, R30 75k: VBUS = pin x 175 / 75). `SLAB_VBUS_PRESENT_MV` 4300 can stay (1.84 V at the pin).
3. A real card power cycle needs about 0.4 s with GPIO13 high (or a GPIO25 reading below 0.4 V) before the rail comes back (CC-2). Q4 now also turns off at every reset, up to about 20 ms after reset release (change review Q4-4).
4. Read SD_CD (R25 now 1M) twice a few milliseconds apart before acting on it.
5. Without an SD_MOSI pull-up, keep driving MOSI before the rail comes up, and turn on GPIO19's internal pull-up whenever the SD bus is released while the rail is on (CONN-2).
6. Average several ADC samples for each VBUS_SENSE reading: GPIO36 has no filter capacitor (change review Q4-5).
7. The other firmware items in the tables: PWR-6, PWR-10, PERIPH-2, FP-5 and PERIPH-3, L6, ESP32-6, FW-HW-2 to FW-HW-7, CC-2 and the optional PWR-2 message.

Changes 1 and 2 (and the test in `tests/test_power.c` that asserts the old divider) must be made before any firmware, the bring-up test included, runs on a revision A board (change review Q4-1).

### Table

| ID | Severity | Disposition | What was done, or why not now |
| --- | --- | --- | --- |
| ESP32-1 | major | Fixed (partly); Rev B; Bring-up | Copper keep-out on all four layers extended from y -21.8 to -18.2: in the antenna's own column, ground now starts 4.5 mm beyond the open end (0.9 mm before; see ANT-1). R31 and R32 moved; I2C_SDA, VBUS and ESP_EN re-routed left of x 21.8; SW1 pad 5 joined to pad 3. Espressif's cut-out with 15 mm clearance needs a new outline: Rev B. Bring-up: A2DP range test with the player in a pocket. |
| FP-1 | major | Fixed; Bring-up | Pin-in-paste openings over J1's four shell slots (pad + 0.25 mm, cut back near other copper since the change review, Decision 11) and an order remark asking JLC to solder the legs. Bring-up: a top-side fillet around each leg; look for solder beads next to J1 pads 1, 2 and 4; measure VBUS, CHG_STAT, LCD_MOSI and USB_DN to GND before the first plug-in. |
| L1 | major | Fixed | EasyEDA's 0.1 mm stroke removed from J1's four power pads (now 0.60 wide as HRO draws them, 1.30 long as in EasyEDA's pattern: GND to VBUS and VBUS to SBU2 gaps 0.20 mm) and from U6's eight corner pads (0.224 wide, gaps 0.188). No other footprint has custom pads. The J1 and U6 DRC exceptions are deleted. |
| BN-1 | minor | Rev B; Bring-up | See Decision 6. Bring-up: if VBAT rings with no pack or U7 faults with a motor, fit the bodge capacitors the finding names. |
| BN-2 | minor | Fixed; Firmware | R30 150k to 75k: 5.25 V gives 2.25 V at GPIO36. Firmware change 2. |
| PWR-1 | minor | Fixed; Firmware | New Q4 gate network (see "Power"): 90 percent in 3.3 to 10.1 ms, at most 161 mA through Q4, 3V3 at U1 at least 3.22 V with the RT9080 at its 610 mA minimum limit and a 250 mA ESP32 load. Firmware change 1. |
| PWR-2 | minor | Fixed (docs); Enclosure; Firmware (optional) | README, ORDER.md and the build guide now say that Q2 blocks a reversed pack only on battery power. ASSEMBLY.md step 6 now has the same words. Optional firmware message when VBUS is present and VBAT_SENSE stays below 2 V. |
| PWR-3 | minor | Fixed (docs); Bring-up | README VBUS numbers corrected (0.32 to 0.35 ohm, 0.15 to 0.25 V at 0.5 to 0.7 A). Inner copper stays 0.5 oz. Bring-up: VBUS at U3 pin 4 while charging with the backlight at full. |
| PWR-4 | minor | Bring-up | Measure the board temperature behind U3 while charging an empty pack in the closed case; above about 50 C, print the front in PETG or raise R7 to 3.9k or 4.7k. |
| PWR-5 | minor | Fixed; Bring-up; Rev B | R9 100k to 10k (wall-charger unplug window from about 50 to 120 ms down to tens of ms). Bring-up: scope 3V3 at TP1 while unplugging at VBAT 3.6 V with audio. Rev B: Schottky across Q3 or an ideal-diode switch. |
| PWR-6 | minor | Firmware | Low-battery cutoff and a higher brownout level; PWR-1 is fixed, so a higher level is now safe. |
| PWR-7 | minor | Fixed; Bring-up | C11 1 uF to 4.7 uF 10 V X5R 0402 (about 2 uF at 3.3 V; Decision 3). Bring-up: look for ringing at C11 during a backlight step and Bluetooth start. |
| PWR-10 | minor | Firmware | Accepted for revision A; keep or lower the backlight cap while on USB. |
| PERIPH-1 | minor | Fixed (docs and checks); Rev B; Bring-up | LCD_LEDA is now an accepted L3 exception (cap 11.92 mm, 2 vias) that `verify.py` guards. Bring-up keeps the PWM-frequency noise sweep. Rev B: R17 on the cathode side. |
| PERIPH-2 | minor | Firmware; Rev B | R17 power cap from VF 2.7 V and 10 ohm; cap brightness at 100 percent. Rev B: a 0.5 W 1206. |
| PERIPH-4 | minor | Rev B | Same as BN-1 (Decision 6). |
| CONN-1 | minor | Fixed (mostly) | VBAT's L1 bridge moved off bar C (now above it, between the contact row and the bar), SD_CD moved out of strip B into the 0.35 mm corridor beside it, and the SD_CS, 3V3_PERIPH and VBUS vias moved out of column A. Rule areas and a custom DRC rule enforce the four hatched areas. Left: about 2.6 mm of SD_CD track in column A, under the SD_CD detect spring (Decision 9). |
| CONN-2 | minor | Rev B; Firmware | No room for the pull-up (Decision 5). Firmware change 5. |
| ESP32-2 | minor | Fixed | With PWR-1: VGS -0.09 to -0.22 V at reset release, Q4 off until firmware drives GPIO13 low. |
| ESP32-4 | minor | Fixed | Same as BN-2. |
| FP-2 | minor | Fixed | Same as L1. |
| FP-3 | minor | Fixed | J2 paste openings follow Hirose's stencil (Decision 12; corrected after the change review, USBC-2). |
| FP-4 | minor | Fixed (mostly) | Same as CONN-1. |
| FP-5 | minor | Firmware; Rev B | Cap sustained-tone duty and length, never hold GPIO2 high. A 47 R would only lower the click and still overload R18 if GPIO2 stuck high. Rev B: a 0.25 W part. |
| FP-6 | minor | Fixed | Same as PWR-7. |
| L2 | minor | Fixed | J1 slots now HRO's 0.6 x 1.7 (beside the contacts) and 0.6 x 1.4 (near the edge) in 0.9 x 2.0 and 0.9 x 1.7 pads: length-to-width 2.8 and 2.3, so JLC's 2:1 rule passes. The real legs (about 0.3 thick, 1.10 and 0.80 wide, HRO side view) keep 0.15 mm per side across and 0.3 mm per end. |
| L3 | minor | Fixed; Bring-up | U8 pin 2's GND via moved 0.4 mm off its pad, under the U8 body; J3 pin 4's via 0.14 mm off its pad. Only the U1 and U2 thermal-pad vias stay in a pad. ORDER.md: Plugged. Bring-up: look at L4 over the U1 pad vias for solder bumps before fitting the disc. |
| L4 | minor | Fixed | DTR via moved 0.26 mm from U2 pin 23's opening (0.15 from the nearest, the unused pin 22). No via is within 0.10 mm of another net's opening. Order remark: vias closer than 0.35 mm to pads may be tented (166 of 274). |
| L5 | minor | Fixed | No-copper rule area on L1 over Alps' prohibited area under SW1; nothing is left in it. |
| L6 | minor | Fixed (docs); Firmware; Rev B | README note 5 corrected (the SD lines cross the wheel on L1). Firmware: GPIO drive strength 0 or 1, 10 MHz fallback. Rev B: series resistors at J3 (with CC-5). |
| MECH-1 | minor | Enclosure; Rev B | ASSEMBLY.md: plug the battery into J4 before the board goes in. Rev B: a connector whose plug path misses the screen. |
| MECH-2 | minor | Enclosure | LED tube to J1 and J3 clearance. |
| MECH-3 | minor | Enclosure | Make the foam thickness and the largest pack agree. |
| MECH-4 | minor | Fixed (partly); Enclosure; Bring-up | The open-end clearance is now 4.5 mm on the board (ESP32-1). The case keeps metal away from the right wall; range test at bring-up. |
| MECH-5 | minor | Enclosure | Grow the card slot toward the board, or centre it on a measured card height. |
| FW-HW-1 | minor | Fixed; Firmware | Q4 is off from reset release until firmware init (PWR-1); README "Power" corrected; firmware change 1 fixes the comments. |
| FW-HW-2 | minor | Firmware | Bring-up `wait_press()`: require a release first and fail a press held 10 s. |
| CC-1 | minor | Fixed | The board ships in its own frame (Decision 10). ORDER.md: Panel by Customer; JLC adds its own rails outside our frame (its form asks for sides over 70 mm). ORDER.md and the build guide say to cut the tabs with flush cutters along the hole line, file the nubs flush and deburr them, never snap them. |
| CC-2 | minor | Firmware; Rev B | Firmware change 3. Rev B: a switched bleed on 3V3_PERIPH. |
| BN-4 | note | Fixed (docs) | SPEC 5.2 corrected: U5 is powered from VBAT. |
| BN-7 | note | No action | VCC and IOVCC at the top of their range, as SPEC 3 chose. |
| PWR-8 | note | Bring-up; Rev B | Scope VBAT with no pack and during CV. Rev B: 10 uF at U3 pins 4 and 3. |
| PWR-9 | note | Bring-up | With no pack, a faint LED flicker and a near-full gauge reading are expected. |
| PWR-11 | note | Fixed | R25 100k to 1M; README deep-sleep budget now includes D1 leakage and the MPR121 slow scan. |
| PWR-12 | note | Fixed | Same as BN-2. |
| PERIPH-3 | note | Firmware; Rev B | Same as FP-5. |
| PERIPH-5 | note | No action | Avoid bench supplies above 5.25 V on VBUS. |
| CONN-3 | note | No action | If the screen misbehaves, measure 3V3_PERIPH at C19 and C20. |
| CONN-5 | note | Enclosure | At assembly, insert the FPC tail flat with the actuator open; trim a tail at the top of its width tolerance. |
| ESP32-6 | note | Firmware | If TE is ever an edge interrupt, mask it around ADC conversions. |
| FP-8 | note | Fixed | With L1: U6 corner pads 0.224 wide; README no longer credits the gaps to NXP. |
| FP-9 | note | Rev B | The buzzer pads are adequate; move them 0.3 to 0.4 mm inward next time. |
| FP-10 | note | Fixed (U2) | U2's exposed pad prints through nine windows, 47 percent, clear of its vias (Decision 13, change review USBC-4); U1 stays at 100 percent. |
| FP-11 | note | Fixed | `rotation-check.csv` now flags U3, U4, U8 and Q2 to Q6 too. |
| FP-12 | note | Rev B | C7 as a 10 uF 0805 needs a new footprint. |
| FP-13 | note | Rev B | TI's longer heel pads for U7. |
| L7 | note | Fixed (docs) | Same as PWR-3. |
| L8 | note | Fixed (docs) | ORDER.md: Plugged, the order remark and the expected DFM comments. |
| L9 | note | Bring-up | Log ELE8 while touching ELE1, ELE2 and the centre, and ELE2 while touching the centre. |
| L10 | note | Fixed (docs); Bring-up | Noise logging now also covers charging and card read bursts. |
| L11 | note | Rev B | Small silkscreen labels may print soft; cosmetic. |
| L12 | note | Fixed | Same as FP-1. |
| L13 | note | Fixed (partly) | Drill-map files are no longer in the zip. The 0.04 mm2 L2 fragment and the E1 pads listed as component holes are cosmetic; at most a DFM note. Record the prepreg thickness JLC's order page shows for the 0.8 mm default stack-up. |
| MECH-8 | note | Bring-up | Log ELE5's baseline at its 6 o'clock edge; give it its own thresholds if needed. |
| MECH-9 | note | Enclosure | Mark the FPC fold on the real screen at the dry fit; fold softly. |
| FW-HW-3 | note | Firmware | Add 13.33 MHz as the in-spec screen clock fallback; cap the Kconfig range at 40 MHz. |
| FW-HW-4 | note | Firmware | Cap the card clock at 20 MHz, or document the output-delay limit. |
| FW-HW-5 | note | Fixed; Firmware | Same as BN-2. |
| FW-HW-6 | note | Firmware | Do not arm ext0 while the side button is still low. |
| FW-HW-7 | note | Firmware | Document "touch and hold about 1 s to wake", or test DT 0 in sleep. |
| CC-3 | note | Bring-up; Rev B | Check the 0402s under a loupe, C4 and C11 first. Rev B: thermal reliefs on SMD GND pads. |
| CC-4 | note | Bring-up; Rev B | Scope VBUS at C1 during a hard plug-in; above 6.0 V, add a 5 V TVS. Rev B: TVS at J1. |
| CC-5 | note | Rev B | Series resistors or a TVS array at J3. |
| BN-6 | note (uncertain) | Bring-up | Check the enumerated VID and PID (1A86:55D4). |
| PERIPH-6 | note (uncertain) | Bring-up | On battery with USB unplugged, measure ESP_EN and IO0 near 3.3 V and confirm a normal boot. |
| CONN-4 | note (uncertain) | Firmware | Keep the USB duty cap; check the FH35C contact rating in the Hirose catalogue. |
| ESP32-7 | note (uncertain) | Bring-up | Same check as PERIPH-6; measure U2 pins 19 and 23 too. |
| BN-5 | note (accepted) | Fixed (docs) | SPEC 5.1 U2 now reads "VDD5 and VBUS from USB VBUS, VIO from 3V3". |
| MECH-7 | note (accepted) | Enclosure | Keep the "sand the head" check. |
| BN-3 | note (refuted) | No action | |
| ESP32-3 | note (refuted) | No action | |
| ESP32-5 | note (refuted) | No action | |
| FP-7 | note (refuted) | No action | ORDER.md now says Plugged anyway. |
| MECH-6 | note (refuted) | No action | |

### Change review, November 21

One row per finding of `review/2026-11-21-change-review.json`, the review of the fixes above (commit 71b8df7), including the items its verifiers found ("missed"). The disposition words mean the same as in the table above.

| ID | Severity | Disposition | What was done, or why not now |
| --- | --- | --- | --- |
| ANT-1 | note | Fixed (docs); Bring-up | "Antenna" now says that the 4.5 mm holds in the antenna's own column; beside the module, ground starts about 0.9 mm from the open-end tip, as in Espressif's reference. Bring-up: read the A2DP range test against this geometry. |
| USBC-1 | minor | Fixed | Custom DRC rule: 0.32 mm from J1's plated slots to other-net copper on every layer (Decision 18). The L3 VBUS run above pad 1 moved 0.06 mm. Measured on the Gerbers and the drill file: L1 0.36, L2 0.44, L3 0.34 (0.28 before), L4 0.32 (ELE5, 0.28 before). Slot and pad sizes stay HRO's. |
| USBC-2 | minor | Fixed | J2 paste follows Hirose's stencil as measured on the drawing: 0.23 x 0.65 and 0.23 x 0.55, flush with each pad's outer edge, rows 2.40 apart (Gerber 2.405); fittings 0.30 x 0.70 at the pad's outer corner (Decision 12). README Decision 12 and ORDER.md now describe this pattern. |
| USBC-3 | note | Fixed (docs); Bring-up | Fill estimate stated for both stencils: about 30 to 32 percent at 0.10 mm and 36 to 39 percent at 0.12 mm, a top-side fillet (Decision 11). The bring-up check is reworded everywhere (FP-1 row, ORDER.md, build guide). |
| USBC-4 | note | Fixed; Bring-up | U2's exposed pad prints through nine windows, 2.96 mm2 (47 percent), 0.11 mm or more from the four via lands (Decision 13). The windows keep paste off the open vias at printing; molten solder can still wick into them. Bring-up: U2 sits flat, all 24 pins are wetted, and the CH9102 enumerates on USB. |
| USBC (missed) | note | Fixed (docs) | The L1 row no longer calls the 1.30 mm pad length HRO's: it is EasyEDA's, and it lands the tails. |
| Q4-1 | note | Firmware | Firmware changes 1 and 2 (`SLAB_PERIPH_RAMP_MS` 20, `SLAB_VBUS_DIVIDER_X1000` 2333, the header comment and `tests/test_power.c`) must be made before any firmware runs on a revision A board. |
| Q4-2 | note | Bring-up | Hold the first board in download mode and measure 3V3 minus PERIPH_GATE: 0.25 V or less. Measure 3V3_PERIPH (under 0.1 V) only with the screen and the card removed (see Q4 missed). |
| Q4-3 | note | Bring-up | Measure the drop from 3V3 to 3V3_PERIPH during an SD write burst; expect under 50 mV. |
| Q4-4 | note | Fixed (docs) | `q4_gate_sim.py` models C11 at 1.3 uF and was re-run (Decision 19). "Power" now gives VGS above about -0.37 V at power-up, the assumptions behind 3.22 V, and turn-off up to about 20 ms after reset release; firmware change 3 says the same. |
| Q4-5 | note | Firmware; Rev B | Average several ADC samples for VBUS_SENSE (firmware note 7, firmware change 6). Rev B: 100 nF 0402 from GPIO36 to GND. |
| Q4 (missed) | note | Fixed (docs); Bring-up | "Power" no longer says that the rail is off in download mode: the GPIO5 and GPIO14 reset pull-ups feed the unpowered card and screen, so 3V3_PERIPH can sit at 1 to 2.5 V. Bring-up check as in Q4-2. The CC-2 firmware item (a GPIO25 reading below 0.4 V before the rail comes back) covers the card's power-cycle need. |
| FAB-1 | minor | Fixed (docs) | The hole row stays 0.35 mm outside the board edge (Decision 10): holes on the edge would scallop the edge and need the ground pours pulled back. Decision 10, the `design.py` comment, ORDER.md "When the boards arrive" and the build guide now say: cut with flush cutters along the hole line, file the nub flush, deburr, never snap. |
| FAB-2 | minor | Fixed | No tab is near H1 now (the nearest tab is 14.5 mm away). The three tabs moved out of the FPC dive zone: left edge y -15.5, top edge x 22.1 to 26.1, right edge y -45.4 to -40.6 (Decision 10). |
| FAB-3 | minor | Fixed (docs) | ORDER.md remark 3 and the PCB-form row: JLC may add rails outside our frame, but must not cut or change our tabs and must ship the boards in the frame. |
| FAB-4 | note | Fixed (partly) | `package_jlc.py` rewrites the job file after the rename: every path names a file in the zip, and the finish is ENIG. The job file still gives 0.035 mm inner copper; JLC takes the stack-up (0.5 oz inner) from the order form. |
| FAB-5 | note | Fixed | The board now hangs at three corners (left edge near the top, top edge near the right, right edge low), not from its top edge. ORDER.md and the build guide give a cut order: hold the board, cut the left tab (next to J4) first. |
| FAB-6 | note | Fixed (docs) | README Decision 11 and ORDER.md agree: JLC usually chooses the stencil (0.10 or 0.12 mm); if the order page offers a choice, take 0.10 mm for J2; the J1 fill is given for both. |
| FAB (missed) | note | Fixed (docs) | ORDER.md "Check before paying" item 1 and README item 2: SW1 and the U1 antenna sit over the device right edge, the left edge in JLC's view. |
| REG-1 | minor | Fixed; Bring-up | The J1 paste openings keep 0.16 mm or more from LCD_MOSI and every other copper, via and opening (Decision 11); `verify.py` checks them against the routed board. Bring-up as in FP-1. |
| REG-2 | note | Fixed (docs and checks) | ORDER.md now has the reversed-pack line. `VBUS_PATH_ACCEPTED` caps L1 0.30 mm track at 21.37 mm (it said 22.67), so `verify.py` guards the measured value. |
| REG-3 | note | Bring-up | Include ELE6 in the noise log on battery with the backlight PWM running; give ELE6 its own threshold if it is noisier than its neighbours. |
| REG-4 | note | Rev B | Accepted for revision A (plugged vias, under mask). Rev B: move these vias about 0.2 mm further from column A and keep VBAT out of the J3 footprint. |
| REG-5 | note | Enclosure | Re-run the enclosure `checks.py` against the new `board-device-coords.step`. This pass changed no outline, part position or height: `mechanical-interface.json` differs only in its copy of the verification summary (the new J1 paste check, VBUS L3 length 0.02 mm shorter, file hashes). |
| REG-6 | note | No action | Commit only `hardware/mark-8/slab-rev-a` and `docs/mark-8-slab-build.md`; the Mark-7 edits belong to their owner. |
| REG (missed) | note | Fixed; Bring-up | The J1 pad 2 opening now keeps 0.16 mm from the tented CHG_STAT and VBUS via rings (0.04 and 0.08 before). Bring-up: measure VBUS and CHG_STAT to GND before the first plug-in. |

A third check (read-only, after revision A.2) measured every claim above in the exported Gerbers and drill files and found no blocker, major or minor item. Its six notes: three tabs hold the board, and JLC supports it from below for printing and placement (if JLC asks about the tabs, discuss it rather than let remark 3 block the order); FAB-4 is only partly fixed (row above); `verify.py` now also checks that each J1 paste opening covers its whole slot pad and is at least 2.5 mm2; Decision 10 had a wrong TP1 distance (corrected); the router leaves a fillet in each inside corner at the tab ends, which must be filed too (ORDER.md, build guide); the U2 bring-up check is restored (USBC-4 row).
