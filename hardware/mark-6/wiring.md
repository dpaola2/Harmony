# Mark-6 historical wiring — suspended after two board failures

**Do not use this map for a rebuild.** Dave reported a second failed ESP32
with USB, display, and SD reader all connected. The cause is unknown; the
physical wiring and power paths have not been verified. Keep the assembly
unpowered pending inspection. The tables below preserve the previous setup
for investigation, not an approved wiring plan.

Four factory-headered Adafruit ESP32 Feather V2 boards (#5900) are in Dave's
DigiKey cart, replacing the four unsoldered #5400 boards removed from Adafruit.
No checkout was performed. They require a separate board-specific pin map and
firmware configuration. See [the carrier connection draft](carrier-rev-a/README.md).

September 21, 2026. HARMONY-17. This map is for the Olimex
ESP32-WROVER-DevKit-LiPo, the photographed HW-125 SD reader, and Adafruit #4383
ST7789 display. Use printed GPIO labels, not header position numbers.

Both failed boards must remain disconnected from USB and battery. Existing
firmware MAC guards still refer to the first bench board. No powered testing
or peripheral reconnection is approved by this document.

| SD reader pin | WROVER connection |
| --- | --- |
| VCC | V5 / +5V |
| GND | GND |
| CS | GPIO25 |
| SCK | GPIO18 |
| MOSI | GPIO23 |
| MISO | GPIO19 |

| Display pin | Connection |
| --- | --- |
| Vin | WROVER V5 / +5V |
| GND | WROVER GND |
| SCK | WROVER GPIO14 |
| MOSI | WROVER GPIO13 |
| TFTCS | WROVER GPIO26 |
| DC | WROVER GPIO33 |
| RST | WROVER GPIO32 |
| LIT | Display's own 3V output |
| SDCS | Display's own 3V output |
| 3V | Local output feeding LIT and SDCS only |
| MISO | Unconnected |

The display's 3V pin is a regulator output. Do not connect it to WROVER 3V3
or 5V. All grounds are common. The 5V wiring goes only to the module power
inputs above; ESP32 GPIO signals use 3.3V. Leave the display's SD socket empty;
the card goes in HW-125. GPIO21/22 are reserved for the incoming I2C controls.
GPIO27 is currently unused. No VS1053, buttons, speaker wires or battery are
part of this bench wiring. SoundCore 2 receives audio over Bluetooth.

Sources: [Olimex WROVER pinout](https://www.olimex.com/Products/IoT/ESP32/ESP32-DevKit-LiPo/resources/ESP32-WROVER-DevKit-Lipo-GPIOs.pdf),
[Adafruit display pinout](https://learn.adafruit.com/adafruit-1-14-240x135-color-tft-breakout/pinouts),
and the photographed HW-125 / earlier SD test in `bench-config.json`.
