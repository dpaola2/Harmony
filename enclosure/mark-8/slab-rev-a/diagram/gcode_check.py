"""Heights of key features in the sliced P2S plate (print/mark8-slab-p2s.gcode.3mf).

Reads the G-code inside the 3MF (nothing is extracted to disk) and finds, for
points on the parts, which layers have extrusion there. Where each part sits on
the plate comes from the 3MF itself: each build item's transform, its component
transform and the bounding box of its mesh. The mesh is matched to a printed
part by its height, and device coordinates are mapped onto the plate through
the part's print pose (the front shell is printed face down, turned 180 degrees
about X; the other parts keep their orientation). Device bounding boxes come
from measurements.json. Writes gcode-check.json.
"""
import json
import math
import os
import re
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
GC3MF = os.path.join(os.path.dirname(HERE), "print", "mark8-slab-p2s.gcode.3mf")


def _tf(t):
    v = [float(x) for x in t.split()]
    return v[9], v[10], v[11]


def placements(z, parts):
    """{part key: (mapper, info)}: mapper(x, y) gives plate X, Y for a device point."""
    model = z.read("3D/3dmodel.model").decode("utf-8", "ignore")
    comps = {}
    for om in re.finditer(r'<object id="(\d+)"[^>]*>(.*?)</object>', model, re.S):
        cm = re.search(r'<component p:path="([^"]+)"[^>]*transform="([^"]+)"', om.group(2))
        if cm:
            comps[om.group(1)] = (cm.group(1).lstrip("/"), _tf(cm.group(2)))
    items = re.findall(r'<item objectid="(\d+)"[^>]*transform="([^"]+)"', model)
    pose = {"front_shell": (1, -1, -1), "back_plate": (1, 1, 1), "wheel_disc": (1, 1, 1), "button_cap": (1, 1, 1)}
    dev = {p["key"]: p["bbox"] for p in parts if p["key"] in pose}
    out = {}
    for oid, t in items:
        if oid not in comps:
            continue
        path, ct = comps[oid]
        txt = z.read(path).decode("utf-8", "ignore")
        vs = re.findall(r'<vertex x="([-\d.eE+]+)" y="([-\d.eE+]+)" z="([-\d.eE+]+)"', txt)
        xs = [float(a) for a, _, _ in vs]
        ys = [float(b) for _, b, _ in vs]
        zs = [float(c) for _, _, c in vs]
        mmin = (min(xs), min(ys), min(zs))
        mh = max(zs) - min(zs)
        key = min(dev, key=lambda k: abs((dev[k][5] - dev[k][4]) - mh) + 0.01 * abs((dev[k][3] - dev[k][2]) - (max(ys) - min(ys))))
        sx, sy, sz = pose[key]
        b = dev[key]
        pmin = (min(sx * b[0], sx * b[1]), min(sy * b[2], sy * b[3]), min(sz * b[4], sz * b[5]))
        it = _tf(t)
        off = tuple(it[i] + ct[i] + mmin[i] - pmin[i] for i in range(3))

        def mapper(x, y, sx=sx, sy=sy, off=off):
            return off[0] + sx * x, off[1] + sy * y
        out[key] = (mapper, {"object": oid, "mesh": path, "item_translation": [round(v, 3) for v in it],
                             "mesh_height": round(mh, 3), "plate_offset": [round(v, 3) for v in off]})
    return out


def segments():
    z = zipfile.ZipFile(GC3MF)
    model = z.read("3D/3dmodel.model").decode("utf-8", "ignore")
    items = re.findall(r'<item objectid="(\d+)"[^>]*transform="([^"]+)"', model)
    text = z.read("Metadata/plate_1.gcode").decode("utf-8", "ignore")
    zc = 0.0
    x = y = 0.0
    segs = []
    for ln in text.splitlines():
        if ln.startswith("; Z_HEIGHT:"):
            zc = float(ln.split(":")[1])
            continue
        if ln[:3] in ("G1 ", "G0 ", "G2 ", "G3 "):
            d = dict(re.findall(r"([XYZEF])([-\d.]+)", ln.split(";")[0]))
            nx, ny = float(d.get("X", x)), float(d.get("Y", y))
            if "E" in d and float(d["E"]) > 0 and not ln.startswith("G0"):
                segs.append((zc, x, y, nx, ny))
            x, y = nx, ny
    return segs, items


def _segd(px, py, x0, y0, x1, y1):
    dx, dy = x1 - x0, y1 - y0
    L2 = dx * dx + dy * dy
    t = 0 if L2 == 0 else max(0.0, min(1.0, ((px - x0) * dx + (py - y0) * dy) / L2))
    return math.hypot(px - x0 - t * dx, py - y0 - t * dy)


def layers_at(segs, X, Y, r):
    out = set()
    for zz, x0, y0, x1, y1 in segs:
        if _segd(X, Y, x0, y0, x1, y1) <= r:
            out.add(round(zz, 2))
    return sorted(out)


MAP = {}


def shell(x, y):
    return MAP["front_shell"](x, y)


def plate(x, y):
    return MAP["back_plate"](x, y)


def gaps(zs):
    """Open bands between extruded layers: list of (bottom height, top height)."""
    out = []
    for a, b in zip(zs[:-1], zs[1:]):
        if b - a > 0.21:
            out.append((round(a, 2), round(b - 0.2, 2)))
    return out


def run():
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    segs, items = segments()
    pl = placements(zipfile.ZipFile(GC3MF), m["parts"])
    for k, (fn, info) in pl.items():
        MAP[k] = fn
    s = 1 / math.sqrt(2)
    out = {"file": "print/mark8-slab-p2s.gcode.3mf", "build_items": items, "segments": len(segs),
           "placements": {k: info for k, (fn, info) in pl.items()}}
    top = {}
    for name, (bx, by) in (("boss bottom left", (-24.7, -47.15)), ("boss top left", (-24.7, 47.15)),
                           ("boss bottom right", (24.7, -47.15)), ("boss top right", (24.7, 47.15))):
        sx, sy = (1 if bx < 0 else -1), (1 if by < 0 else -1)
        X, Y = shell(bx + sx * 2.1 * s, by + sy * 2.1 * s)
        top[f"shell {name} face"] = max(layers_at(segs, X, Y, 0.3))
    X, Y = shell(-28.5, 0.0)
    top["shell rim (side wall)"] = max(layers_at(segs, X, Y, 0.3))
    for pp, (px, py) in (("PP1", (-24.9, -33.0)), ("PP2", (-3.6, -30.7)), ("PP3", (6.2, -31.0)), ("PP4", (6.8, -21.4))):
        X, Y = plate(px, py)
        top[f"plate post {pp} tip"] = max(layers_at(segs, X, Y, 1.2))
    X, Y = plate(-24.7 + 2.4 * s, -47.15 + 2.4 * s)
    top["plate screw pad"] = max(layers_at(segs, X, Y, 0.2))
    X, Y = plate(-5.83 + 0.72, -48.0)
    top["plate LED tube tip"] = max(layers_at(segs, X, Y, 0.15))
    X, Y = shell(-12.0, -11.4)
    top["shell pin H1 tip"] = max(layers_at(segs, X, Y, 0.3))
    out["top_layer_height"] = top
    opn = {}
    for name, (x, y) in (("USB-C opening (x 0, y -50.5)", (0.0, -50.5)), ("card slot (x -13.7, y -50.4)", (-13.7, -50.4)),
                         ("button slot (x 28.3, y -15.6)", (28.3, -15.6))):
        X, Y = shell(x, y)
        g = gaps(layers_at(segs, X, Y, 0.2))
        opn[name] = {"open_heights": g, "device_z": [[-a, -b] for a, b in g]}
    out["openings"] = opn
    hb = min(v for k, v in top.items() if k.startswith("shell boss"))
    hp = top["plate screw pad"]
    ht = min(v for k, v in top.items() if k.startswith("plate post"))
    hr = top["shell rim (side wall)"]
    plate_t = m["stack"]["back_plate_t"]
    board_face = m["stack"]["pcb"][0]
    z_o = -(hb + hp)
    # design heights from the STEP, for comparison: boss face and rim from the front; pads and post tips from the plate's outer face
    st, lv = m["stack"], m.get("levels", {})
    back = st["back_face_z"]
    out["design_heights"] = {"shell boss face": round(-lv.get("boss_face", m["bosses"]["bottom_left"]["boss_face_z"]), 2),
                             "shell rim": round(-st["shell_rim_z"], 2),
                             "plate screw pad": round(m["bosses"]["bottom_left"]["plate_pad_top_z"] - back, 2),
                             "plate post tip": round(m["posts_pins"]["posts"][0]["tip_z"] - back, 2),
                             "plate LED tube tip": round(m["led"]["tip_z"] - back, 2)}
    out["assembled"] = {
        "plate_outer_face_z": round(z_o, 2), "plate_inner_face_z": round(z_o + plate_t, 2), "shell_rim_z": -hr,
        "post_tip_z": round(z_o + ht, 2), "post_press_into_board": round(z_o + ht - board_face, 2),
        "case_thickness": round(-z_o, 2),
        "note": "pads seat on the boss faces; the plate inner face meets the rim at the same time when the two agree",
    }
    usb = opn["USB-C opening (x 0, y -50.5)"]["device_z"]
    if usb:
        j1 = m["usb"]["j1_shell_z"]
        out["assembled"]["usb_opening_z"] = usb[0]
        out["assembled"]["j1_gap_top"] = round(usb[0][0] - j1[1], 2)
        out["assembled"]["j1_gap_bottom"] = round(j1[0] - usb[0][1], 2)
    return out


if __name__ == "__main__":
    r = run()
    json.dump(r, open(os.path.join(HERE, "gcode-check.json"), "w"), indent=1)
    print(json.dumps(r["top_layer_height"], indent=1))
    print(json.dumps(r["openings"], indent=1))
    print(json.dumps(r["assembled"], indent=1))
