from pathlib import Path
import subprocess,json,re,hashlib
d=Path(__file__).resolve().parent;root=d.parents[3];cli=root/'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli'
for n,src in [('before',d/'faceplate-before.kicad_pcb'),('net-aware',d/'faceplate-net-aware-before-refill.kicad_pcb')]:
 dest=d/f'gerber-{n}';dest.mkdir(exist_ok=True)
 subprocess.run([str(cli),'pcb','export','gerbers','--no-x2','--no-netlist','--layers','F.Cu,B.Cu,F.Mask,B.Mask,Edge.Cuts','-o',str(dest)+'/',str(src)],check=True)
def norm(f):return '\n'.join(l for l in f.read_text().splitlines() if not l.startswith('G04'))
a=sorted(f for f in (d/'gerber-before').glob('*.g*') if f.suffix!='.gbrjob');b=sorted(f for f in (d/'gerber-net-aware').glob('faceplate-net-aware-before-refill-*.g*') if f.suffix!='.gbrjob');r=[]
assert len(a)==len(b)==5
for f,g in zip(a,b):r.append({'before':f.name,'after':g.name,'identical_geometry_commands':norm(f)==norm(g),'sha256':hashlib.sha256(norm(f).encode()).hexdigest()})
assert all(x['identical_geometry_commands'] for x in r)
(d/'electrode-gerber-equivalence.json').write_text(json.dumps(r,indent=2)+'\n');print(r)
