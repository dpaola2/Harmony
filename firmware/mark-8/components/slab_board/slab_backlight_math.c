/* VSYS compensation for the backlight. Pure, host-tested. */
#include "slab_backlight.h"

unsigned slab_bl_full_ma(unsigned vsys_mv)
{
    if (vsys_mv <= SLAB_BL_VF0_MV) return 0;
    return (unsigned)(((unsigned long)(vsys_mv - SLAB_BL_VF0_MV) * 1000u + SLAB_BL_R_MOHM / 2) / SLAB_BL_R_MOHM);
}

slab_bl_plan_t slab_bl_plan(unsigned brightness_pct, unsigned vsys_mv, bool usb)
{
    slab_bl_plan_t p = {0};
    p.full_ma = slab_bl_full_ma(vsys_mv);
    if (!brightness_pct || !p.full_ma) { p.limited = brightness_pct && !p.full_ma; return p; }
    /* duty (permille) = 1000 x target / full, target = reference x brightness / 100 */
    unsigned long scaled = (unsigned long)slab_bl_full_ma(SLAB_BL_REF_VSYS_MV) * 10u * brightness_pct;
    unsigned long duty = (scaled + p.full_ma / 2) / p.full_ma;
    /* R17 power limit: duty * I^2 * R <= P_MAX. */
    unsigned long full_mw = (unsigned long)p.full_ma * p.full_ma * SLAB_BL_R17_MOHM / 1000000u;
    unsigned long power_cap = full_mw ? (unsigned long)SLAB_BL_P_MAX_MW * 1000u / full_mw : 1000u;
    unsigned long cap = 1000u;
    if (power_cap < cap) cap = power_cap;
    if (usb && cap > SLAB_BL_USB_MAX_PERMILLE) cap = SLAB_BL_USB_MAX_PERMILLE;
    if (duty > cap) { duty = cap; p.limited = true; }
    if (duty < SLAB_BL_MIN_PERMILLE) duty = SLAB_BL_MIN_PERMILLE;
    p.duty_permille = (unsigned)duty;
    p.avg_ma = (unsigned)((p.full_ma * duty + 500u) / 1000u);
    p.r17_mw = (unsigned)((full_mw * duty + 500u) / 1000u);
    return p;
}
