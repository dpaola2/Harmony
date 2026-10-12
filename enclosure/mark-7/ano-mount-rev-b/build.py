"""Internal mounting trial: original face openings, no exterior screw holes."""
from pathlib import Path
import json, itertools
import cadquery as cq
import trimesh
R=Path(__file__).resolve().parent; REPO=R.parents[2]; B=R.parent/'pocket-rev-b'
p=json.loads((B/'parameters.json').read_text()); W,L,D=p['width'],p['length'],p['depth']; split=D-p['front_thickness']
for sub in ['print','cad','preview']: (R/sub).mkdir(exist_ok=True)
def box(x,y,z,w,h,t): return cq.Workplane('XY').box(w,h,t,centered=False).translate((x,y,z))
def cyl(x,y,z,r,h): return cq.Workplane('XY').center(x,y).circle(r).extrude(h).translate((0,0,z))
def bed(s):
 b=s.BoundingBox();return s.translate((-b.xmin,-b.ymin,-b.zmin))
front=cq.Workplane('XY').box(W,L,2,centered=(True,True,False)).edges('|Z').fillet(5).translate((32,52.5,24)).faces('>Z').edges().chamfer(1)
x,y,w,h=p['screen_opening'];front=front.cut(box(x,y,23,w,h,4))
front=front.cut(cyl(32,32,23,16.5,4)).cut(cyl(32,32,23.9,17.7,.5))
ano=cq.importers.importStep(str(REPO/'hardware/mark-6/carrier-rev-a/reference/5740 ANO Rotary Encoder QT.step')).val().rotate((0,0,0),(1,1,0),180).translate((32,32,21.67))
display=cq.importers.importStep(str(B/'reference/4311-display.step')).val().rotate((0,0,0),(1,0,0),180).rotate((0,0,0),(0,0,1),90)
b=display.BoundingBox();display=display.translate((2.4725-b.xmin,64-b.ymin,23.8-b.zmax))
# STEP PCB datums: use the board's actual thickness, not the overall module.
dpcb=display.Solids()[0].BoundingBox(); dtop,dbottom=dpcb.zmax,dpcb.zmin
# ANO top datum inherited from physically accepted wheel fit; PCB thickness from STEP.
pcbs=[s for s in ano.Solids() if s.BoundingBox().xlen>35 and s.BoundingBox().ylen>30 and s.BoundingBox().zlen<2]
assert len(pcbs)==1
apcb=pcbs[0].BoundingBox();atop,abottom=apcb.zmax,apcb.zmin
assert abs(atop-21.67)<.02
# A shallow guide ring surrounds the raised screen package with 0.25 mm per side.
# Its bottom stays above the PCB; four pads set depth and leave glass 0.2 mm clear.
glass=display.Solids()[13].BoundingBox();g=.25;wall=.8;gz=dtop+.2
outer=box(glass.xmin-g-wall,glass.ymin-g-wall,gz,glass.xlen+2*(g+wall),glass.ylen+2*(g+wall),24-gz+.05)
inner=box(glass.xmin-g,glass.ymin-g,gz-.1,glass.xlen+2*g,glass.ylen+2*g,24-gz+.3)
front=front.union(outer.cut(inner))
mounts=[]; collars={}; screws={}
def mount(name,x,y,top,bottom,r=2.45,spacer=2,pilot=3):
 global front
 # M2 x 6 pointed screw, through a printed insulating spacer and PCB.
 front=front.union(cyl(x,y,top,r,24-top+.05)).cut(cyl(x,y,top-.1,.8,pilot+.1))
 collar=cyl(x,y,bottom-spacer,2.1,spacer).cut(cyl(x,y,bottom-spacer-.1,1.15,spacer+.2)).val()
 collars[name+'-collar']=collar
 # Conservative head envelope, unthreaded screw envelope for clearance checks.
 screw=cyl(x,y,bottom-spacer-2,2,2).union(cyl(x,y,bottom-spacer,1,6)).val();screws[name+'-screw']=screw
 mounts.append(dict(name=name,xy=[x,y],pcb_thickness=top-bottom,spacer_mm=spacer,screw_mm=6,penetration_mm=6-spacer-(top-bottom),pilot_depth_mm=pilot,outer_skin_mm=26-(top+pilot)))
for i,(x,y) in enumerate(itertools.product([14.22,49.78],[16.76,47.24])):mount('ano-'+str(i+1),x,y,atop,abottom)
for i,y in enumerate([66.54,97.02]):mount('screen-'+str(i+1),58.9875,y,dtop,dbottom,2.1,1.4,3.6)
clips={};pads={}
for name,sy,fy,r in [('lower',61.4,66,2.15),('upper',101.2,97.5,2.0)]:
 sx=7;fx=4.3; foot_r=1.15
 front=front.union(cyl(fx,fy,dtop,foot_r,24-dtop+.05))
 # Clip seats against a column; its PCB contact leaves 0.3mm for a pad.
 shoulder=dbottom-.3; rear=shoulder-1.2
 column=cyl(sx,sy,shoulder,r,24-shoulder+.05)
 if name=="upper":column=column.intersect(box(0,99.81,0,64,5.19,26))
 front=front.union(column).cut(cyl(sx,sy,shoulder-.1,.8,5.3))
 a=cyl(sx,sy,rear,r,1.2);b=cyl(fx,fy,rear,foot_r,1.2)
 arm=box(min(sx,fx)-1.15,min(sy,fy),rear,abs(sx-fx)+2.3,abs(sy-fy),1.2)
 clip=a.union(b).union(arm).cut(cyl(sx,sy,rear-.1,1.15,1.4)).clean().val()
 clips['clip-'+name]=clip;pads['pad-'+name]=cyl(fx,fy,dbottom-.3,foot_r,.3).val()
 screws['clip-'+name+'-screw']=cyl(sx,sy,rear-2,2,2).union(cyl(sx,sy,rear,1,6)).val()
 mounts.append(dict(name='clip-'+name,xy=[sx,sy],screw_mm=6,penetration_mm=4.8,pilot_depth_mm=5.2,outer_skin_mm=26-(shoulder+5.2)))
front=front.clean().val()
tray=cq.importers.importStep(str(B/'cad/tray.step')).val()
bx,by,bz=p['battery_origin'];bw,bh,bt=p['battery'];battery=box(bx,by,bz,bw,bh,bt).val()
f=cq.importers.importStep(str(REPO/'hardware/mark-6/carrier-rev-a/reference/5400 ESP32 Feather V2.step')).val();fb=f.BoundingBox();fx,fy=p['feather_origin_xy'];fz=p['feather_pcb_z'];floor=fz-p['header_extension_below_pcb']
feather=box(fx,fy,floor,fb.xlen,fb.ylen,fb.zlen+p['header_extension_below_pcb']).val()
parts={'front':front,'display':display,'ano':ano,'tray':tray,'battery':battery,'feather-envelope':feather,**clips,**pads,**collars,**screws}
checks={}
# Screw engagement into pilots is intentional. Everything else must be disjoint.
for a,b in itertools.combinations(parts,2):
 if 'screw' in a or 'screw' in b:
  other=b if 'screw' in a else a
  if other=='front':continue
 checks[a+'/'+b]=parts[a].intersect(parts[b]).Volume()
bad={k:v for k,v in checks.items() if v>.005}
print('collisions',json.dumps(bad,indent=2),flush=True)
assert not bad,bad
assert all(m['outer_skin_mm']>=1.2 and m['pilot_depth_mm']-m['penetration_mm']>=.399 for m in mounts)
# Standalone blind-boss coupon reproduces the shortest mount and 2mm spacer stack.
coupon=box(0,0,0,36,14,1.33)
for x,dia in [(6,1.6),(18,1.7),(30,1.8)]:
 coupon=coupon.union(cyl(x,7,1.33,2.45,3)).cut(cyl(x,7,1.33,dia/2,3.1))
# A 1.6mm dummy board tab allows seating the real 6mm screw without electronics.
tab=box(0,0,0,10,10,1.6).cut(cyl(5,5,-.1,1.15,1.8)).val()
models={'front':bed(front.rotate((0,0,0),(1,0,0),180)),**{n:bed(s) for n,s in clips.items()},'ano-spacer-2mm':bed(collars['ano-1-collar']),'screen-spacer-1p4mm':bed(collars['screen-1-collar']),'pilot-coupon':coupon.val(),'coupon-dummy-board':tab}
mesh_report={}
for name,s in models.items():
 assert s.isValid() and len(s.Solids())==1,name
 path=R/'print'/f'mark7-mount-b-{name}.stl';cq.exporters.export(s,str(path),tolerance=.025,angularTolerance=.1)
 mesh=trimesh.load(path,force='mesh');assert mesh.is_watertight and mesh.body_count==1 and mesh.is_winding_consistent,name
 path.with_suffix('.3mf').write_bytes(trimesh.exchange.threemf.export_3MF(trimesh.Scene(mesh)))
 cq.exporters.export(s,str(R/'cad'/f'{name}.step'));mesh_report[name]=dict(watertight=True,single_body=True,extents_mm=mesh.extents.tolist())
assembly=cq.Assembly(name='Mark7_internal_mount_trial')
for name,s in parts.items():
 color=(.94,.91,.81) if name=='front' else (.3,.55,.8) if 'clip' in name or 'collar' in name else (.2,.3,.2)
 assembly.add(s,name=name,color=cq.Color(*color));cq.exporters.export(s,str(R/'preview'/f'{name}.stl'))
assembly.export(str(R/'cad/assembly.step'))
report=dict(status='Unpowered mounting candidate; screw fit, real solder/cables and retention not yet physically tested',mounts=mounts,glass_to_front_mm=.2,screen_guide_clearance_per_side_mm=.25,checks_mm3=checks,meshes=mesh_report,hardware='Eight M2 x 6 self-tapping screws from IMG_7822; four 2mm ANO collars, two 1.4mm screen collars; two 0.5mm nonconductive foam pads compressed to nominal 0.3mm',limitations=['Screw head envelope assumed 4mm diameter x 2mm tall; measure actual hardware','Printed pilot fit must pass coupon trial; do not force screws','Solder joints, wire bends and QT plug not modeled','Tray closure, Feather retention and rigid battery barrier remain unfinished'])
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k!='checks_mm3'},indent=2))
