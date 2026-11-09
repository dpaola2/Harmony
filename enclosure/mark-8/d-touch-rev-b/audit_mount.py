"""Independent clearance audit of exported revision B solids. No source-build import."""
import cadquery as cq, json, math
from pathlib import Path
from OCP.BRepExtrema import BRepExtrema_DistShapeShape
R=Path(__file__).resolve().parent
cache={}
def shape(n):
 if n not in cache:cache[n]=cq.importers.importStep(str(R/'cad'/f'{n}.step')).val()
 return cache[n]
def distance(a,b):
 e=BRepExtrema_DistShapeShape(shape(a).wrapped,shape(b).wrapped);e.Perform();return round(e.Value(),3)
def overlap(a,b):return round(shape(a).intersect(shape(b)).Volume(),4)
out={'status':'CAD REVIEW; PHYSICAL DRY FIT STILL REQUIRED','dimensions_mm':{'case':[112,94,44,80],'PCB_underside_z':29,'socket_drop_measured':18,'socket_exit_z':11,'wire_bend_reserve_lowest_z':5.5,'floor_top_z':2.4,'wire_floor_gap':3.1,'usb_opening':[15,13],'usb_body_measured':[10.17,14.45,4.45],'usb_metal_length_measured':6.86,'usb_side_margin_each':2.415,'usb_bottom_margin':3.975,'usb_top_margin':4.575},'checks':[],'unqualified':['Display harness length, white mating plug and exact wire paths are not measured.','Battery and QT mating-plug shapes are inherited envelopes, not new user measurements.','Socket width reserve 3.2 mm and 5.5 mm wire-bend allowance are design assumptions.','Battery cushioning material and pouch retention require physical rehearsal.','USB insertion force, PCB flex, printed tolerances and lid closure require disconnected physical dry fit.']}
pairs=[('feather-vendor-board','base-tray'),('feather-vendor-board','waveshare-vendor-module'),('feather-vendor-board','battery-cover'),('usb-plug-body','base-tray'),('usb-plug-body','sloped-face'),('battery-plug-reserve','base-tray'),('battery-plug-reserve','battery-cover'),('qt-plug-reserve','base-tray'),('qt-plug-reserve','waveshare-vendor-module')]
for i in range(1,11):
 for a in [f'display-socket-{i:02}',f'wire-bend-reserve-{i:02}']:
  for b in ['base-tray','battery-cover','waveshare-vendor-module']:pairs.append((a,b))
for a,b in pairs:
 v=overlap(a,b);row={'a':a,'b':b,'intersection_mm3':v,'pass':v<.015}
 if (a,b) in pairs[:9]:row['distance_mm']=distance(a,b)
 out['checks'].append(row);print(row,flush=True)
out['passed']=all(x['pass'] for x in out['checks'])
(R/'mount-validation.json').write_text(json.dumps(out,indent=2)+'\n')
assert out['passed'],[x for x in out['checks'] if not x['pass']]
