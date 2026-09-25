#!/usr/bin/env python3
"""Build a solid ergonomic dummy, not an electronics enclosure.
uv run --with cadquery==2.8.0 --with trimesh --with matplotlib --with networkx --with lxml python build.py
"""
from pathlib import Path
import sys
import hashlib
import json
import cadquery as cq
import trimesh
import numpy as np

HERE=Path(__file__).resolve().parent
CARRIER=HERE.parents[2]/'hardware/mark-6/carrier-rev-a'
sys.path.insert(0,str(CARRIER))
from mechanical_layout import layout
D=layout()
W,H,T=D['case']
OUT=HERE/'print';OUT.mkdir(exist_ok=True)
CAD=HERE/'cad';CAD.mkdir(exist_ok=True)
PREVIEW=HERE/'preview';PREVIEW.mkdir(exist_ok=True)

# CAD +Y is toward the top. Drawing coordinates are measured downward.
body=(cq.Workplane('XY').box(W,H,T,centered=(True,True,False))
      .edges('|Z').fillet(D['case_corner_radius'])
      .faces('>Z').edges().fillet(1.0))
sx,sy,sw,sh=D['display_active_guide']
screen=(cq.Workplane('XY',origin=(sx+sw/2-W/2,H/2-sy-sh/2,T-.7))
        .box(sw,sh,1.4,centered=(True,True,False)).edges('|Z').fillet(.8))
body=body.cut(screen)
wx,wy=D['wheel_center'];wx-=W/2;wy=H/2-wy
# All cues are recessed so the 28 mm dimension includes every feature.
ring=(cq.Workplane('XY',origin=(wx,wy,T-.7)).circle(D['wheel_diameter']/2)
      .circle(11.45).extrude(1.4))
button=cq.Workplane('XY',origin=(wx,wy,T-.7)).circle(4.05).extrude(1.4)
body=body.cut(ring).cut(button).clean()
solid=body.val()
assert solid.isValid() and len(solid.Solids())==1
stl=OUT/'harmony-mark6-size-74x178x28.stl'
cq.exporters.export(solid,str(stl),tolerance=.05,angularTolerance=.1)
cq.exporters.export(solid,str(CAD/'harmony-mark6-size.step'))
m=trimesh.load(stl,force='mesh')
assert m.is_watertight and m.is_winding_consistent and m.volume>0
assert m.body_count==1
assert np.allclose(m.extents,[W,H,T],atol=.001)
assert abs(m.bounds[0,2])<.0001
assert all(m.extents < 256)
# Geometry-only 3MF: no printer settings or machine instructions.
scene=trimesh.Scene(m)
three=OUT/'harmony-mark6-size-74x178x28.3mf'
three.write_bytes(trimesh.exchange.threemf.export_3MF(scene))
reloaded=trimesh.load(three,force='mesh')
assert reloaded.is_watertight and np.allclose(reloaded.extents,m.extents,atol=.001)
report={
    'status':'Mesh-verified solid size dummy. No functional electronics cavity or physical fit pass.',
    'dimensions_mm':[float(v) for v in m.extents],
    'bottom_z_mm':float(m.bounds[0,2]),
    'solid_valid':True,'watertight':True,'winding_consistent':True,'connected_bodies':m.body_count,
    'fits_256mm_build_volume':True,'three_mf_round_trip':True,
    'volume_mm3':round(float(m.volume),3),
    'screen_recess_mm':.7,'wheel_recess_mm':.7,
    'placement_revision':D['revision'],
    'limitations':D['limitations'],
    'hashes':{str(p.relative_to(HERE)):hashlib.sha256(p.read_bytes()).hexdigest()
              for p in [stl,three,CAD/'harmony-mark6-size.step']},
    'mechanical_source_sha256':hashlib.sha256((CARRIER/'mechanical_layout.py').read_bytes()).hexdigest()
}
(HERE/'validation.json').write_text(json.dumps(report,indent=2)+'\n')

from render_preview import render
render(m,D['case'],PREVIEW)
print(json.dumps({k:v for k,v in report.items() if k not in ['hashes','limitations']},indent=2))
