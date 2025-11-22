# Prototype 2 (Phase 2)

- Goal: migrate to ESP32-WROVER dev kit (DevKitC with WROVER-B, PSRAM, classic BT) for audio/A2DP and full feature set once available.
- Display: ST7789 SPI (2.0–2.4" IPS), may upgrade from Phase 1 screen.
- Storage: MicroSD SPI breakout.
- Inputs: rotary encoder (EC11) with push for scroll/select; tactile buttons for back/play-pause/volume; optional extra buttons.
- Audio: start with Bluetooth A2DP source; optional I2S DAC/amp (PCM5102A, MAX98357A) later.
- Power: USB for bring-up; plan LiPo + TP4056 + switch for production.
- Wiring: map SPI for SD/display, GPIO for encoder/buttons, I2S pins reserved if needed. Document pin mappings when set.
