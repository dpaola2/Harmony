from pathlib import Path
import cadquery as cq,trimesh,json,hashlib
R=Path(__file__).resolve().parent
s=cq.importers.importStep(str(R/'cad/base-tray.step')).val()
cut=cq.Workplane('XY').box(38,57,40,centered=False).translate((3,37,0)).val()
s=s.intersect(cut).translate((-3,-37,0)).clean()
assert s.isValid() and len(s.Solids())==1
cq.exporters.export(s,str(R/'cad/feather-usb-fit-fixture.step'))
p=R/'print/feather-usb-fit-fixture.stl';cq.exporters.export(s,str(p),tolerance=.05,angularTolerance=.1)
m=trimesh.load(p);assert m.is_watertight and len(m.split())==1
sc=trimesh.Scene(m);p3=R/'print/05-feather-usb-fit-first.3mf';p3.write_bytes(trimesh.exchange.threemf.export_3MF(sc));assert len(trimesh.load(p3).geometry)==1
(R/'fit-fixture-validation.json').write_text(json.dumps({'valid_solid':True,'watertight':True,'solids':1,'dimensions_mm':m.extents.tolist(),'same_mount_and_usb_geometry_as_final_tray':True,'purpose':'Disconnected physical USB and 18 mm socket rehearsal before the full tray. No display or battery validation.','sha256':hashlib.sha256(p.read_bytes()).hexdigest()},indent=2)+'\n')
print(m.extents)
