#!/usr/bin/env python3
"""Build the September 26 mechanical trial. Does not change carrier electronics."""
from pathlib import Path
import hashlib,json,sys
import cadquery as cq
import trimesh,numpy as np
H=Path(__file__).resolve().parent
C=H.parents[2]/'hardware/mark-6/carrier-rev-a'
sys.path.insert(0,str(C))
from display_model import load_display,DISPLAY_RECT,ACTIVE_RECT
for d in ['print','cad','preview']: (H/d).mkdir(exist_ok=True)
W,L=74,178
# Reuse the tested tray, lip, recess and board-gauge geometry without exporting R1.
base=H.parent/'fit-prototype/build.py'
ns={'__file__':str(base),'__name__':'baseline_geometry'}
exec(compile(base.read_text().split('# All print files')[0],str(base),'exec'),ns)
tray,lid,gauge=ns['tray'],ns['lid'],ns['gauge']
box=ns['box']; holes=ns['holes']; outer=ns['outer']
def cyl(x,y,z,r,h):return cq.Workplane('XY').center(x,-y).circle(r).extrude(h).translate((0,0,z))
# The wider underside clears the ANO's 34 mm lower flange.
# Upper opening gives 0.585 mm radial clearance around the measured 31.83 mm ring.
wheel_center=(37,120.78)
fill=cyl(*wheel_center,26.4,17.7,1.6)
lid=lid.union(fill)
wheel_cut=cyl(*wheel_center,26.2,16.5,2.1)
lid=lid.cut(wheel_cut)
# Three cover screws, clear of the display, carrier and Feather.
closure=[(3.7,3.7),(70.3,3.7),(3.2,174)]
for x,y in closure:
 radius=1.8 if y>170 else 2.2
 post=cyl(x,y,1.6,radius,24.8).intersect(outer)
 if y>170: post=post.cut(box(3.7,171.5,6.2,3,5,2.2)) # Clear carrier edge with 0.3 mm allowance.
 tray=tray.union(post).cut(cyl(x,y,20.4,1.05,6.2))
 lid=lid.cut(cyl(x,y,26.3,1.4,2))
 # Clear the lid alignment lip around each tall post.
 lid=lid.cut(cyl(x,y,23.3,radius+.25,3.1))
# Four removable retainers support the rear mounting feet, never the electronics.
# Threading of the vendor's metal feet is deliberately not assumed.
feet=[(14.2305,15.9985),(59.7905,15.9985),(14.2305,89.8385),(59.7905,89.8385)]
clips=[]; clip_posts=[]
for fx,fy in feet:
 sx=3.8 if fx<37 else 70.2
 clip_posts.append((sx,fy))
 # Printed pilot takes an M2 screw from the rear. Front skin remains unpierced.
 col=cyl(sx,fy,14.8,2.15,11.6)
 lid=lid.union(col).cut(cyl(sx,fy,14.7,.8,7.1))
 # Flat base, 2 mm thick, with a pad below the metal foot.
 a=cyl(sx,fy,12.8,2.1,2)
 b=cyl(fx,fy,12.8,2.5,2)
 x0=min(sx,fx)
 arm=box(x0,fy-2.1,12.8,abs(fx-sx),4.2,2)
 clip=a.union(b).union(arm).union(cyl(fx,fy,14.8,2.5,1.9))
 clip=clip.cut(cyl(sx,fy,12.7,1.15,2.2)).clean()
 clips.append(clip.val())
# Four M2.5 through-bolts and nuts secure ANO to carrier through these sleeves.
spacer=cq.Workplane('XY').circle(2.5).circle(1.35).extrude(14)
# A small plate duplicates the full front's wheel opening at the same Z datum.
coupon=box(12,96,26.4,50,50,1.6).cut(wheel_cut).val()
# Registration feet rest on ANO PCB top (23.67), locating the coupon during trial.
for x,y,d in holes[4:]:
 foot=cyl(x,y,23.67,2.45,2.73).cut(cyl(x,y,23.5,1.4,3))
 coupon=coupon.fuse(foot.val())
# Pilot coupon allows screw fit to be tried away from the expensive shell.
pilot=cq.Workplane('XY').box(40,12,8,centered=(False,False,False))
for x,d in [(5,1.6),(15,1.8),(25,2.0),(35,2.1)]:
 pilot=pilot.cut(cq.Workplane('XY').center(x,6).circle(d/2).extrude(6).translate((0,0,2)))
def bed(s):
 b=s.BoundingBox(); return s.translate((-b.xmin,-b.ymin,-b.zmin))
models={'tray':bed(tray.val()),'front':bed(lid.val().rotate((0,0,0),(1,0,0),180)),
 'ano-spacer-14mm':spacer.val(),'wheel-coupon':bed(coupon.rotate((0,0,0),(1,0,0),180)),
 'display-retainer-left':bed(clips[0]),'display-retainer-right':bed(clips[1]),'pilot-coupon':pilot.val()}
report={'date':'2026-09-26','status':'CAD candidate; physical fit and fastener qualification required',
 'measured_wheel_mm':31.83,'opening_mm':33.0,'spacer_mm':14.0,'nominal_control_front_above_face_mm':1.47,
 'closure_screws_xy':closure,'display_support_feet_xy':feet,'display_support_top_z':16.7,
 'display_foot_bottom_z':17.0,'display_pad_uncompressed_mm':0.5,'parts':{},'source_sha256':hashlib.sha256(base.read_bytes()).hexdigest()}
for name,s in models.items():
 assert s.isValid() and len(s.Solids())==1,(name,'invalid or disconnected')
 p=H/'print'/f'harmony-m6-b-{name}.stl'
 cq.exporters.export(s,str(p),tolerance=.035,angularTolerance=.08)
 mesh=trimesh.load(p,force='mesh')
 assert mesh.is_watertight and mesh.is_winding_consistent and mesh.body_count==1,name
 assert abs(mesh.bounds[0,2])<.001 and max(mesh.extents)<256,name
 p3=p.with_suffix('.3mf');p3.write_bytes(trimesh.exchange.threemf.export_3MF(trimesh.Scene(mesh)))
 roundtrip=trimesh.load(p3,force='mesh');assert np.allclose(mesh.extents,roundtrip.extents,atol=.001)
 cq.exporters.export(s,str(H/'cad'/f'{name}.step'))
 report['parts'][name]={'dimensions_mm':mesh.extents.tolist(),'watertight':True,'solids':1,'print_z_min':float(mesh.bounds[0,2])}
 print('exported',name,flush=True)
feather=cq.importers.importStep(str(C/'reference/5400 ESP32 Feather V2.step')).val().translate((5.5,-173.59,19.15))
ano=cq.importers.importStep(str(C/'reference/5740 ANO Rotary Encoder QT.step')).val().rotate((0,0,0),(1,1,0),180).translate((37,-120.78,23.67))
display=load_display(); carrier=gauge.val().translate((0,0,6.5))
checks={}
for n,s in [('feather',feather),('ano',ano),('display',display),('carrier',carrier)]:
 for shell,part in [('tray',tray.val()),('front',lid.val())]+[(f'retainer{i}',s) for i,s in enumerate(clips)]:
  checks[f'{shell}/{n}']=part.intersect(s).Volume()
for i,clip in enumerate(clips):
 checks[f'tray/retainer{i}']=tray.val().intersect(clip).Volume()
 checks[f'front/retainer{i}']=lid.val().intersect(clip).Volume()
# Bound the through-bolt hardware and sleeve, including its tip below the nut.
for i,(x,y,d) in enumerate(holes[4:]):
 shaft=cyl(x,y,3.67,1.25,20).val()
 head=cyl(x,y,23.67,2.25,2.5).val()
 nut=cyl(x,y,4.5,3.2,2).cut(cyl(x,y,4.4,1.3,2.2)).val()
 sleeve=cyl(x,y,8.1,2.5,14).cut(cyl(x,y,8,1.35,14.2)).val()
 for n,solid in [('shaft',shaft),('head',head),('nut',nut),('sleeve',sleeve)]:
  for other,part in [('tray',tray.val()),('front',lid.val()),('ano',ano),('display',display),('feather',feather),('carrier',carrier)]:
   checks[f'control{i}_{n}/{other}']=solid.intersect(part).Volume()
checks['tray/front']=tray.val().intersect(lid.val()).Volume()
checks['coupon/ano']=coupon.intersect(ano).Volume()
report['intersection_mm3']=checks
(H/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print('interference checks:',len(checks),'nonzero:',{k:v for k,v in checks.items() if v>.0001},flush=True)
assert max(checks.values())<.001,'Mechanical collision; see validation.json'
assembly=cq.Assembly(name='Harmony_M6_fit_rev_b')
for n,s,color in [('tray',tray.val(),(.7,.75,.8)),('front',lid.val(),(.85,.9,.95)),('ano',ano,(.15,.15,.15)),('display',display,(.15,.2,.25)),('carrier_gauge',carrier,(.1,.5,.3))]:
 assembly.add(s,name=n,color=cq.Color(*color))
for i,s in enumerate(clips):assembly.add(s,name=f'retainer_{i}',color=cq.Color(.85,.55,.15))
assembly.save(str(H/'cad/assembly.step'))
# Lightweight meshes for visual review use actual vendor models.
for n,s in [('assembled-tray',tray.val()),('assembled-front',lid.val()),('assembled-ano',ano),('assembled-display',display),('assembled-gauge',carrier)]+[(f'assembled-retainer{i}',s) for i,s in enumerate(clips)]:
 cq.exporters.export(s,str(H/'preview'/f'{n}.stl'),tolerance=.08,angularTolerance=.15)
print('PASS',flush=True)
