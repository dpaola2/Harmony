"""Read native KiCad pads; verify exact public PCB identity and schematic parity."""
import hashlib,json,xml.etree.ElementTree as ET
from pathlib import Path
import pcbnew,wx
app=wx.App(False)
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
report={'result':'PASS','boards':[]}
for name in ['mainboard','faceplate']:
 f=f'tangara-{name}/tangara-{name}.kicad_pcb'
 src=ROOT/'hardware/tangara-reference'/f;new=ROOT/'hardware/revisions/harmony-r4'/f
 assert src.read_bytes()==new.read_bytes()
 b=pcbnew.LoadBoard(str(new));pads={}
 for fp in b.GetFootprints():
  for p in fp.Pads():
   if p.GetNumber() and p.GetNetname():
    k=(fp.GetReference(),p.GetNumber());assert k not in pads or pads[k]==p.GetNetname();pads[k]=p.GetNetname()
 sch={}
 for n in ET.parse(HERE/f'{name}-netlist.xml').getroot().findall('nets/net'):
  for node in n.findall('node'):
   k=(node.get('ref'),node.get('pin'));assert k not in sch;sch[k]=n.get('name')
 assert pads==sch,[(k,pads.get(k),sch.get(k)) for k in pads.keys()|sch.keys() if pads.get(k)!=sch.get(k)]
 report['boards'].append({'board':name,'pcb_sha256':hashlib.sha256(new.read_bytes()).hexdigest(),'byte_identical_to_public_reference':True,'pin_nets_matching_schematic':len(pads)})
(HERE/'connectivity-verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
