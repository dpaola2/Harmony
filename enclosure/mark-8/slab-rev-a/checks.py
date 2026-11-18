"""Assembly and print checks. Results go to checks/*.json."""
import fnmatch
import json
import math
import os

import cadquery as cq
import numpy as np

import params as P
from geom import box

TOL_VOL = 0.001

# Pairs that touch or overlap on purpose: (pattern a, pattern b, reason).
INTENDED = [
    ("board PCB", "front shell", "board touch side lies on the skin (face contact)"),
    ("board PCB", "wheel disc", "disc back face lies on L4 (face contact)"),
    ("board PCB", "back plate", "press posts on PP1 to PP4, 0.1 planned interference each"),
    ("FPC tail", "board J2", "FPC end inserted 1.3 into the J2 slot"),
    ("insert *", "front shell", "heat-set knurl 3.2 OD in the 3.0 hole, melts in"),
    ("screw *", "insert *", "screw thread in the insert"),
    ("screw *", "back plate", "head seats in the counterbore"),
    ("screen body", "front shell", "screen front rim on the skin (face contact)"),
    ("screen FPC bonded end", "FPC leg and wide section", "same FPC, cut at the screen edge"),
    ("battery 404050", "back plate", "pack rests on the back plate (face contact)"),
    ("motor", "back plate", "motor glued in its seat on the back plate"),
    ("battery wires", "battery plug PHR-2", "same cable"),
    ("battery plug PHR-2", "board J4", "plug mated in J4 (face contact at the J4 face)"),
    ("button cap", "front shell", "cap flange rests on the wall inner face (face contact)"),
    ("wheel disc", "front shell", "disc flange seats in the skin recess (face contact)"),
    ("board J1 leg *", "board *", "board model"),
]
SKIP_GROUPS = [("board", "board"), ("screen", "screen"), ("fpc", "fpc"), ("hardware", "hardware")]


def _match(name, pat):
    return fnmatch.fnmatch(name, pat)


def intended(a, b):
    for pa, pb, why in INTENDED:
        if (_match(a, pa) and _match(b, pb)) or (_match(a, pb) and _match(b, pa)):
            return why
    return None


def _bb(s):
    b = s.BoundingBox()
    return (b.xmin, b.xmax, b.ymin, b.ymax, b.zmin, b.zmax)


def _bb_gap(a, b):
    dx = max(0.0, max(a[0], b[0]) - min(a[1], b[1]))
    dy = max(0.0, max(a[2], b[2]) - min(a[3], b[3]))
    dz = max(0.0, max(a[4], b[4]) - min(a[5], b[5]))
    return math.sqrt(dx * dx + dy * dy + dz * dz)


def common_volume(a, b):
    try:
        c = a.intersect(b)
        return max(0.0, c.Volume()), None
    except Exception as e:  # noqa: BLE001
        return None, str(e)[:80]


STATS = {}


def interference(solids, extra=()):
    items = [(it["name"], it["group"], it["shape"], _bb(it["shape"])) for it in solids]
    rows = []
    STATS["pairs_checked"] = 0
    for i in range(len(items)):
        for j in range(i + 1, len(items)):
            na, ga, sa, ba = items[i]
            nb, gb, sb, bb = items[j]
            if (ga, gb) in SKIP_GROUPS or (gb, ga) in SKIP_GROUPS:
                continue
            if _bb_gap(ba, bb) > 0:
                continue
            vol, err = common_volume(sa, sb)
            STATS["pairs_checked"] += 1
            if vol is None or vol > TOL_VOL or intended(na, nb):
                why = intended(na, nb)
                rows.append({"a": na, "b": nb, "volume_mm3": None if vol is None else round(vol, 4),
                             "intended": why, "error": err,
                             "status": "ok" if (why or (vol is not None and vol <= TOL_VOL)) else "FAIL"})
    # reference solids against everything (reported, not part of the build)
    ref_rows = []
    for name, shape in extra:
        bb = _bb(shape)
        hits = []
        for na, ga, sa, ba in items:
            if ga == "battery" or _bb_gap(bb, ba) > 0:
                continue
            if name.startswith("battery") and na in ("back plate",):
                continue
            vol, err = common_volume(shape, sa)
            if vol and vol > TOL_VOL:
                hits.append({"with": na, "volume_mm3": round(vol, 3)})
        ref_rows.append({"solid": name, "size": [round(bb[1] - bb[0], 2), round(bb[3] - bb[2], 2), round(bb[5] - bb[4], 2)],
                         "overlaps": hits, "fits": not hits})
    return rows, ref_rows


def _dist(a, b):
    try:
        return round(a.distance(b), 3)
    except Exception:  # noqa: BLE001
        return None


def clearances(solids):
    by = {it["name"]: it["shape"] for it in solids}
    board = {n[6:]: s for n, s in by.items() if n.startswith("board ") and "leg" not in n}
    out = {}

    # FPC against every board part close to it.
    fpc_names = [n for n in by if n.startswith("FPC")]
    near = []
    for fn in fpc_names:
        fb = _bb(by[fn])
        for ref, s in board.items():
            if ref in ("PCB",) or (fn == "FPC tail" and ref == "J2"):
                continue
            if _bb_gap(fb, _bb(s)) > 3.0:
                continue
            d = _dist(by[fn], s)
            if d is not None:
                near.append({"fpc": fn, "part": ref, "clearance": d})
    near.sort(key=lambda r: r["clearance"])
    out["fpc_vs_board_parts"] = near[:12]
    out["fpc_vs_pcb"] = min(_dist(by[fn], board["PCB"]) for fn in fpc_names)
    out["fpc_vs_printed"] = {p: min(_dist(by[fn], by[p]) for fn in fpc_names)
                             for p in ("front shell", "back plate", "button cap", "wheel disc")}
    out["fpc_vs_battery_and_plug"] = {p: min(_dist(by[fn], by[p]) for fn in fpc_names)
                                      for p in ("battery 404050", "battery plug PHR-2", "battery wires", "motor")}
    # Battery against the bosses and the walls.
    shell = by["front shell"]
    bat = by["battery 404050"]
    out["battery_vs_front_shell"] = _dist(bat, shell)
    bosses = []
    for (bx, by_) in P.TOP_BOSSES:
        boss = shell.intersect(box(bx - 3.5, bx + 3.5, by_ - 3.5, by_ + 3.5, P.BOSS_END_Z, P.TOP_BOSS_TOP_Z))
        bosses.append(_dist(bat, boss))
    out["battery_vs_top_bosses"] = bosses
    out["battery_vs_back_plate_ribs_xy"] = round(P.RIB_GAP, 3)
    out["battery_vs_screen_back"] = round(P.SCR_Z0 - (P.SPLIT_Z + P.BAT_404050[2]), 3)
    out["battery_plug_vs_screen"] = _dist(by["battery plug PHR-2"], by["screen body"])
    out["battery_plug_vs_front_shell"] = _dist(by["battery plug PHR-2"], shell)
    # Button cap and SW1.
    cap = by["button cap"]
    sw1 = board["SW1"]
    out["cap_vs_sw1_rest"] = _dist(cap, sw1)
    pressed = cap.translate(cq.Vector(-P.CAP_STOP, 0, 0))
    vol = pressed.intersect(sw1).Volume()
    tip = pressed.BoundingBox()
    flange_only = pressed.intersect(box(0, P.X_IN - P.CAP_STOP, -30, 0, -10, 0))
    out["cap_pressed_to_stop"] = {
        "travel": P.CAP_STOP,
        "plunger_past_actuator_rest_tip": round(P.CAP_STOP - P.CAP_REST_GAP, 3),
        "switch_travel": P.SB["travel"],
        "overlap_with_static_switch_model_mm3": round(vol, 3),
        "flange_to_sw1_body": _dist(flange_only.cut(box(P.SB_TIP[0] - 1.5, 40, P.SB_TIP[1] - 1.3, P.SB_TIP[1] + 1.3, -10, 0)), sw1),
        "cap_x_min_at_stop": round(tip.xmin, 3),
    }
    # Posts against parts around each pad.
    plate = by["back plate"]
    posts = {}
    for pp in P.PADS:
        px, py = pp["centre"]
        post = plate.intersect(box(px - 3, px + 3, py - 3, py + 3, P.SPLIT_Z + 0.01, 0))
        best = None
        for ref, s in board.items():
            if ref == "PCB" or _bb_gap(_bb(post), _bb(s)) > 3:
                continue
            d = _dist(post, s)
            if d is not None and (best is None or d < best[1]):
                best = (ref, d)
        posts[pp["ref"]] = {"nearest_part": best[0] if best else None, "clearance": best[1] if best else None}
    out["press_posts_vs_parts"] = posts
    # LED shroud.
    tube = plate.intersect(box(P.LED_X - 2, P.LED_X + 2, -50, -46, P.SPLIT_Z + 0.01, 0))
    out["led_shroud"] = {r: _dist(tube, board[r]) for r in ("LED1", "J1", "J3", "R8")}
    # Locating pins in the holes.
    pins = {}
    for h in P.HOLES:
        hx, hy = h["centre"]
        pin = shell.intersect(box(hx - 1, hx + 1, hy - 1, hy + 1, P.PIN_TIP_Z - 0.1, -P.SKIN - 0.001))
        pins[h["ref"]] = {"pcb": _dist(pin, board["PCB"]),
                          "radial_clearance": round((h["diameter"] - P.PIN_D) / 2, 3)}
        best = None
        for ref, s in board.items():
            if ref == "PCB" or _bb_gap(_bb(pin), _bb(s)) > 3:
                continue
            d = _dist(pin, s)
            if d is not None and (best is None or d < best[1]):
                best = (ref, d)
        pins[h["ref"]]["nearest_part"] = best
    out["locating_pins"] = pins
    # Touch-side protrusions against the skin and the disc.
    legs = [s for n, s in by.items() if n.startswith("board J1 leg")]
    out["j1_legs_vs_skin"] = min(_dist(l, shell) for l in legs)
    out["j1_legs_vs_disc"] = min(_dist(l, by["wheel disc"]) for l in legs)
    out["disc_vs_shell"] = _dist(by["wheel disc"], shell)
    out["motor_vs_board_parts"] = min(_dist(by["motor"], s) for r, s in board.items() if r != "PCB" and _bb_gap(_bb(by["motor"]), _bb(s)) < 4)
    out["screen_vs_top_bosses"] = round(P.SCR_Z0 - P.TOP_BOSS_TOP_Z, 3)
    out["screen_vs_front_shell_lateral"] = P.SCR_CLEAR
    return out


# ------------------------------------------------------------------ printability
def mesh(shape, tol=0.02, ang=0.15):
    import trimesh
    v, f = shape.tessellate(tol, ang)
    m = trimesh.Trimesh(np.array([(p.x, p.y, p.z) for p in v]), np.array(f), process=True)
    m.merge_vertices()
    return m


def wall_thickness(shape, spacing=0.35, limit=0.8):
    """Ray-cast inward from points on the surface; report spots thinner than limit."""
    import trimesh
    m = mesh(shape)
    n = int(m.area / (spacing * spacing))
    pts, fid = trimesh.sample.sample_surface_even(m, n, seed=1)
    # leave out the 1.0 edge rounds on the outer outline (not walls)
    import cadquery as cq
    keep = []
    for i, p in enumerate(pts):
        ax, ay = abs(p[0]), abs(p[1])
        dx = ax - (P.X_OUT - P.CORNER_R)
        dy = ay - (P.Y_OUT - P.CORNER_R)
        if dx > 0 and dy > 0:
            d_out = P.CORNER_R - math.hypot(dx, dy)
        else:
            d_out = min(P.X_OUT - ax, P.Y_OUT - ay)
        on_round = d_out < P.EDGE_ROUND + 0.05 and (p[2] > -P.EDGE_ROUND - 0.05 or p[2] < -P.T + P.EDGE_ROUND + 0.05)
        keep.append(not on_round)
    keep = np.array(keep)
    pts, fid = pts[keep], fid[keep]
    n = len(pts)
    nrm = m.face_normals[fid]
    origins = pts - nrm * 1e-3
    dirs = -nrm
    locs, ray_idx, tri_idx = m.ray.intersects_location(origins, dirs, multiple_hits=False)
    thick = np.full(len(pts), np.inf)
    for loc, ri, ti in zip(locs, ray_idx, tri_idx):
        if np.dot(m.face_normals[ti], nrm[ri]) > -0.9:
            continue  # exit through a face that is not opposite: an edge, not a wall
        d = np.linalg.norm(loc - origins[ri])
        thick[ri] = min(thick[ri], d)
    thin = np.where(thick < limit - 0.02)[0]
    clusters = []
    if len(thin):
        from scipy.sparse.csgraph import connected_components
        from scipy.spatial import cKDTree
        tree = cKDTree(pts[thin])
        pairs = tree.query_pairs(1.0, output_type="ndarray")
        import scipy.sparse as sp
        g = sp.coo_matrix((np.ones(len(pairs)), (pairs[:, 0], pairs[:, 1])), shape=(len(thin), len(thin)))
        k, lab = connected_components(g, directed=False)
        for c in range(k):
            idx = thin[lab == c]
            p = pts[idx]
            j = idx[np.argmin(thick[idx])]
            clusters.append({"min": round(float(thick[idx].min()), 3), "points": int(len(idx)),
                             "min_at": [round(float(v), 2) for v in pts[j]],
                             "centre": [round(float(v), 2) for v in p.mean(axis=0)],
                             "bbox": [round(float(v), 2) for v in (p[:, 0].min(), p[:, 0].max(), p[:, 1].min(),
                                                                   p[:, 1].max(), p[:, 2].min(), p[:, 2].max())]})
        clusters.sort(key=lambda c: c["min"])
    finite = thick[np.isfinite(thick)]
    return {"samples": int(n), "min": round(float(finite.min()), 3) if len(finite) else None, "thin_spots": clusters}


def overhangs(shape_device, pose, angle=45.0, bed_skip=0.3):
    """Down-facing areas steeper than `angle` from vertical, in print orientation.
    Centres are also given back in device coordinates."""
    import export
    shape_print = export.print_pose(shape_device, pose)
    b = shape_device.BoundingBox()
    flip = pose == "flip"
    if flip:
        rx = (b.xmin + b.xmax) / 2
        ry = (-b.ymax + -b.ymin) / 2
        rz = -b.zmax
    else:
        rx, ry, rz = (b.xmin + b.xmax) / 2, (b.ymin + b.ymax) / 2, b.zmin

    def to_device(p):
        q = (p[0] + rx, p[1] + ry, p[2] + rz)
        return (q[0], -q[1], -q[2]) if flip else q
    m = mesh(shape_print, tol=0.02, ang=0.1)
    nz = m.face_normals[:, 2]
    zc = m.triangles_center[:, 2]
    lim = -math.cos(math.radians(90 - angle)) - 1e-3   # normal z below -sin(45)
    sel = np.where((nz < lim) & (zc > bed_skip))[0]
    out = []
    if len(sel):
        import trimesh
        sub = m.submesh([sel], append=True)
        comps = trimesh.graph.connected_components(sub.face_adjacency, min_len=1,
                                                   nodes=np.arange(len(sub.faces)), engine="scipy")
        for comp in comps:
            comp = np.asarray(comp)
            a = float(sub.area_faces[comp].sum())
            if a < 0.05:
                continue
            tc = sub.triangles_center[comp]
            c = (tc * sub.area_faces[comp][:, None]).sum(axis=0) / a
            v = sub.vertices[np.unique(sub.faces[comp])]
            nzc = sub.face_normals[comp][:, 2]
            out.append({"area_mm2": round(a, 2), "centre_print": [round(float(q), 2) for q in c],
                        "centre_device": [round(float(q), 2) for q in to_device(c)],
                        "z_print": [round(float(v[:, 2].min()), 2), round(float(v[:, 2].max()), 2)],
                        "size_xy": [round(float(np.ptp(v[:, 0])), 2),
                                    round(float(np.ptp(v[:, 1])), 2)],
                        "max_angle_from_vertical": round(float(np.degrees(np.arcsin(np.clip(-nzc, -1, 1))).max()), 1)})
        out.sort(key=lambda r: -r["area_mm2"])
    return out


def dimensions(solids):
    by = {it["name"]: it["shape"] for it in solids}
    case = by["front shell"].fuse(by["back plate"])
    b = case.BoundingBox()
    pol = by["screen front polarizer"].BoundingBox()
    margin = (51.46 - 48.96) / 2   # vendor drawing: POL 51.46, AA 48.96, concentric
    aa = (pol.xmin + margin, pol.xmax - margin, pol.ymin + margin, pol.ymax - margin)
    win_x = P.AA_X + P.WIN_MARGIN
    win = (-win_x, win_x, P.AA_Y0 - P.WIN_MARGIN, P.AA_Y1 + P.WIN_MARGIN)
    # measure the window from the shell: probe the skin on the window centre lines
    shell = by["front shell"]

    def edge(x0, y0, dx, dy):
        x, y = x0, y0
        while not shell.isInside(cq.Vector(x, y, -0.7), 1e-4):
            x += dx
            y += dy
            if abs(x) > 40 or abs(y) > 60:
                return None
        return (x - dx / 2, y - dy / 2)
    cy = (win[2] + win[3]) / 2
    mx0 = edge(0, cy, -0.005, 0)[0]
    mx1 = edge(0, cy, 0.005, 0)[0]
    my0 = edge(0, cy, 0, -0.005)[1]
    my1 = edge(0, cy, 0, 0.005)[1]
    return {
        "outline_x": round(b.xmax - b.xmin, 3), "outline_y": round(b.ymax - b.ymin, 3),
        "thickness": round(b.zmax - b.zmin, 3), "z_range": [round(b.zmin, 3), round(b.zmax, 3)],
        "active_area_from_step": [round(v, 3) for v in aa],
        "active_area_spec": [-P.AA_X, P.AA_X, P.AA_Y0, P.AA_Y1],
        "window_measured_at_z-0.7": [round(v, 3) for v in (mx0, mx1, my0, my1)],
        "aa_centre": [round((aa[0] + aa[1]) / 2, 3), round((aa[2] + aa[3]) / 2, 3)],
        "window_centre": [round((mx0 + mx1) / 2, 3), round((my0 + my1) / 2, 3)],
        "centre_offset": [round((mx0 + mx1) / 2 - (aa[0] + aa[1]) / 2, 3), round((my0 + my1) / 2 - (aa[2] + aa[3]) / 2, 3)],
    }


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=1)
