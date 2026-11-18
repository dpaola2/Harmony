/* MAX17048 register conversions. Pure, host-tested. */
#include "max17048.h"

unsigned max17048_vcell_mv(uint16_t raw) { return (unsigned)(((uint32_t)raw * 5u + 32u) / 64u); }

unsigned max17048_percent(uint16_t soc_raw)
{
    unsigned percent = ((unsigned)soc_raw + 128u) >> 8;
    /* The gauge can report a few percent above 100 just after a full charge. */
    return percent > 100 ? 100 : percent;
}

int max17048_crate(uint16_t raw) { return (int)(int16_t)raw * 208; }

bool max17048_version_ok(uint16_t version) { return (version & 0xFFF0u) == 0x0010u; }

void max17048_parse(const uint8_t vcell[2], const uint8_t soc[2], const uint8_t crate[2],
                    uint16_t version, max17048_reading_t *out)
{
    uint16_t v = (uint16_t)(vcell[0] << 8 | vcell[1]);
    uint16_t s = (uint16_t)(soc[0] << 8 | soc[1]);
    uint16_t c = (uint16_t)(crate[0] << 8 | crate[1]);
    out->version = version;
    out->vcell_mv = max17048_vcell_mv(v);
    out->soc_x256 = s;
    out->percent = max17048_percent(s);
    out->crate_pct_x1000 = max17048_crate(c);
}
