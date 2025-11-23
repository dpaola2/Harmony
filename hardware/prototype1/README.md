# Prototype 1 (Phase 1)

- Goal: bring-up on ESP32-S3-WROOM (ESP32-S3-DevKitC-1 v1.1) while waiting for WROVER; no audio/A2DP expected. Focus on SD + display + buttons.
- Display: Waveshare ST7789V2, 1.69", 240x280.
- Storage: basic MicroSD SPI reader.
- Inputs: basic tactile buttons (up/down/left/right/select/back, play/pause, volume +/-). No rotary, no battery.
- Power: USB from dev kit.
- Wiring: 3V3/GND from dev kit; SPI for SD and ST7789V2; GPIOs for buttons. Document pin mappings once chosen.
- Notes: S3 WROOM lacks classic BT; expect UI/navigation only. Plan to port to WROVER in Prototype 2 for audio.***

## Wiring Plan (ESP32-S3-DevKitC-1 v1.1)

- Power: use 3V3 and GND from the dev kit to SD and display. Common ground everywhere.
- SPI shared for SD + ST7789V2:
  - CLK (SCK): GPIO12 → display `CLK`
  - MOSI (DIN): GPIO11 → display `DIN`
  - MISO: GPIO13 (used only by SD; display does not need it)
  - SD CS: GPIO10
  - Display CS: GPIO9
  - Display DC: GPIO8
  - Display RST: GPIO18
  - Display BL: GPIO17 (or tie to 3V3 for always-on backlight)
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
2) **SD test**: copy a small `sd_test.py` that mounts SPI with the pins above (CS=10) and `os.listdir('/')` after mounting; expect to see your `Artist/Album/Track.mp3` folders.
3) **Display test**: copy a `display_test.py` that inits ST7789V2 with CS=9, DC=8, RST=18, BL=17 (or BL tied high) and fills the screen with a solid color/text.
4) **Combined test**: mount SD, then draw “SD OK” on the display to prove both peripherals coexist.
5) After buttons are wired, map the planned GPIOs, emit `ButtonEvent`s, and drive `PlayerApp`.

## How to Run the Tests / Flash & Upload

- Host dependencies (macOS): Python 3.11+, `pip install --user esptool mpremote` (or use a venv). `mpremote` is simplest for copy/run.
- Flash MicroPython (once per board):
  - Download the latest ESP32-S3 MicroPython `.bin` from micropython.org.
  - Erase and flash: `esptool.py --chip esp32s3 --port /dev/tty.usbmodem* erase_flash` then `esptool.py --chip esp32s3 --port /dev/tty.usbmodem* write_flash -z 0x0 firmware.bin`.
- Verify REPL: `mpremote connect /dev/tty.usbmodem* repl`.
- Upload tests: `mpremote connect /dev/tty.usbmodem* cp sd_test.py :sd_test.py` and same for `display_test.py`.
- Run on-board: `mpremote connect /dev/tty.usbmodem* run sd_test.py` (or `display_test.py`).
- When ready for the app, copy the MicroPython `main.py` (once we add it) and reboot; it will auto-run.

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
