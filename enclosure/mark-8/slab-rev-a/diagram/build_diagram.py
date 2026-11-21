"""Rebuild the independent check and the diagrams for the Mark-8 slab rev A.

    cd enclosure/mark-8/slab-rev-a/diagram
    uv run --quiet --with cadquery==2.8.0 --with matplotlib --with pillow python build_diagram.py [steps]

Steps (all by default): measure, gcode, clearances, figures, doccheck, data.
Reads only the STEP files, the KiCad board file and mechanical-interface.json.
Writes only into this folder. The first run reads the STEP files once and
caches them as BREP in .cache/ (git-ignored by the case folder's .gitignore).
"""
import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

IMAGES = [
    ("exploded-isometric", "Exploded view: every part along the stacking axis in assembly order, with names and overall sizes"),
    ("stack-section", "Section along the long axis at x = 0: every layer's z and thickness, with the thinnest walls"),
    ("stack-section-across", "Section across at y = 20: screen, foam, planned pack, side ribs, lip and walls"),
    ("closeup-usb-c", "USB-C opening and J1: opening, port recess and the gaps around the receptacle shell"),
    ("closeup-microsd", "microSD slot and J3 with a 1.0 card at the drawing's card plane"),
    ("closeup-led-tube", "Charge LED light tube between J3 and J1"),
    ("closeup-side-button", "Side button cap and SW1: rest gap and travel stop"),
    ("closeup-fpc-j2", "Screen FPC tail, its fold and the end in J2"),
    ("closeup-screw-boss", "Screw boss with heat-set insert and M2 x 4 screw: engagement and bottoming"),
    ("closeup-board-edges-tabs", "Board edge to the walls, standoffs, notches and the three frame tabs with a 0.35 nub"),
    ("closeup-antenna-corner", "Antenna corner: keep-out, nearby metal and the FPC"),
    ("closeup-screen-corner", "Screen top corner against the side wall: the overlap that stops the screen seating"),
    ("closeup-battery-ydl403450", "Planned YDL 403450 pack in the case: fit, top rib conflict and lead path to J4"),
]


def git_info():
    repo = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
    try:
        br = subprocess.run(["git", "-C", repo, "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True).stdout.strip()
        ci = subprocess.run(["git", "-C", repo, "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
        return {"branch": br, "commit": ci}
    except Exception:  # noqa: BLE001
        return {}


def stack_rows(m, y):
    st = m["stack"]
    pk = y["nominal"]["bbox"]
    rows = [
        ("Front skin", st["skin"][1], st["skin"][0]),
        ("Wheel disc (in the skin)", st["disc"][1], st["disc"][0]),
        ("Board (touch side on the skin)", st["pcb"][1], st["pcb"][0]),
        (f"Board parts (tallest {st['lowest_board_part']})", st["pcb"][0], st["lowest_board_part_z"]),
        ("Screen", st["screen"][1], st["screen"][0]),
        ("Foam 0.5", st["foam"][1], st["foam"][0]),
        ("YDL 403450 pack (planned, on the foam)", pk[5], pk[4]),
        ("Room for swelling", pk[4], st["back_plate"][1]),
        ("Back plate", st["back_plate"][1], st["back_plate"][0]),
    ]
    out = [{"layer": a, "z_front": round(b, 3), "z_back": round(c, 3), "thickness": round(b - c, 3)} for a, b, c in rows]
    out.append({"layer": "Total", "z_front": st["front_face_z"], "z_back": st["back_face_z"], "thickness": st["total_thickness"]})
    return out


def data_json(m, cl, dc):
    y = cl["ydl_403450"]
    src = {"front_shell": "Printed", "wheel_disc": "Printed", "button_cap": "Printed", "screen": "DigiKey",
           "foam": "Bought", "fpc": "With the screen", "board": "JLCPCB", "battery": "Bought (YDL 403450 planned)",
           "motor": "LCSC C2759984", "inserts": "Bought", "back_plate": "Printed", "screws": "Bought"}
    parts = []
    for p in m["parts"]:
        row = {"item": p["item"], "name": p["label"], "size_mm": p.get("size_each") or p["size"], "material": p["material"],
               "source": src.get(p["key"], ""), "solids": p["solids"]}
        if p["key"] == "board":
            row["size_mm"] = p["size_bare"]
            row["size_with_parts_mm"] = p["size"]
        if p["key"] == "battery":
            row["name"] = "LiPo YDL 403450, 650 mAh, with JST PHR-2 plug (planned)"
            row["size_mm"] = [34.0, 52.0, 4.0]
            row["case_model_pack_mm"] = p["size_pack"]
        parts.append(row)
    pairs = cl["pairs"]
    feats = cl["features"]
    order = {"FAIL": 0, "TIGHT": 1, "NOT MEASURED": 2, "PASS": 3}
    crow = [{"where": f["feature"], "measured": f["measured"], "expected_min": f["expected_min"], "status": f["status"],
             "reason": f["reason"], "note": f["note"], "kind": "feature"} for f in feats]
    crow += [{"where": f"{r['a']} to {r['b']}", "measured": r["min_distance"], "overlap_mm3": r["overlap_mm3"],
              "expected_min": r["expected_min"], "status": r["status"], "reason": r["reason"], "note": r["note"], "kind": "pair"} for r in pairs]
    crow.sort(key=lambda r: (order.get(r["status"], 9), r["measured"] if r["measured"] is not None else 9))
    summ = {k: sum(1 for r in crow if r["status"] == k) for k in ("FAIL", "TIGHT", "PASS", "NOT MEASURED")}
    dsum = {k: sum(1 for r in dc if r["status"] == k) for k in ("DISAGREE", "AGREE", "CHANGED", "NOT MEASURED")}
    images = []
    for stem, cap in IMAGES:
        svg, png = os.path.join(HERE, stem + ".svg"), os.path.join(HERE, stem + ".png")
        images.append({"name": stem, "svg": stem + ".svg", "png": stem + ".png", "caption": cap,
                       "svg_bytes": os.path.getsize(svg) if os.path.exists(svg) else None,
                       "png_bytes": os.path.getsize(png) if os.path.exists(png) else None})
    # findings come from the FAIL and TIGHT rows of the clearance check, plus measured notes
    findings = []
    for r in crow:
        if r["status"] in ("FAIL", "TIGHT"):
            val = r["measured"]
            if r["kind"] == "pair" and r.get("overlap_mm3"):
                txt = f"overlap {r['overlap_mm3']:.3f} mm3"
            else:
                txt = "n/a" if val is None else f"{val:.3f}"
            findings.append({"status": r["status"], "where": r["where"],
                             "text": f"measured {txt}, expected at least {r['expected_min']:.2f} ({r['reason']})" + (f"; {r['note']}" if r["note"] else "")})
    bd = m["board"]
    off = bd["board_face_z_diff_range"]
    findings.append({"status": "NOTE", "where": "Board STEP vs mechanical-interface.json",
                     "text": f"All {bd['parts_compared']} parts match in x and y within {bd['parts_xy_max_diff']:.3f} and in body height within "
                             f"{max(abs(v) for v in bd['body_height_diff_range']):.3f}; in the STEP each part sits {abs(off[1]):.2f} to {abs(off[0]):.2f} "
                             "below the board face, deeper than the JSON z values."})
    fw = m.get("fpc_wing")
    if fw and fw["missing_width"] > 0.05:
        findings.append({"status": "NOTE", "where": "Screen FPC width",
                         "text": f"The vendor FPC is full width to x {fw['flat_wing_x_max']:.2f} beside its small part; the case model's routed FPC "
                                 f"stops at x {fw['model_wing_x_max']:.2f}. At the true width the wing is "
                                 f"{fw['full_wing_to_parts'].get('board SW2', 0):.2f} from SW2 and {fw['full_wing_to_keepout_x']:.2f} from the antenna keep-out."})
    fails = [f for f in findings if f["status"] == "FAIL"]
    tights = [f for f in findings if f["status"] == "TIGHT"]
    board_fail = [f for f in fails if "board" in f["where"].lower() or "J1" in f["where"] or "PCB" in f["where"]]
    if fails:
        verdict = (f"Not ready to print: {len(fails)} FAIL row(s): " + "; ".join(f["where"] for f in fails) + ".")
    else:
        verdict = "Ready to print by this check: no FAIL rows."
    if tights:
        verdict += f" {len(tights)} TIGHT row(s) to watch on the first print: " + "; ".join(f["where"] for f in tights) + "."
    verdict += (" The board fits the case: no board part fails a clearance, and its outline, holes and part positions match the JSON."
                if not board_fail else " Board-related FAIL rows: " + "; ".join(f["where"] for f in board_fail) + ".")
    return {
        "title": "Harmony Mark-8 slab rev A: exploded assembly and fit check",
        "verdict": verdict,
        "findings": findings,
        "generated": time.strftime("%Y-%m-%d %H:%M"),
        "repo": git_info(),
        "sources": ["enclosure/mark-8/slab-rev-a/step/*.step", "hardware/mark-8/slab-rev-a/board-device-coords.step",
                    "hardware/mark-8/slab-rev-a/harmony-mark8-slab.kicad_pcb", "hardware/mark-8/slab-rev-a/mechanical-interface.json",
                    "hardware/mark-8/slab-rev-a/reference/DLC-T2.7DDS1.step"],
        "parts": parts,
        "stack_up": stack_rows(m, y),
        "clearances": {"summary": summ, "rows": crow},
        "ydl_403450": y,
        "doc_check": {"summary": dsum,
                      "disagree": [r for r in dc if r["status"] == "DISAGREE"],
                      "rows": dc},
        "board_vs_json": {k: m["board"][k] for k in ("pcb_size", "outline_max_deviation_from_json", "parts_compared",
                                                       "parts_xy_max_diff", "top_z_diff_range", "board_face_z_diff_range",
                                                       "body_height_diff_range", "changed_parts", "locating_holes")},
        "print_files": m["print_files"],
        "sliced_plate": json.load(open(os.path.join(HERE, "gcode-check.json"))) if os.path.exists(os.path.join(HERE, "gcode-check.json")) else None,
        "images": images,
    }


def main(steps):
    t0 = time.time()

    def log(s):
        print(f"[{time.time() - t0:6.1f}s] {s}", flush=True)

    if "measure" in steps:
        import measure
        mm = measure.measure_all()
        json.dump(mm, open(os.path.join(HERE, "measurements.json"), "w"), indent=1)
        log("measurements.json")
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    if "gcode" in steps or "clearances" in steps:
        import gcode_check
        json.dump(gcode_check.run(), open(os.path.join(HERE, "gcode-check.json"), "w"), indent=1)
        log("gcode-check.json")
    if "clearances" in steps:
        import clearances
        rows, feats, y = clearances.run(m)
        json.dump({"pairs": rows, "features": feats, "ydl_403450": y}, open(os.path.join(HERE, "clearances.json"), "w"), indent=1)
        clearances.write_md(rows, feats, os.path.join(HERE, "clearances.md"), y, m)
        log("clearances.json, clearances.md")
    cl = json.load(open(os.path.join(HERE, "clearances.json")))
    if "figures" in steps:
        import exploded
        import fig_closeups
        import fig_stack
        exploded.labels_and_save(m["parts"])
        fig_stack.long_section(m, cl["ydl_403450"])
        fig_stack.cross_section(m, cl["ydl_403450"])
        for name in fig_closeups.ALL:
            f = getattr(fig_closeups, name)
            f(m, cl["ydl_403450"]) if name == "battery" else f(m)
        log("figures")
    if "doccheck" in steps:
        import doc_check
        doc_check.run()
        log("doc-check.md")
    dc = json.load(open(os.path.join(HERE, "doc-check.json")))
    if "data" in steps:
        json.dump(data_json(m, cl, dc), open(os.path.join(HERE, "data.json"), "w"), indent=1)
        log("data.json")


if __name__ == "__main__":
    main(sys.argv[1:] or ["measure", "gcode", "clearances", "figures", "doccheck", "data"])
