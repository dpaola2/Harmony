"""Export bed-oriented geometry for an unpowered fit trial; not sliced jobs."""
from pathlib import Path
import hashlib,json
import cadquery as cq
import trimesh
import numpy as np
R=Path(__file__).resolve().parent
P=R/'print';P.mkdir(exist_ok=True)
parts={}
for name in ('front','tray','battery-cover'):
 s=cq.importers.importStep(str(R/'cad'/f'{name}.step')).val()
 if name=='front': s=s.rotate((0,0,0),(1,0,0),180)
 parts[name]=s
# Same narrow cross-section as a screen-end closure column. The base closes
# the blind pilot; the coupon tests insertion, not full-height column bending.
post=cq.Workplane('XY').box(12,12,2,centered=(False,False,False))
post=post.union(cq.Workplane('XY').box(6,3.65,5.2,centered=(False,False,False)).translate((3,4.15,2)))
post=post.cut(cq.Workplane('XY').circle(.85).extrude(5.3).translate((6,6,2)))
parts['closure-pilot-coupon']=post.val()
tab=cq.Workplane('XY').box(12,12,1.6,centered=(False,False,False))
tab=tab.cut(cq.Workplane('XY').circle(1.15).extrude(1.7).translate((6,6,0)))
parts['closure-coupon-tab']=tab.val()
# Right side of the real tray, including both carrier supports and USB/Reset openings.
tray=cq.importers.importStep(str(R/'cad/tray.step')).val()
cut=cq.Workplane('XY').box(16,26,28,centered=False).translate((48,75,-8)).val()
parts['port-fit']=tray.intersect(cut)
# Screen support coupon: same 4.9 mm boss, 1.7 mm pilot and 3.6 mm pilot depth.
base=cq.Workplane('XY').box(12,12,1.4,centered=False)
boss=cq.Workplane('XY').center(6,6).circle(2.45).extrude(3.6).translate((0,0,1.4))
hole=cq.Workplane('XY').center(6,6).circle(.85).extrude(3.7).translate((0,0,1.4))
parts['screen-pilot-coupon']=base.union(boss).cut(hole).val()
screen_tab=cq.Workplane('XY').box(12,12,1.57,centered=False).cut(cq.Workplane('XY').center(6,6).circle(1.15).extrude(1.7))
parts['screen-coupon-tab']=screen_tab.val()
spacer=cq.Workplane('XY').circle(2.1).circle(1.15).extrude(1.4)
parts['screen-coupon-spacer']=spacer.val()
carrier_spacer=cq.Workplane('XY').circle(2).circle(1.2).extrude(2)
parts['carrier-spacer']=carrier_spacer.val()
report={'purpose':'Unpowered physical fit trial; not sliced','parts':{},'plates':{}}
meshes={}
for name,s in parts.items():
 b=s.BoundingBox();s=s.translate((-b.xmin,-b.ymin,-b.zmin))
 assert s.isValid() and len(s.Solids())==1,name
 path=P/f'mark7-shell-d-{name}.stl'
 cq.exporters.export(s,str(path),tolerance=.05,angularTolerance=.1)
 mesh=trimesh.load(path,force='mesh')
 assert mesh.is_watertight and len(mesh.split())==1,name
 assert abs(mesh.bounds[0,2])<1e-5,name
 meshes[name]=mesh
 (P/f'mark7-shell-d-{name}.3mf').write_bytes(trimesh.exchange.threemf.export_3MF(trimesh.Scene(mesh)))
 report['parts'][name]={'extents_mm':mesh.extents.tolist(),'watertight':True,'single_solid':True,'bed_z':float(mesh.bounds[0,2]),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
for name,layout in {'fit-checks':[('port-fit',0,0),('closure-pilot-coupon',24,0),('closure-coupon-tab',42,0),('screen-pilot-coupon',24,18),('screen-coupon-tab',42,18),('screen-coupon-spacer',60,18),('carrier-spacer',24,36),('carrier-spacer',32,36),('carrier-spacer',40,36),('carrier-spacer',48,36)],'shell-kit':[('front',0,0),('tray',74,0),('battery-cover',148,0)]}.items():
 scene=trimesh.Scene();bounds=[]
 for index,(part,x,y) in enumerate(layout):
  m=meshes[part].copy();m.apply_translation((x,y,0))
  for b in bounds: assert not ((np.minimum(b[1,:2],m.bounds[1,:2])-np.maximum(b[0,:2],m.bounds[0,:2]))>0).all()
  bounds.append(m.bounds.copy());scene.add_geometry(m,node_name=f"{part}-{index}",geom_name=f"{part}-{index}")
 assert max(scene.extents)<256
 path=P/f'mark7-shell-d-{name}.3mf';path.write_bytes(trimesh.exchange.threemf.export_3MF(scene))
 loaded=trimesh.load(path)
 assert len(loaded.geometry)==len(layout)
 report['plates'][name]={'objects':len(layout),'extents_mm':scene.extents.tolist(),'roundtrip_objects':len(loaded.geometry),'sliced':False}
report['source_step_sha256']={n:hashlib.sha256((R/'cad'/f'{n}.step').read_bytes()).hexdigest() for n in ('front','tray','battery-cover')}
(P/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
