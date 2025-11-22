# Waveshare 1.69" ST7789V2 LCD Module

### **240×280 | IPS | SPI Interface | 1.69-inch**

**Model:** Waveshare ST7789V2
**Resolution:** 240 × 280 pixels
**Panel Type:** IPS TFT
**Driver IC:** ST7789V2
**Interface:** 4-wire SPI
**Active Area:** 27.97 × 32.56 mm
**Operating Voltage:** 3.3 V logic
**Backlight:** White LED (typically 20–40 mA)

---

## Overview

The Waveshare 1.69″ ST7789V2 display is a compact high-brightness IPS TFT panel with a 240×280 pixel resolution and SPI interface. It provides wide viewing angles, fast refresh, and excellent color reproduction while remaining power-efficient—making it ideal for battery-powered embedded devices such as handheld MP3 players.

The module includes its own PCB carrier with:

* 0.1″ header pins (soldered or through-hole)
* SPI pin breakout
* I/O level shifter on some versions (but most Waveshare ST7789V2 modules are **3.3 V only**)
* Backlight control pin (LED)
* Optional onboard reset circuitry

---

## Key Features

* **1.69-inch diagonal** compact IPS panel
* **240×280 pixels** (portrait-native geometry)
* **ST7789V2 controller**, compatible with ST7789 drivers
* **4-wire SPI** interface (MOSI, SCK, DC, CS)
* Supports **up to ~60Hz refresh** depending on MCU & SPI clock
* **3.3 V logic**, safe to drive directly from ESP32-S3
* Built-in **backlight LED driver** (requires ~25–40 mA)
* Wide viewing angle thanks to IPS technology
* Low-power consumption
* Pre-solderable pin header for breadboarding or wiring

---

## Pinout

> **Note:** Pin order varies slightly between production runs.
> Typical Waveshare labeling:

| Pin | Name                 | Description                                     |
| --- | -------------------- | ----------------------------------------------- |
| 1   | **VCC**              | Power input (3.3 V recommended)                 |
| 2   | **GND**              | Ground                                          |
| 3   | **SCL / SCK**        | SPI clock input                                 |
| 4   | **SDA / DIN / MOSI** | SPI data input                                  |
| 5   | **RES / RST**        | Hardware reset (active LOW)                     |
| 6   | **DC / RS**          | Data/Command select                             |
| 7   | **CS**               | Chip select (active LOW)                        |
| 8   | **BL / LED**         | Backlight control (PWM-capable pin recommended) |

**Important:**

* There is **no MISO** because the module is write-only over SPI.
* Some Waveshare versions include a **“Lite”** pin instead of “BL”.

---

## Electrical Characteristics

| Parameter                    | Value                      |
| ---------------------------- | -------------------------- |
| Logic voltage                | **3.3 V only**             |
| I/O type                     | 3.3 V tolerant             |
| Typical current draw (logic) | ~1–3 mA                    |
| Backlight current            | ~20–40 mA                  |
| SPI clock                    | 10–80 MHz depending on MCU |
| Operating temperature        | -20°C to +70°C             |

Backlight can be tied to 3.3 V for full brightness or driven with PWM for dimming.

---

## Display Geometry

### Native orientation

* **Vertical (280 px height)**
* Default memory-mapped orientation may require `MADCTL` adjustments.

### Pixel order

* RGB order is typically **RGB565**, but some modules default to **BGR**.
* Can be configured via the controller's `MADCTL` register.

---

## Communication Protocol

Uses **4-wire SPI**:

* **Command/write over DC=0**
* **Data/write over DC=1**
* No read operations required or supported for normal use.

### Typical SPI Command Flow

1. Pull **CS low**
2. Set **DC = 0** → send command byte
3. Set **DC = 1** → send argument bytes
4. Repeat for next command
5. Pull **CS high** when finished

### Initialization Sequence

The ST7789V2 requires a startup sequence including:

* **SWRESET** (software reset)
* **SLPOUT** (sleep out)
* **COLMOD** (color mode, typically 0x55 for RGB565)
* **MADCTL** (orientation)
* **CASET/RASET** (column/row ranges)
* **DISPON** (turn on display)

Exact sequence varies by driver library (Adafruit, LovyanGFX, TFT_eSPI, etc.), but all follow the ST7789 datasheet.

---

## Software Compatibility

The module works with many popular embedded libraries:

### ESP32 / ESP32-S3

* **TFT_eSPI** (recommended; supports 240×280 config)
* **LovyanGFX** (high performance, fully supports ST7789V2)
* **Adafruit ST7789** (works, requires custom offsets)

### MicroPython

* The `st7789.py` community driver supports 240×240 and 240×280 with appropriate offsets.

### Arduino

* Adafruit_ST7789
* TFT_eSPI
* Ucglib
* LovyanGFX

### ESP-IDF

* `lcd_driver` component
* SPI master driver + ST7789 init sequences

---

## Important Notes for This Specific Module

1. **Offset alignment matters**
   Most 240×280 ST7789V2 panels require an **x-offset of 0 or 20 px** and a **y-offset of 0** depending on library orientation.

   * TFT_eSPI: commonly `#define TFT_Y_OFFSET 20`
   * Adafruit: typically `setRotation(0)` + manual window adjustments

2. **Backlight pin is not auto-controlled**
   You must drive **BL** manually or tie it HIGH.

3. **Color inversion**
   Some Waveshare units ship with color inversion enabled or disabled by default.

   * Use `INVON` or `INVOFF` depending on color accuracy.

4. **Not all libraries support 280 px height out of the box**
   TFT_eSPI and LovyanGFX do; others require patching because 240×280 is a somewhat uncommon resolution.

5. **High SPI speeds may cause tearing**
   For ESP32-S3, ~40 MHz is a safe starting point.
   Higher values (up to 80 MHz) may work depending on cable length.

---

## Dimensions

* **Module Size:** ~39.22 × 44.44 mm
* **Active Area:** 27.97 × 32.56 mm
* **Mounting:** PCB-based with solderable 0.1″ pins
* **Panel:** Glass LCD bonded to PCB carrier

*(Exact numbers may vary slightly per batch; Waveshare publishes precise CAD drawings.)*

---

## Files & Links

* Waveshare product page (variant dependent):
  [https://www.waveshare.com/wiki/1.69inch_LCD_Module](https://www.waveshare.com/wiki/1.69inch_LCD_Module)

* Controller datasheet (ST7789V2):
  [https://www.waveshare.com/w/upload/d/d0/ST7789V2_Datasheet.pdf](https://www.waveshare.com/w/upload/d/d0/ST7789V2_Datasheet.pdf)

* Example initialization codes (from Waveshare repo):
  [https://github.com/waveshare/LCD_1in69](https://github.com/waveshare/LCD_1in69)
