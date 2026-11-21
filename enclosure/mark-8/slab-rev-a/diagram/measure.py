"""Independent measurements of the Mark-8 slab rev A assembly, from the STEP solids.

Nothing here reads params.py or the case scripts. Positions come from the
solids by exact ray probes (OCP line/face intersection), exact distances
(BRepExtrema_DistShapeShape) and exact booleans. The JSON and KiCad files are
read only to compare against.

Run: uv run --quiet --with cadquery==2.8.0 python measure.py
Writes measurements.json next to this file.
"""
import json
import math
import os
import sys

import cadquery as cq

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import common as C  # noqa: E402
import load  # noqa: E402

R = lambda v, n=3: None if v is None else round(float(v), n)  # noqa: E731

# Reference levels, measured from the solids once (levels()). Probes below are
# placed relative to these, so they follow the case when its heights change.
L = {}


def levels(A):
    sh, bp = A["front shell"], A["back plate"]
    pl = C.zspan(bp, 0.0, 0.0)
    L["plate_in"] = pl[0][1]                       # back plate inner face
    L["back"] = C.bb(bp)[4]                         # back face
    L["rim"] = C.bb(sh)[4]                          # shell rim
    zb = C.zspan(sh, -24.7 + 2.0, -47.15)
    L["boss_face"] = zb[0][0]                       # shell boss face (insert side)
    L["front"] = C.bb(sh)[5]
    return L


def box(x0, x1, y0, y1, z0, z1):
    return cq.Solid.makeBox(x1 - x0, y1 - y0, z1 - z0, cq.Vector(x0, y0, z0))


def first(iv):
    return iv[0] if iv else (None, None)


def span_containing(ivs, v):
    for a, b in ivs:
        if a - 1e-6 <= v <= b + 1e-6:
            return (a, b)
    return None


def gap_around(ivs, v):
    """The free interval (between material intervals) that contains v."""
    lo, hi = -1e9, 1e9
    for a, b in ivs:
        if b <= v:
            lo = max(lo, b)
        if a >= v:
            hi = min(hi, a)
    return lo, hi


# ------------------------------------------------------------------ parts and items
# The exploded order asked for: front shell, wheel disc, button cap, screen with
# foam, FPC, board, battery with plug, motor, inserts, back plate, screws.
ITEMS = [
    # key, label, material, members (prefixes of solid names), item number in ASSEMBLY.md
    ("front_shell", "Front shell", "PLA, printed (Jade White)", ["front shell"], 1),
    ("wheel_disc", "Wheel disc", "PLA, printed (Black)", ["wheel disc"], 2),
    ("button_cap", "Side button cap", "PLA, printed (Jade White)", ["button cap"], 3),
    ("screen", "Screen DLC-T2.7DDS#1", "Glass, polarizers, metal frame", ["screen body", "screen front", "screen CF",
                                                                           "screen TFT", "screen rear", "screen FPC"], 5),
    ("foam", "Foam tape 35 x 45 (on the screen back)", "Double-sided foam, 0.5 modelled", ["battery foam"], 8),
    ("fpc", "Screen FPC, routed and folded", "Polyimide flex (part of the screen)", ["FPC "], 6),
    ("board", "Main board, assembled", "FR-4 0.8 with parts", ["board "], 7),
    ("battery", "LiPo pack with JST PHR-2 plug (case model)", "Pouch cell, plug, wires", ["battery pack", "battery plug",
                                                                                "battery wires"], 8),
    ("motor", "Vibration motor 10 x 2.7 (optional)", "Steel can", ["motor"], 9),
    ("inserts", "Heat-set inserts M2 x 3 (4)", "Brass", ["insert "], 4),
    ("back_plate", "Back plate", "PLA, printed (Jade White)", ["back plate"], 10),
    ("screws", "Screws M2 x 4 button head (4)", "Steel", ["screw "], 11),
]


def members(A, prefixes):
    return [n for n in A if any(n.startswith(p) for p in prefixes)]


def group_bb(A, names):
    bbs = [C.bb(A[n]) for n in names]
    return (min(b[0] for b in bbs), max(b[1] for b in bbs), min(b[2] for b in bbs),
            max(b[3] for b in bbs), min(b[4] for b in bbs), max(b[5] for b in bbs))


def part_table(A):
    rows = []
    for key, label, mat, pre, no in ITEMS:
        ms = members(A, pre)
        b = group_bb(A, ms)
        row = {"key": key, "label": label, "item": no, "material": mat, "solids": len(ms),
               "bbox": [R(v) for v in b], "size": [R(b[1] - b[0], 2), R(b[3] - b[2], 2), R(b[5] - b[4], 2)]}
        if key in ("inserts", "screws"):
            one = C.bb(A[ms[0]])
            row["size_each"] = [R(one[1] - one[0], 2), R(one[3] - one[2], 2), R(one[5] - one[4], 2)]
        if key == "board":
            p = C.bb(A["board PCB"])
            row["size_bare"] = [R(p[1] - p[0], 2), R(p[3] - p[2], 2), R(p[5] - p[4], 2)]
        if key == "battery":
            p = C.bb(A["battery pack"])
            row["size_pack"] = [R(p[1] - p[0], 2), R(p[3] - p[2], 2), R(p[5] - p[4], 2)]
        rows.append(row)
    return rows


# ------------------------------------------------------------------ sources
def sources(A, P, B, S):
    out = {"printed_step_vs_assembly": {}, "board_step_vs_assembly": {}, "screen_vendor_vs_assembly": {}}
    for n, s in P.items():
        a = A[n]
        out["printed_step_vs_assembly"][n] = {
            "volume_step": R(C.volume(s)), "volume_assembly": R(C.volume(a)),
            "bbox_max_diff": R(max(abs(x - y) for x, y in zip(C.bb(s), C.bb(a))), 4)}
    bmap = {e["ref"]: e for e in B}
    bad = []
    for n, s in A.items():
        if not n.startswith("board ") or n.startswith("board J1 leg"):
            continue
        e = bmap.get(n[6:])
        if e is None:
            bad.append(n)
            continue
        if max(abs(x - y) for x, y in zip(C.bb(s), e["bbox"])) > 1e-3 or abs(C.volume(s) - C.volume(e["shape"])) > 1e-3:
            bad.append(n)
    out["board_step_vs_assembly"] = {"board_step_solids": len(B), "matched_by_kicad_pads": sum(1 for e in B if e["ref"] != "UNMATCHED"),
                                     "assembly_board_solids": sum(1 for n in A if n.startswith("board ") and not n.startswith("board J1 leg")),
                                     "assembly_names_that_differ": bad}
    body = max(S, key=lambda s: C.volume(s))
    vb = C.bb(body)
    ab = C.bb(A["screen body"])
    t = (ab[0] - vb[0], ab[2] - vb[2], ab[4] - vb[4])
    out["screen_vendor_vs_assembly"] = {
        "translation": [R(v, 3) for v in t],
        "outline_centre_device": [R((ab[0] + ab[1]) / 2), R((ab[2] + ab[3]) / 2)],
        "front_face_z": R(ab[5]), "back_face_z": R(ab[4])}
    return out


# ------------------------------------------------------------------ board vs JSON and KiCad
def board_check(A, B, mi):
    parts = {p["ref"]: p for p in mi["parts"]}
    fps = {f["ref"]: f for f in load.footprints()}
    rows = []
    dz_bottom, dz_top, dh = [], [], []
    for e in B:
        ref = e["ref"]
        if ref in ("PCB", "UNMATCHED") or ref not in parts:
            continue
        p = parts[ref]
        b = e["bbox"]
        jz0, jz1 = min(p["z"]), max(p["z"])
        # parts hang toward -Z: the face on the board is the larger z
        # J1 and SW1 pass through the board, so their board-side face is not their max z
        step_top = b[4]
        dz_top.append(step_top - jz0)
        if ref not in ("J1", "SW1"):
            dz_bottom.append(b[5] - jz1)
            dh.append((b[5] - b[4]) - p["height"])
        row = {"ref": ref, "json_x": p["x"], "json_y": p["y"], "json_z": [jz0, jz1], "json_height": p["height"],
               "step_x": [R(b[0]), R(b[1])], "step_y": [R(b[2]), R(b[3])], "step_z": [R(b[4]), R(b[5])],
               "dx": R(max(abs(b[0] - p["x"][0]), abs(b[1] - p["x"][1]))),
               "dy": R(max(abs(b[2] - p["y"][0]), abs(b[3] - p["y"][1]))),
               "top_z_diff": R(step_top - jz0),
               "protrusion_from_board_face_step": R(-1.8 - b[4]),
               "kicad_centre": [R(v) for v in fps[ref]["centre"]] if ref in fps else None,
               "json_centre": p.get("centre")}
        rows.append(row)
    pcb = A["board PCB"]
    pb = C.bb(pcb)
    # outline: section of the bare board at mid thickness against the JSON outline
    faces = C.section(pcb, "z", -1.4)
    outer = max((f[0] for f in faces), key=lambda L: abs(_area(L)))
    jout = mi["board"]["outline"]
    dev = _poly_dev(outer, jout)
    holes = []
    for h in mi["locating_holes"]:
        hx, hy = h["centre"]
        xs = C.xspan(pcb, hy, -1.4)
        g = gap_around(xs, hx)
        ys = C.yspan(pcb, hx, -1.4)
        gy = gap_around(ys, hy)
        holes.append({"ref": h["ref"], "json_centre": h["centre"], "json_d": h["diameter"],
                      "step_d_x": R(g[1] - g[0]), "step_d_y": R(gy[1] - gy[0]),
                      "step_centre": [R((g[0] + g[1]) / 2), R((gy[0] + gy[1]) / 2)]})
    changed = {}
    for ref in ("R31", "R32", "R34", "C26"):
        r = next((x for x in rows if x["ref"] == ref), None)
        if r:
            sx = (r["step_x"][0] + r["step_x"][1]) / 2
            sy = (r["step_y"][0] + r["step_y"][1]) / 2
            changed[ref] = {"step_centre": [R(sx), R(sy)], "kicad_centre": r["kicad_centre"], "json_centre": r["json_centre"],
                            "step_z": r["step_z"], "json_z": r["json_z"], "json_height": r["json_height"],
                            "body_height_step": R(r["step_z"][1] - r["step_z"][0])}
    kicad_extra = {r: [R(v) for v in fps[r]["centre"]] for r in ("PP1", "PP2", "PP3", "PP4", "H1", "H2") if r in fps}
    j1 = fps["J1"]
    shell_pads = [p for p in j1["pads"] if (p[1] - p[0]) > 0.85 and (p[3] - p[2]) > 1.5]
    return {
        "pcb_bbox": [R(v) for v in pb], "pcb_size": [R(pb[1] - pb[0]), R(pb[3] - pb[2]), R(pb[5] - pb[4])],
        "outline_max_deviation_from_json": R(dev, 4), "outline_points_step": len(outer),
        "locating_holes": holes,
        "parts_compared": len(rows),
        "parts_xy_max_diff": R(max(max(r["dx"], r["dy"]) for r in rows), 4),
        "top_z_diff_range": [R(min(dz_top), 4), R(max(dz_top), 4)],
        "board_face_z_diff_range": [R(min(dz_bottom), 4), R(max(dz_bottom), 4)],
        "body_height_diff_range": [R(min(dh), 4), R(max(dh), 4)],
        "changed_parts": changed,
        "kicad_extra": kicad_extra,
        "j1_shell_pads_kicad": [[R(v) for v in p] + [R(p[1] - p[0]), R(p[3] - p[2])] for p in shell_pads],
        "j1_protrusions_json": mi["touch_side_protrusions"]["items"],
        "rows": rows,
    }


def _area(L):
    return 0.5 * sum(L[i][0] * L[(i + 1) % len(L)][1] - L[(i + 1) % len(L)][0] * L[i][1] for i in range(len(L)))


def _seg_dist(p, a, b):
    ax, ay = a
    bx, by = b
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy
    t = 0.0 if L2 == 0 else max(0.0, min(1.0, ((p[0] - ax) * dx + (p[1] - ay) * dy) / L2))
    return math.hypot(p[0] - ax - t * dx, p[1] - ay - t * dy)


def _poly_dev(A_, B_):
    """Symmetric max distance between two closed polylines (vertex to segment)."""
    def one(P_, Q_):
        m = 0.0
        for p in P_:
            m = max(m, min(_seg_dist(p, Q_[i], Q_[(i + 1) % len(Q_)]) for i in range(len(Q_))))
        return m
    return max(one(A_, B_), one(B_, A_))


# ------------------------------------------------------------------ stack-up
def stack(A):
    sh, bp, pcb = A["front shell"], A["back plate"], A["board PCB"]
    out = {}
    out["front_face_z"] = R(C.bb(sh)[5])
    out["back_face_z"] = R(C.bb(bp)[4])
    out["total_thickness"] = R(C.bb(sh)[5] - C.bb(bp)[4])
    out["outline_x"] = R(C.bb(sh)[1] - C.bb(sh)[0])
    out["outline_y"] = R(C.bb(sh)[3] - C.bb(sh)[2])
    sk = C.zspan(sh, -20, -5)
    out["skin"] = [R(sk[0][0]), R(sk[0][1])]
    out["skin_t"] = R(sk[0][1] - sk[0][0])
    out["shell_rim_z"] = R(C.bb(sh)[4])
    pl = C.zspan(bp, 0, 0)
    out["back_plate"] = [R(pl[0][0]), R(pl[0][1])]
    out["back_plate_t"] = R(pl[0][1] - pl[0][0])
    disc = A["wheel disc"]
    d = C.zspan(disc, 5, -27.75)
    out["disc"] = [R(d[0][0]), R(d[0][1])]
    out["disc_t"] = R(d[0][1] - d[0][0])
    pz = C.zspan(pcb, 0, -30.0)
    out["pcb"] = [R(pz[0][0]), R(pz[0][1])]
    out["pcb_t"] = R(pz[0][1] - pz[0][0])
    scr = C.bb(A["screen body"])
    out["screen"] = [R(scr[4]), R(scr[5])]
    out["screen_t"] = R(scr[5] - scr[4])
    fo = C.bb(A["battery foam"])
    out["foam"] = [R(fo[4]), R(fo[5])]
    out["foam_t"] = R(fo[5] - fo[4])
    ba = C.bb(A["battery pack"])
    out["battery"] = [R(ba[4]), R(ba[5])]
    out["battery_t"] = R(ba[5] - ba[4])
    out["battery_to_foam"] = R(fo[4] - ba[5])
    out["plate_to_screen_back"] = R(scr[4] - pl[0][1])
    out["largest_pack_t_0.5_foam_0.1_tol"] = R(scr[4] - pl[0][1] - 0.5 - 0.1)
    out["largest_pack_t_0.2_foam_0.1_tol"] = R(scr[4] - pl[0][1] - 0.2 - 0.1)
    lowest = min(C.bb(A[n])[4] for n in A if n.startswith("board ") and n != "board PCB")
    lowest_ref = min((C.bb(A[n])[4], n) for n in A if n.startswith("board ") and n != "board PCB")[1]
    out["lowest_board_part_z"] = R(lowest)
    out["lowest_board_part"] = lowest_ref[6:]
    out["tallest_part_to_plate"] = R(lowest - pl[0][1])
    out["component_space"] = R(pz[0][0] - pl[0][1])
    out["motor"] = [R(C.bb(A["motor"])[4]), R(C.bb(A["motor"])[5])]
    out["fpc_tail_layers"] = [[R(a), R(b)] for a, b in C.zspan(A["FPC tail"], 10.0, -39.0)]
    return out


# ------------------------------------------------------------------ features
def usb(A):
    sh, j1 = A["front shell"], A["board J1"]
    jb = C.bb(j1)
    # J1 shell outline 0.2 behind its face
    yj = jb[2] + 0.2
    jz = C.zspan(j1, 0.0, yj)
    jx = C.xspan(j1, yj, (jz[0][0] + jz[-1][1]) / 2)
    out = {"j1_face_y": R(jb[2]), "j1_shell_z": [R(jz[0][0]), R(jz[-1][1])], "j1_shell_h": R(jz[-1][1] - jz[0][0]),
           "j1_shell_x": [R(jx[0][0]), R(jx[-1][1])], "j1_shell_w": R(jx[-1][1] - jx[0][0]),
           "j1_receptacle_z": [R(jz[0][1]), R(jz[-1][0])] if len(jz) > 1 else None,
           "j1_centre_z": R((jz[0][0] + jz[-1][1]) / 2)}
    zc = out["j1_centre_z"]
    # opening in the wall, between the recess floor and the inner face
    ys = C.yspan(sh, 6.0, -5.8)                # outside the opening, inside the recess band
    wall = span_containing(ys, -50.5)
    out["wall_inner_face_y"] = R(wall[1]) if wall else None
    out["recess_floor_y"] = R(wall[0]) if wall else None
    out["outer_face_y"] = R(C.bb(sh)[2])
    out["recess_depth"] = R(wall[0] - C.bb(sh)[2]) if wall else None
    ymid = (wall[0] + wall[1]) / 2
    oz = gap_around(C.zspan(sh, 0.0, ymid), zc)
    ox = gap_around(C.xspan(sh, ymid, zc), 0.0)
    out["opening_z"] = [R(oz[0]), R(oz[1])]
    out["opening_h"] = R(oz[1] - oz[0])
    out["opening_x"] = [R(ox[0]), R(ox[1])]
    out["opening_w"] = R(ox[1] - ox[0])
    out["opening_centre_z"] = R((oz[0] + oz[1]) / 2)
    # recess
    yr = (C.bb(sh)[2] + wall[0]) / 2
    rx = gap_around(C.xspan(sh, yr, -3.46), 0.0)
    rz = C.zspan(sh, 0.0, yr)
    out["recess_x"] = [R(rx[0]), R(rx[1])]
    out["recess_w"] = R(rx[1] - rx[0])
    out["recess_bottom_z"] = R(rz[0][1]) if rz else None
    out["recess_h_to_centre_line_x2"] = R(2 * (zc - rz[0][1])) if rz else None
    out["recess_h_from_design_centre"] = R(2 * (out["opening_centre_z"] - rz[0][1])) if rz else None
    # gaps between the J1 shell and the opening
    out["gap_top"] = R(oz[1] - out["j1_shell_z"][1])
    out["gap_bottom"] = R(out["j1_shell_z"][0] - oz[0])
    out["gap_left"] = R(out["j1_shell_x"][0] - ox[0])
    out["gap_right"] = R(ox[1] - out["j1_shell_x"][1])
    d, p, q = C.dist(j1, sh)
    out["j1_to_shell_min"] = R(d)
    out["j1_to_shell_at"] = [R(v, 2) for v in p]
    out["j1_into_wall"] = R(wall[1] - jb[2])
    out["overmold_reach_to_face"] = R(jb[2] - wall[0])
    # touch-side leg reliefs (skin) and disc pockets
    legs = [A[n] for n in A if n.startswith("board J1 leg")]
    out["legs_modelled"] = [[R(v) for v in C.bb(l)] for l in legs]
    rel = []
    for l in legs:
        lb = C.bb(l)
        cx, cy = (lb[0] + lb[1]) / 2, (lb[2] + lb[3]) / 2
        zs = C.zspan(sh, cx, cy)
        sk = span_containing(zs, -0.1)
        xs = gap_around(C.xspan(sh, cy, -0.8), cx)
        ys_ = gap_around(C.yspan(sh, cx, -0.8), cy)
        dzs = C.zspan(A["wheel disc"], cx, cy)
        rel.append({"leg_centre": [R(cx), R(cy)], "skin_over_relief": [R(sk[0]), R(sk[1])] if sk else None,
                    "relief_x": [R(xs[0]), R(xs[1])], "relief_y": [R(ys_[0]), R(ys_[1])],
                    "disc_over_leg": [[R(a), R(b)] for a, b in dzs],
                    "leg_to_shell": R(C.dist(l, sh)[0]), "leg_to_disc": R(C.dist(l, A["wheel disc"])[0])})
    out["leg_reliefs"] = rel
    return out


def microsd(A):
    sh, j3 = A["front shell"], A["board J3"]
    jb = C.bb(j3)
    xc = -13.7
    out = {"j3_bbox": [R(v) for v in jb], "j3_entry_y": R(jb[2])}
    # J3 top cover and bottom plate near the entry, on the card centre line
    out["j3_z_at_entry+0.2"] = [[R(a), R(b)] for a, b in C.zspan(j3, xc, jb[2] + 0.2)]
    out["j3_z_at_entry+1.0"] = [[R(a), R(b)] for a, b in C.zspan(j3, xc, jb[2] + 1.0)]
    out["j3_z_at_entry+3.0"] = [[R(a), R(b)] for a, b in C.zspan(j3, xc, jb[2] + 3.0)]
    cov = C.zspan(j3, xc, jb[2] + 0.2)
    out["j3_cover_underside_z"] = R(cov[0][0]) if cov else None
    # slot in the wall (between the scallop and the inner face)
    ys = C.yspan(sh, xc, -1.0)
    wall = span_containing(ys, -50.5)
    out["wall_at_card_x_y"] = [R(wall[0]), R(wall[1])] if wall else None
    y_in = -50.3
    sz = gap_around(C.zspan(sh, xc, y_in), -3.14)
    sx = gap_around(C.xspan(sh, y_in, -3.14), xc)
    out["slot_z"] = [R(sz[0]), R(sz[1])]
    out["slot_h"] = R(sz[1] - sz[0])
    out["slot_x"] = [R(sx[0]), R(sx[1])]
    out["slot_w"] = R(sx[1] - sx[0])
    out["slot_centre_z"] = R((sz[0] + sz[1]) / 2)
    # slot faces as printed face down at 0.2 layers (heights from the front face, rounded to the nearest layer)
    out["slot_z_at_0.2_layers"] = [R(-round(-sz[0] / 0.2) * 0.2, 2), R(-round(-sz[1] / 0.2) * 0.2, 2)]
    # scallop
    yo = C.bb(sh)[2]
    sc = gap_around(C.xspan(sh, yo + 0.05, -3.141 + 1.9), xc)
    out["scallop_x"] = [R(sc[0]), R(sc[1])]
    ysc = C.yspan(sh, -20.0, -3.14)
    w2 = span_containing(ysc, -50.5)
    out["scallop_floor_y_at_x-20"] = R(w2[0]) if w2 else None
    out["scallop_depth"] = R(w2[0] - yo) if w2 else None
    out["wall_behind_scallop"] = R(w2[1] - w2[0]) if w2 else None
    out["scallop_z_at_floor_x-20"] = [[R(a), R(b)] for a, b in C.zspan(sh, -20.0, yo + 0.05)]
    # cards: 11.0 wide, 1.0 thick, from 1 mm outside the case to the J3 entry
    cards = {"drawing estimate (z -2.38 to -3.38)": (-3.38, -2.38),
             "STEP: top face on the J3 cover": (out["j3_cover_underside_z"] - 1.0, out["j3_cover_underside_z"]),
             "JSON card plane -3.141": (-3.641, -2.641)}
    cr = {}
    for k, (z0, z1) in cards.items():
        card = box(xc - 5.5, xc + 5.5, yo - 1.0, jb[2] - 0.001, z0, z1)
        d, p, q = C.dist(card, sh)
        v, _ = C.common(card, sh)
        cr[k] = {"card_z": [R(z0), R(z1)], "to_shell": R(d), "overlap_mm3": R(v, 4),
                 "margin_board_side": R(sz[1] - z1), "margin_back_side": R(z0 - sz[0]),
                 "margin_sides": [R((xc - 5.5) - sx[0]), R(sx[1] - (xc + 5.5))],
                 "to_j3": R(C.dist(card, j3)[0]),
                 "printed_margin_board_side": R(out["slot_z_at_0.2_layers"][1] - z1),
                 "printed_margin_back_side": R(z0 - out["slot_z_at_0.2_layers"][0])}
    out["cards"] = cr
    return out


def led(A):
    bp = A["back plate"]
    ly = -48.0
    sub = bp.intersect(box(-9, -2.5, -50.2, -45.5, L["plate_in"] + 0.01, 0))
    sb = C.bb(sub)
    out = {"tube_bbox": [R(v) for v in sb]}
    zs = {}
    for z in (-7.5, -6.5, -6.0, -5.6, -5.4, -4.0, -3.2, -2.95):
        ivs = [iv for iv in C.xspan(bp, ly, z) if -9 < iv[0] < -2.5]
        if ivs:
            zs[z] = {"outer": [R(ivs[0][0]), R(ivs[-1][1])], "od": R(ivs[-1][1] - ivs[0][0]),
                     "hole": [R(ivs[0][1]), R(ivs[-1][0])] if len(ivs) > 1 else None,
                     "hole_d": R(ivs[-1][0] - ivs[0][1]) if len(ivs) > 1 else None,
                     "wall": R(ivs[0][1] - ivs[0][0])}
    out["by_z"] = zs
    cx = (zs[-4.0]["outer"][0] + zs[-4.0]["outer"][1]) / 2
    out["tube_centre_x"] = R(cx)
    # neck start: z of the shoulder at r = 1.05
    sz = C.zspan(bp, cx + 1.05, ly)
    out["base_top_z"] = R(sz[0][1]) if sz else None
    tz = C.zspan(bp, cx + 0.7, ly)
    out["tip_z"] = R(tz[0][1]) if tz else None
    tz2 = C.zspan(bp, cx + 0.94, ly)
    out["tip_outer_edge_z"] = R(tz2[0][1]) if tz2 else None
    out["tip_chamfer"] = R(out["tip_z"] - out["tip_outer_edge_z"] + 0.0) if tz2 else None
    led1 = A["board LED1"]
    lb = C.bb(led1)
    out["led1_bbox"] = [R(v) for v in lb]
    out["led1_centre_x"] = R((lb[0] + lb[1]) / 2)
    out["led1_top_z"] = R(lb[4])
    out["tip_to_led_top_z"] = R(out["tip_z"] - lb[4])
    out["hole_offset_from_led_x"] = R(cx - (lb[0] + lb[1]) / 2)
    hz = C.zspan(bp, cx, ly)
    out["hole_open_through"] = (len(hz) == 0)
    for r in ("LED1", "J1", "J3", "R8", "R2", "C1"):
        d, p, q = C.dist(sub, A["board " + r])
        out[f"to_{r}"] = R(d)
        out[f"to_{r}_at"] = [R(v, 2) for v in p]
    j1x = C.bb(A["board J1"])[0]
    j3x = C.bb(A["board J3"])[1]
    out["j3_j1_gap_x"] = [R(j3x), R(j1x), R(j1x - j3x)]
    out["j1_bottom_z"] = R(C.bb(A["board J1"])[4])
    out["j3_bottom_z"] = R(C.bb(A["board J3"])[4])
    out["base_top_to_j1_bottom"] = R(out["j1_bottom_z"] - out["base_top_z"])
    return out


def button(A):
    sh, cap, sw1 = A["front shell"], A["button cap"], A["board SW1"]
    yc, zc = -15.6, -3.5
    cb = C.bb(cap)
    out = {"cap_bbox": [R(v) for v in cb], "cap_size": [R(cb[1] - cb[0]), R(cb[3] - cb[2]), R(cb[5] - cb[4])]}
    out["cap_z"] = [R(cb[4]), R(cb[5])]
    out["cap_h"] = R(cb[5] - cb[4])
    head = C.yspan(cap, 29.15, zc)
    out["head_w"] = R(head[0][1] - head[0][0]) if head else None
    stem = C.yspan(cap, 28.0, zc)
    out["stem_w"] = R(stem[0][1] - stem[0][0])
    ears = C.yspan(cap, cb[0] + 0.05, zc)
    out["ears_w"] = R(ears[-1][1] - ears[0][0])
    out["ears_y"] = [[R(a), R(b)] for a, b in ears]
    px = C.xspan(cap, yc, zc)
    out["plunger_x"] = R(px[0][0])
    out["head_outer_x"] = R(px[-1][1])
    out["head_proud"] = R(px[-1][1] - C.bb(sh)[1])
    hx = C.xspan(cap, -18.0, zc)
    out["head_inner_x"] = R(hx[-1][0]) if hx else None
    out["flange_mid_x"] = R(C.xspan(cap, -17.0, zc)[0][0])
    out["ear_x"] = R(C.xspan(cap, -18.6, zc)[0][0])
    # wall cuts
    sl = gap_around(C.yspan(sh, 28.4, zc), yc)
    out["slot_w"] = R(sl[1] - sl[0])
    slz = gap_around(C.zspan(sh, 28.4, yc), zc)
    out["slot_h"] = R(slz[1] - slz[0])
    pk = gap_around(C.yspan(sh, 29.2, zc), yc)
    out["pocket_w"] = R(pk[1] - pk[0])
    fl = C.xspan(sh, -18.3, zc)
    floor = [iv for iv in fl if iv[0] > 20]
    out["pocket_floor_x"] = R(floor[0][1]) if floor else None
    out["wall_inner_x"] = R(floor[0][0]) if floor else None
    out["travel_to_stop"] = R(out["head_inner_x"] - out["pocket_floor_x"])
    tip = C.bb(sw1)[1]
    out["sw1_tip_x"] = R(tip)
    out["rest_gap"] = R(out["plunger_x"] - tip)
    out["past_tip_at_stop"] = R(out["travel_to_stop"] - out["rest_gap"])
    out["over_travel_vs_0.2"] = R(out["past_tip_at_stop"] - 0.2)
    d, p, q = C.dist(cap, sw1)
    out["rest_min"] = R(d)
    pressed = cap.translate(cq.Vector(-out["travel_to_stop"], 0, 0))
    # flange and ears only (leave out the plunger cup, which meets the actuator on purpose)
    flange = pressed.intersect(box(20, out["wall_inner_x"] - out["travel_to_stop"] + 0.001, -30, 0, -10, 0))
    flange = flange.cut(box(20, 40, yc - 1.2, yc + 1.2, -10, 0))
    d2, p2, q2 = C.dist(flange, sw1)
    out["flange_to_sw1_at_stop"] = R(d2)
    out["flange_to_sw1_at_stop_at"] = [R(v, 2) for v in p2]
    v, _ = C.common(pressed, sw1)
    out["pressed_overlap_with_static_sw1_mm3"] = R(v, 4)
    out["sw1_body_front_x"] = R(C.xspan(sw1, -17.0, zc)[0][1])
    out["cap_to_shell"] = R(C.dist(cap, sh)[0])
    # stem side gaps in the slot
    out["stem_slot_gap_each_side"] = R((out["slot_w"] - out["stem_w"]) / 2)
    out["stem_slot_gap_z_each"] = R((out["slot_h"] - out["cap_h"]) / 2)
    return out


def fpc_j2(A):
    tail, leg, part = A["FPC tail"], A["FPC leg and wide section"], A["FPC part"]
    j2, pcb, bp = A["board J2"], A["board PCB"], A["back plate"]
    tb, jb = C.bb(tail), C.bb(j2)
    out = {"tail_bbox": [R(v) for v in tb], "j2_bbox": [R(v) for v in jb]}
    out["j2_mouth_x"] = R(jb[1])
    out["j2_slot_centre_y"] = R((jb[2] + jb[3]) / 2)
    tip = min(a for a, b in C.xspan(tail, -39.0, -2.2))
    out["tail_tip_x"] = R(tip)
    out["insertion"] = R(jb[1] - tip)
    out["fold_outer_x"] = R(tb[1])
    out["tail_y"] = [R(tb[2]), R(tb[3])]
    out["tail_w"] = R(tb[3] - tb[2])
    out["tail_centre_y"] = R((tb[2] + tb[3]) / 2)
    lay = C.zspan(tail, 10.0, -39.0)
    out["layers_at_x10"] = [[R(a), R(b)] for a, b in lay]
    out["fpc_t"] = R(lay[0][1] - lay[0][0])
    out["fold_inner_gap"] = R(lay[1][0] - lay[0][1]) if len(lay) > 1 else None
    out["fold_inner_r"] = R((lay[1][0] - lay[0][1]) / 2) if len(lay) > 1 else None
    ent = C.zspan(tail, jb[1] + 0.3, -39.0)
    out["tail_z_at_mouth"] = [[R(a), R(b)] for a, b in ent]
    jz = C.zspan(j2, jb[1] - 0.3, -39.0)
    out["j2_z_at_mouth-0.3"] = [[R(a), R(b)] for a, b in jz]
    upper = [iv for iv in ent if iv[0] > -4]
    g = gap_around(jz, (upper[0][0] + upper[0][1]) / 2 - 0.15) if upper else None
    out["j2_slot_gap_z"] = [R(g[0]), R(g[1])] if g else None
    out["j2_slot_centre_z"] = R((g[0] + g[1]) / 2) if g else None
    out["tail_centre_z_at_mouth"] = R((upper[0][0] + upper[0][1]) / 2) if upper else None
    for dx in (0.1, 0.6, 1.0):
        out[f"j2_z_at_mouth-{dx}"] = [[R(a), R(b)] for a, b in C.zspan(j2, jb[1] - dx, -39.0)]
    v, _ = C.common(tail, j2)
    out["tail_j2_overlap_mm3"] = R(v, 4)
    pl = C.zspan(bp, 5.0, -39.0)
    out["plate_in_channel"] = [[R(a), R(b)] for a, b in pl]
    pl2 = C.zspan(bp, 12.0, -45.0)
    out["plate_outside_channel"] = [[R(a), R(b)] for a, b in pl2]
    out["channel_depth"] = R(pl2[0][1] - pl[0][1]) if pl and pl2 else None
    out["tail_to_plate"] = R(C.dist(tail, bp)[0])
    out["tail_to_pcb"] = R(C.dist(tail, pcb)[0])
    d, p, q = C.dist(tail, pcb)
    out["tail_to_pcb_at"] = [R(v, 2) for v in p]
    # leg: lowest and highest z along the leg centre line, loop height
    lb = C.bb(leg)
    out["leg_bbox"] = [R(v) for v in lb]
    loop = []
    for y in [-20 - 0.5 * i for i in range(20)]:
        zz = C.zspan(leg, -10.0, y)
        if zz:
            loop.append((y, zz[-1][1]))
    out["leg_top_z_profile_x-10"] = [[R(a), R(b)] for a, b in loop]
    top = max(loop, key=lambda t: t[1])
    out["loop_top_z"] = R(top[1])
    out["loop_top_y"] = R(top[0])
    flat = C.zspan(leg, -10.0, -20.0)
    out["leg_layer_on_plate_z"] = [R(flat[0][0]), R(flat[0][1])] if flat else None
    out["loop_height_above_plate_layer"] = R(top[1] - flat[0][1]) if flat else None
    out["part_bbox"] = [R(v) for v in C.bb(part)]
    out["wide_section_max_x"] = R(max(C.bb(leg)[1], C.bb(part)[1]))
    # centre-line lengths from volumes (solid = width x thickness x length)
    out["tail_centre_line_len_from_volume"] = R(C.volume(tail) / (out["tail_w"] * 0.2), 2)
    return out


def bosses(A):
    sh, bp = A["front shell"], A["back plate"]
    out = {}
    for tag, (bx, by), ins, scr in (("bottom_left", (-24.7, -47.15), "insert 1", "screw 1"),
                                     ("top_left", (-24.7, 47.15), "insert 3", "screw 3")):
        o = {}
        ib, sb = C.bb(A[ins]), C.bb(A[scr])
        o["insert_z"] = [R(ib[4]), R(ib[5])]
        o["insert_len"] = R(ib[5] - ib[4])
        o["insert_od"] = R(ib[1] - ib[0])
        iid = gap_around(C.xspan(A[ins], by, (ib[4] + ib[5]) / 2), bx)
        o["insert_id"] = R(iid[1] - iid[0])
        o["screw_z"] = [R(sb[4]), R(sb[5])]
        o["screw_head_d"] = R(sb[1] - sb[0])
        hz = C.zspan(A[scr], bx + 1.5, by)
        o["screw_head_z"] = [R(hz[0][0]), R(hz[0][1])] if hz else None
        o["screw_head_h"] = R(hz[0][1] - hz[0][0]) if hz else None
        o["screw_len_under_head"] = R(sb[5] - hz[0][1]) if hz else None
        o["shank_d"] = R(C.xspan(A[scr], by, -6.0)[0][1] - C.xspan(A[scr], by, -6.0)[0][0])
        zs = C.zspan(sh, bx, by)
        o["shell_on_axis"] = [[R(a), R(b)] for a, b in zs]
        o["hole_bottom_z"] = R(zs[0][0]) if zs else None
        o["boss_face_z"] = R(C.zspan(sh, bx + 2.0, by)[0][0])
        hx = gap_around(C.xspan(sh, by, -6.0), bx)
        o["hole_d"] = R(hx[1] - hx[0])
        mx = gap_around(C.xspan(sh, by, o["boss_face_z"] + 0.02), bx)
        o["hole_d_at_mouth"] = R(mx[1] - mx[0])
        bx_ = span_containing(C.xspan(sh, by, -6.0), bx - 2.0)
        o["boss_outer_x"] = [R(bx_[0]), R(bx_[1])] if bx_ else None
        o["boss_wall"] = R(hx[0] - bx_[0]) if bx_ else None
        o["hole_depth"] = R(o["hole_bottom_z"] - o["boss_face_z"])
        if tag == "top_left":
            o["boss_top_z"] = R(zs[0][1]) if zs else None
            o["roof"] = R(zs[0][1] - zs[0][0]) if zs else None
            o["boss_top_to_screen_back"] = R(C.bb(A["screen body"])[4] - zs[0][1])
        o["knurl_interference_radial"] = R((o["insert_od"] - o["hole_d"]) / 2)
        o["insert_top_vs_boss_face"] = R(ib[4] - o["boss_face_z"])
        o["engagement"] = R(min(sb[5], ib[5]) - max(hz[0][1], ib[4]))
        o["tip_past_insert"] = R(sb[5] - ib[5])
        o["tip_to_hole_bottom"] = R(o["hole_bottom_z"] - sb[5])
        o["m2x5_tip_to_hole_bottom"] = R(o["hole_bottom_z"] - (hz[0][1] + 5.0))
        # back plate: counterbore and clearance hole
        cz = C.zspan(bp, bx + 1.5, by)
        o["plate_under_head"] = [R(cz[0][0]), R(cz[0][1])] if cz else None
        o["plate_under_head_t"] = R(cz[0][1] - cz[0][0]) if cz else None
        cbx = gap_around(C.xspan(bp, by, L["back"] + 0.3), bx)
        o["counterbore_d"] = R(cbx[1] - cbx[0])
        o["counterbore_depth"] = R(cz[0][0] - C.bb(bp)[4]) if cz else None
        chx = gap_around(C.xspan(bp, by, (o["screw_head_z"][1] + o["boss_face_z"]) / 2 if o.get("screw_head_z") else L["plate_in"] + 0.3), bx)
        o["clearance_hole_d"] = R(chx[1] - chx[0])
        pz = C.zspan(bp, bx + 2.4, by)
        o["plate_pad_top_z"] = R(pz[0][1]) if pz else None
        o["screw_to_shell"] = R(C.dist(A[scr], sh)[0])
        o["head_flush"] = R(hz[0][0] - C.bb(bp)[4]) if hz else None
        out[tag] = o
    return out


def edges(A):
    sh, pcb = A["front shell"], A["board PCB"]
    z = -1.4
    out = {}
    lr = []
    for y in (-45.0, -40.0, -30.0, -20.0, -15.0, -12.0):
        bx = C.xspan(pcb, y, z)
        sx = C.xspan(sh, y, z)
        left_wall = max(b for a, b in sx if b < bx[0][0] + 1e-6)
        right_wall = min(a for a, b in sx if a > bx[-1][1] - 1e-6)
        lr.append({"y": y, "board_x": [R(bx[0][0]), R(bx[-1][1])], "left_gap": R(bx[0][0] - left_wall),
                   "right_gap": R(right_wall - bx[-1][1])})
    out["side_gaps"] = lr
    bot = []
    for x in (-24.0, -20.9, -15.0, -5.0, 0.0, 5.0, 13.5, 17.0, 20.9, 23.5):
        by_ = C.yspan(pcb, x, z)
        sy = C.yspan(sh, x, z)
        below = [b for a, b in sy if b < by_[0][0] + 1e-6]
        above = [a for a, b in sy if a > by_[-1][1] - 1e-6]
        sy2 = C.yspan(sh, x, -2.3)
        below2 = [b for a, b in sy2 if b < by_[0][0] + 1e-6]
        bot.append({"x": x, "board_y": [R(by_[0][0]), R(by_[-1][1])],
                    "bottom_gap_at_z-1.4": R(by_[0][0] - max(below)) if below else None,
                    "bottom_gap_at_z-2.3": R(by_[0][0] - max(below2)) if below2 else None,
                    "top_gap_at_z-1.4": R(min(above) - by_[-1][1]) if above else None})
    out["bottom_top_gaps"] = bot
    d, p, q = C.dist(pcb.intersect(box(-40, 40, -60, 60, -1.79, -1.01)), sh.intersect(box(-40, 40, -60, 60, -1.79, -1.01)))
    out["board_to_shell_lateral_min"] = R(d)
    out["board_to_shell_lateral_at"] = [R(v, 2) for v in p]
    # standoffs
    st = []
    for x in (-20.9, 13.5, 20.9):
        sx = gap_around(C.xspan(sh, -49.95, -1.5), x - 1.0)
        piece = span_containing(C.xspan(sh, -49.95, -1.5), x)
        zz = span_containing(C.zspan(sh, x, -50.1), -1.5)
        face = max(b for a, b in C.yspan(sh, x, -1.5) if b < -49.0)
        face2 = max(b for a, b in C.yspan(sh, x, zz[0] + 0.01) if b < -49.0) if zz else None
        st.append({"x": x, "x_range": [R(piece[0]), R(piece[1])] if piece else None,
                   "width": R(piece[1] - piece[0]) if piece else None,
                   "face_y": R(face), "gap_to_board_edge": R(-49.6 - face),
                   "z_end": R(zz[0]) if zz else None,
                   "face_y_at_end": R(face2) if face2 else None,
                   "chamfer_y": R(face - face2 + 0.01) if face2 else None})
    out["standoffs"] = st
    # notches at the bottom bosses
    no = []
    for bxc in (-24.7, 24.7):
        rs = []
        for k in range(0, 360, 3):
            a = math.radians(k)
            r = C.ray(pcb, (bxc, -47.15, -1.4), (math.cos(a), math.sin(a), 0), 0, 6)
            if r:
                rs.append(r[0][0])
        bxs = span_containing(C.xspan(sh, -47.15, -1.4), bxc)
        boss_r = None
        if bxs:
            boss_r = min(abs(bxs[0] - bxc), abs(bxs[1] - bxc)) if (bxs[1] - bxs[0]) < 8 else None
        ray_boss = C.ray(sh, (bxc, -47.15 + 4.0, -1.4), (0, -1, 0), 0, 4)
        r_boss = 4.0 - ray_boss[0][0] if ray_boss else None
        d_, p_, q_ = C.dist(pcb, sh.intersect(cq.Solid.makeCylinder(2.75, 0.78, cq.Vector(bxc, -47.15, -1.79))))
        no.append({"boss_x": bxc, "notch_r_min": R(min(rs)), "notch_r_max": R(max(rs)), "boss_r_from_ray": R(r_boss),
                   "gap": R(min(rs) - r_boss) if r_boss else None, "pcb_to_boss_region_min": R(d_),
                   "pcb_to_boss_region_at": [R(v, 2) for v in p_]})
    out["notches"] = no
    # frame tabs: nub 0.35 proud over the tab length, board thickness
    t = 0.35
    tabs = [("left", (-17.9, -13.1)), ("top", (22.1, 26.1)), ("right", (-45.4, -40.6))]
    local = sh.intersect(box(-40, 40, -60, 60, -10, -1.02))
    others = [n for n in A if not n.startswith("board ") and n != "front shell"]
    rows = []
    for edge, (a, b) in tabs:
        if edge == "left":
            nub, flush = box(-27.2 - t, -27.2, a, b, -1.8, -1.0), box(-27.21, -27.2, a, b, -1.8, -1.0)
            wbox = box(-27.3, -26.0, a, b, -1.79, -1.01)
        elif edge == "right":
            nub, flush = box(27.2, 27.2 + t, a, b, -1.8, -1.0), box(27.2, 27.21, a, b, -1.8, -1.0)
            wbox = box(26.0, 27.3, a, b, -1.79, -1.01)
        else:
            nub, flush = box(a, b, -10.0, -10.0 + t, -1.8, -1.0), box(a, b, -10.0, -9.99, -1.8, -1.0)
            wbox = box(a, b, -11.0, -9.9, -1.79, -1.01)
        dn, pn, qn = C.dist(nub, local)
        dfl, _, _ = C.dist(flush, local)
        near = []
        for n in others:
            if C.bb_gap(C.bb(nub), C.bb(A[n])) < 3:
                near.append((n, R(C.dist(nub, A[n])[0])))
        near.sort(key=lambda x: x[1])
        # board edge itself along the tab: distance from the bare board to the shell in the tab window
        win = pcb.intersect(wbox)
        dw, pw, qw = C.dist(win, local)
        rows.append({"edge": edge, "range": [a, b], "board_edge_to_shell": R(dw), "filed_flush_to_shell": R(dfl),
                     "nub_0.35_to_shell": R(dn), "nub_to_shell_at": [R(v, 2) for v in qn], "nub_near_parts": near[:4]})
    out["frame_tabs"] = rows
    # screen lips and the board top edge
    out["board_top_to_screen"] = R(C.dist(pcb, A["screen body"])[0])
    return out


def screen_fit(A):
    sh, scr = A["front shell"], A["screen body"]
    sb = C.bb(scr)
    out = {"screen_bbox": [R(v) for v in sb], "screen_size": [R(sb[1] - sb[0]), R(sb[3] - sb[2]), R(sb[5] - sb[4])],
           "screen_centre": [R((sb[0] + sb[1]) / 2), R((sb[2] + sb[3]) / 2)]}
    z = -2.0
    xs = gap_around(C.xspan(sh, 20.0, z), 0.0)
    out["pocket_x_at_y20"] = [R(xs[0]), R(xs[1])]
    out["side_gap_left"] = R(sb[0] - xs[0])
    out["side_gap_right"] = R(xs[1] - sb[1])
    ys = gap_around(C.yspan(sh, 0.0, z), 20.0)
    out["pocket_top_y"] = R(ys[1])
    out["top_gap"] = R(ys[1] - sb[3])
    lip = C.yspan(sh, -20.0, -1.5)
    lp = [iv for iv in lip if -10 < iv[0] < -7]
    out["lip_y"] = [R(lp[0][0]), R(lp[0][1])] if lp else None
    out["lip_gap"] = R(sb[2] - lp[0][1]) if lp else None
    lz = C.zspan(sh, -20.0, -8.4)
    out["lip_z"] = [[R(a), R(b)] for a, b in lz]
    v, com = C.common(sh, scr)
    out["overlap_with_shell_mm3"] = R(v, 3)
    out["overlap_pieces"] = [{"volume": R(C.volume(s), 3), "bbox": [R(q) for q in C.bb(s)]} for s in com.Solids()] if v else []
    pen = []
    for sx in (-1, 1):
        cx, cy = sx * (sb[1] if sx > 0 else -sb[0]), sb[3]
        dvec = (-sx / math.sqrt(2), -1 / math.sqrt(2), 0)
        r = C.ray(sh, (cx - dvec[0] * 2, cy - dvec[1] * 2, z), dvec, 0, 4)
        depth = max([(b - 2.0) for a, b in r if a < 2.0 < b], default=0.0)
        # wall left outside the screen corner, along the diagonal: first material from the corner outward
        out_dir = (-dvec[0], -dvec[1], 0)
        ro = C.ray(sh, (cx, cy, z), out_dir, 0, 6)
        first = ro[0] if ro else None
        # clearance from the screen body to the shell around the corner (skin contact left out)
        cb = box(cx - 2.5 if sx > 0 else cx - 0.01, cx + 0.01 if sx > 0 else cx + 2.5, cy - 2.5, cy + 0.01, -3.1, -1.05)
        cbig = box(cx - 3.0, cx + 3.0, cy - 3.0, cy + 3.0, -3.1, -1.05)
        scr_c = scr.intersect(cb)
        sh_c = sh.intersect(cbig)
        dc = C.dist(scr_c, sh_c)[0] if scr_c.Solids() and sh_c.Solids() else None
        yy = gap_around(C.yspan(sh, sx * 26.5, z), 20.0)
        xx = gap_around(C.xspan(sh, 49.5, z), 0.0)
        pen.append({"corner": [R(cx), R(cy)], "wall_into_screen_on_diagonal": R(depth),
                    "corner_clearance": R(-depth) if depth > 1e-6 else R(dc),
                    "wall_outside_corner_on_diagonal": R(first[1] - first[0]) if first else None,
                    "gap_to_wall_on_diagonal": R(first[0]) if first else None,
                    "pocket_top_at_x26.5": R(yy[1]), "pocket_x_at_y49.5": [R(xx[0]), R(xx[1])]})
    out["top_corners"] = pen
    # outer wall left at the corner if the pocket were cut with 0.15 clearance (doc claim 0.83)
    out["corner_wall_measured"] = pen[1]["wall_outside_corner_on_diagonal"]
    # actual wall at the corner, measured on the diagonal from the screen corner outward
    r = C.ray(sh, (26.68, 49.65, z), (1 / math.sqrt(2), 1 / math.sqrt(2), 0), -3, 6)
    out["shell_material_on_corner_diagonal"] = [[R(a), R(b)] for a, b in r]
    # window
    wz = -0.7
    wx = gap_around(C.xspan(sh, 23.0, wz), 0.0)
    wy = gap_around(C.yspan(sh, 0.0, wz), 23.0)
    out["window_at_z-0.7"] = [R(wx[0]), R(wx[1]), R(wy[0]), R(wy[1])]
    out["window_size"] = [R(wx[1] - wx[0]), R(wy[1] - wy[0])]
    wx0 = gap_around(C.xspan(sh, 23.0, -0.01), 0.0)
    out["window_x_at_front"] = [R(wx0[0]), R(wx0[1])]
    out["window_chamfer"] = R(wx[0] - wx0[0])
    pol = C.bb(A["screen front polarizer"])
    out["polarizer_size"] = [R(pol[1] - pol[0]), R(pol[3] - pol[2])]
    aa = (pol[0] + 1.25, pol[1] - 1.25, pol[2] + 1.25, pol[3] - 1.25)
    out["active_area"] = [R(v) for v in aa]
    out["window_margin"] = [R(aa[0] - wx[0]), R(wx[1] - aa[1]), R(aa[2] - wy[0]), R(wy[1] - aa[3])]
    out["window_centre_offset"] = [R((wx[0] + wx[1]) / 2 - (aa[0] + aa[1]) / 2), R((wy[0] + wy[1]) / 2 - (aa[2] + aa[3]) / 2)]
    # window corner radius from the diagonal
    cxw, cyw = wx[1], wy[1]
    rr = C.ray(sh, (cxw - 3, cyw - 3, wz), (1 / math.sqrt(2), 1 / math.sqrt(2), 0), 0, 6)
    hit = rr[0][0] if rr else None
    if hit is not None:
        # point on the arc along the diagonal: distance from the corner point
        e = 3 * math.sqrt(2) - hit
        out["window_corner_r"] = R(e / (math.sqrt(2) - 1))
    tb = C.zspan(sh, -24.7, 47.15)
    out["screen_back_to_top_boss"] = R(C.bb(A["screen body"])[4] - tb[0][1]) if tb else None
    return out


def wheel(A):
    sh, disc = A["front shell"], A["wheel disc"]
    db = C.bb(disc)
    out = {"disc_bbox": [R(v) for v in db]}
    wy = -27.75
    dx = C.xspan(disc, wy, -0.5)
    out["disc_d"] = R(dx[-1][1] - dx[0][0])
    fx = C.xspan(disc, wy, -0.9)
    out["flange_d"] = R(fx[-1][1] - fx[0][0])
    fz = C.zspan(disc, 17.7, wy)
    out["flange_z"] = [R(fz[0][0]), R(fz[0][1])]
    out["flange_t"] = R(fz[0][1] - fz[0][0])
    ox = gap_around(C.xspan(sh, wy, -0.5), 0.0)
    out["opening_d"] = R(ox[1] - ox[0])
    out["opening_radial_gap"] = R((out["opening_d"] - out["disc_d"]) / 2)
    rx = gap_around(C.xspan(sh, wy, -0.8), 0.0)
    out["recess_d"] = R(rx[1] - rx[0])
    out["recess_radial_gap"] = R((out["recess_d"] - out["flange_d"]) / 2)
    sz = C.zspan(sh, 17.9, wy)
    out["skin_over_recess"] = [[R(a), R(b)] for a, b in sz]
    out["skin_over_recess_t"] = R(sz[0][1] - sz[0][0]) if sz else None
    out["disc_centre"] = [R((dx[0][0] + dx[-1][1]) / 2), R(wy)]
    out["disc_t"] = R(C.zspan(disc, 5.0, wy)[0][1] - C.zspan(disc, 5.0, wy)[0][0])
    out["disc_to_pcb"] = R(C.dist(disc, A["board PCB"])[0])
    out["flange_top_y"] = R(db[3])
    out["flange_past_board_top"] = R(db[3] - C.bb(A["board PCB"])[3])
    # key tab direction: point of the disc furthest from the centre
    hits = []
    for k in range(0, 720):
        a = math.radians(k / 2)
        r = C.ray(disc, (0, wy, -0.9), (math.cos(a), math.sin(a), 0), 0, 25)
        if r and r[-1][1] > 19.0:
            hits.append((k / 2, r[-1][1]))
    if hits:
        angs = [h[0] for h in hits]
        out["key_angle_deg"] = R(sum(angs) / len(angs), 1)
        out["key_angle_range"] = [min(angs), max(angs)]
        out["key_outer_r"] = R(max(h[1] for h in hits))
    return out


def battery(A):
    bp, sh = A["back plate"], A["front shell"]
    ba = C.bb(A["battery pack"])
    out = {"pack_bbox": [R(v) for v in ba], "pack_size": [R(ba[1] - ba[0]), R(ba[3] - ba[2]), R(ba[5] - ba[4])]}
    fo = C.bb(A["battery foam"])
    out["foam_bbox"] = [R(v) for v in fo]
    out["foam_size"] = [R(fo[1] - fo[0]), R(fo[3] - fo[2]), R(fo[5] - fo[4])]
    out["pack_lower_edge_y"] = R(ba[2])
    out["cable_bay_from_screen_edge"] = R(ba[2] - C.bb(A["screen body"])[2])
    # ribs are 1.2 tall and the lip 0.8: probe between the two so the lip is not taken for a rib
    rib = C.xspan(bp, 20.0, L["plate_in"] + 1.0)
    ribs = [iv for iv in rib if abs(iv[0]) < 25]
    out["side_ribs_x"] = [[R(a), R(b)] for a, b in ribs]
    if len(ribs) >= 2:
        out["side_rib_gap_to_pack"] = [R(ba[0] - ribs[0][1]), R(ribs[-1][0] - ba[1])]
    rz = C.zspan(bp, (ribs[0][0] + ribs[0][1]) / 2, 20.0) if ribs else None
    out["rib_top_z"] = R(rz[0][1]) if rz else None
    out["rib_h"] = R(rz[0][1] - L["plate_in"]) if rz else None
    out["pack_bottom_to_plate"] = R(ba[4] - L["plate_in"])
    ty = C.yspan(bp, 0.0, L["plate_in"] + 1.0)
    tops = [iv for iv in ty if iv[0] > 40]
    out["top_rib_y"] = [R(tops[0][0]), R(tops[0][1])] if tops else None
    out["top_rib_gap"] = R(tops[0][0] - ba[3]) if tops else None
    out["pack_to_shell"] = R(C.dist(A["battery pack"], sh)[0])
    out["pack_to_foam"] = R(fo[4] - ba[5])
    # reference packs, as boxes hanging from the foam (top face on the foam), from the model pack's lower edge
    zb = None
    refs = {}
    for name, (w, l, t) in {"52 x 47.65 x 4.55": (52.0, 47.65, 4.55), "43.4 x 52.4 x 4.55": (43.4, 52.4, 4.55),
                            "34 x 50 x 4.0 (403450)": (34.0, 50.0, 4.0), "52 x 54 x 4.8 (SPEC block)": (52.0, 54.0, 4.8)}.items():
        b = box(-w / 2, w / 2, ba[2], ba[2] + l, fo[4] - t, fo[4])
        hits = {}
        dmin = None
        for n in ("front shell", "back plate", "insert 3", "insert 4", "screw 3", "screw 4", "battery foam", "screen body"):
            d, p, q = C.dist(b, A[n])
            if n == "back plate":
                # the pack rests on the plate: count only the lip and ribs it may hit (not the face it lies on)
                v, _ = C.common(b, A[n])
            else:
                v, _ = C.common(b, A[n])
            if v and v > 0.001 and not (n == "back plate"):
                hits[n] = R(v, 2)
            if n not in ("back plate",) and (dmin is None or d < dmin[1]):
                dmin = (n, d)
        vp, _ = C.common(b, A["back plate"])
        refs[name] = {"overlaps": hits, "back_plate_overlap_mm3 (ribs)": R(vp, 2), "nearest": [dmin[0], R(dmin[1])]}
    out["reference_packs"] = refs
    pl = C.bb(A["battery plug PHR-2"])
    out["plug_bbox"] = [R(v) for v in pl]
    out["plug_to_screen"] = R(C.dist(A["battery plug PHR-2"], A["screen body"])[0])
    out["plug_to_shell"] = R(C.dist(A["battery plug PHR-2"], sh)[0])
    j4 = C.bb(A["board J4"])
    out["j4_mouth_to_screen_edge"] = R(C.bb(A["screen body"])[2] - j4[3])
    return out


def posts_pins(A, mi):
    bp, sh, pcb = A["back plate"], A["front shell"], A["board PCB"]
    out = {"posts": [], "pins": []}
    for pp in mi["press_pads"]:
        px, py = pp["centre"]
        zz = C.zspan(bp, px, py)
        tip = gap_around(C.xspan(bp, py, -2.5), px - 3.0)
        tip_iv = span_containing(C.xspan(bp, py, -2.5), px)
        base = span_containing(C.xspan(bp, py, -6.0), px)
        post = bp.intersect(box(px - 3, px + 3, py - 3, py + 3, L["plate_in"] + 0.01, 0))
        v, com = C.common(post, pcb)
        near = []
        for n in A:
            if not n.startswith("board ") or n == "board PCB":
                continue
            if C.bb_gap(C.bb(post), C.bb(A[n])) < 2.5:
                near.append((n[6:], R(C.dist(post, A[n])[0])))
        near.sort(key=lambda x: x[1])
        out["posts"].append({"ref": pp["ref"], "centre": pp["centre"], "tip_z": R(zz[0][1]) if zz else None,
                             "tip_d": R(tip_iv[1] - tip_iv[0]) if tip_iv else None,
                             "base_d": R(base[1] - base[0]) if base else None,
                             "interference_with_pcb": R(zz[0][1] - (-1.8)) if zz else None,
                             "overlap_mm3": R(v, 3), "nearest_parts": near[:3]})
    for h in mi["locating_holes"]:
        hx, hy = h["centre"]
        zz = C.zspan(sh, hx, hy)
        pz = span_containing(zz, -1.5)
        d = span_containing(C.xspan(sh, hy, -1.4), hx)
        hole = gap_around(C.xspan(pcb, hy, -1.4), hx)
        tipd = span_containing(C.xspan(sh, hy, pz[0] + 0.02), hx) if pz else None
        pin = sh.intersect(box(hx - 1.5, hx + 1.5, hy - 1.5, hy + 1.5, -3, -1.01))
        near = []
        for n in A:
            if not n.startswith("board ") or n == "board PCB":
                continue
            if C.bb_gap(C.bb(pin), C.bb(A[n])) < 2.5:
                near.append((n[6:], R(C.dist(pin, A[n])[0])))
        near.sort(key=lambda x: x[1])
        out["pins"].append({"ref": h["ref"], "pin_d": R(d[1] - d[0]) if d else None,
                            "tip_z": R(pz[0]) if pz else None, "tip_past_component_side": R(-1.8 - pz[0]) if pz else None,
                            "tip_d": R(tipd[1] - tipd[0]) if tipd else None,
                            "hole_d": R(hole[1] - hole[0]), "radial_clearance": R((hole[1] - hole[0] - (d[1] - d[0])) / 2),
                            "pin_to_pcb": R(C.dist(pin, pcb)[0]), "nearest_parts": near[:3]})
    return out


def motor(A):
    bp = A["back plate"]
    mb = C.bb(A["motor"])
    out = {"motor_bbox": [R(v) for v in mb], "motor_d": R(mb[1] - mb[0]), "motor_h": R(mb[5] - mb[4])}
    mx, my = (mb[0] + mb[1]) / 2, (mb[2] + mb[3]) / 2
    out["centre"] = [R(mx), R(my)]
    seat = gap_around(C.xspan(bp, my, L["plate_in"] - 0.15), mx)
    out["seat_d"] = R(seat[1] - seat[0])
    sz = C.zspan(bp, mx, my)
    out["seat_floor_z"] = R(sz[0][1]) if sz else None
    out["seat_depth"] = R(L["plate_in"] - sz[0][1]) if sz else None
    out["motor_bottom_vs_seat_floor"] = R(mb[4] - sz[0][1]) if sz else None
    near = []
    for n in A:
        if n.startswith("board ") and n != "board PCB" and C.bb_gap(C.bb(A["motor"]), C.bb(A[n])) < 4:
            near.append((n[6:], R(C.dist(A["motor"], A[n])[0])))
    near.sort(key=lambda x: x[1])
    out["nearest_board_parts"] = near[:3]
    return out


def antenna(A, mi):
    ko = mi["antenna"]["copper_keepout_all_layers"]
    kx, ky = ko["x"], ko["y"]
    ar = mi["antenna"]["antenna_region"]
    koz = box(kx[0], kx[1], ky[0], ky[1], L["back"], 0.0)
    anz = box(ar["x"][0], ar["x"][1], ar["y"][0], ar["y"][1], L["back"], 0.0)
    out = {"keepout": {"x": kx, "y": ky}, "antenna_region": ar}
    metal = ["insert 1", "insert 2", "insert 3", "insert 4", "screw 1", "screw 2", "screw 3", "screw 4", "motor",
             "battery pack", "board SW1", "board J4", "board J1", "board J3", "board SW3", "board SW2"]
    rows = {}
    for n in metal + ["FPC tail", "FPC leg and wide section", "FPC part", "button cap"]:
        d, p, q = C.dist(koz, A[n])
        d2, _, _ = C.dist(anz, A[n])
        rows[n] = {"to_keepout": R(d), "to_antenna_region": R(d2), "at": [R(v, 2) for v in q]}
    out["distances"] = rows
    # plastic inside the keep-out (plan view)
    for n in ("front shell", "back plate", "button cap"):
        v, com = C.common(koz, A[n])
        out[f"{n}_inside_keepout_mm3"] = R(v, 2)
        if v and v > 0.01:
            out[f"{n}_inside_keepout_bbox"] = [R(x) for x in C.bb(com)]
    lip = C.xspan(A["back plate"], -28.0, L["plate_in"] + 0.4)
    out["back_plate_lip_x_at_y-28"] = [[R(a), R(b)] for a, b in lip if a > 20]
    wall = C.xspan(A["front shell"], -28.0, -5.0)
    out["right_wall_x_at_y-28"] = [[R(a), R(b)] for a, b in wall if a > 20]
    return out


def walls(A):
    sh, bp, disc = A["front shell"], A["back plate"], A["wheel disc"]
    out = {}
    out["side_wall"] = R(C.xspan(sh, 0.0, -5.0)[-1][1] - C.xspan(sh, 0.0, -5.0)[-1][0])
    tw = C.yspan(sh, 0.0, -5.0)
    out["top_wall"] = R(tw[-1][1] - tw[-1][0])
    out["skin"] = R(C.zspan(sh, -20.0, -5.0)[0][1] - C.zspan(sh, -20.0, -5.0)[0][0])
    out["back_plate"] = R(C.zspan(bp, 0.0, 0.0)[0][1] - C.zspan(bp, 0.0, 0.0)[0][0])
    lip = [iv for iv in C.xspan(bp, 0.0, L["plate_in"] + 0.4) if iv[0] > 20]
    out["lip_x"] = [R(lip[0][0]), R(lip[0][1])] if lip else None
    out["lip_w"] = R(lip[0][1] - lip[0][0]) if lip else None
    lz = C.zspan(bp, (lip[0][0] + lip[0][1]) / 2, 0.0) if lip else None
    out["lip_h"] = R(lz[0][1] - L["plate_in"]) if lz else None
    wall_in = C.xspan(sh, 0.0, -5.0)[-1][0]
    out["lip_gap_to_wall"] = R(wall_in - lip[0][1]) if lip else None
    # thin spots
    out["skin_over_disc_recess"] = R(C.zspan(sh, 17.9, -27.75)[0][1] - C.zspan(sh, 17.9, -27.75)[0][0])
    sk = C.zspan(sh, -4.33, -47.94)
    out["skin_over_usb_leg_relief"] = R(sk[-1][1] - sk[-1][0]) if sk else None
    yw = span_containing(C.yspan(sh, 6.0, -5.8), -50.5)
    out["bottom_wall_behind_port_recess"] = R(yw[1] - yw[0]) if yw else None
    ys = span_containing(C.yspan(sh, -20.0, -3.14), -50.5)
    out["bottom_wall_at_card_scallop"] = R(ys[1] - ys[0]) if ys else None
    tz = C.zspan(sh, -24.7, 47.15)
    out["top_boss_roof"] = R(tz[0][1] - tz[0][0])
    zz = C.zspan(bp, -24.7 + 1.5, -47.15)
    out["plate_under_screw_head"] = R(zz[0][1] - zz[0][0])
    ivs = [iv for iv in C.xspan(bp, -48.0, -4.0) if -9 < iv[0] < -2.5]
    out["led_tube_neck_wall"] = R(ivs[0][1] - ivs[0][0])
    ivs = [iv for iv in C.xspan(bp, -48.0, -6.5) if -9 < iv[0] < -2.5]
    out["led_tube_base_wall"] = R(ivs[0][1] - ivs[0][0])
    out["disc_flange"] = R(C.zspan(disc, 17.7, -27.75)[0][1] - C.zspan(disc, 17.7, -27.75)[0][0])
    dp = C.zspan(disc, -4.33, -43.76)
    out["disc_over_leg_pocket"] = [[R(a), R(b)] for a, b in dp]
    out["disc_over_leg_pocket_t"] = R(dp[0][1] - dp[0][0]) if dp else None
    return out


# ------------------------------------------------------------------ extra probes for the document check
def _corner_r(shape, z, cx, cy, sx, sy, far=10.0):
    """Radius of a plan corner whose arc centre lies on the 45 degree line
    through (cx - sx*far, cy - sy*far): ray along the diagonal to the surface."""
    o = (cx - sx * far, cy - sy * far, z)
    d = (sx / math.sqrt(2), sy / math.sqrt(2), 0)
    iv = C.ray(shape, o, d, 0, 3 * far)
    return iv


def extra(A, mi):
    sh, bp, pcb = A["front shell"], A["back plate"], A["board PCB"]
    out = {}
    # outer plan corner radius: ray from inside along the diagonal, leaving the solid at the arc
    # between the boss faces and the rim, the diagonal meets only the corner wall
    o = (29.3 - 10.0, 51.75 - 10.0, (L["boss_face"] + L["rim"]) / 2)
    iv = C.ray(sh, o, (1 / math.sqrt(2), 1 / math.sqrt(2), 0), 0, 20)
    t_in, t_out = iv[-1]
    r2 = math.sqrt(2)
    out["outer_corner_r"] = R((10 * r2 - t_out) / (r2 - 1))
    out["inner_corner_r"] = R(((10 - 1.6) * r2 - t_in) / (r2 - 1))
    out["corner_wall_on_diagonal"] = R(t_out - t_in)
    # edge rounds: front face flat extent and back face flat extent
    xf = C.xspan(sh, 0.0, -1e-6)
    out["front_edge_round"] = R(29.3 - xf[-1][1])
    xb = C.xspan(bp, 0.0, L["back"] + 1e-6)
    out["back_edge_round"] = R(29.3 - xb[-1][1])
    out["interior_x"] = [R(C.xspan(sh, 0.0, -5.0)[0][1]), R(C.xspan(sh, 0.0, -5.0)[-1][0])]
    out["interior_y"] = [R(C.yspan(sh, -20.0, -5.0)[0][1]), R(C.yspan(sh, -20.0, -5.0)[-1][0])]
    # board corner radius (top corners) from the bare board section
    faces = C.section(pcb, "z", -1.4)
    loop = max((f[0] for f in faces), key=lambda L: len(L))
    pts = [p for p in loop if p[0] < -26.2 and p[1] > -11.0]
    if pts:
        out["board_top_left_corner_r"] = R(max(math.hypot(p[0] + 26.2, p[1] + 11.0) for p in pts))
    ys = C.yspan(pcb, 27.19, -1.4)
    out["board_right_edge_lowest_y_at_x27.19"] = R(ys[0][0]) if ys else None
    out["right_tab_strip_below_tab"] = R(-45.4 - ys[0][0]) if ys else None
    # buzzer grille
    gx = C.xspan(bp, -21.6, -9.0)
    gaps = []
    for a_, b_ in zip(gx[:-1], gx[1:]):
        gaps.append((a_[1], b_[0]))
    slots = [g for g in gaps if 0.5 < g[1] - g[0] < 1.2 and -9 < g[0] < 2]
    out["grille_slots_x"] = [[R(a), R(b)] for a, b in slots]
    if slots:
        out["grille_slot_w"] = R(slots[0][1] - slots[0][0])
        out["grille_pitch"] = R((slots[-1][0] - slots[0][0]) / max(1, len(slots) - 1))
        out["grille_overall_w"] = R(slots[-1][1] - slots[0][0])
        cx = (slots[0][0] + slots[0][1]) / 2
        gy = gap_around(C.yspan(bp, cx, -9.0), -21.6)
        out["grille_slot_l"] = R(gy[1] - gy[0])
    # insert hole lead-in depth: where the hole narrows to 3.0
    lo, hi = L["boss_face"] + 0.01, L["boss_face"] + 1.7
    for _ in range(40):
        z = (lo + hi) / 2
        g = gap_around(C.xspan(sh, -47.15, z), -24.7)
        if g[1] - g[0] > 3.0005:
            lo = z
        else:
            hi = z
    out["insert_lead_in_depth"] = R(hi - L["boss_face"])
    gf = gap_around(C.xspan(sh, -47.15, L["boss_face"] + 1e-4), -24.7)
    out["insert_lead_in_d_at_face"] = R(gf[1] - gf[0])
    # pin chamfer
    for h in mi["locating_holes"]:
        hx, hy = h["centre"]
        zz = C.zspan(sh, hx, hy)
        tip = span_containing(zz, -1.5)[0]
        d0 = span_containing(C.xspan(sh, hy, tip + 1e-3), hx)
        dfull = span_containing(C.xspan(sh, hy, -1.5), hx)
        out[f"pin_{h['ref']}_chamfer"] = R(((dfull[1] - dfull[0]) - (d0[1] - d0[0])) / 2)
    # LED tube tip chamfer (radial, at the tip)
    tz = C.zspan(bp, -5.83 + 0.7, -48.0)
    tip_z = tz[0][1] if tz else -3.0
    ivs = [iv for iv in C.xspan(bp, -48.0, tip_z - 1e-3) if -9 < iv[0] < -2.5]
    ivn = [iv for iv in C.xspan(bp, -48.0, -4.0) if -9 < iv[0] < -2.5]
    out["led_tip_chamfer_radial"] = R(ivs[0][0] - ivn[0][0]) if ivs and ivn else None
    # window chamfer at the very front
    w0 = gap_around(C.xspan(sh, 23.0, -1e-4), 0.0)
    w1 = gap_around(C.xspan(sh, 23.0, -0.7), 0.0)
    out["window_chamfer_at_front"] = R(w1[0] - w0[0])
    # screen band: pocket wall from z ... to ...
    zb = C.zspan(sh, 27.0, 20.0)
    out["pocket_wall_z_at_x27_y20"] = [[R(a), R(b)] for a, b in zb]
    # FPC: loop y range, drop, flat vendor FPC
    leg = A["FPC leg and wide section"]
    prof = []
    yv = -20.0
    while yv > -36.0:
        zz = C.zspan(leg, -10.0, yv)
        if zz:
            prof.append((yv, zz[-1][1]))
        yv -= 0.05
    flat_top = C.zspan(leg, -10.0, -20.0)[0][1]
    up = [p for p in prof if p[1] > flat_top + 0.0005]
    out["fpc_loop_y"] = [R(max(p[0] for p in up)), R(min(p[0] for p in up))] if up else None
    lz = C.zspan(leg, -10.0, -20.0)
    be = C.bb(A["screen FPC bonded end"])
    out["fpc_exit_mid_z"] = R((be[4] + be[5]) / 2)
    out["fpc_leg_on_plate_z"] = [R(lz[0][0]), R(lz[0][1])] if lz else None
    out["fpc_drop"] = R((be[4] + be[5]) / 2 - (lz[0][0] + lz[0][1]) / 2) if lz else None
    import load as L_
    S = L_.screen_vendor()
    fl = [s for s in S if abs(C.volume(s) - 107.017) < 0.5]
    if fl:
        f = fl[0].translate(cq.Vector(-2387.51, -1780.07, -1.0))
        fb = C.bb(f)
        zc = (fb[4] + fb[5]) / 2
        out["flat_fpc_bbox"] = [R(v) for v in fb]
        out["flat_wide_x_at_y-9"] = [R(C.xspan(f, -9.0, zc)[0][0]), R(C.xspan(f, -9.0, zc)[-1][1])]
        out["flat_wide_x_at_y-12"] = [R(C.xspan(f, -12.0, zc)[0][0]), R(C.xspan(f, -12.0, zc)[-1][1])]
        out["flat_leg_x_at_y-30"] = [R(C.xspan(f, -30.0, zc)[0][0]), R(C.xspan(f, -30.0, zc)[-1][1])]
        yw = C.yspan(f, 0.0, zc)
        out["flat_wide_y_at_x0"] = [R(yw[-1][0]), R(yw[-1][1])] if yw else None
        yt = C.yspan(f, 20.0, zc)
        out["flat_tail_y_at_x20"] = [R(yt[0][0]), R(yt[-1][1])] if yt else None
        yl = C.yspan(f, -10.0, zc)
        out["flat_leg_y_at_x-10"] = [R(yl[-1][0]), R(yl[-1][1])] if yl else None
        xt = C.xspan(f, -48.4, zc)
        out["flat_tail_x_at_y-48.4"] = [R(xt[0][0]), R(xt[-1][1])] if xt else None
    # dive zone kept open: case and battery solids inside x -14..19, y -10..-7.8, from the plate to the board
    dz = box(-14.0, 19.0, -10.0, -7.8, L["plate_in"], -1.0)
    occ = {}
    for n in ("front shell", "back plate", "battery pack", "battery plug PHR-2", "battery wires", "motor"):
        v, _ = C.common(dz, A[n])
        occ[n] = R(v, 3)
    out["dive_zone_case_overlap_mm3"] = occ
    # tallest parts in the FPC run zones and the ramp zone (STEP, from the board face z -1.8)
    zones = mi["fpc_zones"]
    def tallest(xr, yr):
        best = None
        for n in A:
            if not n.startswith("board ") or n in ("board PCB",) or n.startswith("board J1 leg"):
                continue
            b = C.bb(A[n])
            if b[1] <= xr[0] or b[0] >= xr[1] or b[3] <= yr[0] or b[2] >= yr[1]:
                continue
            h = -1.8 - b[4]
            if best is None or h > best[1]:
                best = (n[6:], R(h))
        return best
    out["tallest_in_run_zones"] = [tallest(z[0], z[1]) for z in zones["run"]]
    out["tallest_in_ramp_zone"] = tallest(zones["ramp"][0], zones["ramp"][1])
    out["tallest_overall"] = max(((n[6:], R(-1.8 - C.bb(A[n])[4])) for n in A if n.startswith("board ") and n != "board PCB"),
                                 key=lambda t: t[1])
    # J3 card opening x at the entry; SW1 actuator diameter; J1 legs in the board
    j3 = A["board J3"]
    j3b = C.bb(j3)
    gx = gap_around(C.xspan(j3, j3b[2] + 1.0, -3.0), -13.7)
    out["j3_opening_x_at_entry+1"] = [R(gx[0]), R(gx[1])]
    out["j3_opening_centre_x"] = R((gx[0] + gx[1]) / 2)
    sw = A["board SW1"]
    za = C.zspan(sw, 27.0, -15.6)
    ya = C.yspan(sw, 27.0, -3.55)
    out["sw1_actuator_z_at_x27"] = [R(za[0][0]), R(za[-1][1])] if za else None
    out["sw1_actuator_d_z"] = R(za[-1][1] - za[0][0]) if za else None
    out["sw1_actuator_d_y"] = R(ya[-1][1] - ya[0][0]) if ya else None
    out["sw1_actuator_centre_z"] = R((za[0][0] + za[-1][1]) / 2) if za else None
    j1f = C.section(A["board J1"], "z", -1.4)
    legs = []
    for f in j1f:
        xs = [p[0] for p in f[0]]
        ys_ = [p[1] for p in f[0]]
        legs.append([R(min(xs)), R(max(xs)), R(min(ys_)), R(max(ys_)), R(max(xs) - min(xs)), R(max(ys_) - min(ys_))])
    out["j1_legs_in_board"] = legs
    return out


def fpc_wing(A):
    """The vendor FPC is wider beside its small part than the case model's
    routed FPC: measure the flat outline, then add the missing strip to the
    routed wing and measure it against the parts around it."""
    import load as L_
    S = L_.screen_vendor()
    f = [s_ for s_ in S if abs(C.volume(s_) - 107.017) < 0.5][0].translate(cq.Vector(-2387.51, -1780.07, -1.0))
    prof = []
    y = -7.9
    while y > -20.0:
        xs = C.xspan(f, y, -1.515)
        prof.append((round(y, 2), round(xs[-1][1], 3)))
        y -= 0.25
    xmax = max(p[1] for p in prof)
    wide = [p[0] for p in prof if p[1] > xmax - 0.05]
    leg = A["FPC leg and wide section"]
    model_x = C.bb(leg)[1]
    sl = leg.intersect(box(model_x - 0.9, model_x + 0.05, -30, 0, -10, 0))
    ext = sl.translate(cq.Vector(xmax - model_x, 0, 0))
    near = {}
    for n in A:
        if (n.startswith("board ") and n != "board PCB") or n in ("front shell", "back plate", "screen body", "button cap"):
            if C.bb_gap(C.bb(ext), C.bb(A[n])) < 3:
                near[n] = R(C.dist(ext, A[n])[0])
    return {"flat_outline_x_max_by_y": prof, "flat_wing_x_max": R(xmax), "flat_wing_y_range": [max(wide), min(wide)],
            "model_wing_x_max": R(model_x), "missing_width": R(xmax - model_x),
            "routed_full_wing_bbox": [R(v) for v in C.bb(ext)], "full_wing_to_parts": dict(sorted(near.items(), key=lambda kv: kv[1])),
            "full_wing_to_keepout_x": R(21.8 - xmax)}


def doc_pairs(A):
    """Distances the case README lists in its clearance table, measured here."""
    pairs = [("FPC leg and wide section", "board SW2"), ("FPC tail", "board C20"), ("FPC tail", "board J1"),
             ("FPC leg and wide section", "board D1"), ("FPC part", "board SW2"), ("FPC leg and wide section", "board R17"),
             ("battery pack", "front shell"), ("battery plug PHR-2", "screen body"), ("battery plug PHR-2", "front shell"),
             ("button cap", "board SW1"), ("motor", "board J3")]
    out = {}
    for a, b in pairs:
        out[f"{a} | {b}"] = R(C.dist(A[a], A[b])[0])
    fpcs = ["FPC leg and wide section", "FPC part", "FPC tail"]
    for p in ("front shell", "back plate", "wheel disc", "motor", "battery pack", "battery plug PHR-2", "board PCB"):
        out[f"FPC | {p}"] = R(min(C.dist(A[f], A[p])[0] for f in fpcs))
    sh = A["front shell"]
    bz0 = L["boss_face"] + 0.05
    bosses = sh.intersect(box(-27.6, -21, 43, 50.1, bz0, -3.55)).fuse(sh.intersect(box(21, 27.6, 43, 50.1, bz0, -3.55)))
    out["battery pack | top bosses"] = R(C.dist(A["battery pack"], bosses)[0])
    # standoffs to nearest parts
    st = {}
    for x in (-20.9, 13.5, 20.9):
        so = sh.intersect(box(x - 0.81, x + 0.81, -50.1, -49.65, -2.25, -1.0))
        near = []
        for n in A:
            if n.startswith("board ") and n != "board PCB" and C.bb_gap(C.bb(so), C.bb(A[n])) < 4:
                near.append((n[6:], R(C.dist(so, A[n])[0])))
        near.sort(key=lambda t: t[1])
        st[str(x)] = near[:2]
    out["standoff_nearest"] = st
    # changed parts: nearest FPC and nearest part behind the board
    behind = box(-40, 40, -60, 60, -10, -1.801)
    ch = {}
    for ref in ("R31", "R32", "R34", "C26"):
        s = A["board " + ref]
        fp = {f: R(C.dist(s, A[f])[0]) for f in fpcs + ["screen FPC bonded end"]}
        others = {}
        for n in A:
            if n.startswith("board ") or n.startswith("FPC") or n == "screen FPC bonded end":
                continue
            o = A[n]
            if C.bb(o)[4] >= -1.8:
                continue
            if C.bb(o)[5] > -1.8:
                o = o.intersect(behind)
            others[n] = R(C.dist(s, o)[0])
        nf = min(fp.items(), key=lambda kv: kv[1])
        no = min(others.items(), key=lambda kv: kv[1])
        ch[ref] = {"nearest_fpc": nf, "nearest_other_behind_board": no,
                   "screen_body": others.get("screen body"), "back_plate": others.get("back plate")}
    out["changed_parts"] = ch
    # reference packs: distances the README gives
    ba = C.bb(A["battery pack"])
    fo = C.bb(A["battery foam"])
    tmax = C.bb(A["screen body"])[4] - L["plate_in"] - 0.5 - 0.1
    # reference packs sized from the measured limits (0.3 kept to the top bosses or to the lip)
    boss_low = min(a_ for a_, b_ in C.yspan(sh, -24.7, -6.0) if a_ > 40)
    boss_in = max(b_ for a_, b_ in C.xspan(sh, 47.15, -6.0) if -26 < b_ < -20)
    lip_y = min(a_ for a_, b_ in C.yspan(A["back plate"], 15.0, L["plate_in"] + 0.4) if a_ > 40)
    wide = box(-26.0, 26.0, ba[2], boss_low - 0.3, fo[4] - tmax, fo[4])
    narrow = box(boss_in + 0.3, -(boss_in + 0.3), ba[2], lip_y - 0.3, fo[4] - tmax, fo[4])
    bp_lip = A["back plate"].intersect(box(-30, 30, 48.0, 52.0, L["plate_in"] + 0.01, L["plate_in"] + 1.3))
    out["ref wide | top bosses"] = R(C.dist(wide, bosses)[0])
    out["ref wide | front shell"] = R(C.dist(wide, sh)[0])
    out["ref narrow | back plate lip"] = R(C.dist(narrow, bp_lip)[0])
    out["ref narrow | front shell"] = R(C.dist(narrow, sh)[0])
    # largest pack in plan, measured: boss low y and lip
    boss_low = C.yspan(sh, -24.7, -6.0)
    lowy = [a for a, b in boss_low if a > 40]
    out["top_boss_low_y"] = R(min(lowy)) if lowy else None
    bx = C.xspan(sh, 47.15, -6.0)
    inner = [b for a, b in bx if -26 < b < -20]
    out["top_boss_inner_x"] = R(max(inner)) if inner else None
    lipy = [a for a, b in C.yspan(A["back plate"], 15.0, L["plate_in"] + 0.4) if a > 40]
    out["lip_inner_y"] = R(min(lipy)) if lipy else None
    lipx = [a for a, b in C.xspan(A["back plate"], 0.0, L["plate_in"] + 0.4) if a > 20]
    out["lip_inner_x"] = R(min(lipx)) if lipx else None
    return out


def plug_tilt(A):
    """Plug and J4 turned with the board about the two pivots the README uses."""
    out = {}
    plug = A["battery plug PHR-2"]
    scr, sh = A["screen body"], A["front shell"]
    for name, (yp, zp) in {"touch-side bottom edge": (-49.6, -1.0), "J1 shell front top edge (STEP z -1.9)": (-50.4, -1.9)}.items():
        rows = []
        for a in (0, 0.5, 1, 2, 3, 5, 8, 12, 18, 25):
            p = plug.rotate(cq.Vector(0, yp, zp), cq.Vector(1, yp, zp), -a) if a else plug
            rows.append({"deg": a, "to_screen": R(C.dist(p, scr)[0]), "to_shell": R(C.dist(p, sh)[0])})
        out[name] = {"rows": rows, "min_to_screen": min(r["to_screen"] for r in rows), "min_to_shell": min(r["to_shell"] for r in rows)}
    return out


# ------------------------------------------------------------------ print files
def _mesh_3mf_objects(path):
    import re
    import zipfile
    import numpy as np
    z = zipfile.ZipFile(path)
    out = []
    for nm in z.namelist():
        if not nm.endswith(".model"):
            continue
        txt = z.read(nm).decode("utf-8", "ignore")
        for om in re.finditer(r'<object id="(\d+)"[^>]*?(?:name="([^"]*)")?[^>]*>(.*?)</object>', txt, re.S):
            body = om.group(3)
            if "<vertices>" not in body:
                continue
            vs = np.array([[float(a), float(b), float(c)] for a, b, c in
                           re.findall(r'<vertex x="([-\d.eE+]+)" y="([-\d.eE+]+)" z="([-\d.eE+]+)"', body)])
            ts = np.array([[int(a), int(b), int(c)] for a, b, c in
                           re.findall(r'<triangle v1="(\d+)" v2="(\d+)" v3="(\d+)"', body)])
            if len(vs) == 0 or len(ts) == 0:
                continue
            a, b, c = vs[ts[:, 0]], vs[ts[:, 1]], vs[ts[:, 2]]
            vol = float(np.einsum("ij,ij->i", a, np.cross(b, c)).sum() / 6.0)
            mn, mx = vs.min(axis=0), vs.max(axis=0)
            out.append({"file": nm, "id": om.group(1), "name": om.group(2), "volume": round(abs(vol), 2),
                        "size": [round(float(v), 3) for v in (mx - mn)]})
    return out


def _stl(path):
    import numpy as np
    data = open(path, "rb").read()
    import struct
    n = struct.unpack("<I", data[80:84])[0]
    if 84 + n * 50 == len(data):
        arr = np.frombuffer(data[84:], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]), count=n)
        v = arr["v"].reshape(-1, 3, 3).astype(float)
    else:
        import re
        pts = [float(x) for x in re.findall(rb"vertex\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s+([-\d.eE+]+)", data) for x in x]
        v = np.array(pts).reshape(-1, 3, 3)
    a, b, c = v[:, 0], v[:, 1], v[:, 2]
    vol = float(np.einsum("ij,ij->i", a, np.cross(b, c)).sum() / 6.0)
    allv = v.reshape(-1, 3)
    return {"volume": round(abs(vol), 2), "size": [round(float(x), 3) for x in (allv.max(axis=0) - allv.min(axis=0))]}


def print_files(A):
    pdir = os.path.join(load.CASE, "print")
    out = {"stl": {}, "p2s_project": []}
    ref = {}
    for n, stem in (("front shell", "front-shell"), ("back plate", "back-plate"), ("wheel disc", "wheel-disc"),
                    ("button cap", "button-cap")):
        b = C.bb(A[n])
        ref[n] = {"volume": round(C.volume(A[n]), 2), "size": sorted([round(b[1] - b[0], 3), round(b[3] - b[2], 3), round(b[5] - b[4], 3)])}
        s = _stl(os.path.join(pdir, stem + ".stl"))
        out["stl"][n] = {"stl": s, "step": ref[n],
                         "volume_diff_pct": round(100 * (s["volume"] - ref[n]["volume"]) / ref[n]["volume"], 3),
                         "size_diff_max": round(max(abs(x - y) for x, y in zip(sorted(s["size"]), ref[n]["size"])), 3)}
    for o in _mesh_3mf_objects(os.path.join(pdir, "mark8-slab-p2s.3mf")):
        best = min(ref.items(), key=lambda kv: abs(kv[1]["volume"] - o["volume"]))
        o["matches"] = best[0]
        o["volume_diff_pct"] = round(100 * (o["volume"] - best[1]["volume"]) / best[1]["volume"], 3)
        o["size_diff_max"] = round(max(abs(x - y) for x, y in zip(sorted(o["size"]), best[1]["size"])), 3)
        out["p2s_project"].append(o)
    return out


# ------------------------------------------------------------------ main
def measure_all(only=None, prev=None):
    A = load.assembly()
    P = load.printed_steps()
    B = load.board()
    S = load.screen_vendor()
    mi = load.mech()
    levels(A)
    m = dict(prev or {})
    m["levels"] = {k: R(v) for k, v in L.items()}
    m["levels"]["pack_model_code"] = load.PACK_MODEL["code"]
    steps = [("sources", lambda: sources(A, P, B, S)), ("parts", lambda: part_table(A)),
             ("board", lambda: board_check(A, B, mi)), ("stack", lambda: stack(A)), ("usb", lambda: usb(A)),
             ("microsd", lambda: microsd(A)), ("led", lambda: led(A)), ("button", lambda: button(A)),
             ("fpc", lambda: fpc_j2(A)), ("bosses", lambda: bosses(A)), ("edges", lambda: edges(A)),
             ("screen", lambda: screen_fit(A)), ("wheel", lambda: wheel(A)), ("battery", lambda: battery(A)),
             ("posts_pins", lambda: posts_pins(A, mi)), ("motor", lambda: motor(A)), ("antenna", lambda: antenna(A, mi)),
             ("walls", lambda: walls(A)), ("print_files", lambda: print_files(A)),
             ("extra", lambda: extra(A, mi)), ("doc_pairs", lambda: doc_pairs(A)), ("plug_tilt", lambda: plug_tilt(A)),
             ("fpc_wing", lambda: fpc_wing(A))]
    import time
    t0 = time.time()
    for k, f in steps:
        if only and k not in only:
            continue
        m[k] = f()
        print(f"[{time.time() - t0:6.1f}s] {k}", flush=True)
    return m


if __name__ == "__main__":
    only = sys.argv[1:] or None
    path = os.path.join(HERE, "measurements.json")
    prev = json.load(open(path)) if (only and os.path.exists(path)) else None
    m = measure_all(only, prev)
    with open(os.path.join(HERE, "measurements.json"), "w") as f:
        json.dump(m, f, indent=1)
    print("wrote measurements.json")
