"""Stepped LCD clips: physical fit candidates; keep screw/spacer stack unchanged."""
from pathlib import Path
import json
import cadquery as cq
import trimesh
import numpy as np
R=Path(__file__).resolve().parent
scene=trimesh.Scene()
report={}
def box(x,y,z,w,h,t):
    return cq.Workplane('XY').box(w,h,t,centered=False).translate((x,y,z)).val()
# Print screw-head-facing surface on bed; the downward installed tip prints upward.
base=box(0,0,0,8.4,6,1.6).cut(cq.Workplane('XY').center(3,3).circle(1.2).extrude(1.6).val())
for count,step in enumerate([1.0,1.5,2.0],1):
    name=f'lcd-clip-step-{step:.1f}mm-{count}-notch'
    shape=base.fuse(box(6.4,0,1.6,2,6,step))
    # Edge notches identify step after removal from plate; outside screw bearing area.
    for i in range(count):
        shape=shape.cut(box(.4+i*.9,0,0,.4,.4,1.6))
    assert shape.isValid() and len(shape.Solids())==1
    cq.exporters.export(shape,str(R/f'{name}.step'))
    cq.exporters.export(shape,str(R/f'{name}.stl'),tolerance=.02,angularTolerance=.1)
    mesh=trimesh.load(R/f'{name}.stl',force='mesh')
    assert mesh.is_watertight and len(mesh.split())==1
    assert np.allclose(mesh.extents,[8.4,6,1.6+step])
    assert abs(mesh.bounds[0,2])<1e-6
    # Foot starts 0.8 mm beyond original 2.6 mm-radius boss envelope.
    assert 6.4-(3+2.6)>.79
    placed=mesh.copy();placed.apply_translation([10+(count-1)*20,10,0])
    scene.add_geometry(placed,node_name=name,geom_name=name)
    report[name]={'step_mm':step,'notches':count,'extents_mm':mesh.extents.tolist(),'watertight':True,'single_solid':True,'screw_hole_diameter_mm':2.4,'body_thickness_mm':1.6,'tip_contact_area_mm':[2,6],'boss_to_step_clearance_mm':.8}
p=R/'stepped-clips-test-plate.3mf'
p.write_bytes(trimesh.exchange.threemf.export_3MF(scene))
loaded=trimesh.load(p)
assert len(loaded.geometry)==3
assert np.allclose(loaded.bounds,scene.bounds)
report['qualification']='Geometry checked only. User reported 1–2 mm physical gap. Test gently on an intact boss. No installed preload or actual contact surface qualification.'
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
