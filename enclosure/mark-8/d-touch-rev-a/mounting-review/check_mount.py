import cadquery as cq, numpy as np, json, math
from pathlib import Path
r=Path('/Users/dave/projects/Harmony2/enclosure/mark-8/d-touch-rev-a')
s=cq.importers.importStep('/Users/dave/projects/Harmony2/hardware/mark-7/carrier-rev-a/mechanical/feather.step').val()
v,_=s.tessellate(.1);v=np.array([p.toTuple() for p in v])
pins=json.loads(Path('/Users/dave/projects/Harmony2/hardware/mark-6/carrier-rev-a/reference/feather-v2-header-pins.json').read_text())['pins']
used={('JP1',15),('JP1',13),('JP1',12),('JP1',11),('JP1',7),('JP1',4),('JP3',6),('JP3',7),('JP3',9),('JP3',10)}
# Unrotated inverted frame. USB front face (vendor x=58.99) at y=91.7;
# USB shell center at z=user-selected center. Port shell vendor center z=10.65.
def transform(points,angle,zc):
 p=np.array(points); x=p[:,1]-88.43+20.8; y=p[:,0]-58.99; z=10.65-p[:,2]
 a=math.radians(angle);return np.array([x,91.7+y*math.cos(a)-z*math.sin(a),zc+y*math.sin(a)+z*math.cos(a)]).T
sock=[]
for p in pins:
 if (p['header'],p['pin']) not in used:continue
 px=7.095488370849+50.8-p['eagle_x_mm'];py=77+p['eagle_y_mm']
 # 2.54 square socket assumed. Dave measured underside-to-exit 18 mm.
 for dx in [-1.27,1.27]:
  for dy in [-1.27,1.27]:
   for z in [7.95,7.95-18,7.95-23]:sock.append([px+dx,py+dy,z])
results=[]
for angle in range(0,22):
 for zc in np.arange(17,23.1,.5):
  b=transform(v,angle,zc);q=transform(sock,angle,zc)
  gap=float(np.min(28+36/94*q[:,1]-12.15048/math.cos(math.atan2(36,94))-q[:,2]))
  floor=float(b[:,2].min()-2.4)
  # Broad USB shell section at nose, includes 1 mm exterior plug body allowance each side vertically.
  usb=transform([[58.99,83.974,8.55],[58.99,92.914,12.75]],angle,zc)
  usblo=float(usb[:,2].min());usbhi=float(usb[:,2].max())
  if floor>=.8 and gap>=1.5 and usblo>=15.5 and usbhi<=25.5:
   results.append({'angle':angle,'usb_center_z':float(zc),'board_floor_gap':round(floor,3),'socket_and_5mm_bend_display_gap':round(gap,3),'usb_shell_z':[round(usblo,3),round(usbhi,3)]})
print(json.dumps(results,indent=2),flush=True)
(r/'mounting-review/angle-scan.json').write_text(json.dumps({'status':'preliminary conservative envelope scan; no cradle released','assumptions':['Socket width 2.54 mm unmeasured','5 mm straight extension represents bend allowance, not actual wire routing','USB cable body unmeasured','No JST/QT cable or tray-post collision validation yet'],'candidates':results},indent=2)+'\n')
