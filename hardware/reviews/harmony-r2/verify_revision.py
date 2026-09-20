#!/usr/bin/env python3
"""Independent native PCB/netlist reconciliation. Run with KiCad 8 Python."""
import hashlib,json,xml.etree.ElementTree as ET
from pathlib import Path
import pcbnew,wx
app=wx.App(False)
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
REV=ROOT/'hardware/revisions/harmony-r2'
BASE=ROOT/'hardware/tangara-reference'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def nodes(p):
    out={}
    for net in ET.parse(p).getroot().findall('nets/net'):
        for n in net.findall('node'):
            key=(n.get('ref'),n.get('pin'))
            assert key not in out
            out[key]=net.get('name')
    return out
result={'tool':pcbnew.GetBuildVersion(),'boards':[]}
for name in ('mainboard','faceplate'):
    file=f'tangara-{name}/tangara-{name}.kicad_pcb'
    assert digest(REV/file)==digest(BASE/file),'Routed PCB unexpectedly changed'
    board=pcbnew.LoadBoard(str(REV/file))
    pads={}
    for f in board.GetFootprints():
        for p in f.Pads():
            if p.GetNumber() and p.GetNetname():
                k=(f.GetReference(),p.GetNumber())
                assert k not in pads or pads[k]==p.GetNetname()
                pads[k]=p.GetNetname()
    sch=nodes(HERE/f'{name}-netlist.xml')
    shared=set(pads)&set(sch)
    mismatches=[{'reference':r,'pin':p,'schematic':sch[r,p],'pcb':pads[r,p]} for r,p in sorted(shared) if sch[r,p]!=pads[r,p]]
    assert not mismatches,mismatches
    entry={'board':name,'pcb_sha256':digest(REV/file),'shared_pin_nets_checked':len(shared),'mismatches':mismatches,'schematic_only_pin_count':len(set(sch)-set(pads)),'pcb_only_pin_count':len(set(pads)-set(sch))}
    if name=='mainboard':
        for k,v in {('C23','2'):'GND',('U1','25'):'-5VA',('U1','5'):'-5VA',('U9','25'):'GND',('U9','9'):'GND'}.items():
            assert sch[k]==pads[k]==v,(k,sch.get(k),pads.get(k))
        before=nodes(ROOT/'hardware/procurement/assembly-verification/mainboard-native-netlist.xml')
        assert set(before)==set(sch),'Schematic pin set changed'
        changes=[{'reference':k[0],'pin':k[1],'before':before[k],'after':sch[k]} for k in sorted(sch) if before[k]!=sch[k]]
        for change in changes:
            k=(change['reference'],change['pin'])
            assert change['before']=='-5VA' and change['after']=='GND' and pads[k]=='GND',change
        entry['corrected_net_assignments']=changes
    result['boards'].append(entry)
result['result']='PASS_NATIVE_NET_RECONCILIATION_PCB_UNCHANGED'
(HERE/'independent-native-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({**result,'boards':[{k:v for k,v in b.items() if k!='corrected_net_assignments'} for b in result['boards']]},indent=2))
