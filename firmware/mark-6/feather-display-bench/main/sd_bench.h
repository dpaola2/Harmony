#pragma once
#include <stdbool.h>
#include <stddef.h>
#include "esp_err.h"
esp_err_t sd_bench_mount(void);
esp_err_t sd_bench_verify_start(void);
esp_err_t sd_bench_verify_step(bool *done,unsigned *percent);
