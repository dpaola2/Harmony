"""Bought and reference parts for the assembly check and the renders.

The board comes from the cached board STEP, the screen from the vendor STEP.
The rest are simple solids sized from SPEC 10, the JSON and the part drawings.
"""
import math

import cadquery as cq

import params as P
from geom import box, cyl_z, union


def screen_parts(screen):
    """Screen solids in device coordinates. The flat FPC is cut at the screen
    edge: the routed FPC (fpc.py) takes over from there."""
    keep = {}
    for k in ("body", "front polarizer", "CF glass", "TFT glass", "rear polarizer"):
        keep[k] = screen[k]
    bonded = screen["FPC"].intersect(box(-30, 30, P.SCR_Y0, 0, -3, 0))
    keep["FPC bonded end"] = bonded
    return keep


def battery(size, name):
    """Pack stuck on the foam on the screen back (ASSEMBLY step 13), so the
    back plate and its ribs are checked against it."""
    w, l, t = size
    z1 = P.BAT_TOP_Z - P.BAT_FOAM
    y0 = P.BAT_POCKET_Y0
    return box(-w / 2, w / 2, y0, y0 + l, z1 - t, z1)


def max_pack_thickness():
    """Back plate to screen back, less the foam and the screen's thickness
    tolerance, rounded down to 0.05."""
    space = P.BAT_TOP_Z - P.BAT_FOAM - P.SCR_T_TOL - P.SPLIT_Z
    return math.floor(space / 0.05 + 1e-6) * 0.05


def foam():
    """Double-sided foam on the back of the screen, under the pack (MECH-3)."""
    bw, bl, _ = P.BAT_404050
    yc = P.BAT_POCKET_Y0 + bl / 2
    return box(-P.BAT_FOAM_W / 2, P.BAT_FOAM_W / 2, yc - P.BAT_FOAM_L / 2, yc + P.BAT_FOAM_L / 2,
               P.BAT_TOP_Z - P.BAT_FOAM, P.BAT_TOP_Z)


def largest_battery(t=None):
    """Largest rectangular pack (two cases: full width, or narrow enough to pass
    the top bosses), resting on the back plate above the cable bay."""
    t = max_pack_thickness() if t is None else t
    clear = 0.3
    x_wall = P.X_IN - P.LIP_GAP - P.LIP_W - clear          # back plate lip
    y_top_wall = P.Y_IN - P.LIP_GAP - P.LIP_W - clear
    boss_x = P.TOP_BOSSES[1][0] - P.BOSS_D / 2 - clear      # 21.7
    boss_y = P.TOP_BOSSES[1][1] - P.BOSS_D / 2 - clear      # 44.15
    rib_clear = 0.0
    y0 = P.BAT_POCKET_Y0
    wide = (2 * min(x_wall, 26.0), boss_y - y0 - rib_clear, t)
    narrow = (2 * boss_x, y_top_wall - y0, t)
    return {"wide": wide, "narrow": narrow, "t_max": t,
            "z_space_total": round(P.BAT_TOP_Z - P.SPLIT_Z, 3), "foam": P.BAT_FOAM, "screen_tol": P.SCR_T_TOL,
            "z_space": P.BAT_TOP_Z - P.BAT_FOAM - P.SPLIT_Z}


def battery_plug():
    """JST PHR-2 housing in J4 (estimated from the J4 model cavity) and its
    two wires running into the cable bay."""
    plug = box(-23.2, -18.7, -10.53, -8.03, -6.9, -2.4)
    # The wires stop 0.1 short of the pack's near edge (the leads leave the pack there).
    n = (P.BAT_POCKET_Y0 - 0.1) - (-8.04)
    wires = union(cq.Solid.makeCylinder(0.5, n, cq.Vector(-21.45, -8.04, -4.65), cq.Vector(0, 1, 0)),
                  cq.Solid.makeCylinder(0.5, n, cq.Vector(-20.45, -8.04, -4.65), cq.Vector(0, 1, 0)))
    return plug, wires


def inserts():
    out = []
    for (bx, by) in P.BOSSES:
        out.append(cyl_z(bx, by, P.INSERT_OD / 2, P.BOSS_END_Z, P.BOSS_END_Z + P.INSERT_L).cut(
            cyl_z(bx, by, 1.0, P.BOSS_END_Z - 1, P.BOSS_END_Z + P.INSERT_L + 1)))
    return out


def screws(length=4.0, head_d=3.5, head_h=1.1):
    """M2 button head screws (ISO 7380 size), head seated in the counterbore."""
    out = []
    seat = -P.T + P.CBORE_DEPTH
    for (bx, by) in P.BOSSES:
        head = cyl_z(bx, by, head_d / 2, seat - head_h, seat)
        shank = cyl_z(bx, by, 1.0, seat, seat + length)
        out.append(union(head, shank))
    return out


def motor():
    mx, my = P.MOTOR_C
    z0 = P.SPLIT_Z - P.MOTOR_POCKET_DEPTH + 0.02
    return cyl_z(mx, my, P.MOTOR_D / 2, z0, z0 + P.MOTOR_H)


def protrusions():
    """USB-C shell legs and solder on the touch side (JSON), up to 0.4 above L4."""
    out = []
    h = P.PROT["max_height_above_L4"]
    for it in P.PROT["items"]:
        out.append(box(it["x"][0], it["x"][1], it["y"][0], it["y"][1], P.Z_TOUCH, P.Z_TOUCH + h))
    return out
