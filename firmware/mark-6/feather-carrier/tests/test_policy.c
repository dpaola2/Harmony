#include <assert.h>
#include <stdio.h>
#include "carrier_policy.h"

int main(void)
{
    const uint8_t mac[] = {0x58, 0xaa, 0xbb, 0xcc, 0xdd, 0xee};
    const uint8_t zero[6] = {0};
    const uint8_t broadcast[6] = {255, 255, 255, 255, 255, 255};
    assert(carrier_mac_matches("58:aa:bb:cc:dd:ee", mac));
    assert(carrier_mac_matches("58:AA:BB:CC:DD:EE", mac));
    const char *bad[] = {"", "58:aa:bb:cc:dd:ef", "58-aa-bb-cc-dd-ee",
        "58:aa:bb:cc:dd:eeX", "58:aa:bb:cc:dd:e", "58:aa:bb:cc:dd:gg",
        "5c:01:3b:89:24:04"};
    for (unsigned i = 0; i < sizeof(bad) / sizeof(bad[0]); ++i)
        assert(!carrier_mac_matches(bad[i], mac));
    assert(!carrier_mac_matches(NULL, mac));
    assert(!carrier_mac_matches("00:00:00:00:00:00", zero));
    assert(!carrier_mac_matches("ff:ff:ff:ff:ff:ff", broadcast));
    unsigned samples = 0;
    for (int i = 0; i < 9; ++i) assert(!carrier_pg_sample(&samples, true));
    assert(!carrier_pg_sample(&samples, false));
    for (int i = 0; i < 9; ++i) assert(!carrier_pg_sample(&samples, true));
    assert(carrier_pg_sample(&samples, true));
    for (int i = 0; i < 1000; ++i) assert(carrier_pg_sample(&samples, true));
    assert(samples == 10);
    assert(!carrier_pg_sample(&samples, false));
    puts("PASS MAC rejection, case handling and PG debounce/reset/saturation");
}
