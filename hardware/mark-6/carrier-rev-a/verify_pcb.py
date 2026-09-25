#!/usr/bin/env python3
"""Independent exported-netlist, physical header and final DRC audit."""
from pathlib import Path
import xml.etree.ElementTree as E,json,hashlib,collections
import pcbnew as p,wx
app=wx.App(False);H=Path(__file__).resolve().parent;b=p.LoadBoard(str(H/'harmony-mark6-carrier.kicad_pcb'))
nets={}
for n in E.parse(H/'netlist.xml').findall('./nets/net'):
 name=n.get('name').removeprefix('/')
 if name.startswith('unconnected-'):continue
 for x in n.findall('node'):nets[x.get('ref'),x.get('pin')]=name
fps={f.GetReference():f for f in b.GetFootprints()};pads=0
for (ref,pin),net in nets.items():
 hits=[x for x in fps[ref].Pads() if x.GetNumber()==pin]
 assert hits,(ref,pin,'missing')
 for pad in hits:assert pad.GetNetname()==net,(ref,pin,net,pad.GetNetname());pads+=1
for ref,f in fps.items():
 for pad in f.Pads():assert pad.GetNetname()==nets.get((ref,pad.GetNumber()),''),(ref,pad.GetNumber(),'unexpected net')
for h in json.loads((H/'reference/feather-v2-header-pins.json').read_text())['pins']:
 ref='J1' if h['header']=='JP1' else 'J2';pos=fps[ref].FindPadByNumber(str(h['pin'])).GetPosition()
 assert abs(p.ToMM(pos.x)-(5.5+h['eagle_x_mm']))<.00001
 assert abs(p.ToMM(pos.y)-(173.59-h['eagle_y_mm']))<.00001
r=json.loads((H/'final-drc.json').read_text());assert not r['violations'] and not r['unconnected_items']
erc=json.loads((H/'erc.json').read_text());assert all(not x.get('violations') for x in erc.get('sheets',[]))
tracks=list(b.GetTracks());report={'status':'PASS - CAD checks; hardware not qualified','pcb_violations':0,'unconnected_items':0,'matched_electrical_pads':pads,'header_coordinates_matched':28,'footprints':len(fps),'layers':b.GetCopperLayerCount(),'tracks':sum(not isinstance(t,p.PCB_VIA) for t in tracks),'vias':sum(isinstance(t,p.PCB_VIA) for t in tracks),'zones':len(list(b.Zones())),'checks':['Every populated and unconnected PCB pad matches exported schematic netlist','All 28 mating socket coordinates match vendor Feather CAD','No PCB DRC violations or opens under saved project rules','Schematic ERC clear'],'limits':['No powered hardware, signal integrity, thermal or RF qualification','Final display thickness, header tolerance and cable fit require physical check','Via-in-pad filling/capping and assembler DFM acceptance required'],'sha256':{n:hashlib.sha256((H/n).read_bytes()).hexdigest() for n in ['harmony-mark6-carrier.kicad_pcb','harmony-mark6-carrier.kicad_sch','netlist.xml','final-drc.json']}}
(H/'pcb-verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
# Authoritative placement export for documentation (case coordinates, Y down).
items=[]
for f in b.GetFootprints():
 pos=f.GetPosition();items.append({'ref':f.GetReference(),'x':p.ToMM(pos.x),'y':p.ToMM(pos.y),'rotation':f.GetOrientationDegrees()})
(H/'output/pcb-components.json').write_text(json.dumps(items,indent=2)+'\n')
