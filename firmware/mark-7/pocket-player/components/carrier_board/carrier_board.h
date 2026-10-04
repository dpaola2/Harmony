#pragma once
#include <stdbool.h>
#include "esp_err.h"
#include "carrier_pins.h"
// Bench-only adapter for the shared display driver. No carrier power-good input.
esp_err_t carrier_board_init(void);
bool carrier_board_ready(void);
