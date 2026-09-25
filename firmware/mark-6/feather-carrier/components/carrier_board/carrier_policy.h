#pragma once
#include <stdbool.h>
#include <stdint.h>

bool carrier_mac_matches(const char *expected, const uint8_t actual[6]);
/* Ten consecutive 5 ms samples; a low sample resets the count. */
bool carrier_pg_sample(unsigned *consecutive, bool high);
