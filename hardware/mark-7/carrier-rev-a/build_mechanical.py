"""Carrier fit study and unsliced dummy; reuse accepted faceplate geometry."""
from design import *
import cadquery as cq,itertools
OUT=HERE/'mechanical';OUT.mkdir(exist_ok=True)
old=REPO/'enclosure/mark-7/rear-review-c';source=(old/'build.py').read_text();source=source[:source.index('# Snap latch reservations')]
# Preserve XY location and faceplate. Replace rear Feather supports by carrier supports.
source=source.replace('cyl(x,y,floor,2.1,7.9)','cyl(x,y,floor,2.1,1.7)').replace('cyl(x,y,-3.5,.8,5.1)','cyl(x,y,-7.5,.8,2.9)').replace('usb_z=4.2','usb_z=10.65').replace('box(61,93.8,6,5,2,3)','box(61,93.8,12.45,5,2,3)').replace('for x in [13,51]:','for x in []:')
ns={'__file__':str(old/'build.py')};exec(compile(source,str(old/'build.py'),'exec'),ns)
parts=ns['parts'];box,cyl=ns['box'],ns['cyl']
for name in list(parts):
 if name.startswith(('header-reservation','feather-screw')):del parts[name]
for name in ['feather','jst-plug-reservation','qt-plug-reservation']:parts[name]=parts[name].translate((0,0,6.45))
board=cq.Workplane('XY').polyline(outline).close().extrude(1.6).translate((0,0,-4.7))
# Carrier mounting holes. Cut all header/pad holes in the printable PCB dummy.
for x,y in mounts:board=board.cut(cyl(x,y,-4.8,1.2,1.8))
for x,y in ties:board=board.cut(cyl(x,y,-4.8,1,1.8))
for h in headers:
 x,y=position(h);board=board.cut(cyl(x,y,-4.8,.5,1.8))
for ref,label,net,head,num,y,gpio in wires:board=board.cut(cyl(position(pin(head,num))[0],y,-4.8,.5,1.8))
parts['carrier']=board.val()
for i,(x,y) in enumerate(mounts,1):
 spacer=cyl(x,y,-3.1,2,2).cut(cyl(x,y,-3.2,1.2,2.2));parts[f'carrier-spacer-{i}']=spacer.val()
 parts[f'carrier-screw-{i}']=cyl(x,y,-1.1,2,2).union(cyl(x,y,-7.1,1,6)).val()
for head in ['JP1','JP3']:
 pts=[position(h) for h in headers if h['header']==head];xs=[p[0] for p in pts];y=pts[0][1]
 # Samtec SSW single row: body length pitch*N+.51, width2.41, height8.51.
 socket=box(min(xs)-1.525,y-1.205,-3.1,max(xs)-min(xs)+3.05,2.41,8.51)
 male=box(min(xs)-1.27,y-1.27,5.41,max(xs)-min(xs)+2.54,2.54,2.54)
 parts[head+'-socket']=socket.val();parts[head+'-male-spacer']=male.val()
 # Stand-in has oversized pin holes and the 8.51mm socket height; real Feather supplies its existing male spacer, not live sockets.
 dummy=socket
 for x,yy in pts:dummy=dummy.cut(cyl(x,yy,-3.2,.65,11.25))
 cq.exporters.export(dummy.translate((0,0,3.1)),str(OUT/(head+'-dummy.stl')))
# Modeled tails protrude 1.04mm below 1.6mm carrier, with 0.66mm floor clearance.
for i,h in enumerate(headers):
 x,y=position(h);parts[f'socket-tail-{i}']=box(x-.32,y-.32,-5.74,.64,.64,1.04).val()
# Optional axial resistor above carrier.
parts['optional-10k']=cyl(40.115488,87.5,-3.1,1.25,2.5).val()
checks={}
static=['front','display','ano','battery-cover','battery','tray']
new=['carrier','feather','JP1-socket','JP3-socket','JP1-male-spacer','JP3-male-spacer','jst-plug-reservation','qt-plug-reservation']
for a in new:
 for b in static:checks[a+'/'+b]=parts[a].intersect(parts[b]).Volume()
for a in ['carrier','JP1-socket','JP3-socket','JP1-male-spacer','JP3-male-spacer']:
 for b in parts:
  if b.startswith(('clip','screen-','ano-','closure-screw','carrier-spacer')):checks[a+'/'+b]=parts[a].intersect(parts[b]).Volume()
bad={k:round(v,5) for k,v in checks.items() if v>.005}
report={'status':'FIT REVIEW ONLY','case_mm':[64,105,34],'carrier_bottom_z':-4.7,'carrier_top_z':-3.1,'socket_height':8.51,'male_spacer_assumed':2.54,'feather_bottom_z':7.95,'feather_shift_mm':6.45,'tail_floor_clearance_mm':.66,'collision_volumes_mm3':bad,'checks':len(checks),'limitations':['Header body and insertion length must be measured on actual Feather','JST/QT connector envelopes remain approximate','Wire bends and strain relief must be physically fitted','Antenna cutout clears vendor antenna rectangle only, not full RF clearance halo','Feather retained by sockets; insertion/removal loads and shake retention untested','Revised rear tray needed; old faceplate closure issues remain']}
(OUT/'validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report),flush=True)
for n in ['carrier','tray','feather','front','battery-cover','JP1-socket','JP3-socket']:
 cq.exporters.export(parts[n],str(OUT/(n+'.step')))
 cq.exporters.export(parts[n],str(OUT/(n+'.stl')))
cq.exporters.export(board.translate((0,0,4.7)),str(OUT/'carrier-dummy.stl'))
# A small flat base reproduces the revised tray floor and mounting posts.
base=box(5,71,0,56,30,1.6)
for x,y in mounts:base=base.union(cyl(x,y,1.6,2.1,1.7)).cut(cyl(x,y,.5,.8,2.9))
cq.exporters.export(base,str(OUT/'mount-test-base.stl'))
sp=cyl(0,0,0,2,2).cut(cyl(0,0,-.1,1.2,2.2));cq.exporters.export(sp,str(OUT/'screw-spacer-2mm.stl'))
a=cq.Assembly(name='Mark7_carrier_review')
for n,s in parts.items():a.add(s,name=n)
a.export(str(OUT/'assembly.step'))
assert not bad,bad
