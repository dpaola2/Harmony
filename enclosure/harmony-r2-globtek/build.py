#!/usr/bin/env python3
"""GlobTek enclosure adaptation. Reuses R1 front and interfaces; deepens rear 6 mm.
Run: uv run --with cadquery==2.8.0 --with trimesh python build.py
"""
from pathlib import Path
import sys, json, hashlib
import cadquery as cq
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'harmony-r1'))
import build as r1
DEPTH=6.0
CUT_Z=-9.0

def main():
 for n in ['cad','print','preview']: (ROOT/n).mkdir(exist_ok=True)
 parts,_,lens,_=r1.make_parts()
 original=parts['back']
 upper=original.intersect(r1.box(200,200,100,(0,0,CUT_Z+50)))
 lower=original.intersect(r1.box(200,200,100,(0,0,CUT_Z-50))).translate((0,0,-DEPTH))
 faces=[f for f in upper.Faces() if f.geomType()=='PLANE' and f.normalAt().z < -.99 and abs(f.Center().z-CUT_Z)<1e-5]
 assert faces
 walls=[cq.Solid.extrudeLinear(f.outerWire(),f.innerWires(),cq.Vector(0,0,-DEPTH)) for f in faces]
 back=upper.fuse(lower,*walls).clean()
 # Tray rests on the lowered inside floor at -15.6. No preload on pack.
 # 0.5 mm clearance per side; 0.7 mm lower pad allowance and 0.5 mm upper
 # allowance beyond the drawing's conservative 9.3 mm body thickness.
 cx,cy=2.9,0
 cavity=r1.box(32,79,12,(cx,cy,-8.8))
 tray=r1.box(34.4,81.4,1,(cx,cy,-15.1))
 rails=r1.box(34.4,81.4,4,(cx,cy,-12.6)).cut(cavity)
 cage=tray.fuse(rails).clean()
 # Lead exit notch at positive Y. Wire route and restraint require dry fitting.
 cage=cage.cut(r1.box(12,5,4,(cx,40,-11))).clean()
 battery=r1.box(31,78,9.3,(cx,cy,-9.25)) # bottom -13.9, top -4.6
 allowance=r1.box(32,79,10.5,(cx,cy,-9.3)) # bottom -14.55, top -4.05
 parts['back']=back;parts['battery-cage']=cage
 parts={k:v for k,v in parts.items() if not k.startswith('fit-')}
 checks={}
 checks['preserved_upper_back_removed_mm3']=upper.cut(back).Volume()
 checks['preserved_upper_back_added_mm3']=back.intersect(r1.box(200,200,100,(0,0,CUT_Z+50))).cut(upper).Volume()
 assert max(checks.values())<.01
 for name,s in parts.items():
  overlap=s.intersect(allowance).Volume()
  checks[name+'_battery_allowance_intersection_mm3']=overlap
  assert overlap<.01,(name,'battery clearance',overlap)
 overlaps={}
 names=list(parts)
 for i,a in enumerate(names):
  for b in names[i+1:]:
   v=parts[a].intersect(parts[b]).Volume()
   if v>.01:overlaps[a+'/'+b]=v
 assert not overlaps,overlaps
 checks['part_intersections_mm3']=overlaps
 report={'status':'CAD-verified fit prototype; actual electronics, battery, wire routing and retention not physically verified','rear_depth_added_mm':DEPTH,'pack_mpn':'BL2200F9031781S1PCKT','pack_max_body_mm':[31,78,9.3],'clearance_envelope_mm':[32,79,10.5],'checks':checks,'parts':{}}
 prints={}
 rotations={'front':((1,0,0),180),'button-upper':((0,1,0),90),'button-lower':((0,1,0),90),'hold-switch':((0,1,0),-90),'sd-caddy':((0,1,0),90)}
 for n,s in parts.items():
  assert s.isValid() and len(s.Solids())==1,(n,'invalid solid')
  p=r1.bed(s,rotations.get(n));m=r1.mesh(p)
  assert m.is_watertight and m.is_winding_consistent and m.volume>0,(n,'mesh')
  assert abs(m.bounds[0,2])<1e-5 and max(m.extents)<256
  cq.exporters.export(s,str(ROOT/'cad'/f'{n}.step'))
  m.export(ROOT/'print'/f'{n}.stl');prints[n]=p
  report['parts'][n]={'size_mm':[round(float(v),3) for v in m.extents],'solid_valid':True,'watertight':True,'volume_mm3':round(s.Volume(),3)}
 # A solid dummy is for fit checks only and cannot test wiring or swelling.
 dummy=r1.bed(battery);r1.mesh(dummy).export(ROOT/'print/battery-dummy.stl')
 cq.exporters.export(battery,str(ROOT/'cad/battery-envelope.step'))
 cq.exporters.export(allowance,str(ROOT/'cad/battery-clearance-envelope.step'))
 cq.exporters.export(cq.Compound.makeCompound(list(parts.values())+[battery,lens]),str(ROOT/'cad/assembly.step'))
 r1.write_3mf(ROOT/'print/harmony-globtek-fit.3mf',[(n,prints[n],x,128) for n,x in [('back',70),('battery-cage',135)]]+[('battery-dummy',dummy,190,128)])
 # Explicit project metadata, overriding the shared writer's R1 title.
 import zipfile
 p=ROOT/'print/harmony-globtek-fit.3mf'
 with zipfile.ZipFile(p) as z: entries={n:z.read(n) for n in z.namelist()}
 entries['3D/3dmodel.model']=entries['3D/3dmodel.model'].replace(b'Harmony R1 fit prototype',b'Harmony R2 GlobTek fit prototype')
 with zipfile.ZipFile(p,'w',zipfile.ZIP_DEFLATED) as z:
  for n,v in entries.items():z.writestr(n,v)
 (ROOT/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
 hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for folder in ['cad','print'] for p in (ROOT/folder).glob('*')}
 hashes['../harmony-r1/build.py']=hashlib.sha256(Path(r1.__file__).read_bytes()).hexdigest()
 (ROOT/'sha256.json').write_text(json.dumps(hashes,indent=2)+'\n')
 print(json.dumps(report,indent=2))
if __name__=='__main__':main()
