"""Harmony D touch revision A: dimensioned proposal and UNPOWERED fit kit.
Run with Python 3.12, cadquery 2.6.1+, trimesh, numpy, scipy.
Every print export is unsliced geometry. Physical fit and touch behavior remain unqualified.
"""
from pathlib import Path
import cadquery as cq, trimesh, numpy as np
import math,json,hashlib,itertools
R=Path(__file__).resolve().parent; REPO=R.parents[2]
for d in ['cad','print','preview','reference']:(R/d).mkdir(exist_ok=True)
W,D,F,B,T=112.,94.,28.,64.,2.
a=math.degrees(math.atan2(B-F,D)); L=math.hypot(D,B-F); c=math.cos(math.radians(a)); sn=math.sin(math.radians(a)); wall=2.2; floor=2.4
LCDW,LCDH,LCDT=92.4468163653,61.0111907716,10.55048
lx=(W-LCDW)/2; ly=31.; glass_top=-1.6
parts={};prints={}; groups={}
def box(x,y,z,w,h,t):return cq.Workplane('XY').box(w,h,t,centered=False).translate((x,y,z)).val()
def cyl(x,y,z,r,h):return cq.Workplane('XY').circle(r).extrude(h).translate((x,y,z)).val()
def flat(s):return s.rotate((0,0,0),(1,0,0),a).translate((0,0,F))
def hexp(x,y,z,af,h):return cq.Workplane('XY').polygon(6,af/math.cos(math.pi/6)).extrude(h).translate((x,y,z)).val()
def wedge(x,y,z,w,d,zf,zb):return cq.Workplane('YZ').polyline([(y,z),(y+d,z),(y+d,zb),(y,zf)]).close().extrude(w).translate((x,0,0)).val()
def add(name,s,group,printable=False):
 assert s.isValid(),name
 parts[name]=s;groups[name]=group
 if printable:prints[name]=s
# Global body ends at the underside of the sloped lid with a 0.3 mm assembly gap.
tray=wedge(0,0,0,W,D,F-2.3/c,B-2.3/c)
tray=tray.cut(wedge(wall,wall,floor,W-2*wall,D-2*wall,F+(B-F)*wall/D,B-(B-F)*wall/D))
# Clear rear USB/Reset access well. Deliberately generous pending real plug rehearsal.
tray=tray.cut(box(13.8,D-4,14.5,14,6,12))
lid=box(0,0,-T,W,L,T)
# 0.3 mm lateral glass fit clearance; shelf surface is at -1.6 mm.
lid=lid.cut(box(lx-.3,ly-.3,-2.05,LCDW+.6,LCDH+.6,.45))
# Actual active area recovered from vendor STEP. 0.5 mm clearance per edge.
aw,ah=73.4468+1,48.97+1
lid=lid.cut(box(W/2-aw/2,ly+LCDH/2-ah/2,-2.1,aw,ah,2.3))
# Thin continuous touch band; skin thickness is a test parameter, default 1.2 mm.
lid=lid.cut(box(10,5,-2.05,92,18,.85))
centers=[20,38,56,74,92]
# Locate the glass by its outer edge, with four short stops away from connectors.
for x in [lx-.9,lx+LCDW+.3]:
 for y in [ly+8,ly+LCDH-14]:lid=lid.fuse(box(x,y,-3.2,.6,6,1.2))
closures=[(5,5),(W-5,5),(5,L-5),(W-5,L-5)]
for i,(x,u) in enumerate(closures,1):
 y=u*c;zt=F+u*sn-2.3*c
 # Vertical towers intersect the same sloped underside plane.
 tower=cyl(x,y,floor,3.4,zt-floor+3)
 tower=tower.intersect(wedge(0,0,0,W,D,F-2.3/c,B-2.3/c))
 tray=tray.fuse(tower)
 # Side-loaded brass pocket has a 2 mm retaining roof below the lid.
 tray=tray.cut(flat(hexp(x,u,-14.5,3.3,10.2)))
 tray=tray.cut(flat(box(x if x<W/2 else x-4.5,u-1.65,-14.5,4.5,3.3,10.2)))
 tray=tray.cut(flat(cyl(x,u,-4.4,1.3,2.3)))
 lid=lid.cut(cyl(x,u,-2.1,1.3,2.3)).cut(cyl(x,u,-.6,2.05,.8))
 add(f'brass-{i}',flat(hexp(x,u,-14.3,3.,10).cut(cyl(x,u,-14.4,1,10.3))),'hardware')
 add(f'closure-screw-{i}',flat(cyl(x,u,-8.6,1,8).fuse(cyl(x,u,-.6,1.6,1.3))),'hardware')
# Carrier mounting uses the actual PCB mounting coordinates transformed through +90 degrees.
carrier_x,carrier_y,carrier_z=9.,31.,4.4
mounts=[]
for ox,oy in [(9.635488,79.54),(55.355488,79.54),(9.635488,97.32),(55.355488,97.32)]:
 x=37.3-(oy-72);y=31+(ox-6.5);mounts.append((x,y))
 tray=tray.fuse(cyl(x,y,floor,2.7,2)).cut(cyl(x,y,.7,.85,4))
 spacer=cyl(x,y,6,2.2,2).cut(cyl(x,y,5.9,1.2,2.2))
 add(f'carrier-spacer-{len(mounts)}',spacer,'carrier',True)
# Component proxies reserve populated height, rather than treating the PCB as the whole part.
carrier=box(9,31,4.4,28.3,53.5,1.6)
for x,y in mounts:carrier=carrier.cut(cyl(x,y,4.3,1.2,1.8))
add('carrier-pcb-reference',carrier,'carrier')
feather=box(9,31,6,28.3,53.5,18.67)
for x,y in mounts:feather=feather.cut(cyl(x,y,5.9,2.3,2.2))
add('feather-and-sockets-envelope',feather,'carrier')
# Battery reserve includes the previous measured-build allowance. Floor foam remains a supply check.
bx,by,bw,bh=50.,25.,50.5,62.5
add('battery-envelope',box(bx,by,2.9,bw,bh,8.1),'battery')
add('battery-cushion-reference',box(bx,by,2.4,bw,bh,.5),'battery')
# Raised rigid cover, open sides, and retaining edges keep fasteners away from the pouch.
for x,y,w,h in [(bx-1.4,by-1.4,bw+2.8,1),(bx-1.4,by+bh+.4,bw+2.8,1),(bx-1.4,by,1,bh),(bx+bw+.4,by,1,bh)]:tray=tray.fuse(box(x,y,floor,w,h,9.6))
# Lead exit at front edge; 12 mm wide. Actual lead direction must be checked.
tray=tray.cut(box(bx+17,by-2,7,12,3,6))
cover=box(bx-1,by-1,12.5,bw+2,bh+2,1.6)
for i,(x,y) in enumerate([(bx-4,by+10),(bx+bw+4,by+10),(bx-4,by+bh-10),(bx+bw+4,by+bh-10)],1):
 tray=tray.fuse(cyl(x,y,floor,2.8,10.1)).cut(cyl(x,y,8,.85,4.6))
 cover=cover.fuse(box(min(x,bx-1),y-2,12.5,abs(x-(bx-1)) if x<bx else 5,4,1.6)) if x<bx else cover.fuse(box(bx+bw+1,y-2,12.5,3,4,1.6))
 cover=cover.fuse(cyl(x,y,12.5,2.6,1.6)).cut(cyl(x,y,12.4,1.2,1.8))
add('battery-cover',cover,'battery',True)
# MPR121 QT Rev E outline and mounting holes extracted from Adafruit Eagle CAD.
mx,my,mz=64.,3.,5.4
mpr=box(mx,my,mz,33.02,19.177,1.6)
for i,dx in enumerate([2.54,30.48],1):
 x,y=mx+dx,my+2.667
 mpr=mpr.cut(cyl(x,y,mz-.1,1.25,1.8))
 tray=tray.fuse(cyl(x,y,floor,2.7,3)).cut(cyl(x,y,1.8,.85,3.7))
 sp=cyl(x,y,7,2.2,2).cut(cyl(x,y,6.9,1.2,2.2));add(f'touch-board-spacer-{i}',sp,'touch',True)
add('mpr121-pcb-reference',mpr,'touch')
mpr_reserve=box(mx,my,7,33.02,19.177,5)
for dx in [2.54,30.48]:mpr_reserve=mpr_reserve.cut(cyl(mx+dx,my+2.667,6.9,2.3,2.2))
add('mpr121-populated-reserve',mpr_reserve,'touch')
# 12 x 14 mm electrodes. Two 6 mm copper-tape strips per electrode, electrically bonded.
for i,x in enumerate(centers):add(f'electrode-{i}',flat(box(x-6,7,-1.25,12,14,.05)),'touch')
# Four LCD edge clips, with positive stops and 2 mm under-head spacers.
for i,(x,u) in enumerate([(6,45),(6,78),(106,45),(106,78)],1):
 lid=lid.fuse(cyl(x,u,-3.7,2.6,1.7)).cut(cyl(x,u,-3.8,.85,2.5))
 clip=box(3 if x<56 else 100.6,u-3,-5.3,8.4,6,1.6).cut(cyl(x,u,-5.4,1.2,1.8))
 add(f'lcd-clip-{i}',flat(clip),'display',True)
 spacer=cyl(x,u,-7.3,2.2,2).cut(cyl(x,u,-7.4,1.2,2.2));add(f'lcd-clip-spacer-{i}',flat(spacer),'display',True)
# Reuse the exact vendor STEP, front glass toward the lid (source glass front is minimum Z).
vpath=REPO/'hardware/mark-6/carrier-rev-a/reference/waveshare-29318/3.5inch_Capacitive_Touch_LCD_3Dand2D/3.5inch_Capacitive_Touch_LCD.step'
if not vpath.exists():vpath=R/'reference/waveshare-vendor-original.step'
lcd=cq.importers.importStep(str(vpath)).val().rotate((0,0,0),(1,0,0),180)
b=lcd.BoundingBox();lcd=lcd.translate((lx-b.xmin,ly-b.ymin,glass_top-b.zmax))
add('waveshare-vendor-module',flat(lcd),'display')
# Rounded cable saddles are removable; route cables around the battery, never beneath its pouch.
for i,y in enumerate([50,65],1):
 x=42
 tray=tray.fuse(cyl(x,y,floor,2.5,3)).cut(cyl(x,y,1.5,.85,4))
 saddle=box(x-3,y-4,5.4,6,8,2).cut(box(x-1.4,y-4.1,5.3,2.8,8.2,1.2)).cut(cyl(x+1.8,y,5.3,1.1,2.3))
 # Saddle mounting screw shares no pouch space; use a simpler open guide for the fit print.
 saddle=box(x-3,y-4,5.4,9,8,3).cut(box(x+3,y-4.1,5.3,2,8.2,1.8)).cut(cyl(x,y,5.3,1.2,3.3))
 add(f'cable-clamp-{i}',saddle,'base',True)
add('base-tray',tray.clean(),'base',True);add('sloped-face',flat(lid.clean()),'lid',True)
# Touch coupons: identical electrode geometry and lead exit, three candidate skins.
for skin in [.8,1.2,1.6]:
 coupon=box(0,0,0,96,26,3).cut(box(2,2,skin,92,22,3))
 for xx in [12,30,48,66,84]:coupon=coupon.cut(box(xx-1,23,skin,2,3,3))
 prints[f'touch-coupon-{str(skin).replace(".","p")}mm']=coupon
# Cold-fit standoff pocket and independent M2 clearance tests.
cp=box(0,0,0,20,14,14).cut(hexp(6,7,1.8,3.3,10.2)).cut(box(-.1,5.35,1.8,6.1,3.3,10.2)).cut(cyl(6,7,11.9,1.3,2.2)).cut(cyl(15,7,-.1,1.3,14.2));prints['fastener-coupon']=cp
# Full 1:1 hardware envelopes for dry layout without using powered boards.
for name in ['battery-envelope','feather-and-sockets-envelope','mpr121-populated-reserve']:
 s=parts[name];b=s.BoundingBox();prints['dummy-'+name]=s.translate((-b.xmin,-b.ymin,-b.zmin))
report={'status':'UNPOWERED FIT CANDIDATE; not released for powered assembly','enclosure_mm':{'width':W,'depth':D,'front_height':F,'rear_height':B,'face_length':L,'angle_degrees':a},'sources':{'lcd_step_bounds_mm':[LCDW,LCDH,LCDT],'lcd_active_area_mm':[73.4468,48.97],'mpr121_outline_mm':[33.02,19.177],'carrier_mm':[53.5,28.3,1.6],'user_measured_carrier_stack_mm':19.77,'reserved_stack_mm':20.27},'print_parts':{},'intersections':[]}
# Export canonical CAD and assembled reference meshes.
for name,s in parts.items():
 cq.exporters.export(s,str(R/'cad'/f'{name}.step'))
 cq.exporters.export(s,str(R/'preview'/f'{name}.stl'),tolerance=.08,angularTolerance=.15)
# Check every printable piece as a single watertight solid, then put it on the bed.
meshes={}
for name,s in prints.items():
 if name.startswith(('sloped-face','lcd-clip')):s=s.rotate((0,0,0),(1,0,0),-a)
 if name=='sloped-face':s=s.rotate((0,0,0),(1,0,0),180)
 if name.startswith('touch-coupon'):pass
 b=s.BoundingBox();s=s.translate((-b.xmin,-b.ymin,-b.zmin))
 assert s.isValid() and len(s.Solids())==1,(name,len(s.Solids()))
 cq.exporters.export(s,str(R/'cad'/f'{name}-print.step'))
 path=R/'print'/f'{name}.stl';cq.exporters.export(s,str(path),tolerance=.05,angularTolerance=.1)
 mesh=trimesh.load(path,force='mesh');mesh.apply_translation(-mesh.bounds[0]);mesh.export(path);assert mesh.is_watertight and len(mesh.split())==1,name
 assert max(mesh.extents)<256 and abs(mesh.bounds[0,2])<1e-5,name
 meshes[name]=mesh
 report['print_parts'][name]={'extents_mm':mesh.extents.tolist(),'watertight':True,'solids':1,'bed_z':float(mesh.bounds[0,2]),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
# Pairwise geometry checks include all actual solids and all reserved component volumes.
check_names=[n for n in parts if not n.startswith(('electrode','brass','closure-screw'))]
for n,m in itertools.combinations(check_names,2):
 # Modules intentionally represented by adjacent reference PCB/body volumes; no exclusions needed.
 b1,b2=parts[n].BoundingBox(),parts[m].BoundingBox()
 if not all(min(getattr(b1,k+'max'),getattr(b2,k+'max'))-max(getattr(b1,k+'min'),getattr(b2,k+'min'))>1e-4 for k in ['x','y','z']):continue
 v=parts[n].intersect(parts[m]).Volume()
 if v>.015:report['intersections'].append({'a':n,'b':m,'volume_mm3':round(v,4)})
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n');(R/'assembly-groups.json').write_text(json.dumps(groups,indent=2))
assert not report['intersections'],report['intersections']
# Lay out separate plates with explicit quantities. Geometry only, not Bambu machine settings.
plates={'01-touch-tests':[(f'touch-coupon-{s}mm',0,i*34) for i,s in enumerate(['0p8','1p2','1p6'])]+[('fastener-coupon',110,0)],'02-shell-fit':[('base-tray',0,0),('sloped-face',125,0)],'03-internals':[],'04-dummies':[]}
small=[n for n in meshes if n not in ['base-tray','sloped-face'] and not n.startswith(('touch-coupon','fastener-coupon','dummy-'))]
x=y=0;rowh=0
for n in small:
 w,h=meshes[n].extents[:2]
 if x+w>230:x=0;y+=rowh+8;rowh=0
 plates['03-internals'].append((n,x,y));x+=w+8;rowh=max(rowh,h)
x=0
for n in meshes:
 if n.startswith('dummy-'):plates['04-dummies'].append((n,x,0));x+=meshes[n].extents[0]+10
report['plates']={}
for name,layout in plates.items():
 scene=trimesh.Scene();bounds=[]
 for n,x,y in layout:
  mesh=meshes[n].copy();mesh.apply_translation((x,y,0))
  for old in bounds:assert not ((np.minimum(old[1,:2],mesh.bounds[1,:2])-np.maximum(old[0,:2],mesh.bounds[0,:2]))>0).all(),(name,n)
  bounds.append(mesh.bounds);scene.add_geometry(mesh,node_name=n,geom_name=n)
 assert max(scene.extents[:2])<256,(name,scene.extents)
 p=R/'print'/f'{name}.3mf';p.write_bytes(trimesh.exchange.threemf.export_3MF(scene));loaded=trimesh.load(p)
 assert len(loaded.geometry)==len(layout)
 report['plates'][name]={'objects':len(layout),'extent_mm':scene.extents.tolist(),'roundtrip_ok':True,'sliced':False}
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n');(R/'assembly-groups.json').write_text(json.dumps(groups,indent=2))
print(json.dumps({'enclosure':report['enclosure_mm'],'collisions':report['intersections'],'parts':len(prints),'plates':report['plates']},indent=2))
