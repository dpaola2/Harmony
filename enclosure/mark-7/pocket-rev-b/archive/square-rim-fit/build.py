#!/usr/bin/env python3
"""Parametric unpowered pocket fit shell. All unmeasured reservations are explicit."""
from pathlib import Path
import json, hashlib
import cadquery as cq
import trimesh
R=Path(__file__).resolve().parent; REPO=R.parents[2]
p=json.loads((R/'parameters.json').read_text())
W,L,D,wall=p['width'],p['length'],p['depth'],p['wall']; split=D-p['front_thickness']
for d in ('print','cad','preview'): (R/d).mkdir(exist_ok=True)
def box(x,y,z,w,h,t):return cq.Workplane('XY').box(w,h,t,centered=False).translate((x,y,z))
def rounded(w,h,z,t,r):return cq.Workplane('XY').box(w,h,t,centered=(True,True,False)).edges('|Z').fillet(r).translate((W/2,L/2,z))
def cyl(x,y,z,r,t):return cq.Workplane('XY').circle(r).extrude(t).translate((x,y,z))
tray=rounded(W,L,0,split,p['corner_radius']).cut(rounded(W-2*wall,L-2*wall,wall,split+1,p['corner_radius']-wall))
front=rounded(W,L,split,p['front_thickness'],p['corner_radius'])
# Hand-fit shell uses tape closure. Mounts/fasteners await bracket and USB geometry.
x,y,w,h=p['screen_opening'];front=front.cut(box(x,y,split-1,w,h,p['front_thickness']+2))
x,y=p['wheel_center'];front=front.cut(cyl(x,y,split-1,p['wheel_opening_diameter']/2,p['front_thickness']+2))
# Separate display bezel coupon lets us test the opening without a whole case.
coupon=box(0,0,0,50,40,2).cut(box(4,4,-1,42,32,4))
# Battery recess 53 x 65, open at top, pad under pouch. Low locating rails only.
# No screws or clamp pressure on the pouch; do not run a powered build in this shell.
bx,by,bz=p['battery_origin'];bw,bh,bt=p['battery']
for x,y,w,h in [(bx-2.45,by-2.45,bw+4.9,1.2),(bx-2.45,by+bh+1.25,bw+4.9,1.2),
                 (bx-2.45,by-1.25,1.2,bh+2.5),(bx+bw+1.25,by-1.25,1.2,bh+2.5)]:
    tray=tray.union(box(x,y,wall,w,h,2.8))
battery=box(bx,by,bz,bw,bh,bt).val()
# Conservative models reserve all component space, while STEP files show actual parts.
display_path=R/'reference/4311-display.step'
raw=cq.importers.importStep(str(display_path)).val().rotate((0,0,0),(1,0,0),180).rotate((0,0,0),(0,0,1),90)
b=raw.BoundingBox(); dx,dy=p['display_origin_xy'];dz=split-b.zlen
screen=raw.translate((dx-b.xmin,dy-b.ymin,dz-b.zmin))
display_envelope=box(dx,dy,dz,b.xlen,b.ylen,b.zlen).val()
feather_path=REPO/'hardware/mark-6/carrier-rev-a/reference/5400 ESP32 Feather V2.step'
raw=cq.importers.importStep(str(feather_path)).val(); b=raw.BoundingBox(); fx,fy=p['feather_origin_xy'];fz=p['feather_pcb_z']
feather=raw.translate((fx-b.xmin,fy-b.ymin,fz-b.zmin))
feather_height=b.zlen
header_floor=fz-p['header_extension_below_pcb']
feather_envelope=box(fx,fy,header_floor,b.xlen,b.ylen,b.zlen+p['header_extension_below_pcb']).val()
wheel=cyl(*p['wheel_center'],split-p['wheel_reserved_depth'],p['wheel_reserved_diameter']/2,p['wheel_reserved_depth']).val()
# Unmeasured cable adapter reservation between battery and display, above the pouch.
adapter=box(8,55,12,20,8,4).val()
components={'battery':battery,'display-envelope':display_envelope,'feather-header-envelope':feather_envelope,'wheel-reservation':wheel,'adapter-reservation':adapter}
plastic={'tray':tray.val(),'front':front.val()}
checks={}
for name,a in components.items():
    for other,b in components.items():
        if name<other:checks[name+'/'+other]=a.intersect(b).Volume()
    for other,b in plastic.items():checks[name+'/'+other]=a.intersect(b).Volume()
checks['front/tray']=front.val().intersect(tray.val()).Volume()
assert all(v<.001 for v in checks.values()),checks
report={'status':p['status'],'case_mm':[W,L,D],'checks':checks,'parts':{},
        'unverified':['Wheel/bracket diameter, depth and mounting geometry','Adapter outline and ribbon bend radius','Header extension is assumed 7.4 mm','Screen opening registration requires physical alignment','No USB opening, closure screws, or final module retention yet'],
        'clearances_mm':{'feather_to_display':dz-(fz+feather_height),'battery_to_wheel':split-p['wheel_reserved_depth']-(bz+bt)},
        'sources_sha256':{str(f.relative_to(REPO)):hashlib.sha256(f.read_bytes()).hexdigest() for f in [display_path,feather_path,R/'parameters.json']}}
for name,shape in {**plastic,'screen-coupon':coupon.val()}.items():
    assert shape.isValid() and len(shape.Solids())==1
    s=shape; bounds=s.BoundingBox();s=s.translate((-bounds.xmin,-bounds.ymin,-bounds.zmin))
    if name=='front':s=s.rotate((W/2,L/2,p['front_thickness']/2),(W/2+1,L/2,p['front_thickness']/2),180)
    path=R/'print'/f'mark7-pocket-{name}-FIT-ONLY.stl';cq.exporters.export(s,str(path),tolerance=.04,angularTolerance=.1)
    mesh=trimesh.load(path,force='mesh');assert mesh.is_watertight and mesh.is_winding_consistent and mesh.body_count==1
    assert mesh.bounds[0,2]>-.001 and max(mesh.extents)<256
    path.with_suffix('.3mf').write_bytes(trimesh.exchange.threemf.export_3MF(trimesh.Scene(mesh)))
    cq.exporters.export(s,str(R/'cad'/f'{name}.step'))
    report['parts'][name]={'mm':mesh.extents.tolist(),'watertight':True,'single_body':True}
assembly=cq.Assembly(name='Mark7_pocket_fit')
colors={'tray':(.87,.84,.74),'front':(.94,.91,.81),'battery':(.53,.59,.64),'display':(.06,.25,.17),'feather':(.08,.24,.34),'wheel-reservation':(.27,.29,.23),'adapter-reservation':(.45,.4,.23)}
for name,s in {**plastic,'battery':battery,'display':screen,'feather':feather,'wheel-reservation':wheel,'adapter-reservation':adapter}.items():
    assembly.add(s,name=name,color=cq.Color(*colors[name]));cq.exporters.export(s,str(R/'preview'/f'{name}.stl'),tolerance=.08)
assembly.export(str(R/'cad/assembly.step'))
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
