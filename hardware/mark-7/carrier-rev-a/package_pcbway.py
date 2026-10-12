"""Export a checked bare-board package; never submit or release fabrication."""
from pathlib import Path
import subprocess,json,hashlib,zipfile
from design import HERE,REPO,NAME
from gerbonara import LayerStack
from gerbonara.utils import MM
D=HERE/'pcbway';G=D/'gerbers';G.mkdir(parents=True,exist_ok=True)
k=REPO/'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli'
board=HERE/(NAME+'.kicad_pcb')
report=json.loads((HERE/'verification.json').read_text())
assert report['sha256'][board.name]==hashlib.sha256(board.read_bytes()).hexdigest(),'Run verification against current PCB first'
assert report['drc_violations']==0 and report['unconnected']==0
subprocess.run([str(k),'pcb','export','gerbers','--layers','F.Cu,B.Cu,F.Mask,B.Mask,F.Silkscreen,B.Silkscreen,Edge.Cuts','--subtract-soldermask','--output',str(G)+'/',str(board)],check=True)
subprocess.run([str(k),'pcb','export','drill','--format','excellon','--drill-origin','absolute','--excellon-units','mm','--excellon-zeros-format','decimal','--excellon-separate-th','--output',str(G)+'/',str(board)],check=True)
stack=LayerStack.open(G)
bounds=stack.outline.bounding_box(unit=MM)
size=[round(bounds[1][i]-bounds[0][i],3) for i in (0,1)]
assert all(abs(a-b-.05)<.001 for a,b in zip(size,[53.5,28.3])),size # outline stroke adds .05
assert len(stack.drill_pth.objects)==41,len(stack.drill_pth.objects)
assert len(stack.drill_npth.objects)==8,len(stack.drill_npth.objects)
for side in ('top','bottom'):
 (D/(side+'.svg')).write_text(str(stack.to_pretty_svg(side=side)))
 (D/(side+'-copper.svg')).write_text(str(stack.to_svg(colors={f'{side} copper':'#c88b3a','drill pth':'#ffffff','drill npth':'#ffffff','mechanical outline':'#000000'})))
files=sorted(G.iterdir());assert len(files)==10,[p.name for p in files]
zip_path=D/'Harmony-Mark7-Carrier-A-Gerbers.zip'
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as z:
 for f in files:z.write(f,f.name)
with zipfile.ZipFile(zip_path) as z:assert z.testzip() is None
proof={'status':'Quote package; physical fit pending; do not release fabrication','board_sha256':hashlib.sha256(board.read_bytes()).hexdigest(),'zip_sha256':hashlib.sha256(zip_path.read_bytes()).hexdigest(),'outline_centerline_mm':[53.5,28.3],'gerber_outline_stroke_bounds_mm':size,'plated_holes':41,'nonplated_holes':8,'files':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in files}}
(D/'package-verification.json').write_text(json.dumps(proof,indent=2)+'\n')
print(json.dumps(proof,indent=2))
