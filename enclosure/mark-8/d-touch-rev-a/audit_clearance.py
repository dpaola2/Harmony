from pathlib import Path
import json,cadquery as cq
from OCP.BRepExtrema import BRepExtrema_DistShapeShape
R=Path(__file__).resolve().parent;d=json.loads((R/'validation.json').read_text())
names=['waveshare-vendor-module','feather-and-sockets-envelope','battery-cover','mpr121-populated-reserve','sloped-face'];s={n:cq.importers.importStep(str(R/'cad'/f'{n}.step')).val() for n in names}
pairs=[(names[0],names[1]),(names[0],names[2]),(names[0],names[3]),(names[1],names[4]),(names[3],names[4])]
d['minimum_distances_mm']=[]
for a,b in pairs:
 e=BRepExtrema_DistShapeShape(s[a].wrapped,s[b].wrapped);e.Perform();d['minimum_distances_mm'].append({'a':a,'b':b,'distance':round(e.Value(),3)})
d['scope_notes']=['Reference board envelopes have mounting reliefs; actual populated components and cables require physical inspection.','Intersections exclude copper electrodes and closure hardware; positive clearance is not a manufacturing tolerance proof.','All dimensions are in mm; 3MF files are unsliced.']
(R/'validation.json').write_text(json.dumps(d,indent=2)+'\n');print(d['minimum_distances_mm'])
