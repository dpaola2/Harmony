#!/usr/bin/env python3
"""Unpowered fit prototype: tray, removable front and optional carrier gauge."""
from pathlib import Path
import json,hashlib,sys
import cadquery as cq
import trimesh,numpy as np
H=Path(__file__).resolve().parent;C=H.parents[2]/'hardware/mark-6/carrier-rev-a'
sys.path.insert(0,str(C))
from display_model import load_display, DISPLAY_RECT, ACTIVE_RECT, DISPLAY_Z
for n in ['print','cad','preview']:(H/n).mkdir(exist_ok=True)
W,L,T=74,178,28;wall=1.6;split=26.4
# All design coordinates match the PCB case view: X right, Y down, Z frontward.
def rounded(w,h,z,t,r):
 return cq.Workplane('XY').box(w,h,t,centered=(True,True,False)).edges('|Z').fillet(r).translate((W/2,-L/2,z))
def box(x,y,z,w,h,t):return cq.Workplane('XY').box(w,h,t,centered=False).translate((x,-y-h,z))
outer=rounded(W,L,0,split,5)
tray=outer.cut(rounded(W-2*wall,L-2*wall,wall,40,5-wall))
holes=json.loads((C/'pcb-placement.json').read_text())['holes']
for x,y,d in holes[:4]:
 boss=cq.Workplane('XY').center(x,-y).circle(2.7).extrude(6.5)
 pilot=cq.Workplane('XY').center(x,-y).circle(1.05).extrude(7).translate((0,0,1.0))
 tray=tray.union(boss).cut(pilot)
# Deliberately generous plug and card access for the fit test.
usb=box(-1,155.66,19.4,7,13,10)
sd=box(68,14,7.2,8,20,8)
tray=tray.cut(usb).cut(sd).clean()
lid=rounded(W,L,split,1.6,5)
# Display cavity clears the complete vendor module; bezel stays only 0.4 mm
# thick above the cavity. This is a sacrificial fit part, not a durable case.
lid=lid.cut(box(DISPLAY_RECT[0]-.4,DISPLAY_RECT[1]-.4,26.3,DISPLAY_RECT[2]+.8,DISPLAY_RECT[3]+.8,1.3))
lid=lid.cut(box(ACTIVE_RECT[0]-.4,ACTIVE_RECT[1]-.4,26.0,ACTIVE_RECT[2]+.8,ACTIVE_RECT[3]+.8,3))
lid=lid.cut(cq.Workplane('XY').center(37,-120.78).circle(17.7).extrude(5).translate((0,0,24)))
# 0.25 mm radial clearance, 1 mm thick alignment lip; no snap-lock assumption.
lip=rounded(70.3,174.3,23.4,3,3.15).cut(rounded(68.3,172.3,23.3,3.3,2.15))
lid=lid.union(lip).cut(usb).clean()
# Gauge reproduces the PCB outline and mounting holes, but contains no contacts.
poly=[(40,6),(70.2,6),(70.2,138.5),(32.2,138.5),(32.2,148),(51.5,148),(51.5,154),(47.5,154),(47.5,169.5),(51.5,169.5),(51.5,175),(4,175),(4,93.8),(40,93.8)]
gauge=cq.Workplane('XY').polyline([(x,-y) for x,y in poly]).close().extrude(1.6)
for x,y,d in holes:gauge=gauge.cut(cq.Workplane('XY').center(x,-y).circle(d/2).extrude(2))
spacer=cq.Workplane('XY').circle(2.5).circle(1.35).extrude(12)
# All print files have a flat surface at Z=0. Print the lid outside-face down.
models={'tray':tray.val().translate((0,L,0)),
 'front':lid.val().rotate((0,0,0),(1,0,0),180).translate((0,0,T)),
 'carrier-gauge':gauge.val().translate((-4,175,0)),
 'ano-spacer-12mm':spacer.val().translate((2.5,2.5,0))}
report={'date':'2026-09-22','display':'Waveshare 29318 ST7796S','display_rect_mm':DISPLAY_RECT,'display_z_mm':DISPLAY_Z,'case_mm':[W,L,T],'wall_mm':wall,'lid_clearance_mm':.25,'display_bezel_mm':.4,'carrier_mount_z_mm':6.5,'ports':{'usb':{'case_y_mm':[155.66,168.66],'case_z_mm':[19.4,28]},'sd':{'case_y_mm':[14,34],'case_z_mm':[7.2,15.2]}},'parts':{},'status':'CAD/mesh checked; unpowered fit prototype, physical fit unverified','limitations':['Display recess uses Waveshare 29318 STEP; physical tolerances and cable fit unverified','Thin 0.4mm display bezel is sacrificial; do not force or use as a permanent retainer','No display fasteners: support the module during unpowered trial fit','Printed gauge has no electrical contacts and is not a PCB','Case uses alignment lip, not a qualified snap fit; tape closed for trial','Battery remains unconnected; no charging or swelling qualification']}
for name,s in models.items():
 assert s.isValid() and len(s.Solids())==1,name
 stl=H/'print'/('harmony-mark6-'+name+'.stl');cq.exporters.export(s,str(stl),tolerance=.04,angularTolerance=.1)
 mesh=trimesh.load(stl,force='mesh');assert mesh.is_watertight and mesh.is_winding_consistent and mesh.body_count==1,name
 assert abs(mesh.bounds[0,2])<.001 and max(mesh.extents)<256,name
 out=H/'print'/('harmony-mark6-'+name+'.3mf');out.write_bytes(trimesh.exchange.threemf.export_3MF(trimesh.Scene(mesh)))
 m2=trimesh.load(out,force='mesh');assert m2.is_watertight and np.allclose(mesh.extents,m2.extents,atol=.001)
 report['parts'][name]={'dimensions_mm':mesh.extents.tolist(),'watertight':True,'connected_solids':1,'volume_mm3':float(mesh.volume),'print_z_min':float(mesh.bounds[0,2]),'3mf_round_trip':True}
 cq.exporters.export(s,str(H/'cad'/(name+'.step')))
# Compare assembled plastic against known real module geometry and reserved volumes.
feather=cq.importers.importStep(str(C/'reference/5400 ESP32 Feather V2.step')).val().translate((5.5,-173.59,19.15))
ano=cq.importers.importStep(str(C/'reference/5740 ANO Rotary Encoder QT.step')).val().rotate((0,0,0),(1,1,0),180).translate((37,-120.78,21.67))
display=load_display();battery=box(4,8,1.6,32,79,10.5).val()
checks={}
for name,s in [('feather',feather),('ano',ano),('display_vendor_29318',display),('battery_reserved',battery)]:
 for shell,part in [('tray',tray.val()),('front',lid.val())]:
  vol=part.intersect(s).Volume();checks[shell+'/'+name]=vol
checks['tray/front']=tray.val().intersect(lid.val()).Volume()
report['nominal_intersection_mm3']=checks
assert max(checks.values())<.001,checks
assembly=cq.Assembly(name='Harmony_M6_fit_prototype');assembly.add(tray,name='tray',color=cq.Color(.22,.40,.56));assembly.add(lid,name='front',color=cq.Color(.62,.76,.86));assembly.save(str(H/'cad/harmony-mark6-fit-assembly.step'))
report['hashes']={str(p.relative_to(H)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((H/'print').iterdir())}
(H/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
