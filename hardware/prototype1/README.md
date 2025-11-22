# Prototype 1 (Phase 1)

- Goal: bring-up on ESP32-S3-WROOM (ESP32-S3-DevKitC-1 v1.1) while waiting for WROVER; no audio/A2DP expected. Focus on SD + display + buttons.
- Display: Waveshare ST7789V2, 1.69", 240x280.
- Storage: basic MicroSD SPI reader.
- Inputs: basic tactile buttons (up/down/left/right/select/back, play/pause, volume +/-). No rotary, no battery.
- Power: USB from dev kit.
- Wiring: 3V3/GND from dev kit; SPI for SD and ST7789V2; GPIOs for buttons. Document pin mappings once chosen.
- Notes: S3 WROOM lacks classic BT; expect UI/navigation only. Plan to port to WROVER in Prototype 2 for audio.***
