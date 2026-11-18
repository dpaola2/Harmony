#pragma once
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"
#include "mpr121.h"
#include "wheel.h"

/* Starts the MPR121 (after a touch wake, once the finger is off), the wheel
 * task and the side-button task. Feeds the player UI input queue. */
esp_err_t slab_controls_start(const mpr121_settings_t *touch, const wheel_config_t *wheel);
/* Stops both tasks before deep sleep; the MPR121 keeps its configuration. */
void slab_controls_stop(void);
/* A long side-button press asked for deep sleep (consumed once). */
bool slab_controls_take_sleep_request(void);
/* Last wheel or button activity, esp_timer milliseconds. */
uint32_t slab_controls_last_activity_ms(void);
