#!/usr/bin/env python3
"""Build a removable Mark-7 tray around the accepted Mark-6 front geometry."""
from pathlib import Path
import hashlib, json, sys
import cadquery as cq
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
REF = REPO / 'hardware/mark-6/carrier-rev-a'
sys.path.insert(0, str(REF))
from display_model import load_display
for folder in ('print', 'cad', 'preview'):
    (ROOT / folder).mkdir(exist_ok=True)

# Reuse geometry definitions, stopping before the earlier script exports files.
source = REPO / 'enclosure/mark-6/fit-rev-b/build.py'
ns = {'__file__': str(source), '__name__': 'reference_geometry'}
exec(compile(source.read_text().split('# Four M2.5 through-bolts')[0], str(source), 'exec'), ns)
box, cyl, rounded = ns['box'], ns['cyl'], ns['ns']['rounded']
front, clips = ns['lid'], ns['clips']
closure, ano_holes = ns['closure'], ns['holes'][4:]

# Rear floor is the common datum. No custom carrier, converter or SD breakout.
outer = rounded(74, 178, 0, 26.4, 5)
tray = outer.cut(rounded(70.8, 174.8, 1.6, 40, 3.4))
tray = tray.cut(box(-1, 155.66, 19.4, 7, 13, 10))
for x, y in closure:
    r = 1.8 if y > 170 else 2.2
    tray = tray.union(cyl(x, y, 1.6, r, 24.8).intersect(outer))
    tray = tray.cut(cyl(x, y, 20.4, 1.05, 6.2))

# Direct ANO mounting replaces the carrier and loose spacers. PCB bottom 22.1.
for x, y, _ in ano_holes:
    tray = tray.union(cyl(x, y, 1.6, 3.0, 20.5))
    tray = tray.cut(cyl(x, y, 15.5, 1.05, 6.8))
    # Low wide foot reduces the unsupported height without touching components.
    tray = tray.union(cyl(x, y, 1.6, 4.0, 3.0))

# Existing Feather position preserves USB alignment and room below male headers.
feather_mounts = [(53.76, 171.05), (53.76, 153.27)]
for x, y in feather_mounts:
    tray = tray.union(cyl(x, y, 1.6, 2.2, 17.55))
    tray = tray.cut(cyl(x, y, 11.8, .8, 7.5))
# Support the USB end below the PCB center, away from both header rows.
tray = tray.union(box(6.5, 158.5, 1.6, 5, 7, 17.55))

# Pack limits from vendor drawing: 50.5 x 62.5 x 8.1, not catalog typical size.
# Cavity 53 x 65 x 10.4; cover rests on plastic stops, never on the pouch.
battery_wall = box(9.3, 18.8, 1.6, 55.4, 67.4, 10.4)
battery_wall = battery_wall.cut(box(10.5, 20, 1.5, 53, 65, 10.7))
# Wires leave toward the wheel and Feather, through an open-top slot.
battery_wall = battery_wall.cut(box(31, 84.9, 6.5, 12, 2, 5.7))
tray = tray.union(battery_wall)
battery_cover = box(9.3, 18.8, 12, 55.4, 67.4, 1.6)
battery_cover = battery_cover.cut(box(31, 83.2, 11.9, 12, 3.1, 1.9))
battery_mounts = [(7.5, 25), (66.5, 25), (7.5, 79), (66.5, 79)]
for x, y in battery_mounts:
    tray = tray.union(cyl(x, y, 1.6, 2.8, 10.4)).cut(cyl(x, y, 4.8, .8, 7.4))
    battery_cover = battery_cover.union(cyl(x, y, 12, 2.8, 1.6))
    battery_cover = battery_cover.cut(cyl(x, y, 11.9, 1.15, 1.9))

# Trim existing perfboard to 30 x 20. Keep two 3 mm edge strips free of solder.
# Rails support the board at Z8; removable clamps require no PCB mounting holes.
for x in (22, 49):
    tray = tray.union(box(x, 107, 1.6, 3, 20, 6.4))
for y in (105.6, 127.4):
    tray = tray.union(box(22, y, 1.6, 30, 1.2, 6.4))
clamps = []
for x, left in ((18.5, True), (55.5, False)):
    tray = tray.union(cyl(x, 117, 1.6, 3.1, 8.0)).cut(cyl(x, 117, 2.8, .8, 7))
    clamp = box(x - 3.1 if left else 49, 113.9, 9.6, 9.1, 6.2, 1.6)
    clamp = clamp.cut(cyl(x, 117, 9.5, 1.15, 1.9))
    clamps.append(clamp.val())
# Tie points for existing insulated wire used as loose harness lacing.
# These are beside the pouch, never straps across it.
for x, y in ((5, 102), (5, 132), (29, 141)):
    anchor = box(x, y, 1.6, 8, 6, 5)
    anchor = anchor.cut(box(x - .1, y + 1.5, 2.6, 8.2, 3, 2))
    tray = tray.union(anchor)
tray = tray.clean()
battery_cover = battery_cover.clean()

feather = cq.importers.importStep(str(REF/'reference/5400 ESP32 Feather V2.step')).val().translate((5.5, -173.59, 19.15))
ano = cq.importers.importStep(str(REF/'reference/5740 ANO Rotary Encoder QT.step')).val().rotate((0,0,0),(1,1,0),180).translate((37,-120.78,23.67))
display = load_display()
battery = box(11.75, 21.25, 2.1, 50.5, 62.5, 8.1).val()
perfboard = box(22, 107, 8, 30, 20, 1.6).val()
# Component/solder envelope excludes the clamped edge strips.
perf_components = box(25, 107, 9.6, 24, 20, 8).val()
perf_solder = box(25, 107, 6, 24, 20, 2).val()

def bed(s):
    b = s.BoundingBox()
    return s.translate((-b.xmin, -b.ymin, -b.zmin))
models = {'tray': bed(tray.val()),
          'front': bed(front.val().rotate((0,0,0),(1,0,0),180)),
          'battery-cover': bed(battery_cover.val()),
          'perfboard-clamp-left': bed(clamps[0]),
          'perfboard-clamp-right': bed(clamps[1]),
          'display-retainer-left': bed(clips[0]),
          'display-retainer-right': bed(clips[1])}
report = {'date': '2026-10-03', 'status': 'Printable fit candidate; assembled fit and thermal behavior untested',
          'case_mm': [74,178,28], 'battery_max_mm': [50.5,62.5,8.1],
          'battery_cavity_mm': [53,65,10.4], 'battery_cover_bottom_z':12,
          'battery_top_with_0_5mm_floor_pad_z':10.2, 'parts': {},
          'sources_sha256': {str(p.relative_to(REPO)): hashlib.sha256(p.read_bytes()).hexdigest() for p in (source, ROOT/'reference/adafruit-328-datasheet.pdf')}}
for name, shape in models.items():
    assert shape.isValid() and len(shape.Solids()) == 1, name
    path = ROOT/'print'/f'harmony-m7-a-{name}.stl'
    cq.exporters.export(shape, str(path), tolerance=.035, angularTolerance=.08)
    mesh = trimesh.load(path, force='mesh')
    assert mesh.is_watertight and mesh.is_winding_consistent and mesh.body_count == 1, name
    assert abs(mesh.bounds[0,2]) < .001 and max(mesh.extents) < 256, name
    path.with_suffix('.3mf').write_bytes(trimesh.exchange.threemf.export_3MF(trimesh.Scene(mesh)))
    cq.exporters.export(shape, str(ROOT/'cad'/f'{name}.step'))
    report['parts'][name] = {'dimensions_mm': mesh.extents.tolist(), 'watertight': True, 'solids': 1}
    print('exported', name, flush=True)

plastic = {'tray': tray.val(), 'front': front.val(), 'battery-cover': battery_cover.val(),
           **{f'retainer-{i}': s for i,s in enumerate(clips)},
           **{f'perf-clamp-{i}': s for i,s in enumerate(clamps)}}
components = {'feather': feather, 'ano': ano, 'display': display, 'battery': battery,
              'perfboard': perfboard, 'perf-top-envelope': perf_components, 'perf-solder-envelope': perf_solder}
checks = {}
for name, shape in plastic.items():
    for other, comp in components.items():
        checks[f'{name}/{other}'] = shape.intersect(comp).Volume()
    for other, comp in plastic.items():
        if name < other: checks[f'{name}/{other}'] = shape.intersect(comp).Volume()
for name, shape in components.items():
    for other, comp in components.items():
        if name < other: checks[f'{name}/{other}'] = shape.intersect(comp).Volume()
# Screw envelopes. Intersections with their threaded plastic posts are intended.
screws=[]
for x,y,_ in ano_holes: screws.append(('ano',x,y,23.67,6,1.25,2.25,2.5))
for x,y in feather_mounts: screws.append(('feather',x,y,20.75,8,1.,1.9,1.8))
for x,y in battery_mounts: screws.append(('battery',x,y,13.6,8,1.,1.9,1.8))
for x in (18.5,55.5): screws.append(('perf',x,117,11.2,8,1.,1.9,1.8))
for i,(kind,x,y,z,length,r,hr,hh) in enumerate(screws):
    shape = cyl(x,y,z-length,r,length).union(cyl(x,y,z,hr,hh)).val()
    for other, comp in components.items(): checks[f'screw-{i}-{kind}/{other}'] = shape.intersect(comp).Volume()
    checks[f'screw-{i}-{kind}/front'] = shape.intersect(front.val()).Volume()
report['intersection_mm3'] = checks
(ROOT/'validation.json').write_text(json.dumps(report, indent=2)+'\n')
fail = {k:v for k,v in checks.items() if v > .001}
print('interferences', fail, flush=True)
assert not fail, 'See validation.json'
assembly = cq.Assembly(name='Harmony_Mark7_portable_rev_a')
colors={'tray':(.83,.80,.69),'front':(.91,.88,.77),'battery-cover':(.70,.70,.64),
        'battery':(.5,.55,.61),'feather':(.1,.2,.35),'ano':(.12,.12,.13),
        'display':(.08,.25,.20),'perfboard':(.45,.28,.12)}
for name, shape in {**plastic, **{k:v for k,v in components.items() if 'envelope' not in k}}.items():
    assembly.add(shape, name=name, color=cq.Color(*colors.get(name,(.75,.5,.18))))
    cq.exporters.export(shape, str(ROOT/'preview'/f'{name}.stl'), tolerance=.08, angularTolerance=.15)
assembly.save(str(ROOT/'cad/assembly.step'))
print('PASS', len(checks), 'interference checks', flush=True)
