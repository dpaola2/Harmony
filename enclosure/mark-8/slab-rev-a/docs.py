"""Fill the generated tables in README.md and build ASSEMBLY.html.

README.md is written by hand. Text between <!-- auto:NAME --> and
<!-- /auto:NAME --> is replaced on every build, so the numbers always match
the CAD.
"""
import html
import math
import os
import re

import params as P

# ------------------------------------------------------------------ explanations


def _near(c, x, y, r):
    return math.hypot(c[0] - x, c[1] - y) <= r


def explain_thin(part, cl):
    """Say why a thin spot is there. cl is a cluster from checks.wall_thickness."""
    x, y, z = cl.get("min_at", cl["centre"])
    bb = cl["bbox"]
    rw = math.hypot(x - P.WC[0], y - P.WC[1])
    if part == "front shell":
        for bx, by in P.TOP_BOSSES:
            if _near((x, y), bx, by, 3.2) and z < -3.0:
                return "roof over the insert hole in a top boss, 0.5"
        if y < -49.9 and abs(x) <= P.USB_POCKET_W / 2 + 0.5:
            return "bottom wall behind the USB-C port recess, 0.7"
        if y < -49.9 and P.SD_SCALLOP_X[0] - 0.5 <= x <= P.SD_SCALLOP_X[1] + 0.5:
            return "bottom wall at the microSD scallop, 0.7"
        if bb[1] - bb[0] > 20 and z > -1.05:
            return "skin over the disc flange recess (0.6) and the USB-C leg reliefs (0.5), by design (brief items 1 and 3)"
        if z > -1.05 and (abs(abs(x) - (P.AA_X + P.WIN_MARGIN)) < 0.8 or abs(y - (P.AA_Y0 - P.WIN_MARGIN)) < 0.8
                          or abs(y - (P.AA_Y1 + P.WIN_MARGIN)) < 0.8):
            return "window edge: the 0.4 front chamfer leaves 0.6 at the edge"
        if x > P.X_IN - 0.5 and abs(y - P.SB_TIP[1]) < 4:
            return "right wall at the button slot"
        if y < P.BOARD_Y0 and any(abs(x - sx) < P.STANDOFF_W / 2 + 0.3 for sx in P.STANDOFF_X):
            return "chamfered edge of a bottom wall standoff"
    if part == "wheel disc":
        if _near((x, y), P.WC[0], P.WC[1] + P.LABEL_R, 4.5):
            return "ridges inside the debossed HOME letters (corners of M and E); they print slightly rounded"
        if rw > P.DISC_R - 0.3 or bb[1] - bb[0] > 30:
            return "flange and key tab, 0.4 by design (brief item 1)"
        if abs(rw - P.LABEL_R) < 3.5:
            return "under a debossed label, 0.6"
    if part == "button cap":
        if x < P.X_IN + 0.05:
            return "flange: 0.4 in front of SW1, 0.6 at the ears (space between SW1 and the wall)"
        return "head corners (0.6 round on the 0.7 head)"
    if part == "back plate":
        for bx, by in P.BOSSES:
            if _near((x, y), bx, by, 3.0):
                return "plastic under the screw head, 0.7"
        if _near((x, y), P.LED_X, P.LED["centre"][1], 1.6):
            if z > P.LED_NECK_Z - 0.05:
                return "LED light tube neck beside J1 and J3, 0.45 (MECH-2)"
            return "LED light tube base, 0.65"
        if _near((x, y), P.BZ["centre"][0], P.BZ["centre"][1], 3.0):
            return "web between buzzer slots, 0.8"
        if -13.7 <= x <= 19.5 and abs(y - P.J2_YC) < 3.0:
            return "plate under the FPC tail channel, 0.9"
    return "CHECK"


def explain_overhang(part, c):
    x, y, z = c
    if part == "front shell":
        if abs(x) <= P.USB_POCKET_W / 2 + 0.5 and y < -49.5:
            return "top of the USB-C opening and overmold pocket: short bridge"
        if P.SD_SCALLOP_X[0] - 0.5 <= x <= P.SD_SCALLOP_X[1] + 0.5 and y < -49.5:
            return "top of the microSD slot and scallop: short bridge, scallop is 46 deg at most"
        if x > P.X_IN - 0.5 and abs(y - P.SB_TIP[1]) < 4:
            return "top of the button slot and pocket: short bridge"
        for bx, by in P.TOP_BOSSES:
            if _near(c, bx, by, 4.5):
                return "top boss shelf over the screen corner: corner overhang about 3 mm"
        if abs(y - (P.AA_Y0 - P.WIN_MARGIN)) < 1 or abs(y - (P.AA_Y1 + P.WIN_MARGIN)) < 1 or abs(abs(x) - (P.AA_X + P.WIN_MARGIN)) < 1:
            return "window chamfer, 45 deg"
    if part == "back plate":
        for bx, by in P.BOSSES:
            if _near(c, bx, by, 3.0):
                return "ceiling of a screw counterbore: 0.9 wide ring, bridged"
    if part == "wheel disc":
        return "ceiling of a USB-C leg relief on the bed side: 2 x 3 bridge"
    return "CHECK"


# ------------------------------------------------------------------ tables
def _fmt(v, n=2):
    return "-" if v is None else f"{v:.{n}f}"


def t_interference(rows, refs, stats):
    fails = [r for r in rows if r["status"] != "ok"]
    out = [f"Pairs checked with exact solids: {stats.get('pairs_checked', '?')} "
           f"(bounding boxes overlap; board-to-board and screen-to-screen pairs skipped). "
           f"Tolerance {0.001} mm^3. Unintended overlaps: **{len(fails)}**.", ""]
    out += ["| Part | Part | Overlap mm^3 | Status | Why |", "| --- | --- | --- | --- | --- |"]
    for r in rows:
        out.append(f"| {r['a']} | {r['b']} | {_fmt(r['volume_mm3'], 3)} | {r['status']} | {r['intended'] or r.get('error') or ''} |")
    out += ["", "Face contacts that the check counts as touching (0 volume) are listed when they are planned.", "",
            "Reference solids (not built, checked against the case):", "",
            "| Solid | Size (mm) | Fits | Overlaps |", "| --- | --- | --- | --- |"]
    for r in refs:
        ov = ", ".join(f"{h['with']} {h['volume_mm3']}" for h in r["overlaps"]) or "none"
        out.append(f"| {r['solid']} | {' x '.join(str(v) for v in r['size'])} | {'yes' if r['fits'] else 'NO'} | {ov} |")
    return "\n".join(out)


def t_clearances(c):
    f = c["fpc_vs_board_parts"]
    cap = c["cap_pressed_to_stop"]
    lines = ["| Near miss | Clearance (mm) |", "| --- | --- |"]
    for r in f[:6]:
        lines.append(f"| {r['fpc']} to {r['part']} | {r['clearance']:.2f} |")
    lines += [
        f"| FPC to the board itself (under J2, at the S-curve top) | {c['fpc_vs_pcb']:.2f} |",
        f"| FPC to the front shell / back plate / disc | {c['fpc_vs_printed']['front shell']:.2f} / "
        f"{c['fpc_vs_printed']['back plate']:.2f} (floats 0.02 over the plate in the model) / {c['fpc_vs_printed']['wheel disc']:.2f} |",
        f"| FPC to the motor / battery / battery plug | {c['fpc_vs_battery_and_plug']['motor']:.2f} / "
        f"{c['fpc_vs_battery_and_plug']['battery 404050']:.2f} / {c['fpc_vs_battery_and_plug']['battery plug PHR-2']:.2f} |",
        f"| 404050 pack to the top bosses | {min(c['battery_vs_top_bosses']):.2f} |",
        f"| 404050 pack to the front shell (any feature) | {c['battery_vs_front_shell']:.2f} |",
        f"| 404050 pack to the back plate side ribs (each side) | {c['battery_vs_back_plate_ribs_xy']:.2f} |",
        f"| 404050 pack (4.0, on {c['battery_foam_thickness']} foam on the screen back) to the back plate | {c['battery_vs_back_plate']:.2f} (any feature: {_fmt(c['battery_vs_back_plate_solid'])}) |",
        f"| Battery plug to the screen / to the front shell lips | {c['battery_plug_vs_screen']:.2f} / {c['battery_plug_vs_front_shell']:.2f} |",
        f"| Button cap to SW1 at rest | {c['cap_vs_sw1_rest']:.2f} |",
        f"| Button cap at its stop ({cap['travel']} travel): plunger past the actuator rest tip | {cap['plunger_past_actuator_rest_tip']:.2f} (switch travel {cap['switch_travel']}) |",
        f"| Button cap flange to the SW1 body at the stop | {_fmt(cap['flange_to_sw1_body'])} |",
    ]
    for k, v in c["press_posts_vs_parts"].items():
        lines.append(f"| Press post {k} to {v['nearest_part']} | {v['clearance']:.2f} |")
    for k, v in c["led_shroud"].items():
        lines.append(f"| LED light tube to {k} | {v:.2f} |")
    for k, v in c["locating_pins"].items():
        lines.append(f"| Pin {k} in its hole (radial) | {v['radial_clearance']:.3f} |")
    lines += [f"| USB-C legs to the skin reliefs / to the disc pockets | {c['j1_legs_vs_skin']:.2f} / {c['j1_legs_vs_disc']:.2f} |",
              f"| Motor to the nearest board part | {c['motor_vs_board_parts']:.2f} |",
              f"| Screen back to the top bosses | {c['screen_vs_top_bosses']:.2f} |"]
    for r in c["bottom_standoffs"]:
        lines.append(f"| Bottom wall standoff at x {r['x']} to the board edge / to {r['nearest_part']} | "
                     f"{r['to_board_edge']:.2f} / {_fmt(r['nearest_part_clearance'])} |")
    for ref, r in c["reg5_parts"].items():
        if "error" in r:
            lines.append(f"| {ref} | {r['error']} |")
            continue
        f, k = r["nearest_fpc"] or ("FPC", None), r["nearest_case_or_bought_part"] or ("case", None)
        lines.append(f"| {ref} ({r['centre'][0]}, {r['centre'][1]}, {r['zone_json']}) to the {f[0]} / to the {k[0]} (behind the board) | "
                     f"{_fmt(f[1])} / {_fmt(k[1])} |")
    for r in c["frame_tabs"]:
        a, b = r["filed_flush"] or ("case", None), r["nub_0.35_left"] or ("case", None)
        lines.append(f"| Frame tab, {r['edge']} edge ({r['range'][0]} to {r['range'][1]}), to the {a[0]}: filed flush / 0.35 nub left | "
                     f"{_fmt(a[1])} / {_fmt(b[1])} |")
    sd = c["microsd_slot"]
    for k in ("drawing estimate", "JSON card plane"):
        r = sd[k]
        lines.append(f"| 1.0 card at the {k} (z {r['card_z'][0]} to {r['card_z'][1]}) to the slot, board side / back side | "
                     f"{r['margin_board_side']:.2f} / {r['margin_back_side']:.2f} |")
    t = c["battery_tilt_in"]
    for pv, d in t.items():
        m = d["min"]
        lines.append(f"| Board tilt-in with the plug in J4 (0 to 25 deg about the {pv}): plug to the screen / to the front shell | "
                     f"{m['battery plug PHR-2 to screen body'][0]:.2f} / {m['battery plug PHR-2 to front shell'][0]:.2f} |")
    return "\n".join(lines)


def t_printability(pr):
    out = ["| Part | Thinnest wall found | Spots under 0.8 | Where and why |", "| --- | --- | --- | --- |"]
    for part, d in pr.items():
        w = d["wall"]
        spots = w["thin_spots"]
        seen = {}
        for s in spots:
            why = explain_thin(part, s)
            if why not in seen or s["min"] < seen[why]:
                seen[why] = s["min"]
        why = "; ".join(f"{k} ({v:.2f})" for k, v in sorted(seen.items(), key=lambda kv: kv[1])) or "none"
        out.append(f"| {part} | {_fmt(w['min'])} | {len(spots)} | {why} |")
    out += ["", "| Part | Overhangs over 45 deg (print orientation, above the first 0.3) | Where and why |", "| --- | --- | --- |"]
    for part, d in pr.items():
        oh = d["overhangs"]
        groups = {}
        for o in oh:
            why = explain_overhang(part, o["centre_device"])
            g = groups.setdefault(why, [0.0, 0])
            g[0] += o["area_mm2"]
            g[1] += 1
        txt = "; ".join(f"{k}: {v[1]} areas, {v[0]:.1f} mm^2" for k, v in groups.items()) or "none"
        out.append(f"| {part} | {len(oh)} areas | {txt} |")
    return "\n".join(out)


def t_fpc(f):
    d, t = f["dive"], f["tail"]
    return "\n".join([
        "| Item | Value |", "| --- | --- |",
        f"| FPC centre line, flat (vendor STEP): exit to tail centre line (Y) / leg centre to tip (X) / total | "
        f"{f['flat_centre_line_y']:.2f} / {f['flat_centre_line_x']:.2f} / {f['flat_centre_line_total']:.2f} |",
        f"| Routed centre line, same three | {f['routed_centre_line_y']:.2f} / {f['routed_centre_line_x']:.2f} / {f['routed_centre_line_total']:.2f} |",
        f"| Exit from the screen | y {f['flat']['exit_y']}, z {f['flat']['mid_z']:.3f} (FPC mid plane) |",
        f"| Wide section | bends {d['phi_deg']:.1f} deg down in the single area (R {d['R1']}), runs straight {d['slant_len']:.2f} under the board, second bend (R {d['R2']}) lays the leg on the plate at y {d['y_on_plate']:.2f} |",
        f"| Tail centre line if the leg ran straight | y {f['tail_y_without_loop']:.2f} (J2 slot centre is y {P.J2_YC}) |",
        f"| **Slack along Y** | **{f['y_slack']:.2f}**, taken by one loop in the leg: R {d['loop_R']}, height {d['loop_height']:.2f}, from y {d['loop_y'][0]:.1f} to {d['loop_y'][1]:.1f} |",
        f"| **Fold** | fold starts at x {f['fold_start_x']:.2f}; fold apex x {f['fold_apex_x_mid']:.2f} (mid plane), {f['fold_apex_x_outer']:.2f} (outside); inner radius {P.FOLD_RI} |",
        f"| **Fold line measured from the tail end** | **{f['fold_from_tip_along_fpc']:.1f} mm** along the FPC from the contact end |",
        f"| Slack along X | {f['x_slack']:.1f}: the fold position takes up the X length exactly |",
        f"| Layers on the plate | first layer z {t['z_low'] - P.FPC_T / 2:.2f} to {t['z_low'] + P.FPC_T / 2:.2f} (in a 0.3 channel), folded layer z {t['z_up'] - P.FPC_T / 2:.2f} to {t['z_up'] + P.FPC_T / 2:.2f} |",
        f"| Rise to J2 | S-curve R {t['Rs']}, {t['theta_deg']:.0f} deg, from x {t['x_r']:.2f} to {t['x_m']:.2f}; flat for {t['x_m'] - t['x_tip']:.2f} (stiffener plus 0.2) into the slot; tip at x {t['x_tip']:.3f} ({P.FPC_INSERT} inside the mouth) |",
    ])


def t_battery(fit, refs):
    w, n = fit["wide"], fit["narrow"]
    lines = ["| Item | Value |", "| --- | --- |",
             f"| Height from the back plate to the screen back | {fit['z_space_total']:.2f} |",
             f"| Less the foam ({fit['foam']}) and the screen thickness tolerance ({fit['screen_tol']}): largest pack thickness | {fit['t_max']:.2f} |",
             f"| Largest pack, full width | {w[0]:.1f} x {w[1]:.2f} x {w[2]:.2f} (stops 0.3 short of the top bosses) |",
             f"| Largest pack, narrow enough to pass the top bosses | {n[0]:.1f} x {n[1]:.2f} x {n[2]:.2f} (stops 0.3 short of the back plate lip) |",
             f"| Pack lower edge | y {P.BAT_POCKET_Y0} (cable bay from the screen edge to here) |"]
    for r in refs:
        lines.append(f"| {r['solid']} | {'fits' if r['fits'] else 'does not fit: ' + ', '.join(h['with'] for h in r['overlaps'])} |")
    return "\n".join(lines)


def t_dims(d):
    return "\n".join([
        "| Check | Target | Measured |", "| --- | --- | --- |",
        f"| Outline X | 58.6 | {d['outline_x']:.3f} |",
        f"| Outline Y | 103.5 | {d['outline_y']:.3f} |",
        f"| Thickness T | {P.T} (9.5 in SPEC 2; whole 0.2 layers) | {d['thickness']:.3f} (z {d['z_range'][0]} to {d['z_range'][1]}) |",
        f"| Active area from the screen STEP (polarizer less 1.25) | SPEC x +-24.48, y -1.51 to 47.45 | x {d['active_area_from_step'][0]} to {d['active_area_from_step'][1]}, y {d['active_area_from_step'][2]} to {d['active_area_from_step'][3]} |",
        f"| Window in the skin (measured at z -0.7) | AA plus 0.3 | x {d['window_measured_at_z-0.7'][0]} to {d['window_measured_at_z-0.7'][1]}, y {d['window_measured_at_z-0.7'][2]} to {d['window_measured_at_z-0.7'][3]} |",
        f"| Active area centred in the window | within 0.1 | offset x {d['centre_offset'][0]:+.3f}, y {d['centre_offset'][1]:+.3f} |",
    ])


def t_files(here):
    rows = ["| File | Size | LFS |", "| --- | --- | --- |"]
    lfs = []
    for sub in ("step", "print", "renders", "checks"):
        d = os.path.join(here, sub)
        for fn in sorted(os.listdir(d)):
            p = os.path.join(d, fn)
            sz = os.path.getsize(p)
            big = (fn.endswith(".step") and sz > 1e6) or fn.endswith(".3mf") or (fn.endswith(".stl") and sz > 1e6)
            if big:
                lfs.append(f"enclosure/mark-8/slab-rev-a/{sub}/{fn}")
            rows.append(f"| {sub}/{fn} | {sz / 1e6:.2f} MB | {'yes' if big else ''} |")
    return "\n".join(rows), lfs


def _replace(text, name, body):
    pat = re.compile(rf"(<!-- auto:{name} -->)(.*?)(<!-- /auto:{name} -->)", re.S)
    if not pat.search(text):
        return text
    return pat.sub(lambda m: m.group(1) + "\n" + body + "\n" + m.group(3), text)


def write_all(here, solids, meta, rows, refs, clear, dims, pr, stats=None):
    with open(os.path.join(here, "checks", "printability.md"), "w") as f:
        f.write("# Printability notes (generated by build.py)\n\n" + t_printability(pr) + "\n")
    with open(os.path.join(here, "checks", "interference.md"), "w") as f:
        f.write("# Interference report (generated by build.py)\n\n" + t_interference(rows, refs, stats or {})
                + "\n\n## Clearances\n\n" + t_clearances(clear) + "\n")
    readme = os.path.join(here, "README.md")
    if os.path.exists(readme):
        with open(readme) as f:
            t = f.read()
        t = _replace(t, "interference", t_interference(rows, refs, stats or {}))
        t = _replace(t, "clearances", t_clearances(clear))
        t = _replace(t, "printability", t_printability(pr))
        t = _replace(t, "fpc", t_fpc(meta["fpc"]))
        t = _replace(t, "battery", t_battery(meta["battery_fit"], refs))
        t = _replace(t, "dims", t_dims(dims))
        files, lfs = t_files(here)
        t = _replace(t, "files", files)
        t = _replace(t, "lfs", "```\n" + "\n".join(f'"{p}" filter=lfs diff=lfs merge=lfs -text' for p in lfs) + "\n```")
        with open(readme, "w") as f:
            f.write(t)
    assembly_html(here)


CSS = """
body { font-family: -apple-system, Helvetica, Arial, sans-serif; max-width: 1000px; margin: 24px auto;
       padding: 0 16px; color: #111; background: #fff; line-height: 1.45; }
h1 { font-size: 24px; } h2 { font-size: 19px; margin-top: 28px; border-bottom: 1px solid #ccc; }
img { max-width: 100%; border: 1px solid #ddd; margin: 8px 0; }
table { border-collapse: collapse; margin: 8px 0; } td, th { border: 1px solid #bbb; padding: 4px 8px; font-size: 14px; }
code { background: #f2f2f2; padding: 0 3px; }
@media print { body { max-width: none; margin: 0; } h2 { page-break-after: avoid; } img { page-break-inside: avoid; } }
"""


def assembly_html(here):
    import markdown
    src = os.path.join(here, "ASSEMBLY.md")
    if not os.path.exists(src):
        return
    with open(src) as f:
        md = f.read()
    body = markdown.markdown(md, extensions=["tables"])
    page = ("<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
            "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            f"<title>Harmony Mark-8 slab assembly</title><style>{CSS}</style></head><body>{body}</body></html>")
    with open(os.path.join(here, "ASSEMBLY.html"), "w") as f:
        f.write(page)
    _ = html  # keep import for escapes in future edits
