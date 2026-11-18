"""Bought and reference parts for the assembly check and the renders.

The board comes from the cached board STEP, the screen from the vendor STEP.
The rest are simple solids sized from SPEC 10, the JSON and the part drawings.
"""
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
    w, l, t = size
    z0 = P.SPLIT_Z
    y0 = P.BAT_POCKET_Y0
    return box(-w / 2, w / 2, y0, y0 + l, z0, z0 + t)


def largest_battery(t=4.8):
    """Largest rectangular pack (two cases: full width, or narrow enough to pass
    the top bosses), resting on the back plate above the cable bay."""
    clear = 0.3
    x_wall = P.X_IN - P.LIP_GAP - P.LIP_W - clear          # back plate lip
    y_top_wall = P.Y_IN - P.LIP_GAP - P.LIP_W - clear
    boss_x = P.TOP_BOSSES[1][0] - P.BOSS_D / 2 - clear      # 21.7
    boss_y = P.TOP_BOSSES[1][1] - P.BOSS_D / 2 - clear      # 44.15
    rib_clear = 0.0
    y0 = P.BAT_POCKET_Y0
    wide = (2 * min(x_wall, 26.0), boss_y - y0 - rib_clear, t)
    narrow = (2 * boss_x, y_top_wall - y0, t)
    return {"wide": wide, "narrow": narrow, "z_space": P.BAT_TOP_Z - P.BAT_FOAM - P.SPLIT_Z}


def battery_plug():
    """JST PHR-2 housing in J4 (estimated from the J4 model cavity) and its
    two wires running into the cable bay."""
    plug = box(-23.2, -18.7, -10.53, -8.03, -6.9, -2.4)
    wires = union(cq.Solid.makeCylinder(0.5, 4.4, cq.Vector(-21.45, -8.04, -4.65), cq.Vector(0, 1, 0)),
                  cq.Solid.makeCylinder(0.5, 4.4, cq.Vector(-20.45, -8.04, -4.65), cq.Vector(0, 1, 0)))
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
