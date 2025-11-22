# Prototype Profile

- Goal: breadboard setup with ESP32 dev board, SD breakout, ST7789 display, basic buttons (no rotary, no battery).
- Recommended MCU: ESP32-WROVER dev kit (DevKitC with WROVER-B, includes PSRAM and classic BT). Avoid WROOM-only boards (e.g., HUZZAH32) for A2DP source; they lack PSRAM and have tighter RAM.
- Wiring: use dev board 3V3/GND; SPI for SD and display; GPIO for a few buttons (up/down/select/back, play/pause, volume +/-).
- Power: USB from dev board (no LiPo).
- BOM (prototype):
  - ESP32-WROVER dev kit (DevKitC with WROVER-B, PSRAM, BT Classic)
  - MicroSD SPI breakout (3.3V)
  - ST7789 SPI display (2.0–2.4" IPS)
  - Tactile buttons for navigation/back/play-pause/volume
  - Breadboard + jumper wires
- Notes: document pin mappings and any level shifting if needed; photos/diagrams welcome. Add optional I2S DAC/amp later if desired.
