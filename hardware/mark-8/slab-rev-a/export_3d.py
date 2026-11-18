"""Transform the KiCad board STEP into device coordinates and check it against the interface file.

Run with uv + CadQuery after `kicad-cli pcb export step` wrote jlcpcb/harmony-mark8-slab.step.
KiCad STEP frame: x = kicad_x, y = -kicad_y, board bottom (L4) at z = 0, component side (L1) at
z = 0.8. Device frame (SPEC 1): x = X0 - x, y = Y0 + y, z = -1.0 - z. That is a 180-degree turn
about the Y axis plus a translation, so the solid keeps its handedness.
Writes board-device-coords.step and prints bounding-box checks of the transformed model.
"""
import json
import sys
from pathlib import Path
import cadquery as cq

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from design import X0, Y0, Z_TOUCH, NAME  # noqa: E402

src = HERE / 'jlcpcb' / (NAME + '.step')
dst = HERE / 'board-device-coords.step'
shape = cq.importers.importStep(str(src)).val()
moved = shape.rotate(cq.Vector(0, 0, 0), cq.Vector(0, 1, 0), 180).translate(cq.Vector(X0, Y0, Z_TOUCH))
cq.exporters.export(cq.Workplane().add(moved), str(dst))
bb = moved.BoundingBox()
iface = json.loads((HERE / 'mechanical-interface.json').read_text())
report = dict(device_bbox=dict(x=[round(bb.xmin, 3), round(bb.xmax, 3)], y=[round(bb.ymin, 3), round(bb.ymax, 3)],
                               z=[round(bb.zmin, 3), round(bb.zmax, 3)]))


def solids_near(x, y, r=0.6):
    out = []
    for s in moved.Solids():
        b = s.BoundingBox()
        if b.xmin - r <= x <= b.xmax + r and b.ymin - r <= y <= b.ymax + r:
            out.append(b)
    return out


checks = {}
# USB-C mating face: the most -Y point of the solids around x = 0 below the board edge.
usb = [b for b in moved.Solids() if abs((b.BoundingBox().xmin + b.BoundingBox().xmax) / 2) < 1.0
       and b.BoundingBox().ymin < -49.0]
if usb:
    checks['usb_c_front_y_step'] = round(min(s.BoundingBox().ymin for s in usb), 3)
    checks['usb_c_front_y_interface'] = iface['usb_c']['mating_face_y']
checks['lowest_z_step'] = report['device_bbox']['z'][0]
checks['lowest_z_interface'] = iface['lowest_component_z']
checks['touch_side_z_step_max'] = report['device_bbox']['z'][1]
report['checks'] = checks
ok = (abs(checks.get('usb_c_front_y_step', 99) - checks.get('usb_c_front_y_interface', 0)) < 0.15 and
      abs(checks['lowest_z_step'] - checks['lowest_z_interface']) < 0.1 and checks['touch_side_z_step_max'] < -0.5)
report['status'] = 'PASS' if ok else 'CHECK'
(HERE / 'review/step-check.json').write_text(json.dumps(report, indent=1) + '\n')
print(json.dumps(report, indent=1))
