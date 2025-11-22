# Prototype 1 (Phase 1)

- Goal: bring-up on ESP32-S3-WROOM (ESP32-S3-DevKitC-1 v1.1) while waiting for WROVER; no audio/A2DP expected. Focus on SD + display + buttons.
- Display: Waveshare ST7789V2, 1.69", 240x280.
- Storage: basic MicroSD SPI reader.
- Inputs: basic tactile buttons (up/down/left/right/select/back, play/pause, volume +/-). No rotary, no battery.
- Power: USB from dev kit.
- Wiring: 3V3/GND from dev kit; SPI for SD and ST7789V2; GPIOs for buttons. Document pin mappings once chosen.
- Notes: S3 WROOM lacks classic BT; expect UI/navigation only. Plan to port to WROVER in Prototype 2 for audio.***

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
