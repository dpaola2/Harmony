#!/usr/bin/env python3
"""Inspect exported project contents and render deposited paths, not CAD."""
from pathlib import Path
import json, zipfile, hashlib, re, collections, math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection

H = Path(__file__).resolve().parent
report = {'tool': 'Bambu Studio 02.08.02.61', 'machine': 'Bambu Lab A1 0.4 nozzle',
          'filament': 'Bambu PLA Basic', 'bed': 'Textured PEI Plate',
          'status': 'Offline sliced and paths reviewed; no printer job sent', 'plates': {}}
for name, count in [('wheel-check', 6), ('shells', 2), ('retainers', 4)]:
    d = H/'slicing'/name
    inputs=json.loads((d/'input-sha256.json').read_text())
    for source,metadata in inputs.items():
        assert hashlib.sha256(Path(source).read_bytes()).hexdigest()==metadata['sha256'],source
    assert sum(v['quantity'] for v in inputs.values())==count
    result = json.loads((d/'result.json').read_text())
    assert result['return_code'] == 0 and len(result['sliced_plates']) == 1
    plate = result['sliced_plates'][0]
    assert len(plate['objects']) == count and not plate['warning_message']
    for obj in plate['objects']:
        b = obj['bbox']
        assert b['z'] == 0 and b['x'] >= 0 and b['y'] >= 0
        assert b['x']+b['width'] <= 256 and b['y']+b['depth'] <= 256
    project = d/('harmony-m6-b-'+name+'-a1.3mf')
    with zipfile.ZipFile(project) as z:
        assert z.testzip() is None
        code = z.read('Metadata/plate_1.gcode')
        assert code == (d/'plate_1.gcode').read_bytes()
        settings = json.loads(z.read('Metadata/project_settings.config'))
        assert settings['printer_model'] == 'Bambu Lab A1'
        assert settings['enable_support'] == '0' and settings['wall_loops'] == '4'
        assert settings['curr_bed_type'] == 'Textured PEI Plate'
    layers = collections.defaultdict(list)
    x = y = 0.; height = None; feature = 'Custom'
    for line in code.decode().splitlines():
        if line.startswith('; Z_HEIGHT:'): height = round(float(line.split(':')[1]), 3)
        if line.startswith('; FEATURE:'): feature = line.split(':', 1)[1].strip()
        if not re.match(r'^G[0123] ', line): continue
        values = {k:float(v) for k,v in re.findall(r'([XYEIJ])(-?[\d.]+)', line.split(';')[0])}
        nx, ny = values.get('X',x), values.get('Y',y)
        if height and feature != 'Custom' and values.get('E',0)>0:
            if line.startswith(('G2 ', 'G3 ')):
                cx,cy=x+values.get('I',0),y+values.get('J',0)
                radius=math.hypot(x-cx,y-cy)
                a=math.atan2(y-cy,x-cx);end=math.atan2(ny-cy,nx-cx)
                span=(end-a)%(2*math.pi) if line.startswith('G3 ') else -((a-end)%(2*math.pi))
                if abs(span)<1e-8:span=2*math.pi if line.startswith('G3 ') else -2*math.pi
                steps=max(4,int(abs(span)*radius/.2))
                points=[(cx+radius*math.cos(a+span*i/steps),cy+radius*math.sin(a+span*i/steps)) for i in range(steps+1)]
                layers[height].extend(zip(points,points[1:]))
            elif (nx,ny)!=(x,y):
                layers[height].append(((x,y),(nx,ny)))
        x,y=nx,ny
    chosen = {'shells':[.2,.4,.6,15.4], 'wheel-check':[.2,1.6,3.,14.], 'retainers':[.2,1.,2.,3.8]}[name]
    fig,axes=plt.subplots(1,4,figsize=(15,5),layout='constrained')
    for ax,z in zip(axes,chosen):
        assert layers[z],(name,z)
        ax.add_collection(LineCollection(layers[z], colors='#14658a', linewidths=.35))
        ax.set(xlim=(0,256),ylim=(0,256),aspect='equal',title=f'Z = {z:g} mm')
        ax.set_xlabel('Bed X (mm)')
    fig.suptitle('Harmony Mark 6 / '+name+' / deposited G-code paths')
    fig.savefig(d/'toolpath-review.png',dpi=160);plt.close(fig)
    report['plates'][name] = {'objects':count, 'minutes':round(plate['total_predication']/60,1),
        'grams':round(sum(f['total_used_g'] for f in plate['filaments']),2),
        'slice_warning_message':plate['warning_message'], 'layers':len(layers),
        'project_sha256':hashlib.sha256(project.read_bytes()).hexdigest()}
report['limits'] = ['Estimates depend on the configured PLA and plate; confirm loaded material before printing',
                   'CAD and slice checks do not establish physical fit or bridge quality',
                   'CLI notes missing filament color and an unused tree-support default; support is disabled']
(H/'slicing/verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
