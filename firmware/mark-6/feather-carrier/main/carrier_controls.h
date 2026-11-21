#pragma once
#include "esp_err.h"
esp_err_t carrier_controls_start(void);

#ifdef HARMONY_MARK7_POWER
#include <stdbool.h>
bool carrier_controls_wake_verified(void);
void carrier_controls_arm_sleep(void);
int carrier_controls_sleep_state(void);
void carrier_controls_cancel_sleep(void);
#endif
