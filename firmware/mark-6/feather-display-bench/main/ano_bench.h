#pragma once
#include <stdint.h>
#include "esp_err.h"
esp_err_t ano_bench_init(void);
esp_err_t ano_bench_read(uint32_t *position, uint32_t *buttons);
