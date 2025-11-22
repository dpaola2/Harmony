Here’s a clear, actionable project plan for building your tactile-controlled, Bluetooth-streaming, offline MP3 player—very much iPod-inspired, based on ESP32 hardware, MicroPython, and a 3D-printed case.

---

# ✅ **1. Core Requirements**

**Functional**

* Offline MP3 playback from local storage (SD card or internal flash)
* Bluetooth **A2DP source** (i.e., ESP32 sending audio to headphones/speakers)
* Screen + GUI (non-touch)
* Tactile hardware controls (wheel or buttons)
* Good battery life, rechargeable (USB-C if possible)
* iPod-inspired navigation UI

**Hardware constraints**

* ESP32 variant with A2DP source support (not all do)
* Enough RAM/flash to decode MP3 + run GUI
* Separate audio codec DAC for high-quality analog playback (optional if Bluetooth only)
* Screen compatible with ESP32 SPI or parallel bus

---

# ✅ **2. ESP32 Hardware Recommendation**

To meet all requirements, you need an ESP32 variant with:

* Classic Bluetooth (required for A2DP source mode)
* Dual-core processor
* Enough flash/RAM
* Good MicroPython support

### ⭐ **Best choice: ESP32-WROVER module or dev board**

**Why:**

* Classic BT + BLE
* PSRAM (4–8 MB) — useful for audio buffers + UI
* Fully compatible with MicroPython
* Widely supported by A2DP source libraries

You can buy it as:

### 👉 **ESP32 WROVER Development Board**

* Easy USB connection
* Exposed GPIO
* Built-in PSRAM
* ~$12–18

### (OPTIONAL) Alternative if you want better audio playback:

**ESP32-LyraT** or **ESP32-LyraT-Mini**

* Specifically designed for audio
* Has dedicated DAC/codec chips
* Buttons + headphone jack + mic built in
* Good if you want *very* high audio quality
  Downside: bulky, not ideal for a pocketable walk device.

---

# ✅ **3. Audio Path Options**

### **A. Bluetooth only (simplest)**

Just stream A2DP → headphones. The ESP32 handles encoding internally.

**Pros:** Simple, no DAC needed
**Cons:** No wired headphone fallback

### **B. Bluetooth + wired headphone jack (recommended)**

Use a small I2S DAC board:

* **MAX98357A (I2S) → speaker/headphones**
* **PCM5102A (I2S)** → better quality, line-out/headphones

---

# ✅ **4. Storage Options**

You will need space for MP3 files:

### Best for this project:

* **MicroSD card module (SPI interface)**
  Simple and supports large storage (64+ GB with FAT32/exFAT).

---

# ✅ **5. Screen Recommendations**

For an iPod-like experience, you want:

* Small rectangular display
* Fast enough for smooth menus
* Good readability outdoors

### ⭐ **Best choice: 2.0–2.4” SPI IPS LCD (ST7789 driver)**

Example:
**2" ST7789 320×240 IPS SPI LCD**

**Why:**

* Fast SPI (up to 80 MHz)
* Beautiful colors + viewing angles
* Works well with MicroPython
* Cheap ($10–$15)

### Alternative:

**OLED 1.3" or 1.5" (SH1106/SSD1327)**

* Lower power, but lower resolution

---

# ✅ **6. Control Input Options (Tactile & iPod-like)**

You have two main paths:

---

## **Option A — Real scroll wheel (iPod-style)**

Use:

* **EC11 rotary encoder + push button**
  (very tactile, satisfying turn + click)
* Map rotation to menu navigation
* Map click to “select”

Add 3–4 auxiliary buttons:

* Menu/back
* Play/pause
* Next/previous (optional)

---

## **Option B — D-pad + buttons**

Simpler wiring:

* 5-way tactile switch
  (up, down, left, right, center click)
* Additional play/pause button

---

# ✅ **7. Power System**

For a pocketable MP3 player, you want:

### Battery

* **LiPo 1000–2000 mAh** (flat cell)

### Power management module

* **TP4056 charging board (USB-C version available)**
* **MT3608 step-up** (if your system needs 5V)
* Or a:

  * **LiPo + ESP32 built-in regulator** if using dev board

### Switch

* SPDT slide or lockable tactile on/off switch

---

# ✅ **8. Software Architecture (MicroPython)**

### **Major modules:**

1. **Filesystem + metadata**

   * Read SD card directory
   * Parse MP3 tags (ID3v1/v2)

2. **UI system**

   * Draw lists, now playing screen, settings
   * Input handler (rotary encoder or buttons)
   * Screen update loop (~30–60 Hz)

3. **Audio**

   * MP3 decoding (likely using built-in ESP32 codecs)
   * Bluetooth A2DP source library
   * Optional I2S DAC output handlers

4. **Power management**

   * Battery readout via ADC
   * Sleep mode + wake logic

5. **Settings persistence**

   * JSON file stored in flash (volume, last track, theme, etc.)

---

# ✅ **9. 3D Printed Enclosure**

Design considerations:

* Two-part clamshell with screw posts
* Front shell: screen window + wheel opening
* Back shell: battery compartment
* Side cutouts:

  * USB-C charging port
  * Power switch
  * Optional headphone jack
* Rear ventilation if using speaker
* Mounting posts for:

  * ESP32 dev board
  * Screen
  * Rotary encoder

You can prototype in **Fusion 360**, **Onshape**, or **FreeCAD**.

---

# ✅ **10. Shopping List**

### **Core Electronics**

| Component            | Recommended Part                  | Notes                  |
| -------------------- | --------------------------------- | ---------------------- |
| Microcontroller      | **ESP32-WROVER Dev Board**        | Must have PSRAM        |
| Display              | **ST7789 2.0–2.4” IPS LCD**       | SPI                    |
| Input Wheel          | **EC11 rotary encoder w/ button** | iPod-like control      |
| Aux Buttons          | 6× tactile buttons                | Menu, play/pause, etc. |
| Storage              | MicroSD card + SPI module         | FAT32/exFAT            |
| Battery              | 1000–2000 mAh LiPo                | Flat cell preferred    |
| Battery charger      | TP4056 USB-C                      | LiPo charging          |
| Audio DAC (optional) | PCM5102A I2S                      | For wired audio        |
| Amp (optional)       | MAX98357A                         | For speaker            |
| Connectors           | JST-PH cables                     | For battery + wiring   |

### **Mechanical**

* 3D printing filament (PLA recommended for prototyping)
* Small machine screws (M2 or M2.5)
* Clear acrylic piece for screen window (optional)

---

# ✅ **11. Next Steps / What I Can Help With**

If you want, I can prepare:

### 👍 **A. Wiring diagram (ESP32 → screen → SD → buttons → battery)**

### 👍 **B. A more detailed bill of materials**

### 👍 **C. Software scaffolding for MicroPython project**

* UI framework
* Button handler
* MP3 playback loop
* Bluetooth A2DP setup
* Event loop

### 👍 **D. 3D enclosure design sketch plan**

---

# 🚀 What would you like next?

1. Wiring diagram?
2. Detailed BOM with purchase links?
3. Software architecture skeleton?
4. 3D enclosure design guidelines?
5. Comparison of ESP32-WROVER vs LyraT vs ESP32-S3 options?
