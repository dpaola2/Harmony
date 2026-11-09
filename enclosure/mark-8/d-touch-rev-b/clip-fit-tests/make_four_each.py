from pathlib import Path
import numpy as np
import trimesh
R=Path(__file__).resolve().parent
scene=trimesh.Scene()
for row,step in enumerate([1.0,1.5,2.0]):
    source=R/f'lcd-clip-step-{step:.1f}mm-{row+1}-notch.stl'
    for col in range(4):
        mesh=trimesh.load(source,force='mesh')
        assert mesh.is_watertight and len(mesh.split())==1
        mesh.apply_translation((10+col*20,10+row*20,0))
        name=f'{step:.1f}mm-{row+1}-notch-copy-{col+1}'
        scene.add_geometry(mesh,node_name=name,geom_name=name)
p=R/'stepped-clips-four-of-each.3mf'
p.write_bytes(trimesh.exchange.threemf.export_3MF(scene))
loaded=trimesh.load(p)
assert len(loaded.geometry)==12
assert np.allclose(loaded.bounds,scene.bounds)
bounds=[m.bounds for m in loaded.geometry.values()]
for i,a in enumerate(bounds):
    for b in bounds[i+1:]:
        assert not np.all(np.minimum(a[1,:2],b[1,:2])>np.maximum(a[0,:2],b[0,:2]))
print(f'{p}\nVerified: 12 separate watertight parts, four per size, no overlap, original print orientation.')
