"""Deletion experiments on copies only, to localize otherwise unpositioned DRC sliver."""
from pathlib import Path
import json,subprocess,concurrent.futures,shutil
from sexpr_tools import spans
p=Path(__file__).resolve().parent;r=p.parents[2];src=r/'revisions/harmony-r3/tangara-faceplate/tangara-faceplate.kicad_pcb';cli=r.parent/'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli'
s=src.read_text(); variants=[]
for ref in ('SW1','SW2','SW3'):
 for i,j in spans(s,'footprint'):
  f=s[i:j]
  if f'(property "Reference" "{ref}"' in f:variants.append((ref,s[:i]+s[j:]));break
z=list(spans(s,'zone'));v=s
for i,j in reversed(z):v=v[:i]+v[j:]
variants.append(('zones',v))
for n,(i,j) in enumerate(spans(s,'fp_poly')):
 if '(layer "F.Cu")' in s[i:j]:variants.append((f'poly-{n}',s[:i]+s[j:]))
def run(x):
 n,v=x;d=p/'sliver-localization'/n;d.mkdir(parents=True,exist_ok=True);b=d/'tangara-faceplate.kicad_pcb';b.write_text(v);shutil.copy(src.with_suffix('.kicad_pro'),b.with_suffix('.kicad_pro'))
 log=subprocess.run([str(cli),'pcb','drc','--format','json','--severity-all','-o',str(d/'drc.json'),str(b)],capture_output=True,text=True)
 data=json.loads((d/'drc.json').read_text());return {'removed_for_experiment':n,'sliver_count':sum(a['type']=='copper_sliver' for a in data['violations']),'stdout':log.stdout}
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as e:out=list(e.map(run,variants))
(p/'sliver-localization.json').write_text(json.dumps(out,indent=2)+'\n');print(out)
