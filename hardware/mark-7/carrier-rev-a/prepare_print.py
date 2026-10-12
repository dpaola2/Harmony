"""Arrange a small unpowered fit kit, with no slicer or printer action."""
from design import *
import trimesh,numpy as np
P=HERE/'print';P.mkdir(exist_ok=True);M=HERE/'mechanical';scene=trimesh.Scene();report={}
layout=[('mount-test-base',0,0),('carrier-dummy',65,0),('JP1-dummy',0,38),('JP3-dummy',0,48),*[(f'screw-spacer-2mm',65+i*8,38) for i in range(4)]]
bounds=[]
for i,(name,x,y) in enumerate(layout):
 mesh=trimesh.load(M/(name+'.stl'),force='mesh');assert mesh.is_watertight and mesh.body_count==1,name
 mesh.apply_translation(-mesh.bounds[0]);mesh.export(P/(name+'.stl'));mesh.apply_translation((x,y,0))
 for bb in bounds:assert not (np.minimum(bb[1,:2],mesh.bounds[1,:2])-np.maximum(bb[0,:2],mesh.bounds[0,:2])>0).all()
 bounds.append(mesh.bounds.copy());scene.add_geometry(mesh,node_name=f'{name}-{i}',geom_name=f'{name}-{i}');report[f'{name}-{i}']={'extents_mm':mesh.extents.tolist(),'watertight':True,'xy':[x,y]}
path=P/'mark7-carrier-fit-kit.3mf';path.write_bytes(trimesh.exchange.threemf.export_3MF(scene));loaded=trimesh.load(path);assert len(loaded.geometry)==8;assert max(scene.extents)<256
(P/'validation.json').write_text(json.dumps({'sliced':False,'objects':8,'parts':report,'plate_mm':scene.extents.tolist()},indent=2)+'\n');print('Fit kit validated:',scene.extents.tolist())
