"""Complete Mark-7 enclosure review. No print release: harness fit remains provisional."""
from pathlib import Path
import json,itertools,math,xml.etree.ElementTree as ET
import cadquery as cq
import trimesh
R=Path(__file__).resolve().parent;REPO=R.parents[2];OLD=R.parent/'ano-mount-rev-b'
for n in ['cad','preview']: (R/n).mkdir(exist_ok=True)
# Reuse precisely the accepted board mounting geometry without exporting/replacing it.
source=(OLD/'build.py').read_text();ns={'__file__':str(OLD/'build.py')}
exec(compile(source[:source.index('tray=cq.importers.importStep')],str(OLD/'build.py'),'exec'),ns)
box,cyl=ns['box'],ns['cyl'];front=cq.Workplane(obj=ns['front']);back=-8;floor=-6.4
parts={n:ns[n] for n in ['display','ano']};parts.update(ns['clips']);parts.update(ns['pads']);parts.update(ns['collars']);parts.update(ns['screws'])
def rounded(w,h,z,t,r):return cq.Workplane('XY').box(w,h,t,centered=(True,True,False)).edges('|Z').fillet(r).translate((32,52.5,z))
outer=rounded(64,105,back,32,5)
tray=outer.faces('<Z').edges().chamfer(1).cut(rounded(60.8,101.8,floor,32,3.4))
# Tongue locates the joint; interruptions provide cable freedom and screw clearance.
lip=rounded(60.3,101.3,22,2.05,3.15).cut(rounded(58.7,99.7,21.9,2.3,2.35))
front=front.union(lip)
closing=[];closure_positions=[(3.5,10),(60.5,10),(20,102.2),(44,102.2)]
for i,(x,y) in enumerate(closure_positions):
 if y>100:
  col=box(x-3,100.35,.6,6,3.65,23.45)
  # Local receiver slots in the top wall; 0.8mm outer wall remains until assembled.
  tray=tray.cut(box(x-3.25,100.1,.6,6.5,4.1,24))
  foot=cyl(x,y,floor,2.8,7).intersect(box(x-4,100.35,floor,8,5,7.1))
 else:
  col=cyl(x,y,.6,2.8,23.45).intersect(box(1.85,0,.5,60.3,105,24))
  foot=cyl(x,y,floor,2.8,7)
 front=front.union(col).cut(cyl(x,y,.5,.8,7.3))
 # Rear M2x8 head seats at z=-1; driver reaches through a 7mm deep rear recess.
 tray=tray.union(foot).cut(cyl(x,y,back-.1,2.2,7.1)).cut(cyl(x,y,-1.1,1.15,1.8))
 screw=cyl(x,y,-3,2,2).union(cyl(x,y,-1,1,8)).val();parts[f'closure-screw-{i+1}']=screw
 closing.append(dict(xy=[x,y],length_mm=8,rear_head_seat_z=-1,engagement_mm=6.4,pilot_depth_mm=7.2))
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
 tray=tray.union(cyl(x,y,floor,2.1,7.9)).cut(cyl(x,y,-3.5,.8,5.1))
 parts[f'feather-screw-{i+1}']=cyl(x,y,3.07,2,2).union(cyl(x,y,-2.93,1,6)).val()
# USB plug is measured 10mm wide; reserve 12mm width and provisional 7mm height.
usb_y=88.44;usb_z=4.2
tray=tray.cut(box(58,usb_y-6,usb_z-4,8,12,8))
# Small adjoining service notch for a thin plastic tool toward Reset (unplug USB).
tray=tray.cut(box(61,93.8,6,5,2,3))
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
for x in [13,51]:
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
# Snap latch reservations are annotations only, not modeled spring clips.
for x in [1.85,58.15]:
 for y in [26,50]:
  zone=box(x,y,18,4,8,6).val();cq.exporters.export(zone,str(R/'preview'/f'future-snap-{x}-{y}.stl'))
# Proposed service path for Reset; location from SW2 in the vendor board file.
start=cq.Vector(65,94.6,7.3);end=cq.Vector(46.1475,93.51,5.45);v=end-start
reset_access=cq.Solid.makeCylinder(.35,v.Length,start,v.normalized())
checks={};intentional=[]
# Interface contact and modeled screw engagement are expected. Header holes contain pins.
for a,b in itertools.combinations(parts,2):
 skip=('screw' in a or 'screw' in b) and ('front' in [a,b] or 'tray' in [a,b])
 if skip:intentional.append(a+'/'+b);continue
 checks[a+'/'+b]=parts[a].intersect(parts[b]).Volume()
# Full measured-height reservation must clear the faceplate hardware and battery cover.
for name,s in parts.items():
 if name in ['front','display','ano','battery-cover'] or name.startswith(('clip','screen-','ano-')):
  checks['measured-feather-envelope/'+name]=wire_envelope.intersect(s).Volume()
for name in ['display','ano','feather','front','battery-cover']:
 checks['reset-access/'+name]=reset_access.intersect(parts[name]).Volume()
bad={k:round(v,6) for k,v in checks.items() if v>.005};print('COLLISIONS',json.dumps(bad,indent=2),flush=True)
assert not bad, bad
# Export reviewed geometry; this is not manufacturing qualification.
for name,s in parts.items():cq.exporters.export(s,str(R/'preview'/f'{name}.stl'),tolerance=.05)
cq.exporters.export(wire_envelope,str(R/'preview/measured-wire-envelope.stl'));cq.exporters.export(reset_access,str(R/'preview/reset-access.stl'))
meshreport={}
for name in ['front','tray','battery-cover']:
 s=parts[name];assert s.isValid() and len(s.Solids())==1,name
 cq.exporters.export(s,str(R/'cad'/f'{name}.step'))
 mesh=trimesh.load(R/'preview'/f'{name}.stl',force='mesh');meshreport[name]=dict(watertight=bool(mesh.is_watertight),single_body=mesh.body_count==1)
 assert mesh.is_watertight and mesh.body_count==1,name
assembly=cq.Assembly(name='Mark7_rear_review_C')
for name,s in parts.items():assembly.add(s,name=name)
assembly.export(str(R/'cad/assembly.step'))
report=dict(status='Design review only; not a print release',size_mm=[64,105,34],measured_feather_total_mm=20,reserved_total_mm=20.5,assumed_header_below_pcb_mm=7.4,usb_socket_width_reported_mm=9,usb_plug_width_reported_mm=10,usb_opening_mm=[12,8],battery_cover_gap_mm=1.8,closure=closing,checks_mm3=checks,collisions=bad,meshes=meshreport,intentional_thread_intersections=intentional,limitations=['PCB-to-pin-bottom datum still assumed 7.4mm; user measured total thickness only','USB plug height, cable bends and actual JST/QT plug bodies not measured; connector proxies are approximate','Existing faceplate printing now lacks closure bosses and locating lip; new front required for closure','Snap clips reserved as later closure option; not designed or fatigue-qualified','Battery lead exit location and cushioning fit need physical check','Metal display already overlaps antenna in plan; Bluetooth range needs closed-case testing'])
(R/'validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k not in ['checks_mm3','intentional_thread_intersections']},indent=2))
