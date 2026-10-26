"""Matched carrier shell, revision E. Measured October 25; unpowered fit candidate."""
from pathlib import Path
import json,itertools,math,xml.etree.ElementTree as ET
import cadquery as cq
import trimesh
R=Path(__file__).resolve().parent;REPO=R.parents[2];OLD=R.parent/'ano-mount-rev-b'
for n in ['cad','preview']: (R/n).mkdir(exist_ok=True)
# Reuse precisely the accepted board mounting geometry without exporting/replacing it.
source=(OLD/'build.py').read_text()
# Preserve accepted screen/ANO locations; soften the face and strengthen screen bosses.
source=source.replace(".faces('>Z').edges().chamfer(1)", ".faces('>Z').edges().fillet(1.2)")
source=source.replace('2.1,1.4,3.6)', '2.45,1.4,3.6)')
source=source.replace('top-.1,.8,pilot+.1', "top-.1,(.85 if name.startswith('screen-') else .8),pilot+.1")
ns={'__file__':str(OLD/'build.py')}
exec(compile(source[:source.index('tray=cq.importers.importStep')],str(OLD/'build.py'),'exec'),ns)
box,cyl=ns['box'],ns['cyl'];front=cq.Workplane(obj=ns['front']);back=-8;floor=-6.4
parts={n:ns[n] for n in ['display','ano']};parts.update(ns['clips']);parts.update(ns['pads']);parts.update(ns['collars']);parts.update(ns['screws'])
def rounded(w,h,z,t,r):return cq.Workplane('XY').box(w,h,t,centered=(True,True,False)).edges('|Z').fillet(r).translate((32,52.5,z))
outer=rounded(64,105,back,32,5)
tray=outer.faces('<Z').edges().fillet(1.2).cut(rounded(60.8,101.8,floor,32,3.4))
# Tongue locates the joint; interruptions provide cable freedom and screw clearance.
lip=rounded(60.3,101.3,22,2.05,3.15).cut(rounded(58.7,99.7,21.9,2.3,2.35))
front=front.union(lip)
def hex_prism(x,y,z,af,h):
 return cq.Workplane('XY').polygon(6,af/math.cos(math.pi/6)).extrude(h).translate((x,y,z))
closing=[];closure_positions=[(3.5,10),(60.5,10),(20,102.1),(44,102.1)]
for i,(x,y) in enumerate(closure_positions):
 if y>100:
  col=box(x-3,100.1,.6,6,4,23.45)
  # Local receiver slots in the top wall; 0.65mm outer wall remains until assembled.
  tray=tray.cut(box(x-3.25,99.85,.6,6.5,4.5,24))
  foot=cyl(x,y,floor,2.8,7).intersect(box(x-4,100.35,floor,8,5,7.1))
 else:
  col=cyl(x,y,.6,2.8,23.45).intersect(box(1.85,0,.5,60.3,105,24))
  foot=cyl(x,y,floor,2.8,7)
 front=front.union(col).cut(hex_prism(x,y,.5,3.25,11.7)).cut(cyl(x,y,12.1,1.15,14))
 parts[f'closure-standoff-{i+1}']=hex_prism(x,y,2.2,3,10).cut(cyl(x,y,2.1,1,10.2)).val()
 parts[f'closure-front-screw-{i+1}']=cyl(x,y,26,1.6,1.3).union(cyl(x,y,10,1,16)).val()
 # Rear M2x6 head seats at z=-1; driver reaches through a 7mm deep rear recess.
 tray=tray.union(foot).cut(cyl(x,y,back-.1,2.2,7.1)).cut(cyl(x,y,-1.1,1.15,1.8))
 screw=cyl(x,y,-2.3,1.6,1.3).union(cyl(x,y,-1,1,6)).val();parts[f'closure-screw-{i+1}']=screw
 closing.append(dict(xy=[x,y],rear_screw_mm=6,front_screw_mm=16,rear_head_seat_z=-1,front_head_seat_z=26,rear_thread_engagement_mm=2.8,front_thread_engagement_mm=2.2,standoff_length_mm=10,standoff_af_mm=3,pocket_af_mm=3.25,pocket_roof_z=12.2))
# Feather rotated 180 degrees in plan: USB right; JST battery plug faces the bay.
fpath=REPO/'hardware/mark-6/carrier-rev-a/reference/5400 ESP32 Feather V2.step'
f=cq.importers.importStep(str(fpath)).val();b=f.BoundingBox();f=f.translate((6-b.xmin,77-b.ymin,1.5-b.zmin)).rotate((32.495,88.43,0),(32.495,88.43,1),180)
parts['feather']=f
# Derive header reservations from the actual 1mm pin holes in the PCB STEP.
pcb=f.Solids()[0];pb=pcb.BoundingBox();header_holes=[]
for face in pcb.Faces():
 b=face.BoundingBox()
 if face.geomType()=='CYLINDER' and abs(b.xlen-1)<.02 and abs(b.ylen-1)<.02 and abs(b.zlen-1.57)<.02:header_holes.append(((b.xmin+b.xmax)/2,(b.ymin+b.ymax)/2))
for i,yy in enumerate(sorted(set(round(y,2) for x,y in header_holes))):
 xs=[x for x,y in header_holes if abs(y-yy)<.02]
 parts[f'header-reservation-{i}']=box(min(xs)-1.27,yy-1.27,-5.9,max(xs)-min(xs)+2.54,2.54,7.4).val()
for i,(x,y) in enumerate(itertools.product([9.635,55.355],[79.54,97.32])):
 tray=tray.union(cyl(x,y,floor,2.1,1.7)).cut(cyl(x,y,-7.5,.8,2.9))
 parts[f'feather-screw-{i+1}']=cyl(x,y,3.07,2,2).union(cyl(x,y,-2.93,1,6)).val()
# USB plug is measured 10mm wide; reserve 12mm width and provisional 7mm height.
# Measured carrier underside to USB metal bottom is 14 mm.
# Vendor metal housing height supplies the remaining center offset (4.2 mm).
carrier_bottom=-4.7
usb_metal_bottom=carrier_bottom+14.0
usb_y=88.44;usb_z=usb_metal_bottom+2.1
feather_shift=usb_z-4.2
tray=tray.cut(box(58,usb_y-6,usb_z-4,8,12,8))
# Small adjoining service notch for a thin plastic tool toward Reset (unplug USB).
tray=tray.cut(box(61,93.8,6+feather_shift,5,2,3))
parts['usb-plug-reservation']=box(58.99,usb_y-5.5,usb_z-3.5,10,11,7).val()
# Current total 20mm was measured by Dave. Add 0.5mm above that for this review.
wire_envelope=box(pb.xmin,pb.ymin,-5.9,pb.xlen,pb.ylen,20.5).val()
# Battery base pad 0.5mm; 0.75mm lateral clearance; no compression from cover.
parts['battery']=box(6.75,5,-5.9,50.5,62.5,8.1).val()
parts['battery-pad']=box(6.75,5,floor,50.5,62.5,.5).val()
for x,y,w,h in [(5.2,3.45,53.6,.8),(5.2,68.25,53.6,.8),(5.2,4.25,.8,64),(58,4.25,.8,64)]:tray=tray.union(box(x,y,floor,w,h,9.4))
# Lead exit toward the board bay. Exact pack lead position remains to be checked.
tray=tray.cut(box(39,67.8,-2.5,12,2,6))
cover=box(5.2,3.45,4,53.6,65.6,1.6)
for x in [3.5,60.5]:
 for y in [30,60]:
  boss=cyl(x,y,floor,2.45,10.4).intersect(box(1.85,0,floor,60.3,105,11))
  tray=tray.union(boss).cut(cyl(x,y,-1.2,.8,5.3))
  ear=cyl(x,y,4,2.45,1.6).intersect(box(1.85,0,4,60.3,105,2))
  bridge=box(min(x,6),y-2,4,abs(x-(6 if x<32 else 58)),4,1.6) if x<32 else box(58,y-2,4,x-58,4,1.6)
  cover=cover.union(ear).union(bridge).cut(cyl(x,y,3.9,1.15,1.8))
  parts[f'cover-screw-{x}-{y}']=cyl(x,y,5.6,2,2).union(cyl(x,y,-.4,1,6)).val()
for x,y in closure_positions:cover=cover.cut(cyl(x,y,3.9,3.05,1.8))
cover=cover.cut(box(39,66,3.9,12,4,2))
# Rounded printed tie bars in the inter-board bay retain cables beside, not on, pouch.
for x in []:
 tie=box(x-3,71,floor,6,4,4).cut(box(x-1.5,70.9,floor+.8,3,4.2,2))
 tray=tray.union(tie)
# JST plug reservation derived from rotated battery connector, directed toward bay.
parts['jst-plug-reservation']=box(42.96,71.75,3.2,7.9,5.5,5.0).val()
# Sideways QT plug on rotated Feather. Harness and bend radius still need dry fit.
parts['qt-plug-reservation']=box(29.65,81.16,4.3,6,6,3.5).val()
for x,y in closure_positions[:2]:
 relief=cyl(x,y,.6,3.05,24).intersect(box(1.6,0,.6,60.8,105,24))
 tray=tray.cut(relief)
parts['battery-cover']=cover.clean().val();parts['tray']=tray.clean().val();parts['front']=front.clean().val()

# Apply the carrier layout without regenerating the fabricated PCB.
import importlib.util
spec=importlib.util.spec_from_file_location('carrier_design',REPO/'hardware/mark-7/carrier-rev-a/design.py')
carrier_design=importlib.util.module_from_spec(spec);spec.loader.exec_module(carrier_design)
headers=carrier_design.headers;position=carrier_design.position;mount_points=carrier_design.mounts
for name in list(parts):
 if name.startswith(('header-reservation','feather-screw')): del parts[name]
for name in ['feather','jst-plug-reservation','qt-plug-reservation']:
 parts[name]=parts[name].translate((0,0,feather_shift))
parts['carrier']=cq.importers.importStep(str(REPO/'hardware/mark-7/carrier-rev-a/mechanical/carrier.step')).val()
# The measured total includes the actual sockets; their individual height remains unmeasured.
for head in ['JP1','JP3']:
 pts=[position(h) for h in headers if h['header']==head];xs=[p[0] for p in pts];y=pts[0][1]
 socket_height=8.51+(feather_shift-6.45)
 parts[head+'-socket']=box(min(xs)-1.525,y-1.205,-3.1,max(xs)-min(xs)+3.05,2.41,socket_height).val()
 parts[head+'-male-spacer']=box(min(xs)-1.27,y-1.27,-3.1+socket_height,max(xs)-min(xs)+2.54,2.54,2.54).val()
for i,(x,y) in enumerate(mount_points,1):
 parts[f'carrier-spacer-{i}']=cyl(x,y,-3.1,2,2).cut(cyl(x,y,-3.2,1.2,2.2)).val()
 parts[f'carrier-screw-{i}']=cyl(x,y,-1.1,2,2).union(cyl(x,y,-7.1,1,6)).val()
for i,h in enumerate(headers):
 x,y=position(h)
 parts[f'socket-tail-{i}']=box(x-.32,y-.32,-5.74,.64,.64,1.04).val()
# Conservative full-footprint envelope, 0.5 mm above Dave's 19.77 mm measurement.
measured_top=carrier_bottom+19.77
measured_envelope=box(pb.xmin,pb.ymin,carrier_bottom,pb.xlen,pb.ylen,20.27).val()
start=cq.Vector(65,94.6,7.3+feather_shift);end=cq.Vector(46.1475,93.51,5.45+feather_shift)
v=end-start;reset_access=cq.Solid.makeCylinder(.35,v.Length,start,v.normalized())
print('Geometry built; checking fit',flush=True)
checks={};intentional=[]
for a,b in itertools.combinations(parts,2):
 # Modeled screw shafts intentionally engage plastic pilots. PCB holes are modeled.
 if ('screw' in a or 'screw' in b) and ('front' in [a,b] or 'tray' in [a,b]):
  intentional.append(a+'/'+b);continue
 # Fast reject disjoint bounding boxes before costly solid booleans.
 ba,bb=parts[a].BoundingBox(),parts[b].BoundingBox()
 if any(min(getattr(ba,k+'max'),getattr(bb,k+'max'))<=max(getattr(ba,k+'min'),getattr(bb,k+'min'))+1e-7 for k in 'xyz'):
  checks[a+'/'+b]=0.;continue
 checks[a+'/'+b]=parts[a].intersect(parts[b]).Volume()
for name in ['front','display','ano','battery-cover']+[n for n in parts if n.startswith(('clip','screen-','ano-'))]:
 checks['measured-stack-envelope/'+name]=measured_envelope.intersect(parts[name]).Volume()
for name in ['display','ano','feather','front','battery-cover','tray']:
 checks['reset-access/'+name]=reset_access.intersect(parts[name]).Volume()
bad={k:round(v,6) for k,v in checks.items() if v>.005}
print('Collisions:',json.dumps(bad),flush=True)
report=dict(status='Unpowered fit candidate; physical validation pending',as_of='2026-10-25',
 body_mm=[64,105,34],outer_perimeter_fillet_mm=1.2,plan_corner_radius_mm=5,
 measurements={'carrier_underside_to_highest_feather_mm':19.77,'carrier_underside_to_usb_metal_bottom_mm':14},
 carrier_bottom_z=carrier_bottom,measured_top_z=measured_top,reserved_top_z=measured_top+.5,
 usb_center_z=usb_z,usb_opening_mm=[12,8],feather_shift_from_old_tray_mm=feather_shift,
 screen_boss_diameter_mm=4.9,screen_pilot_diameter_mm=1.7,closure_clearance_diameter_mm=2.3,closure=closing,
 checks_mm3=checks,collisions=bad,intentional_thread_intersections=intentional,
 limitations=['Actual socket tail protrusion and solder clearance require dry fit',
 'Individual socket height and USB metal height are vendor assumptions; total stack and USB bottom are user measured',
 'Wire bends, USB plug insertion, Reset tool access, and printed pilot grip require physical checks',
 'Screen and ANO positions unchanged; new front required for closure',
 'Cold-fit hex pocket and thin top-column walls require coupon test before full shell print',
 'SD card removal still requires opening the shell; no external SD slot in this revision',
 'Closed-case Bluetooth, charging temperature, and battery restraint require physical tests'])
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
assert not bad,bad
for name,s in parts.items():
 cq.exporters.export(s,str(R/'preview'/f'{name}.stl'),tolerance=.05)
cq.exporters.export(measured_envelope,str(R/'preview/measured-stack-envelope.stl'))
cq.exporters.export(reset_access,str(R/'preview/reset-access.stl'))
for name in ['front','tray','battery-cover']:
 s=parts[name];assert s.isValid() and len(s.Solids())==1,name
 cq.exporters.export(s,str(R/'cad'/f'{name}.step'))
 mesh=trimesh.load(R/'preview'/f'{name}.stl',force='mesh')
 assert mesh.is_watertight and mesh.body_count==1,name
assembly=cq.Assembly(name='Mark7_shell_E')
for name,s in parts.items():assembly.add(s,name=name)
assembly.export(str(R/'cad/assembly.step'))
print(json.dumps({k:v for k,v in report.items() if k not in ['checks_mm3','intentional_thread_intersections']},indent=2),flush=True)
