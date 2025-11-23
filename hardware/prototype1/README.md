# Prototype 1 (Phase 1)

- Goal: bring-up on ESP32-S3-WROOM (ESP32-S3-DevKitC-1 v1.1) while waiting for WROVER; no audio/A2DP expected. Focus on SD + display + buttons.
- Display: Waveshare ST7789V2, 1.69", 240x280.
- Storage: basic MicroSD SPI reader.
- Inputs: basic tactile buttons (up/down/left/right/select/back, play/pause, volume +/-). No rotary, no battery.
- Power: USB from dev kit.
- Wiring: 3V3/GND from dev kit; SPI for SD and ST7789V2; GPIOs for buttons. Document pin mappings once chosen.
- Notes: S3 WROOM lacks classic BT; expect UI/navigation only. Plan to port to WROVER in Prototype 2 for audio.***

## Wiring Plan (ESP32-S3-DevKitC-1 v1.1)

- Power: use 3V3 and GND from the dev kit. Common ground everywhere.
- Display (ST7789V2 over SPI):
  - CLK (SCK): GPIO12 → display `CLK`
  - MOSI (DIN): GPIO11 → display `DIN`
  - CS: GPIO9
  - DC: GPIO8
  - RST: GPIO18
  - BL: GPIO17 (or tie to 3V3 for always-on backlight)
  - MISO: not used by display
- SD card: pause wiring for now (we’ll revisit once a better breakout is on hand). If you experiment, pick free GPIOs not used above and update `sd_test.py` accordingly.
- Buttons (active-low to GND, enable internal pull-ups in code):
  - Up: GPIO2
  - Down: GPIO3
  - Left: GPIO4
  - Right: GPIO5
  - Select: GPIO6
  - Back: GPIO7
  - Play/Pause: GPIO14
  - Volume Up: GPIO15
  - Volume Down: GPIO16

## MicroPython Bring-Up Notes

- SD: mount FAT32 with folder convention `Artist/Album/Track.ext` at root. Use SPI(2) (or explicit pins) with the mapping above.
- Display: drive ST7789V2 over SPI using the same SCK/MOSI; set CS/DC/RST/BL per wiring above.
- Input: poll buttons with internal pull-ups; translate to `ButtonEvent` values for `PlayerApp`.
- Audio: none on this phase; use a stub `AudioBackend` (no-op play/pause/resume/stop, track loader from SD).
- Main script flow: mount SD → build track list → init display/buttons/audio stub → run event loop feeding `PlayerApp.handle_button()` and calling `render()`.

## Testing

Use these quick checks before wiring buttons:

1) Flash MicroPython and confirm REPL works over USB.
2) **Display test**: copy `display_test.py` that inits ST7789V2 with CS=9, DC=8, RST=18, BL=17 (or BL tied high) and fills the screen with solid colors/text.
3) **(Optional) SD test**: once you have a known-good breakout, wire it to free pins, update `sd_test.py` to match, and run it to list `/sd`.
4) After buttons are wired, map the planned GPIOs, emit `ButtonEvent`s, and drive `PlayerApp`.

## How to Run the Tests / Flash & Upload

- Host dependencies (macOS): Python 3.11+, `pip install --user esptool mpremote` (or use a venv). `mpremote` is simplest for copy/run.
- Flash MicroPython (once per board):
  - Download the latest ESP32-S3 MicroPython `.bin` from micropython.org.
  - Erase and flash: `esptool.py --chip esp32s3 --port /dev/tty.usbmodem* erase_flash` then `esptool.py --chip esp32s3 --port /dev/tty.usbmodem* write_flash -z 0x0 firmware.bin`.
- Verify REPL: `mpremote connect /dev/tty.usbmodem* repl`.
- Upload tests: `mpremote connect /dev/tty.usbmodem* cp display_test.py :display_test.py` (and `sd_test.py` if you wire SD).
- Run on-board: `mpremote connect /dev/tty.usbmodem* run display_test.py`.
- When ready for the app, copy the MicroPython `main.py` (once we add it) and reboot; it will auto-run.
- If/when you revisit SD, update `sd_test.py` pins to match your wiring and run it similarly: `mpremote … run sd_test.py`.

## Running the demo UI on device (no buttons required)

The ESP32 build mirrors the PC simulator UI and drives itself in a loop so you can see the screens on the ST7789 without wiring buttons yet.

1) From repo root, copy the core logic and ESP32 platform adapter files:

```bash
mpremote connect /dev/tty.usbmodem* cp -r core :core
mpremote connect /dev/tty.usbmodem* cp platforms/esp32/esp_screen.py :esp_screen.py
mpremote connect /dev/tty.usbmodem* cp platforms/esp32/esp_audio_backend.py :esp_audio_backend.py
mpremote connect /dev/tty.usbmodem* cp platforms/esp32/main_esp32.py :main.py
```

2) Run the demo (or just reboot to auto-run `main.py`):

```bash
mpremote connect /dev/tty.usbmodem* run main.py
```

What it does: uses a mock library (artists → albums → tracks), animates through Library/Now Playing/Settings, and exercises play/pause/volume state so you can confirm rendering and navigation on the display.

### Optional splash image

If you want a branded/loading screen for ~5s on boot, place a raw RGB565 image sized 240x280 at `assets/loading.raw` on the device (relative to root). The demo will load it if present; otherwise it falls back to a text “Harmony MP3 / Loading…” splash. Copy with:

```bash
mpremote connect /dev/tty.usbmodem* cp assets/loading.raw :assets/loading.raw
```

# ESP32-S3-DevKitC-1 v1.1 Docs

https://www.digikey.com/en/products/detail/dfrobot/DFR0895/18069302

---

### 📄 Key Documentation Links

* User Guide v1.1: [https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/user_guide_v1.1.html](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/user_guide_v1.1.html) — covers getting started, hardware reference, revision details. ([Espressif Docs][1])
* Main board page: [https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/index.html](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/index.html) — links to PDF downloads and all versions. ([Espressif Docs][2])
* Additional reference (pinout, etc): article from Random Nerd-Tutorials explaining the pinout and functions for similar board. ([Random Nerd Tutorials][3])

---

### 🔍 What the documentation includes

In particular, the User Guide v1.1 has:

* “Getting Started” section with overview of the board and how to flash firmware. ([Espressif Docs][1])
* “Hardware Reference” section that details the board’s components, pin headers, etc. ([Espressif Docs][1])
* “Hardware Revision Details” showing version changes, known issues, etc. ([Espressif Docs][1])
* Related supporting documents (module datasheets, etc) via links.
  Also the board page lists older version (v1.0) so you can compare if needed. ([Espressif Docs][2])

---

### ✅ Why it’s the right documentation

* Even though your board is stated as “v1.1”, the User Guide explicitly calls out **v1.1** in the title. ([Espressif Docs][1])
* The manufacturer (Espressif) hosts the docs on their “esp-dev-kits” site, so it is authoritative.
* All major hardware details, revision info, and pin headers are covered — very useful for your audio/USB project with the ESP32-S3 board.

---

If you like, I can pull **the direct PDF download** of the User Guide (v1.1) and also extract **key pinout diagrams and header-maps** for your board (makes wiring breadboard / UI easier). Would you like me to fetch those?

[1]: https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/user_guide_v1.1.html?utm_source=chatgpt.com "ESP32-S3-DevKitC-1 v1.1 - Technical Documents"
[2]: https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/index.html?utm_source=chatgpt.com "ESP32-S3-DevKitC-1 - — esp-dev-kits latest documentation"
[3]: https://randomnerdtutorials.com/esp32-s3-devkitc-pinout-guide/?utm_source=chatgpt.com "ESP32-S3 DevKitC Pinout Reference Guide: GPIOs ..."
