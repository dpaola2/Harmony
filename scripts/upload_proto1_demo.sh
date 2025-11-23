#!/usr/bin/env bash
set -euo pipefail

# Upload Prototype 1 demo to the board and run it.
# Override PORT to match your device (e.g., /dev/tty.usbmodemXXXX or /dev/ttyUSB0).
PORT="${PORT:-/dev/cu.usbmodem11101}"

mpremote connect "${PORT}" cp -r core :core
mpremote connect "${PORT}" cp platforms/esp32/esp_screen.py :esp_screen.py
mpremote connect "${PORT}" cp platforms/esp32/esp_audio_backend.py :esp_audio_backend.py
mpremote connect "${PORT}" cp platforms/esp32/main_esp32.py :main.py

# Kick off the demo loop
mpremote connect "${PORT}" exec "import main"
