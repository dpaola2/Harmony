/* Divider and VSYS arithmetic. Pure, host-tested. */
#include "slab_analog.h"

unsigned slab_divider_mv(unsigned pin_mv, unsigned ratio_x1000)
{
    return (unsigned)(((unsigned long)pin_mv * ratio_x1000 + 500u) / 1000u);
}

bool slab_vbus_present(unsigned vbus_mv) { return vbus_mv >= SLAB_VBUS_PRESENT_MV; }

unsigned slab_vsys_estimate_mv(unsigned vbus_mv, unsigned vbat_mv)
{
    if (!slab_vbus_present(vbus_mv)) return vbat_mv;
    unsigned from_usb = vbus_mv - SLAB_D1_DROP_MV;
    unsigned from_diode = vbat_mv > SLAB_Q3_BODY_DIODE_MV ? vbat_mv - SLAB_Q3_BODY_DIODE_MV : 0;
    return from_usb > from_diode ? from_usb : from_diode;
}
