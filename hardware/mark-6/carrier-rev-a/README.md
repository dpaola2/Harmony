# Harmony Mark-6 carrier, revision A

Current logistics, September 22: Dave has received the printed shells, gauge and spacers. The ordered PiShop display has shipped. Physical fit and the other deliveries remain unconfirmed. Use the [arrival checklist](arrival-checklist.md) for the next checks. A [supplier request draft](supplier-request-draft.md) is prepared but unsent.

September 22 display update: **Waveshare 29318 (ST7796S)** replaces unavailable Adafruit #5846. [PiShop.us](https://www.pishop.us/product/3-5inch-capacitive-touch-display-320-480-ips-2tpd/) lists it in stock at $24.95. The [sourcing and compatibility review](display-sourcing.md), [hollow prototype](../../../enclosure/mark-6/fit-prototype/README.md) and [firmware](../../../firmware/mark-6/feather-carrier/README.md) now use this module. The carrier electrical nets are unchanged. Manufacturing remains review-only.

Updated September 22, 2026. HARMONY-17. **Routed prototype design; manufacturing review package, not an order release.**

Dave printed and accepted the **74 x 178 x 28 mm** size dummy. The component
stack now uses the actual Feather and ANO 3D models, specified sockets and
an antenna cutout. The routed four-layer PCB passes KiCad DRC with **zero
violations and zero unconnected nets**. The independent PCB audit matches
122 electrical pads to the schematic and all 28 Feather mating coordinates
to vendor CAD. The schematic also passes ERC.

The [assembly readiness review](assembly-readiness.md) records the corrected ENIG metadata, part/placement audit and the documented U1 thermal-hole DRC warning.

Start with [the design review](output/pdf/design-review.pdf),
[editable PCB](harmony-mark6-carrier.kicad_pcb),
[schematic](harmony-mark6-carrier.kicad_sch), and
[manufacturing review package](output/manufacturing-review/README.md).
[Mechanical review](mechanical-review.md), [power review](power-review.md)
and [machine-readable verification](pcb-verification.json) document the
checks and their limits. No order has been placed.

USB-only operation remains adopted. Battery space is reserved for Mark 8.
The accepted size dummy proves the outside dimensions work for Dave; physical
display fit, header insertion and cable access still require a trial assembly.
The revised prototype uses the Waveshare vendor STEP, including rear connectors.

Dave adopted a 3.5-inch display and separate display/storage buses. The carrier
will arrive assembled, including its sockets and connectors. Dave plugs in a
factory-headered ESP32 Feather V2 (#5900), a display ribbon cable and the
controls cable. No hand soldering is part of the intended assembly.

## Parts and interfaces

Bluetooth verification: the live DigiKey cart contains four Adafruit #5900,
DigiKey 1528-5900-ND. Adafruit's Feather V2 schematic identifies X3 as
ESP32-PICO-MINI-02, containing ESP32-PICO-V3-02. This original ESP32 supports
Bluetooth 4.2 BR/EDR (Classic) and BLE; it meets the radio requirement for
A2DP source streaming. Adafruit #5900 explicitly specifies Classic/LE, and
[Espressif's module datasheet](https://documentation.espressif.com/esp32-pico-mini-02_datasheet_en.html)
confirms BR/EDR. [ESP-IDF's A2DP source example](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/bluetooth/esp_a2dp.html)
documents audio transmission. This verifies specifications, not a physical
playback test on the new Feather. Keep this exact Classic-capable model in
the BOM; a BLE-only ESP32-family substitution does not satisfy the requirement.

| Function | Draft implementation | Status |
| --- | --- | --- |
| Processor and Bluetooth | Adafruit ESP32 Feather V2 #5900 in carrier sockets | Four in DigiKey cart; not purchased |
| Display | Waveshare 29318 3.5-inch IPS, via 18-pin ribbon | Glass 61.00 x 92.44 mm; PiShop.us lists in stock |
| Storage | Hirose DM3AT-SF-PEJM5 microSD socket on carrier | Pin and footprint pad sets checked |
| Controls | Previously ordered assembled ANO I2C control board | 50 mm QT-to-QT cable; nominal stack checked |
| Power | USB-C through Feather; TPS62162 3.3 V peripheral supply | USB budget reviewed; physical startup/load/thermal qualification remains |

The EYESPI breakout replaces the proposed FeatherWing connection so that the
carrier can assign display and storage to separate SPI hosts. Its onboard SD
socket stays unused. Capacitive touch on Waveshare 29318 is incidental; the interface
still uses physical controls.

## Proposed GPIO assignment

These are **ESP32 GPIO numbers**, not generic Feather pin numbers. Header
references below use the numbering in Adafruit's Feather V2 Eagle files.
They are for schematic development, not a breadboard wiring instruction.

| Signal | GPIO | Feather header | Destination |
| --- | ---: | --- | --- |
| SD clock | 5 | JP1.6 | Carrier SD CLK |
| SD MOSI | 19 | JP1.5 | Carrier SD CMD |
| SD MISO | 21 | JP1.4 | Carrier SD DAT0 |
| SD select | 25 | JP1.11 | Carrier SD DAT3 |
| Display clock | 14 | JP3.10 | EYESPI 4 |
| Display MOSI | 27 | JP3.6 | EYESPI 5 |
| Display select | 26 | JP1.12 | EYESPI 9 |
| Display command/data | 33 | JP3.7 | EYESPI 7 |
| Display reset | 32 | JP3.9 | EYESPI 8 |
| Display backlight control | 4 | JP1.7 | EYESPI 2 |
| Controls I2C clock | 20 | JP3.11 | Controls SCL |
| Controls I2C data | 22 | JP3.12 | Controls SDA |
| Peripheral power-good input | 34 | JP1.10 | TPS62162 PG |

Use SPI3 for SD and SPI2 for display in native ESP-IDF. The allocation does
not reuse signal GPIOs. A 47k pull-up reinforces GPIO5's normal high boot
strap; the SD clock destination is an input. GPIO12 and GPIO15 stay unused.
Display MISO and touch are unused. The display-side SD select is held high.
The Waveshare display uses SPI without jumper soldering. GPIO34 reads peripheral power-good before firmware starts I/O.

## Power, parts and mechanics

The exact carrier component choices are in `bom-draft.csv`; the grouped
assembler BOM is `output/manufacturing-review/assembly-bom.csv`. Both sockets
and every connector must be fitted by the assembler. F1 is a 0.75 A-hold
Bourns PTC, with 0.52 A hold at 60 C. The regulator uses 2.2 uH and 22 uF
input/output bulk capacitors. The [power review](power-review.md) gives the
source budget, limits and staged first-power procedure.

The [mechanical review](mechanical-review.md) records the 6.5 mm carrier
height, 12 mm ANO spacers, cable orientation and case-port requirements.
The vendor 3D model yields 0.88 mm nominal clearance above the Feather
beneath a 1.6 mm front wall. Display geometry uses the Waveshare vendor STEP.
The detailed assembly is in `output/mechanical/`; it is a review model,
not the final hollow housing.

The carrier cutout removes board material beneath the antenna. Ground pours
avoid the 15 mm halo, while unavoidable header copper remains inside part
of it. The finished device still needs an RF test. Vias inside SMT pads
require filled, copper-capped construction and assembler stencil review.
The release conditions are listed in the manufacturing package.

`build_pcb.py` creates the initial placement; `routing.ses` is the saved
routing result. `routed-base.kicad_pcb` preserves its imported state.
`finish_pcb.py` loads that base, completes the remaining routes, adjusts
edge clearance and fills ground planes. `verify_pcb.py` checks the final
board against the exported schematic netlist. Run it with KiCad's bundled
Python after generating a fresh `final-drc.json`.

## Evidence and limits

Mark-5 SD reads provoked clicks in its local VS1053 analog output; RAM-only
playback was clean. That did not establish shared SPI as the cause. Separate
buses reduce contention; they do not prove clean playback or replace power
layout work. Mark-6 must still demonstrate display refresh during Bluetooth
playback, controls, reconnection and the deferred full-album run.

Vendor Feather, display, ANO and EYESPI CAD, licenses and source hashes are
preserved in `reference/`. Passive socket symbols do not model the ESP32's
electrical limits, so a clean ERC alone cannot establish GPIO compatibility.
The netlist checks explicitly verify the connector mapping and supply
separation; bench and RF tests remain. The previous WROVER wiring is suspended
after two reported board failures; their root cause remains unknown.

## Sources and cross-references

- [Feather V2 vendor CAD](https://github.com/adafruit/Adafruit-ESP32-Feather-V2-PCB)
- [Selected Waveshare 29318 display](https://www.waveshare.com/3.5inch-capacitive-touch-lcd.htm)
- [EYESPI pinout](https://learn.adafruit.com/adafruit-eyespi-breakout-board/pinouts)
- [EYESPI vendor CAD](https://github.com/adafruit/Adafruit-EYESPI-PCB/tree/bc5fa13b55c25feb3bf47e483b4d0bc770fbf20b)
- [TPS62162 datasheet](https://www.ti.com/lit/ds/symlink/tps62160.pdf)
- [Coilcraft XFL4020-222](https://www.coilcraft.com/en-us/products/power/high-voltage-inductors/xfl/xfl4020/xfl4020-222/)
- [Espressif antenna placement guidance](https://documentation.espressif.com/esp-hardware-design-guidelines/en/latest/esp32/index.html)
- [Historical bench wiring](../wiring.md) and [bench evidence](../bench-config.json)
- Work tracking: HARMONY-17; Mark-5 evidence: HARMONY-16.
