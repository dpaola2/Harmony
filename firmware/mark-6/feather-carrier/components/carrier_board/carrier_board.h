#pragma once
#include <stdbool.h>
#include "esp_err.h"
#include "carrier_pins.h"

esp_err_t carrier_board_init(void);
bool carrier_board_ready(void);
