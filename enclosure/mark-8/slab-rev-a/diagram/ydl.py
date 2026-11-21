"""The planned battery: YDL 403450, 650 mAh, 4.0 x 34 x 52 including its
protection board, 50 mm 26 AWG leads, JST PHR-2 plug.

Placed as ASSEMBLY.md step 13 says: cable end toward J4 (-Y), centred left to
right, stuck to 0.5 foam on the screen back. Nominal near edge at y -4.0 (the
case model's pack position, about 4 mm from the screen's lower edge). ASSEMBLY.md
allows 3.6 to 5 mm from the screen's lower edge; both ends of that window are
checked too. The pack's 52 side runs along Y.

The lead check is geometric: straight-line distance from the plug's wire exit
to the pack's lead exit, flat and with the board tilted in (ASSEMBLY.md steps 7
and 8), against the 50 mm lead. The lead exit point on the pack's 34 end is not
known, so three positions are checked (end nearest J4, centre, far end).
"""
import math
import os
import sys

import cadquery as cq

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import common as C  # noqa: E402

W, L, T = 34.0, 52.0, 4.0
LEAD = 50.0
FOAM = 0.5
NEAR_EDGE_Y = -4.0            # nominal near edge (case model and ASSEMBLY.md step 13)
WINDOW = (3.6, 5.0)           # ASSEMBLY.md step 13: near edge 3.6 to 5 mm from the screen's lower edge
R = lambda v, n=3: None if v is None else round(float(v), n)  # noqa: E731


def box(x0, x1, y0, y1, z0, z1):
    return cq.Solid.makeBox(x1 - x0, y1 - y0, z1 - z0, cq.Vector(x0, y0, z0))


def placement(A, y0=NEAR_EDGE_Y):
    scr = C.bb(A["screen body"])
    ztop = scr[4] - FOAM
    return (-W / 2, W / 2, y0, y0 + L, ztop - T, ztop)


def solid(A, y0=NEAR_EDGE_Y):
    return box(*placement(A, y0))


def _rot(p, yp, zp, a_deg):
    """Board far end up (toward -Z): turn about the X axis through (yp, zp)."""
    a = math.radians(-a_deg)
    y, z = p[1] - yp, p[2] - zp
    return (p[0], yp + y * math.cos(a) - z * math.sin(a), zp + y * math.sin(a) + z * math.cos(a))


def _plate_levels(A):
    bp = A["back plate"]
    plate_in = C.zspan(bp, 0.0, 0.0)[0][1]
    return plate_in


def _ribs(A, plate_in):
    """Back plate ribs at the pack's height: bottom ribs (near-edge stop), side ribs, top rib if any."""
    bp = A["back plate"]
    zr = plate_in + 1.0          # ribs are 1.2 tall, the lip 0.8: probe between them
    bottom = []
    for x in (-11.0, 11.0):
        for a, b in C.yspan(bp, x, zr):
            if -12.0 < b < 0.0:
                bottom.append((a, b))
    side = [iv for iv in C.xspan(bp, 20.0, zr) if abs(iv[0]) < 26.0]
    top = [iv for iv in C.yspan(bp, 0.0, zr) if iv[0] > 40]
    rib_top_z = None
    if bottom:
        zz = C.zspan(bp, -11.0, (bottom[0][0] + bottom[0][1]) / 2)
        rib_top_z = zz[0][1] if zz else None
    return bottom, side, top, rib_top_z


def check(A):
    scr = C.bb(A["screen body"])
    edge = scr[2]
    plate_in = _plate_levels(A)
    bottom, side, top, rib_top_z = _ribs(A, plate_in)
    wall_y = [a for a, b in C.yspan(A["front shell"], 0.0, -5.0) if a > 40]
    lip = [iv for iv in C.yspan(A["back plate"], 15.0, plate_in + 0.4) if iv[0] > 40]
    out = {"pack": {"w_x": W, "l_y": L, "t": T, "lead": LEAD, "foam": FOAM, "nominal_near_edge_y": NEAR_EDGE_Y,
                    "window_from_screen_edge": list(WINDOW), "screen_lower_edge_y": R(edge)},
           "plate_inner_face_z": R(plate_in),
           "bottom_ribs_y": [[R(a), R(b)] for a, b in bottom], "bottom_rib_top_z": R(rib_top_z),
           "side_ribs_x": [[R(a), R(b)] for a, b in side], "top_rib_y": [[R(a), R(b)] for a, b in top]}
    places = {"nominal": NEAR_EDGE_Y, f"window_{WINDOW[0]}": edge + WINDOW[0], f"window_{WINDOW[1]}": edge + WINDOW[1]}
    for tag, y0 in places.items():
        b = placement(A, y0)
        s = box(*b)
        rows = {}
        for n in ("front shell", "back plate", "insert 3", "insert 4", "screw 3", "screw 4", "screen body",
                  "battery foam", "board PCB", "board J4", "battery plug PHR-2", "FPC leg and wide section", "FPC part",
                  "motor"):
            if n not in A:
                continue
            d, p, q = C.dist(s, A[n])
            v, com = C.common(s, A[n]) if d < 1e-4 else (0.0, None)
            r = {"distance": R(d), "overlap_mm3": R(v, 3) if v else 0.0}
            if v and v > 0.001:
                r["overlap_bbox"] = [R(x) for x in C.bb(com)]
            rows[n] = r
        bosses = []
        for bx in (-24.7, 24.7):
            # boss column only: stop short of the side and top walls
            boss = A["front shell"].intersect(box(-27.6 if bx < 0 else 21.0, -21.0 if bx < 0 else 27.6, 43.0, 50.1, -7.95, -3.55))
            bosses.append(R(C.dist(s, boss)[0]))
        rec = {
            "near_edge_y": R(b[2]), "near_edge_from_screen_edge": R(b[2] - edge),
            "bbox": [R(v) for v in b], "far_edge_y": R(b[3]),
            "distances": rows, "to_top_bosses": bosses,
            "to_back_plate": rows["back plate"]["distance"], "back_plate_overlap_mm3": rows["back plate"]["overlap_mm3"],
            "to_back_plate_face": R(b[4] - plate_in),
            "to_back_plate_face_with_thick_screen_0.1": R(b[4] - 0.1 - plate_in),
            "near_edge_to_bottom_rib": R(b[2] - max(bb_ for _, bb_ in bottom)) if bottom else None,
            "bottom_rib_top_above_pack_bottom": R(rib_top_z - b[4]) if rib_top_z is not None else None,
            "side_gap_to_ribs": [R(b[0] - side[0][1]), R(side[-1][0] - b[1])] if len(side) >= 2 else None,
            "lip_inner_y": R(lip[0][0]) if lip else None,
            "far_edge_to_lip_y": R(lip[0][0] - b[3]) if lip else None,
            "far_edge_to_top_wall": R(min(wall_y) - b[3]) if wall_y else None,
            "top_rib_present": bool(top),
            "far_edge_past_top_rib_start": R(b[3] - top[0][0]) if top else None,
            "near_edge_to_plug": R(b[2] - C.bb(A["battery plug PHR-2"])[3]),
            "near_edge_to_fpc_top_y": R(b[2] - C.bb(A["FPC leg and wide section"])[3]),
        }
        out[tag] = rec
    nb = out["nominal"]["bbox"]
    out["nominal"]["max_length_to_lip_with_0.3"] = R(out["nominal"]["lip_inner_y"] - 0.3 - nb[2]) if lip else None
    # lead reach
    b = placement(A)
    plug = C.bb(A["battery plug PHR-2"])
    if "battery wires" in A:
        wires = C.bb(A["battery wires"])
        exit_p = ((wires[0] + wires[1]) / 2, plug[3], (wires[4] + wires[5]) / 2)
    else:
        exit_p = ((plug[0] + plug[1]) / 2, plug[3], (plug[4] + plug[5]) / 2)
    zc = (b[4] + b[5]) / 2
    ends = {"near J4 (x -15)": (-15.0, b[2], zc), "centre (x 0)": (0.0, b[2], zc), "far end (x +15)": (15.0, b[2], zc)}
    pivots = {"touch-side bottom edge (y -49.6, z -1.0)": (-49.6, -1.0),
              "USB-C shell front top edge (y -50.4, z -1.9)": (-50.4, -1.9)}
    reach = {"plug_wire_exit": [R(v) for v in exit_p], "pack_lead_exits": {k: [R(v) for v in p] for k, p in ends.items()},
             "flat": {}, "tilt": {}}
    fpc = C.bb(A["FPC leg and wide section"])
    reach["fpc_left_edge_x"] = R(fpc[0])
    reach["fpc_top_y"] = R(fpc[3])
    reach["plug_exit_left_of_fpc"] = R(fpc[0] - exit_p[0])
    for k, p in ends.items():
        reach["flat"][k] = R(math.dist(exit_p, p), 2)
    for pn, (yp, zp) in pivots.items():
        rows = []
        for a in (0, 5, 10, 15, 20, 25, 30):
            q = _rot(exit_p, yp, zp, a)
            rows.append({"deg": a, "exit": [R(v, 2) for v in q], **{k: R(math.dist(q, p), 2) for k, p in ends.items()}})
        reach["tilt"][pn] = rows
    worst = max(r[k] for pr in reach["tilt"].values() for r in pr for k in ends)
    reach["worst_straight_distance"] = worst
    reach["lead_margin_worst"] = R(LEAD - worst, 2)
    bay_y = (edge + b[2]) / 2
    reach["bay_y_range"] = [R(edge), R(b[2])]
    reach["bay_width"] = R(b[2] - edge)
    reach["bay_path_length"] = {k: R(abs(bay_y - exit_p[1]) + abs(p[0] - exit_p[0]) + abs(b[2] - bay_y), 2)
                                for k, p in ends.items()}
    reach["slack_in_bay"] = {k: R(LEAD - v, 2) for k, v in reach["bay_path_length"].items()}
    out["lead"] = reach
    return out
