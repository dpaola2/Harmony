"""Measure every footprint's 3D model in footprint-local coordinates -> lib/model_geometry.json.

Run with uv + CadQuery (see rebuild.sh). For each footprint in lib/Harmony8.pretty this applies the
footprint's own model transform (KiCad: final = offset + Rz(-rot) * raw; model Y up, footprint Y
down) and records the body bounding box in footprint coordinates and the height above the board.
It also measures the microSD card opening and the USB-C receptacle opening at their front faces.
verify.py uses this file, so it runs under KiCad's Python without CadQuery.
"""
import json
import math
import re
import sys
from pathlib import Path
import cadquery as cq

HERE = Path(__file__).resolve().parent
PRETTY = HERE / 'lib/Harmony8.pretty'
SHAPES = HERE / 'lib/Harmony8.3dshapes'


def model_of(text):
    m = re.search(r'\(model "\$\{KIPRJMOD\}/lib/Harmony8\.3dshapes/([^"]+)"\s*\(offset\s*\(xyz ([^)]*)\)\s*\)\s*'
                  r'\(scale\s*\(xyz [^)]*\)\s*\)\s*\(rotate\s*\(xyz ([^)]*)\)\s*\)', text)
    if not m:
        return None
    off = [float(x) for x in m.group(2).split()]
    rot = [float(x) for x in m.group(3).split()]
    return m.group(1), off, rot


def placed(shape, off, rot):
    s = shape.rotate((0, 0, 0), (0, 0, 1), -rot[2]).translate(cq.Vector(*off))
    return s


out = {}
cache = {}
for fpfile in sorted(PRETTY.glob('*.kicad_mod')):
    mod = model_of(fpfile.read_text())
    if not mod:
        continue
    name, off, rot = mod
    if name not in cache:
        cache[name] = cq.importers.importStep(str(SHAPES / name)).val()
    s = placed(cache[name], off, rot)
    bb = s.BoundingBox()
    # footprint coordinates: x same, y = -model y
    out[fpfile.stem] = dict(model=name, x=[round(bb.xmin, 3), round(bb.xmax, 3)],
                            y=[round(-bb.ymax, 3), round(-bb.ymin, 3)], z=[round(bb.zmin, 3), round(bb.zmax, 3)])


def gap_along_z(shape, x, y, z0, z1, step=0.02):
    """Return list of (zlo, zhi) intervals free of material on a vertical line at (x, y)."""
    free, cur = [], None
    z = z0
    while z <= z1:
        inside = shape.isInside(cq.Vector(x, y, z), 1e-4)
        if not inside and cur is None:
            cur = z
        if inside and cur is not None:
            free.append((round(cur, 3), round(z, 3))); cur = None
        z += step
    if cur is not None:
        free.append((round(cur, 3), round(z1, 3)))
    return free


# microSD: probe 0.3 mm inside the front face along the card centre line (footprint x = -0.35).
sd = out['DM3AT-SF-PEJM5']
name, off, rot = model_of((PRETTY / 'DM3AT-SF-PEJM5.kicad_mod').read_text())
s = placed(cache[name], off, rot)
y_model = -(sd['y'][1] - 0.3)
out['DM3AT-SF-PEJM5']['card_opening_z'] = gap_along_z(s, -0.35, y_model, 0.0, sd['z'][1] - 0.01)
# USB-C: probe 0.3 mm inside the mating face on the centre line.
uc = out['USB-C_HRO_TYPE-C-31-M-12']
name, off, rot = model_of((PRETTY / 'USB-C_HRO_TYPE-C-31-M-12.kicad_mod').read_text())
s = placed(cache[name], off, rot)
out['USB-C_HRO_TYPE-C-31-M-12']['opening_z_on_axis'] = gap_along_z(s, 0.0, -(uc['y'][1] - 0.3), 0.0, uc['z'][1] - 0.01)
(HERE / 'lib/model_geometry.json').write_text(json.dumps(out, indent=1) + '\n')
for k, v in out.items():
    print('%-28s x %s y %s z %s %s' % (k, v['x'], v['y'], v['z'], {kk: vv for kk, vv in v.items() if 'opening' in kk}))
