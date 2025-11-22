# Hardware Notes

## Target Platform
- ESP32-WROVER dev board (PSRAM, classic BT + BLE). Alternative: ESP32-LyraT/Mini for richer audio but bulkier.
- Audio path: Bluetooth A2DP source; optional I2S DAC (PCM5102A) or amp (MAX98357A) for wired/speaker output.
- Storage: MicroSD (SPI) for library content using folder convention `Artist/Album/Track.ext`.
- Display: 2.0–2.4" SPI IPS LCD (ST7789).
- Inputs: rotary encoder (EC11) with push for scroll/select; aux buttons for back, play/pause, volume up/down (or rotary push/wheel for volume if desired).

## Volume Input Options
- Buttons: dedicated volume up/down buttons produce relative events; core clamps 0–100 and calls `set_volume`.
- Encoder-as-volume: use a second rotary (or mode switch) to emit relative steps; map to the same core events.
- Absolute knob (potentiometer): yields an analog value; platform adapter should translate ADC reading to a clamped 0–100 and push into core via `set_volume` (core supports absolute level set).

## Power System
- Battery: LiPo 1000–2000 mAh flat cell.
- Charging: TP4056 (USB-C variant) for LiPo charging.
- Regulation: ESP32 dev board regulator or MT3608 step-up if 5V needed for peripherals.
- Power switch: SPDT slide/lockable on/off.
- Optional: battery voltage sensing via ADC for future battery UI; plan GPIO and resistor divider.

## Notes/Next Steps
- Wiring: document GPIO mapping for encoder, buttons, SD (SPI), display (SPI), and optional I2S pins.
- Bluetooth A2DP: confirm ESP32 MicroPython support vs ESP-IDF shim; may need C-extension for stable source mode.
- Settings persistence: volume, last track, etc., stored in flash/SD (JSON) on device; core ready once adapters persist/load.
