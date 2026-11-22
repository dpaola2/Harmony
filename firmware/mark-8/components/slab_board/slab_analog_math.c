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

slab_bat_state_t slab_bat_guard_poll(slab_bat_guard_t *g, unsigned vbat_mv, bool usb)
{
    g->low_polls = !usb && vbat_mv <= SLAB_BAT_CUTOFF_MV ? g->low_polls + 1 : 0;
    g->reversed_polls = usb && vbat_mv < SLAB_BAT_REVERSED_MV ? g->reversed_polls + 1 : 0;
    if (g->low_polls >= SLAB_BAT_CUTOFF_POLLS) return SLAB_BAT_EMPTY;
    if (g->reversed_polls >= SLAB_BAT_REVERSED_POLLS) return SLAB_BAT_REVERSED;
    return SLAB_BAT_OK;
}

bool slab_bat_wake_allowed(unsigned vbat_mv, bool usb) { return usb || vbat_mv >= SLAB_BAT_WAKE_MIN_MV; }
