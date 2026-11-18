"""Load the board, the screen and the mechanical interface, in device coordinates.

The board STEP is 73 MB. The first build reads it once and writes one BREP file
per top-level part plus an index to .cache/board/. Later builds read the cache.
Every part is matched to its reference in mechanical-interface.json by its
bounding box.
"""
import json
import os

import cadquery as cq
from OCP.BRep import BRep_Builder
from OCP.BRepTools import BRepTools
from OCP.TopoDS import TopoDS_Iterator, TopoDS_Shape

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
BOARD_DIR = os.path.join(REPO, "hardware", "mark-8", "slab-rev-a")
MI_PATH = os.path.join(BOARD_DIR, "mechanical-interface.json")
BOARD_STEP = os.path.join(BOARD_DIR, "board-device-coords.step")
SCREEN_STEP = os.path.join(BOARD_DIR, "reference", "DLC-T2.7DDS1.step")
CACHE = os.path.join(HERE, ".cache")


def mech():
    with open(MI_PATH) as f:
        return json.load(f)


def _bbox(shape):
    b = cq.Shape.cast(shape).BoundingBox()
    return [b.xmin, b.xmax, b.ymin, b.ymax, b.zmin, b.zmax]


def _overlap(a, b):
    """Overlap volume of two boxes divided by the larger box volume."""
    dx = max(0.0, min(a[1], b[1]) - max(a[0], b[0]))
    dy = max(0.0, min(a[3], b[3]) - max(a[2], b[2]))
    dz = max(0.0, min(a[5], b[5]) - max(a[4], b[4]))
    va = max(1e-9, (a[1] - a[0]) * (a[3] - a[2]) * (a[5] - a[4]))
    vb = max(1e-9, (b[1] - b[0]) * (b[3] - b[2]) * (b[5] - b[4]))
    return dx * dy * dz / max(va, vb)


def _match_refs(entries, mi):
    """Give each cached child the reference of the JSON part it overlaps most."""
    parts = []
    for p in mi["parts"]:
        parts.append((p["ref"], [p["x"][0], p["x"][1], p["y"][0], p["y"][1], p["z"][0], p["z"][1]]))
    used = set()
    for e in entries:
        bb = e["bbox"]
        # The bare board: 0.8 thick, spans the full outline.
        if abs(bb[4] - (-1.8)) < 0.05 and abs(bb[5] - (-1.0)) < 0.05 and (bb[1] - bb[0]) > 50:
            e["ref"] = "PCB"
            continue
        best, score = None, 0.0
        for ref, pb in parts:
            s = _overlap(bb, pb)
            if s > score:
                best, score = ref, s
        e["ref"] = best if score > 0.05 else "UNMATCHED"
        e["match"] = round(score, 3)
        used.add(best)
    return entries


def board_parts(rebuild=False):
    """Return a list of dicts: ref, bbox, shape (cq.Shape), in device coordinates."""
    cdir = os.path.join(CACHE, "board")
    index = os.path.join(cdir, "index.json")
    src_stat = os.stat(BOARD_STEP)
    key = f"{src_stat.st_size}-{int(src_stat.st_mtime)}"
    if not rebuild and os.path.exists(index):
        with open(index) as f:
            meta = json.load(f)
        if meta.get("key") == key:
            out = []
            for e in meta["entries"]:
                sh = TopoDS_Shape()
                BRepTools.Read_s(sh, os.path.join(cdir, e["file"]), BRep_Builder())
                out.append(dict(e, shape=cq.Shape.cast(sh)))
            return out
    os.makedirs(cdir, exist_ok=True)
    print("reading the board STEP once (73 MB), this takes a while ...", flush=True)
    whole = cq.importers.importStep(BOARD_STEP).val().wrapped
    entries = []
    it = TopoDS_Iterator(whole)
    i = 0
    while it.More():
        child = it.Value()
        fn = f"part{i:03d}.brep"
        BRepTools.Write_s(child, os.path.join(cdir, fn))
        entries.append({"file": fn, "bbox": _bbox(child)})
        i += 1
        it.Next()
    entries = _match_refs(entries, mech())
    with open(index, "w") as f:
        json.dump({"key": key, "entries": entries}, f, indent=1)
    return board_parts(rebuild=False)


# Screen: vendor frame to device frame. The vendor outline centre is
# (2387.51, 1800.975) and the vendor front face is z = 0. SPEC 3 puts the
# outline centre at (0, 20.905) and the front face at z = -1.0.
SCREEN_DX = -2387.51
SCREEN_DY = 20.905 - 1800.975
SCREEN_DZ = -1.0

SCREEN_SOLID_NAMES = {
    22: "body",
    4: "front polarizer",
    18: "CF glass",
    8: "TFT glass",
    10: "rear polarizer",
    14: "FPC",
    6: "FPC stiffener",
    21: "FPC part",
}


def screen_solids():
    """Return {name: cq.Shape} for the screen in device coordinates."""
    sh = cq.importers.importStep(SCREEN_STEP).val()
    solids = sh.Solids()
    out = {}
    contacts = []
    for i, s in enumerate(solids):
        moved = s.translate(cq.Vector(SCREEN_DX, SCREEN_DY, SCREEN_DZ))
        name = SCREEN_SOLID_NAMES.get(i)
        if name is None:
            contacts.append(moved)
        else:
            out[name] = moved
    out["FPC contacts"] = cq.Compound.makeCompound(contacts)
    return out
