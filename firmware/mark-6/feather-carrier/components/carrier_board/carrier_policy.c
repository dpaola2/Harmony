#include <stddef.h>
#include <string.h>
#include "carrier_policy.h"

static int hex_digit(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

bool carrier_mac_matches(const char *expected, const uint8_t actual[6])
{
    if (!expected || !actual || strlen(expected) != 17) return false;
    unsigned nonzero = 0;
    for (unsigned i = 0; i < 6; i++) {
        int hi = hex_digit(expected[i * 3]), lo = hex_digit(expected[i * 3 + 1]);
        if (hi < 0 || lo < 0 || (i < 5 && expected[i * 3 + 2] != ':')) return false;
        uint8_t value = (hi << 4) | lo;
        if (value != actual[i]) return false;
        nonzero |= value;
    }
    return nonzero && !(actual[0] & 1);
}

bool carrier_pg_sample(unsigned *consecutive, bool high)
{
    if (!high) *consecutive = 0;
    else if (*consecutive < 10) ++*consecutive;
    return *consecutive >= 10;
}
