"""Load the real 3D geometry for the independent check, in device coordinates.

Sources (nothing is taken from params.py):
* step/assembly.step: every part as the case model places it, with names (XCAF).
* step/front-shell.step, back-plate.step, wheel-disc.step, button-cap.step:
  the printed parts as exported; compared with the assembly copies.
* hardware/mark-8/slab-rev-a/board-device-coords.step: the assembled board.
  Its solids carry no reference names, so each top-level solid is matched to
  a KiCad footprint by its pads (harmony-mark8-slab.kicad_pcb), not by the
  JSON boxes the case code uses.
* hardware/mark-8/slab-rev-a/reference/DLC-T2.7DDS1.step: the vendor screen.

Everything is cached as BREP in diagram/.cache/ (git-ignored by the parent
.gitignore). Delete that folder to read the STEP files again.
"""
import json
import math
import os
import re

import cadquery as cq
from OCP.BRep import BRep_Builder
from OCP.BRepTools import BRepTools
from OCP.TopoDS import TopoDS_Iterator, TopoDS_Shape

HERE = os.path.dirname(os.path.abspath(__file__))
CASE = os.path.dirname(HERE)
REPO = os.path.abspath(os.path.join(CASE, "..", "..", ".."))
BOARD_DIR = os.path.join(REPO, "hardware", "mark-8", "slab-rev-a")
ASM_STEP = os.path.join(CASE, "step", "assembly.step")
PART_STEPS = {n: os.path.join(CASE, "step", f + ".step") for n, f in
              (("front shell", "front-shell"), ("back plate", "back-plate"),
               ("wheel disc", "wheel-disc"), ("button cap", "button-cap"))}
BOARD_STEP = os.path.join(BOARD_DIR, "board-device-coords.step")
SCREEN_STEP = os.path.join(BOARD_DIR, "reference", "DLC-T2.7DDS1.step")
KICAD_PCB = os.path.join(BOARD_DIR, "harmony-mark8-slab.kicad_pcb")
MI_PATH = os.path.join(BOARD_DIR, "mechanical-interface.json")
CACHE = os.path.join(HERE, ".cache")


def _key(path):
    st = os.stat(path)
    return f"{st.st_size}-{int(st.st_mtime)}"


def _write(shape, path):
    BRepTools.Write_s(shape, path)


def _read(path):
    sh = TopoDS_Shape()
    BRepTools.Read_s(sh, path, BRep_Builder())
    return cq.Shape.cast(sh)


def bbox(shape):
    b = shape.BoundingBox()
    return [b.xmin, b.xmax, b.ymin, b.ymax, b.zmin, b.zmax]


def mech():
    with open(MI_PATH) as f:
        return json.load(f)


# ------------------------------------------------------------------ assembly.step
def _read_xcaf(path):
    from OCP.STEPCAFControl import STEPCAFControl_Reader
    from OCP.TCollection import TCollection_ExtendedString
    from OCP.TDataStd import TDataStd_Name
    from OCP.TDF import TDF_Label, TDF_LabelSequence
    from OCP.TDocStd import TDocStd_Document
    from OCP.XCAFDoc import XCAFDoc_DocumentTool, XCAFDoc_ShapeTool

    doc = TDocStd_Document(TCollection_ExtendedString("XmlOcaf"))
    rd = STEPCAFControl_Reader()
    rd.SetNameMode(True)
    if rd.ReadFile(path) != 1:
        raise RuntimeError(f"cannot read {path}")
    rd.Transfer(doc)
    st = XCAFDoc_DocumentTool.ShapeTool_s(doc.Main())
    free = TDF_LabelSequence()
    st.GetFreeShapes(free)

    def name_of(lab):
        nm = TDataStd_Name()
        if lab.FindAttribute(TDataStd_Name.GetID_s(), nm):
            return nm.Get().ToExtString()
        return None

    out = []
    for i in range(free.Length()):
        root = free.Value(i + 1)
        comps = TDF_LabelSequence()
        XCAFDoc_ShapeTool.GetComponents_s(root, comps, False)
        for j in range(comps.Length()):
            c = comps.Value(j + 1)
            ref = TDF_Label()
            nm = None
            if XCAFDoc_ShapeTool.GetReferredShape_s(c, ref):
                nm = name_of(ref)
            nm = nm or name_of(c)
            shp = XCAFDoc_ShapeTool.GetShape_s(c)
            out.append((nm, shp))
    return out


PACK = "battery pack"          # canonical name for the case model's pack (the STEP names it by its size code)
PACK_MODEL = {"code": None}


def _canon(names_shapes):
    out = {}
    for n, s in names_shapes.items():
        m = re.match(r"^battery (\d{6})$", n)
        if m:
            PACK_MODEL["code"] = m.group(1)
            out[PACK] = s
        else:
            out[n] = s
    return out


def assembly():
    """{name: cq.Shape} from step/assembly.step, names as in the STEP with
    underscores turned back into spaces. The case model's pack ('battery
    404050' or similar) is renamed 'battery pack'."""
    return _canon(_assembly_raw())


def _assembly_raw():
    cdir = os.path.join(CACHE, "assembly")
    idx = os.path.join(cdir, "index.json")
    key = _key(ASM_STEP)
    if os.path.exists(idx):
        meta = json.load(open(idx))
        if meta.get("key") == key:
            return {e["name"]: _read(os.path.join(cdir, e["file"])) for e in meta["entries"]}
    os.makedirs(cdir, exist_ok=True)
    print("reading step/assembly.step (81 MB) ...", flush=True)
    entries = []
    seen = {}
    for i, (nm, shp) in enumerate(_read_xcaf(ASM_STEP)):
        nm = (nm or f"unnamed {i}").replace("_", " ")
        if nm in seen:
            seen[nm] += 1
            nm = f"{nm} #{seen[nm]}"
        else:
            seen[nm] = 1
        fn = f"a{i:03d}.brep"
        _write(shp, os.path.join(cdir, fn))
        entries.append({"name": nm, "file": fn})
    json.dump({"key": key, "entries": entries}, open(idx, "w"), indent=1)
    return _assembly_raw()


def printed_steps():
    """{name: cq.Shape} for the four printed-part STEP files."""
    out = {}
    cdir = os.path.join(CACHE, "printed")
    os.makedirs(cdir, exist_ok=True)
    for n, p in PART_STEPS.items():
        fn = os.path.join(cdir, n.replace(" ", "-") + "-" + _key(p) + ".brep")
        if not os.path.exists(fn):
            sh = cq.importers.importStep(p).val()
            _write(sh.wrapped, fn)
        out[n] = _read(fn)
    return out


# ------------------------------------------------------------------ KiCad footprints
def _blocks(text, head):
    """Yield the balanced s-expression blocks that start with `head`."""
    i = 0
    while True:
        i = text.find(head, i)
        if i < 0:
            return
        depth = 0
        j = i
        while j < len(text):
            ch = text[j]
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    break
            elif ch == '"':
                j = text.find('"', j + 1)
            j += 1
        yield text[i:j + 1]
        i = j + 1


def footprints():
    """KiCad footprints in device coordinates: ref, centre, side, pad box.
    device x = 150 - kicad x, device y = 70 - kicad y (mechanical-interface.json)."""
    text = open(KICAD_PCB).read()
    out = []
    for blk in _blocks(text, "(footprint "):
        lib = re.match(r'\(footprint "([^"]+)"', blk).group(1)
        layer = re.search(r'\(layer "([^"]+)"\)', blk).group(1)
        at = re.search(r'\n\t\t\(at ([-\d.]+) ([-\d.]+)(?: ([-\d.]+))?\)', blk)
        fx, fy = float(at.group(1)), float(at.group(2))
        fr = float(at.group(3) or 0)
        ref = re.search(r'\(property "Reference" "([^"]+)"', blk).group(1)
        pads = []
        for pb in _blocks(blk, "(pad "):
            m = re.search(r'\(at ([-\d.]+) ([-\d.]+)(?: ([-\d.]+))?\)', pb)
            s = re.search(r'\(size ([-\d.]+) ([-\d.]+)\)', pb)
            if not m or not s:
                continue
            px, py = float(m.group(1)), float(m.group(2))
            a = math.radians(fr)
            # KiCad rotates footprints counter-clockwise on screen with y down
            kx = fx + px * math.cos(a) + py * math.sin(a)
            ky = fy - px * math.sin(a) + py * math.cos(a)
            pr = float(m.group(3) or fr)
            w, h = float(s.group(1)), float(s.group(2))
            ar = math.radians(pr)
            ex = abs(w * math.cos(ar)) / 2 + abs(h * math.sin(ar)) / 2
            ey = abs(w * math.sin(ar)) / 2 + abs(h * math.cos(ar)) / 2
            pads.append((150 - kx - ex, 150 - kx + ex, 70 - ky - ey, 70 - ky + ey))
        if pads:
            box = [min(p[0] for p in pads), max(p[1] for p in pads), min(p[2] for p in pads), max(p[3] for p in pads)]
        else:
            box = [150 - fx, 150 - fx, 70 - fy, 70 - fy]
        out.append({"ref": ref, "lib": lib, "layer": layer, "centre": [150 - fx, 70 - fy], "rot": fr,
                    "pad_box": box, "pads": pads})
    return out


# ------------------------------------------------------------------ board STEP
def _ov(a, b):
    dx = max(0.0, min(a[1], b[1]) - max(a[0], b[0]))
    dy = max(0.0, min(a[3], b[3]) - max(a[2], b[2]))
    return dx * dy


def board():
    """List of dicts: ref, shape, bbox, match info. Top-level children of the
    board STEP. The bare board is the 0.8 thick child that spans the outline."""
    cdir = os.path.join(CACHE, "board")
    idx = os.path.join(cdir, "index.json")
    key = _key(BOARD_STEP)
    if os.path.exists(idx):
        meta = json.load(open(idx))
        if meta.get("key") == key:
            return [dict(e, shape=_read(os.path.join(cdir, e["file"]))) for e in meta["entries"]]
    os.makedirs(cdir, exist_ok=True)
    print("reading the board STEP (73 MB) ...", flush=True)
    whole = cq.importers.importStep(BOARD_STEP).val().wrapped
    it = TopoDS_Iterator(whole)
    entries = []
    i = 0
    while it.More():
        ch = it.Value()
        fn = f"b{i:03d}.brep"
        _write(ch, os.path.join(cdir, fn))
        entries.append({"file": fn, "bbox": bbox(cq.Shape.cast(ch))})
        i += 1
        it.Next()
    _match(entries)
    json.dump({"key": key, "entries": entries}, open(idx, "w"), indent=1)
    return board()


def _match(entries):
    fps = footprints()
    used = {}
    for e in entries:
        bb = e["bbox"]
        if (bb[1] - bb[0]) > 50 and abs(bb[5] - bb[4] - 0.8) < 0.05:
            e["ref"] = "PCB"
            e["score"] = 1.0
            continue
        best, score = None, 0.0
        for fp in fps:
            pb = fp["pad_box"]
            # share of the pad box covered by the solid's XY box
            area = max(1e-6, (pb[1] - pb[0]) * (pb[3] - pb[2]))
            s = _ov(bb, pb) / area
            # prefer the footprint whose centre lies in the solid's box
            cx, cy = fp["centre"]
            inside = bb[0] - 0.05 <= cx <= bb[1] + 0.05 and bb[2] - 0.05 <= cy <= bb[3] + 0.05
            s = s + (0.5 if inside else 0.0)
            if s > score:
                best, score = fp["ref"], s
        e["ref"] = best if score > 0.3 else "UNMATCHED"
        e["score"] = round(score, 3)
        used.setdefault(e["ref"], 0)
        used[e["ref"]] += 1
    for e in entries:
        if used.get(e["ref"], 0) > 1 and e["ref"] not in ("PCB", "UNMATCHED"):
            e["duplicate"] = True


# ------------------------------------------------------------------ screen STEP
def screen_vendor():
    """Solids of the vendor screen STEP, in the vendor frame."""
    cdir = os.path.join(CACHE, "screen")
    os.makedirs(cdir, exist_ok=True)
    idx = os.path.join(cdir, "index.json")
    key = _key(SCREEN_STEP)
    if os.path.exists(idx):
        meta = json.load(open(idx))
        if meta.get("key") == key:
            return [_read(os.path.join(cdir, f)) for f in meta["files"]]
    sh = cq.importers.importStep(SCREEN_STEP).val()
    files = []
    for i, s in enumerate(sh.Solids()):
        fn = f"s{i:03d}.brep"
        _write(s.wrapped, os.path.join(cdir, fn))
        files.append(fn)
    json.dump({"key": key, "files": files}, open(idx, "w"))
    return screen_vendor()


if __name__ == "__main__":
    import time
    t = time.time()
    a = assembly()
    print(len(a), "assembly solids", round(time.time() - t, 1), "s", flush=True)
    p = printed_steps()
    print(len(p), "printed", round(time.time() - t, 1), "s", flush=True)
    s = screen_vendor()
    print(len(s), "screen solids", round(time.time() - t, 1), "s", flush=True)
    b = board()
    print(len(b), "board solids", round(time.time() - t, 1), "s", flush=True)
    for e in b:
        print(e["ref"], e["score"], [round(v, 2) for v in e["bbox"]], "DUP" if e.get("duplicate") else "")
