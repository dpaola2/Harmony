"""Exact minimum distance for every pair of parts within 1.0 mm in the
assembled position, with the expected minimum and PASS, TIGHT or FAIL.

Pairs inside one bought part are skipped (board part to board part, screen
layer to screen layer, the FPC to itself or to the screen it belongs to).
The planned YDL 403450 pack is added as its own solid (ydl.py).

Rules for the expected minimum:
* printed (FDM) against a rigid or bought part: 0.30
* printed against printed (sliding fits): 0.15
* bought rigid parts placed by different printed features: 0.20
* the FPC (flexible) against anything: 0.10
* a smaller value given with a reason in the case documents replaces these
* designed face contacts, press fits, mated or inserted parts are checked as such

PASS: meets the expected minimum, or the designed contact or fit is as designed.
TIGHT: a gap that is positive but under the expected minimum.
FAIL: an overlap or touch where a gap is needed, or a designed fit off by more than 0.03.
"""
import json
import math
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import common as C  # noqa: E402
import load  # noqa: E402
import ydl  # noqa: E402

YDL = "battery YDL 403450 (planned)"
PRINTED = {"front shell", "back plate", "wheel disc", "button cap"}


def group(n):
    if n in PRINTED:
        return "printed"
    if n.startswith("board "):
        return "board"
    if n.startswith("screen ") and n != "screen FPC bonded end":
        return "screen"
    if n.startswith("FPC") or n == "screen FPC bonded end":
        return "fpc"
    if n.startswith("insert") or n.startswith("screw"):
        return "hw"
    if n == "battery foam":
        return "foam"
    if n == YDL:
        return "ydl"
    if n.startswith("battery"):
        return "battery"
    return n


def kind(n):
    g = group(n)
    if g == "printed":
        return "fdm"
    if g == "fpc" and n != "FPC part":
        return "flex"
    if n in ("battery wires",):
        return "flex"
    if g in ("foam",) or n in ("battery pack", YDL):
        return "soft"
    return "rigid"


def skip(a, b):
    ga, gb = group(a), group(b)
    if ga == gb and ga in ("board", "screen", "fpc"):
        return "same bought part"
    if {ga, gb} == {"screen", "fpc"}:
        return "the FPC is part of the screen"
    if {a, b} == {"battery pack", YDL}:
        return "alternative packs"
    return None


def pair_is(a, b, pa, pb):
    import fnmatch
    return (fnmatch.fnmatch(a, pa) and fnmatch.fnmatch(b, pb)) or (fnmatch.fnmatch(a, pb) and fnmatch.fnmatch(b, pa))


POST_PRESS = 0.20     # planned press of the back plate posts into PP1 to PP4 (case params POST_TIP_Z -1.6 on a -1.8 board face)

# (pattern a, pattern b, mode, expected, reason). mode: contact, press, joined, gap
RULES = [
    ("front shell", "board PCB", "contact", 0.0, "board touch side lies on the skin; side, pin, notch and standoff gaps are rows below"),
    ("front shell", "screen body", "contact", 0.0, "screen front rim lies on the skin; pocket 0.15 per side (README conflict 13)"),
    ("front shell", "screen *", "gap", 0.0, "screen layer, placed by the screen body"),
    ("wheel disc", "board PCB", "contact", 0.0, "disc back lies on L4"),
    ("wheel disc", "front shell", "contact", 0.0, "flange seats in the skin recess; 0.15 radial (README conflict 1)"),
    ("button cap", "front shell", "contact", 0.0, "ears rest on the wall inside face; slot 0.15 per side"),
    ("back plate", "front shell", "contact", 0.0, "plate inner face on the shell rim, pads on the bosses; lip 0.15 inside the walls"),
    ("back plate", "board PCB", "press", POST_PRESS, f"press posts on PP1 to PP4, {POST_PRESS} planned interference"),
    ("battery foam", "battery pack", "contact", 0.0, "case model's pack stuck on the foam"),
    ("back plate", "motor", "contact", 0.0, "motor glued in its seat"),
    ("back plate", "screw *", "contact", 0.0, "head seats in the counterbore"),
    ("back plate", "insert *", "contact", 0.0, "screw pad on the boss face, insert flush with it"),
    ("front shell", "insert *", "press", 0.10, "heat-set knurl 3.2 in a 3.0 hole, melts in (0.1 radial)"),
    ("insert 1", "screw 1", "joined", 0.0, "screw in the insert"),
    ("insert 2", "screw 2", "joined", 0.0, "screw in the insert"),
    ("insert 3", "screw 3", "joined", 0.0, "screw in the insert"),
    ("insert 4", "screw 4", "joined", 0.0, "screw in the insert"),
    ("battery foam", "screen body", "contact", 0.0, "foam stuck on the screen back"),
    ("battery foam", YDL, "contact", 0.0, "pack stuck on the foam (ASSEMBLY.md step 13)"),
    ("battery plug PHR-2", "board J4", "joined", 0.0, "plug mated in J4"),
    ("battery plug PHR-2", "battery wires", "joined", 0.0, "same cable"),
    ("FPC tail", "board J2", "joined", 0.0, "FPC end inserted into the J2 slot"),
    ("FPC *", "back plate", "contact", 0.0, "FPC lies on the plate and in the tail channel (model floats it 0.02)"),
    ("button cap", "board SW1", "gap", 0.12, "rest gap to the actuator tip (README conflict 6)"),
    ("front shell", "board J1 leg *", "gap", 0.10, "modelled solder 0.4 proud in a 0.5 relief (README conflict 3)"),
    ("wheel disc", "board J1 leg *", "gap", 0.10, "modelled solder 0.4 proud in a 0.5 disc pocket (README conflict 3)"),
    ("board J1 leg *", "board PCB", "joined", 0.0, "board model"),
    ("wheel disc", "board J1", "gap", 0.0, "J1 locating pegs end 0.25 inside their board holes, under the disc"),
]


def rule(a, b):
    for pa, pb, mode, exp, why in RULES:
        if pair_is(a, b, pa, pb):
            return mode, exp, why
    ka, kb = sorted([kind(a), kind(b)])
    if ka == kb == "fdm":
        return "gap", 0.15, "printed against printed"
    if "flex" in (ka, kb):
        return "gap", 0.10, "flexible part against a part"
    if "fdm" in (ka, kb):
        return "gap", 0.30, "printed against a bought part"
    return "gap", 0.20, "bought parts placed by different printed features"


def status(mode, exp, d, ov, depth):
    eps = 0.005
    if mode == "joined":
        return "PASS", "mated or inserted as designed"
    if mode == "press":
        if depth is None:
            return "FAIL", "no interference where a press fit is designed"
        if abs(depth - exp) <= 0.03:
            return "PASS", f"press fit {depth:.2f} as designed"
        return "FAIL", f"press fit {depth:.2f} instead of {exp:.2f}"
    if mode == "contact":
        if ov is not None and ov > 0.001:
            return "FAIL", f"overlap {ov:.3f} mm3 where only face contact is designed"
        if d <= 0.02 + eps:
            return "PASS", "face contact as designed"
        return "PASS", f"designed contact, model leaves {d:.2f}"
    if ov is not None and ov > 0.001:
        return "FAIL", f"overlap {ov:.3f} mm3"
    if d < 0.02 - eps and exp > 0:
        return "FAIL", "touching where a gap is needed"
    if d + eps >= exp:
        return "PASS", ""
    return "TIGHT", f"{d:.2f} is under {exp:.2f}"


BIG = {"front shell", "back plate", "wheel disc"}
THROUGH_EDGE = ("board J1", "board SW1")     # board parts that reach past the board outline


def _box(b, g):
    import cadquery as cq
    return cq.Solid.makeBox(b[1] - b[0] + 2 * g, b[3] - b[2] + 2 * g, b[5] - b[4] + 2 * g,
                            cq.Vector(b[0] - g, b[2] - g, b[4] - g))


def _clip(big_name, big, other_name, other_bb):
    """Part of a big printed solid that can come within 1.0 of the other part.
    For a board part on the component side, the skin and the disc on the other
    side of the 0.8 board are left out: the board lies between them."""
    import cadquery as cq
    b = list(other_bb)
    win = _box(b, 1.05)
    if other_name.startswith("board ") and other_name != "board PCB" and not other_name.startswith("board J1 leg") \
            and not other_name.startswith(THROUGH_EDGE) and big_name in ("front shell", "wheel disc"):
        win = win.intersect(cq.Solid.makeBox(200, 200, 50, cq.Vector(-100, -100, -1.801 - 50)))
    try:
        return big.intersect(win)
    except Exception:  # noqa: BLE001
        return big


def compute(A):
    names = [n for n in A]
    shapes = dict(A)
    shapes[YDL] = ydl.solid(A)
    names.append(YDL)
    bbs = {n: C.bb(shapes[n]) for n in names}
    rows = []
    t0 = time.time()
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            a, b = names[i], names[j]
            if skip(a, b):
                continue
            if C.bb_gap(bbs[a], bbs[b]) > 1.0:
                continue
            sa, sb = shapes[a], shapes[b]
            if a in BIG and b not in BIG:
                sa = _clip(a, sa, b, bbs[b])
            elif b in BIG and a not in BIG:
                sb = _clip(b, sb, a, bbs[a])
            if not sa.Solids() or not sb.Solids():
                continue
            d, p, q = C.dist(sa, sb)
            if d is None or d > 1.0:
                continue
            ov = depth = None
            ovb = None
            if d < 1e-4:
                ov, com = C.common(sa, sb)
                if ov and ov > 1e-4:
                    cb = C.bb(com)
                    ovb = [round(v, 3) for v in cb]
                    depth = min(cb[1] - cb[0], cb[3] - cb[2], cb[5] - cb[4])
            mode, exp, why = rule(a, b)
            st, note = status(mode, exp, d, ov, depth)
            rows.append({"a": a, "b": b, "min_distance": round(d, 3), "at": [round(v, 2) for v in p],
                         "overlap_mm3": None if ov is None else round(ov, 4),
                         "overlap_depth": None if depth is None else round(depth, 3), "overlap_bbox": ovb,
                         "mode": mode, "expected_min": exp, "reason": why, "status": st, "note": note,
                         "kinds": [kind(a), kind(b)]})
        print(f"[{time.time() - t0:6.1f}s] {a}: {len(rows)} rows", flush=True)
    return rows


def special_cases(rows, m):
    """Pairs the general rule gets wrong, fixed with the measured reason."""
    for r in rows:
        ab = {r["a"], r["b"]}
        if ab == {"front shell", "insert 1"} or (r["a"] == "front shell" and r["b"].startswith("insert")):
            # the knurl ring overlap has no thin bounding box; use the measured radial values
            rad = m["bosses"]["bottom_left"]["knurl_interference_radial"]
            r["overlap_depth"] = rad
            r["status"], r["note"] = ("PASS", f"knurl {rad:.2f} radial into the hole, as designed") if abs(rad - 0.1) <= 0.03 else ("FAIL", f"knurl {rad:.2f} radial")
        if ab == {"front shell", "screen body"} and r["overlap_mm3"] and r["overlap_mm3"] > 0.001:
            c = m["screen"]["top_corners"][0]["wall_into_screen_on_diagonal"]
            r["overlap_depth"] = c
            r["note"] = (f"the side walls' inner corner radius cuts into both top corners of the screen: "
                         f"{r['overlap_mm3']:.2f} mm3, {c:.2f} deep on the diagonal; the screen cannot seat")
    return rows


def feature_rows(m, y):
    """Clearances inside one pair (shell to board, shell to J1, and so on) that
    the pair minimum hides, from measure.py."""
    out = []

    def add(name, value, exp, why, kind_="gap", note=""):
        if value is None:
            out.append({"feature": name, "measured": None, "expected_min": exp, "reason": why, "status": "NOT MEASURED", "note": note})
            return
        if kind_ == "press":
            st = "PASS" if abs(value - exp) <= 0.03 else "FAIL"
        elif value < -0.0005:
            st = "FAIL"
        elif value + 0.005 >= exp:
            st = "PASS"
        elif value < 0.02:
            st = "FAIL"
        else:
            st = "TIGHT"
        out.append({"feature": name, "measured": round(value, 3), "expected_min": exp, "reason": why, "status": st, "note": note})

    e = m["edges"]
    left = min(r["left_gap"] for r in e["side_gaps"])
    right = min(r["right_gap"] for r in e["side_gaps"])
    add("Board edge to left wall (x -27.2 to -27.7)", left, 0.30, "printed wall against the board; design gap 0.5")
    add("Board edge to right wall (x 27.2 to 27.7)", right, 0.30, "printed wall against the board; design gap 0.5")
    for s in e["standoffs"]:
        add(f"Board bottom edge to standoff at x {s['x']}", s["gap_to_board_edge"], 0.10,
            "deliberate 0.1, takes the USB-C pull (README conflict 10, MECH-6)")
    gaps = [r["bottom_gap_at_z-2.3"] for r in e["bottom_top_gaps"] if r["bottom_gap_at_z-2.3"] is not None and r["x"] in (-5.0, 5.0, 0.0, -15.0, 17.0)]
    add("Board bottom edge to bottom wall, between standoffs", min(gaps) if gaps else None, 0.30, "printed wall against the board")
    tops = [r["top_gap_at_z-1.4"] for r in e["bottom_top_gaps"] if r["top_gap_at_z-1.4"] is not None and r["x"] in (-24.0, -20.9, 20.9, 23.5)]
    add("Board top edge to the screen lips", min(tops) if tops else None, 0.30, "printed lips against the board")
    for n in e["notches"]:
        add(f"Board notch to bottom boss at x {n['boss_x']}", n["gap"], 0.20, "deliberate 0.2 (README decision 3)")
    for t in e["frame_tabs"]:
        add(f"Frame tab {t['edge']} edge {t['range']}, filed flush, to the shell", t["filed_flush_to_shell"], 0.30,
            "printed wall against the board")
        add(f"Frame tab {t['edge']} edge {t['range']}, 0.35 nub left, to the shell", t["nub_0.35_to_shell"], 0.30,
            "printed wall against the board", note="ASSEMBLY.md says to file the nubs flush")
    for p in m["posts_pins"]["pins"]:
        add(f"Locating pin {p['ref']} in its hole (radial)", p["radial_clearance"], 0.075, "deliberate 0.075 radial for the tilted insertion (README conflict 10)")
        if p["nearest_parts"]:
            add(f"Locating pin {p['ref']} to nearest part ({p['nearest_parts'][0][0]})", p["nearest_parts"][0][1], 0.30, "printed against a bought part")
    for p in m["posts_pins"]["posts"]:
        add(f"Press post {p['ref']} into its pad", p["interference_with_pcb"], POST_PRESS, f"planned {POST_PRESS} interference", kind_="press")
        if p["nearest_parts"]:
            add(f"Press post {p['ref']} to nearest part ({p['nearest_parts'][0][0]})", p["nearest_parts"][0][1], 0.30, "printed against a bought part")
    s = m["screen"]
    add("Screen to pocket, left side", s["side_gap_left"], 0.15, "deliberate 0.15, screen registration (README conflict 13)")
    add("Screen to pocket, right side", s["side_gap_right"], 0.15, "deliberate 0.15, screen registration (README conflict 13)")
    add("Screen to pocket, top", s["top_gap"], 0.15, "deliberate 0.15, screen registration (README conflict 13)")
    add("Screen to the two lower lips", s["lip_gap"], 0.15, "deliberate 0.15, screen registration (README conflict 13)")
    for c in s["top_corners"]:
        cc = c.get("corner_clearance")
        if cc is None:
            cc = -c["wall_into_screen_on_diagonal"]
        add(f"Screen top corner at x {c['corner'][0]} to the pocket", cc, 0.15,
            "deliberate 0.15 pocket clearance (README conflict 13)",
            note=("negative: the wall is inside the screen corner" if cc < 0 else
                  f"wall left outside the corner {c.get('wall_outside_corner_on_diagonal')}"))
    add("Screen back to top bosses", s["screen_back_to_top_boss"], 0.30, "printed against a bought part")
    u = m["usb"]
    add("J1 shell to USB-C opening, top", u["gap_top"], 0.30, "printed against a bought part")
    add("J1 shell to USB-C opening, bottom", u["gap_bottom"], 0.30, "printed against a bought part")
    # the shell prints face down at 0.2 layers; a layer is solid or open as its mid-height is
    def printed_opening(z_top, z_bottom):
        d0, d1 = -z_top, -z_bottom
        p0 = 0.2 * math.ceil((d0 - 0.1) / 0.2 - 1e-9)
        p1 = 0.2 * math.floor((d1 - 0.1) / 0.2 + 1e-9) + 0.2
        return -p0, -p1
    gpath = os.path.join(HERE, "gcode-check.json")
    g = json.load(open(gpath)) if os.path.exists(gpath) else None
    if g and g.get("assembled", {}).get("usb_opening_z"):
        pt, pb = g["assembled"]["usb_opening_z"]
        src = "in the sliced G-code"
    else:
        pt, pb = printed_opening(u["opening_z"][1], u["opening_z"][0])
        src = "estimate for 0.2 layers"
    add(f"J1 shell to USB-C opening, top, as sliced ({src})", pt - u["j1_shell_z"][1], 0.30, "printed against a bought part",
        note=f"opening top face at z {pt:.2f}")
    add(f"J1 shell to USB-C opening, bottom, as sliced ({src})", u["j1_shell_z"][0] - pb, 0.30, "printed against a bought part",
        note=f"opening bottom face at z {pb:.2f}")
    if g:
        asm = g["assembled"]
        add("Press posts PP1 to PP4 into their pads, as sliced (G-code)", asm["post_press_into_board"], POST_PRESS,
            f"planned {POST_PRESS} interference", kind_="press",
            note=f"boss faces print at {min(v for k, v in g['top_layer_height'].items() if k.startswith('shell boss')):.1f}, "
                 f"post tips at {min(v for k, v in g['top_layer_height'].items() if k.startswith('plate post')):.1f}: "
                 f"the plate sits at z {asm['plate_outer_face_z']:.2f} and the tips end at z {asm['post_tip_z']:.2f}")
    add("J1 shell to USB-C opening, left", u["gap_left"], 0.30, "printed against a bought part")
    add("J1 shell to USB-C opening, right", u["gap_right"], 0.30, "printed against a bought part")
    for lr in u["leg_reliefs"]:
        add(f"J1 leg at {lr['leg_centre']} to the skin relief", lr["leg_to_shell"], 0.10, "deliberate 0.1 (README conflict 3)")
    sd = m["microsd"]
    for k, c in sd["cards"].items():
        why = "deliberate: the 1.8 slot covers both card height estimates (README conflict 5, MECH-5)"
        add(f"1.0 card at {k} to the slot, board side", c["margin_board_side"], 0.10, why,
            note=f"{c['printed_margin_board_side']:.2f} as sliced")
        add(f"1.0 card at {k} to the slot, back side", c["margin_back_side"], 0.10, why,
            note=f"{c['printed_margin_back_side']:.2f} as sliced")
    lt = m["led"]
    for r_ in ("LED1", "J1", "J3", "R8"):
        add(f"LED light tube to {r_}", lt[f"to_{r_}"], 0.30, "printed against a bought part")
    b = m["button"]
    add("Button cap plunger to SW1 tip at rest", b["rest_gap"], 0.12, "deliberate 0.12 (README conflict 6)")
    add("Button cap flange to SW1 body at the stop", b["flange_to_sw1_at_stop"], 0.10, "README conflict 6: flange thinned to stay clear at the stop")
    add("Button over-travel past the 0.2 switch travel at the stop", b["over_travel_vs_0.2"], 0.0,
        "README conflict 6: 0.1 margin for print tolerance", note="the switch bottoms before the cap stops")
    w = m["wheel"]
    add("Wheel disc to the skin opening (radial)", w["opening_radial_gap"], 0.15, "printed against printed")
    add("Disc flange to the recess wall (radial)", w["recess_radial_gap"], 0.15, "printed against printed")
    for tag in ("bottom_left", "top_left"):
        o = m["bosses"][tag]
        add(f"M2 x 4 screw tip to the insert hole bottom ({tag.replace('_', ' ')})", o["tip_to_hole_bottom"], 0.30, "printed against a bought part")
    f = m["fpc"]
    add("FPC tail to the bare board (S-curve under J2)", f["tail_to_pcb"], 0.10, "flexible part against a part")
    fw = m.get("fpc_wing")
    if fw:
        sw2 = fw["full_wing_to_parts"].get("board SW2")
        add(f"Screen FPC wing at its vendor width (x {fw['flat_wing_x_max']:.2f}, the case model stops at {fw['model_wing_x_max']:.2f}) to SW2",
            sw2, 0.10, "flexible part against a part", note="the case model's FPC is narrower than the vendor STEP here")
    ba = m["battery"]
    add("Battery plug to the screen edge", ba["plug_to_screen"], 0.20, "bought parts placed by different printed features",
        note="screen can move 0.15 toward it in its pocket and the board 0.075 on the pins")
    yy = y["nominal"]
    w_lo, w_hi = y["pack"]["window_from_screen_edge"]
    for tag, lab in (("nominal", f"nominal, near edge y {yy['near_edge_y']:.2f}"),
                     (f"window_{w_lo}", f"near edge {w_lo} from the screen edge"),
                     (f"window_{w_hi}", f"near edge {w_hi} from the screen edge")):
        yk = y[tag]
        ov = yk["back_plate_overlap_mm3"]
        add(f"YDL 403450 ({lab}) to the back plate", -1.0 if ov and ov > 0.001 else yk["to_back_plate"], 0.30,
            "printed against the pack", note=f"far end y {yk['far_edge_y']:.2f}, {yk['far_edge_to_lip_y']} to the lip in y; "
            f"near edge {yk['near_edge_to_bottom_rib']} from the bottom ribs" + (f"; overlap {ov:.3f} mm3" if ov and ov > 0.001 else ""))
    add("YDL 403450 (nominal) to the top bosses", min(yy["to_top_bosses"]), 0.30, "printed against the pack")
    if yy.get("top_rib_present"):
        add("YDL 403450 (nominal) far end past the top rib start", -(yy["far_edge_past_top_rib_start"] or 0), 0.30, "printed against the pack")
    add("YDL 403450 (nominal) to the back plate face", yy["to_back_plate_face_with_thick_screen_0.1"], 0.30,
        "swelling room with a +0.1 screen", note=f"{yy['to_back_plate_face']:.2f} nominal; screen 2.15 +-0.10")
    add("YDL 403450 lead reach, worst straight distance vs 50 mm lead", y["lead"]["lead_margin_worst"], 5.0,
        "lead must reach with routing slack", note="lead exit position on the pack end not known; worst of three")
    return out


def _sliced_note():
    gpath = os.path.join(HERE, "gcode-check.json")
    if not os.path.exists(gpath):
        return "- Sliced heights: gcode-check.json not found."
    g = json.load(open(gpath))
    t, a = g["top_layer_height"], g["assembled"]
    boss = sorted({v for k, v in t.items() if k.startswith("shell boss")})
    posts = sorted({v for k, v in t.items() if k.startswith("plate post")})
    txt = (f"- Sliced heights (gcode_check.py, read from {g['file']}): shell boss faces at {', '.join(f'{v:.1f}' for v in boss)}, "
           f"shell rim at {t['shell rim (side wall)']:.1f}; back plate screw pads at {t['plate screw pad']:.1f}, post tips at "
           f"{', '.join(f'{v:.1f}' for v in posts)}, LED tube tip at {t['plate LED tube tip']:.1f}. Assembled from these: back face z "
           f"{a['plate_outer_face_z']:.2f}, post tips at z {a['post_tip_z']:.2f}, press into the board {a['post_press_into_board']:.2f} "
           f"(planned {POST_PRESS}).")
    if a.get("usb_opening_z"):
        txt += f" The USB-C opening prints as z {a['usb_opening_z'][0]:.2f} to {a['usb_opening_z'][1]:.2f}: J1 has {a['j1_gap_top']:.2f} above and {a['j1_gap_bottom']:.2f} below."
    return txt


def write_md(rows, feats, path, y, m=None):
    order = {"FAIL": 0, "TIGHT": 1, "NOT MEASURED": 2, "PASS": 3}
    rows = sorted(rows, key=lambda r: (order[r["status"]], r["min_distance"]))
    feats = sorted(feats, key=lambda r: (order[r["status"]], r["measured"] if r["measured"] is not None else 9))
    nf = sum(1 for r in rows if r["status"] == "FAIL") + sum(1 for r in feats if r["status"] == "FAIL")
    nt = sum(1 for r in rows if r["status"] == "TIGHT") + sum(1 for r in feats if r["status"] == "TIGHT")
    L = ["# Clearances, Mark-8 slab rev A (independent check)", "",
         f"Generated by `diagram/build_diagram.py` from the STEP solids on 21 November 2026. "
         f"{len(rows)} part pairs come within 1.0 mm in the assembled position, and {len(feats)} feature rows measure gaps inside one pair. "
         f"Result: **{nf} FAIL, {nt} TIGHT**.", "",
         "Distances are exact (OCP BRepExtrema_DistShapeShape). Overlaps are exact booleans. "
         "The planned pack is the YDL 403450 (34 x 52 x 4.0), placed as ASSEMBLY.md step 13 says, on 0.5 foam. "
         "The case model's own pack is also listed.", "",
         "Expected minimum: 0.30 for a printed part against a rigid part, 0.15 for two printed parts, 0.20 for two bought parts, "
         "0.10 for the FPC. A smaller value from the case documents replaces these when the documents give a reason. "
         "TIGHT means a gap under the expected minimum. FAIL means an overlap or a touch where a gap is needed.", "",
         "## Feature gaps", "", "| Status | Where | Measured | Expected | Why | Note |", "| --- | --- | --- | --- | --- | --- |"]
    for r in feats:
        mv = "n/a" if r["measured"] is None else f"{r['measured']:.3f}"
        L.append(f"| {r['status']} | {r['feature']} | {mv} | {r['expected_min']:.3f} | {r['reason']} | {r['note']} |")
    yd = y["nominal"]
    ld = y["lead"]
    w_lo, w_hi = y["pack"]["window_from_screen_edge"]
    L += ["", "## Planned pack: YDL 403450 (34 x 52 x 4.0)", "",
          f"Placed as ASSEMBLY.md step 13 says, centred, on 0.5 foam (pack z {yd['bbox'][4]:.2f} to {yd['bbox'][5]:.2f}). "
          f"Nominal near edge y {yd['near_edge_y']:.2f} ({yd['near_edge_from_screen_edge']:.2f} from the screen's lower edge); "
          f"ASSEMBLY.md allows {w_lo} to {w_hi} mm, so both ends are checked too.", "",
          f"| Check | Nominal | {w_lo} from the screen edge | {w_hi} from the screen edge |", "| --- | --- | --- | --- |"]
    cols = [y["nominal"], y[f"window_{w_lo}"], y[f"window_{w_hi}"]]

    def row(label, key, f=lambda v: "n/a" if v is None else (f"{v:.2f}" if isinstance(v, (int, float)) else str(v))):
        return f"| {label} | " + " | ".join(f(c.get(key)) for c in cols) + " |"
    L += [row("Near edge y", "near_edge_y"), row("Far edge y", "far_edge_y"),
          row("Min distance to the back plate (lip, ribs, face)", "to_back_plate"),
          row("Overlap with the back plate, mm3", "back_plate_overlap_mm3"),
          row("Far edge to the lip, in y", "far_edge_to_lip_y"), row("Far edge to the top wall", "far_edge_to_top_wall"),
          row("Near edge to the bottom ribs, in y", "near_edge_to_bottom_rib"),
          row("Near edge to the battery plug, in y", "near_edge_to_plug"),
          "| Pack to the top bosses (left, right) | " + " | ".join(f"{c['to_top_bosses'][0]:.2f}, {c['to_top_bosses'][1]:.2f}" for c in cols) + " |",
          "| Pack to the top inserts / screws | " + " | ".join(
              f"{c['distances']['insert 3']['distance']:.2f} / {c['distances']['screw 3']['distance']:.2f}" for c in cols) + " |",
          row("Room behind the pack to the back plate face", "to_back_plate_face"),
          row("Same with a screen 0.10 thicker", "to_back_plate_face_with_thick_screen_0.1"),
          f"| Top rib on the back plate | {'present' if yd.get('top_rib_present') else 'none'} | | |",
          f"| Side ribs (x) | {y['side_ribs_x']} | | |",
          "", "Lead (50 mm) from the plug's wire exit to the pack's lead exit, nominal position. The lead exit position on the 34 end is not known, so three are checked.", "",
          "| Lead exit on the pack | Straight distance, flat | Path in the cable bay | Worst while the board tilts (0 to 30 deg) |", "| --- | --- | --- | --- |"]
    for k in ld["flat"]:
        worst = max(r[k] for pr in ld["tilt"].values() for r in pr)
        L.append(f"| {k} | {ld['flat'][k]:.1f} | {ld['bay_path_length'][k]:.1f} | {worst:.1f} |")
    L += ["", f"The plug's wire exit is at x {ld['plug_wire_exit'][0]:.2f}, {ld['plug_exit_left_of_fpc']:.2f} left of the FPC's left edge "
          f"(x {ld['fpc_left_edge_x']:.2f}). The FPC is below y {ld['fpc_top_y']:.2f}; the cable bay is y {ld['bay_y_range'][0]:.2f} to {ld['bay_y_range'][1]:.2f} "
          f"({ld['bay_width']:.2f} wide) on the screen back. A lead that leaves the plug toward +Y and runs in the bay does not cross the FPC.", ""]
    if m:
        L += ["## Notes", "",
              f"- Board STEP: every part sits 0.05 below the board face (its bottom at z {m['board']['board_face_z_diff_range'][0] - 1.8:.2f}, not -1.80), "
              "so each part top is 0.05 further back than mechanical-interface.json says. The distances above use the STEP.",
              _sliced_note(),
              "- The FPC route, fold and loop are the case model's construction (one plausible shape). Its clearances show the model, not a measured cable.",
              "- The battery plug is the case model's estimate from the J4 cavity.", ""]
    L += ["", "## Part pairs within 1.0 mm", "",
          "| Status | Part | Part | Min distance | Overlap mm3 | Expected | Rule | Note |", "| --- | --- | --- | --- | --- | --- | --- | --- |"]
    for r in rows:
        ov = "" if not r["overlap_mm3"] else f"{r['overlap_mm3']:.3f}"
        L.append(f"| {r['status']} | {r['a']} | {r['b']} | {r['min_distance']:.3f} | {ov} | {r['expected_min']:.2f} ({r['mode']}) | {r['reason']} | {r['note']} |")
    open(path, "w").write("\n".join(L) + "\n")


def run(m):
    A = load.assembly()
    y = ydl.check(A)
    key = f"{load._key(load.ASM_STEP)}-{ydl.W}-{ydl.L}-{ydl.T}-{ydl.NEAR_EDGE_Y}-{ydl.FOAM}"
    cpath = os.path.join(load.CACHE, "pairs.json")
    rows = None
    if os.path.exists(cpath):
        cached = json.load(open(cpath))
        if cached.get("key") == key:
            rows = cached["rows"]
            for r in rows:
                mode, exp, why = rule(r["a"], r["b"])
                r["mode"], r["expected_min"], r["reason"] = mode, exp, why
                r["status"], r["note"] = status(mode, exp, r["min_distance"], r["overlap_mm3"], r["overlap_depth"])
    if rows is None:
        rows = compute(A)
        json.dump({"key": key, "rows": rows}, open(cpath, "w"))
    rows = special_cases(rows, m)
    feats = feature_rows(m, y)
    return rows, feats, y


if __name__ == "__main__":
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    rows, feats, y = run(m)
    json.dump({"pairs": rows, "features": feats, "ydl_403450": y}, open(os.path.join(HERE, "clearances.json"), "w"), indent=1)
    write_md(rows, feats, os.path.join(HERE, "clearances.md"), y, m)
    print("wrote clearances.json and clearances.md")
