#pragma once
void player_power_init(void);
unsigned player_power_battery_mv(void);
/* Display task owns this synchronous transition and all LCD access. */
void player_power_sleep(void);
