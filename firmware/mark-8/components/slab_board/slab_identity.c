/* Pure identity helper (host-tested). */
#include <ctype.h>
#include <stdio.h>
#include "slab_board.h"

bool slab_mac_matches(const char *expected, const uint8_t mac[6])
{
    if (!expected || !expected[0]) return true;
    unsigned v[6];
    char tail;
    if (sscanf(expected, "%2x:%2x:%2x:%2x:%2x:%2x%c", &v[0], &v[1], &v[2], &v[3], &v[4], &v[5], &tail) != 6)
        return false;
    for (int i = 0; i < 17; ++i) {
        char c = expected[i];
        if ((i % 3 == 2) ? c != ':' : !isxdigit((unsigned char)c)) return false;
    }
    for (int i = 0; i < 6; ++i) if (v[i] != mac[i]) return false;
    return true;
}
