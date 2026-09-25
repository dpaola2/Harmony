#!/usr/bin/env python3
"""Cross-check production BOM, placement, holes and via-in-pad inventory."""
from pathlib import Path
import csv, json, math, hashlib, collections
import pcbnew as p, wx
app = wx.App(False)
H = Path(__file__).resolve().parent
b = p.LoadBoard(str(H/'harmony-mark6-carrier.kicad_pcb'))
fps = {f.GetReference():f for f in b.GetFootprints()}
bom = {r['ref']:r for r in csv.DictReader((H/'bom-draft.csv').open()) if r['mpn']}
pos = {r['Ref']:r for r in csv.DictReader((H/'output/all-positions.csv').open())}
assert len(bom)==36 and set(bom).issubset(pos) and set(pos).issubset(fps)
rows=[]
for ref,r in sorted(bom.items()):
    f=fps[ref];q=pos[ref];v=f.GetPosition()
    assert r['value']==f.GetValue()==q['Val'],ref
    assert r['footprint']==str(f.GetFPID().GetLibNickname())+':'+str(f.GetFPID().GetLibItemName()),ref
    assert abs(float(q['PosX'])-p.ToMM(v.x))<1e-5,ref
    assert abs(float(q['PosY'])+p.ToMM(v.y))<1e-5,ref
    assert abs((float(q['Rot'])-f.GetOrientationDegrees())%360)<1e-5,ref
    assert q['Side']=='top' and f.GetLayer()==p.F_Cu,ref
    method='Through-hole' if ref in ['J1','J2'] else 'SMT'
    assert f.GetAttributes() & (p.FP_THROUGH_HOLE if method=='Through-hole' else p.FP_SMD),ref
    rows.append(dict(ref=ref,mpn=r['mpn'],method=method,x_mm=p.ToMM(v.x),y_mm=p.ToMM(v.y),rotation_deg=f.GetOrientationDegrees()))

# Inspect actual drills instead of inferring hole sizes from footprint names.
holes=[]
for ref in ['J1','J2']:
    for pad in fps[ref].Pads():
        assert pad.GetAttribute()==p.PAD_ATTRIB_PTH
        assert p.ToMM(pad.GetDrillSize().x)==1.0
    holes.append({'ref':ref,'count':len(list(fps[ref].Pads())),'finished_hole_mm':1.0,'pad_mm':1.7,
                  'nominal_tail_projection_mm':round(2.64-b.GetDesignSettings().GetBoardThickness()/1e6,2)})
assert len(list(fps['J1'].Pads()))==16 and len(list(fps['J2'].Pads()))==12
pad1=fps['J3'].FindPadByNumber('1');pad18=fps['J3'].FindPadByNumber('18')
assert abs((pad1.GetPosition()-pad18.GetPosition()).EuclideanNorm()/1e6-8.5)<1e-6
assert pad1.GetNetname()=='PERIPH_3V3'
thermal=[pad for pad in fps['U1'].Pads() if pad.GetAttribute()==p.PAD_ATTRIB_PTH]
assert len(thermal)==2 and all(pad.GetNumber()=='9' and pad.GetNetname()=='GND' and p.ToMM(pad.GetDrillSize().x)==.25 for pad in thermal)

vip=[]
for via in b.GetTracks():
    if not isinstance(via,p.PCB_VIA):continue
    for ref,f in fps.items():
        for pad in f.Pads():
            if pad.GetAttribute()==p.PAD_ATTRIB_SMD and pad.IsOnLayer(p.F_Cu) and pad.HitTest(via.GetPosition()):
                vip.append({'ref':ref,'pad':pad.GetNumber(),'x_mm':p.ToMM(via.GetPosition().x),
                            'y_mm':p.ToMM(via.GetPosition().y),'drill_mm':p.ToMM(via.GetDrillValue())})
for pad in thermal:
    vip.append({'ref':'U1','pad':'9','x_mm':p.ToMM(pad.GetPosition().x),'y_mm':p.ToMM(pad.GetPosition().y),'drill_mm':.25})
project=json.loads((H/'harmony-mark6-carrier.kicad_pro').read_text())['board']['design_settings']
assert project['drc_exclusions']==[]
ignored=[k for k,v in project['rule_severities'].items() if v=='ignore']
assert ignored==['footprint_type_mismatch'],ignored
strict=json.loads((H/'output/assembly-audit/strict-drc.json').read_text())
assert not strict['unconnected_items'] and len(strict['violations'])==1
warning=strict['violations'][0]
assert warning['type']=='footprint_type_mismatch' and warning['severity']=='warning'
assert [i['description'] for i in warning['items']]==['Footprint U1']
report={'date':'2026-09-22','status':'PASS package consistency; physical and supplier review pending',
        'assembled_parts':len(rows),'SMT':34,'through_hole':2,'placements':rows,'socket_holes':holes,
        'via_in_pad':vip,'ignored_rule':{'name':'footprint_type_mismatch','reason':'U1 is SMT with two plated thermal holes on exposed ground pad 9; strict DRC expects Through hole because of those holes'},
        'strict_drc':{'violations':1,'errors':0,'unconnected':0,'reviewed_warning':'Only U1 footprint_type_mismatch'},
        'sources':{'Hirose_J3':'https://www.hirose.com/en/product/p/CL0586-0530-1-55',
                   'Samtec_J1':'https://www.samtec.com/products/ssw-116-01-g-s',
                   'Samtec_dimensions':'https://suddendocs.samtec.com/catalog_english/ssw_th.pdf'},
        'sha256':{n:hashlib.sha256((H/n).read_bytes()).hexdigest() for n in ['harmony-mark6-carrier.kicad_pcb','harmony-mark6-carrier.kicad_pro','bom-draft.csv','output/all-positions.csv']}}
(H/'assembly-audit.json').write_text(json.dumps(report,indent=2)+'\n')
with (H/'output/via-in-pad.csv').open('w') as out:
    w=csv.DictWriter(out,fieldnames=['ref','pad','x_mm','y_mm','drill_mm']);w.writeheader();w.writerows(vip)
print('PASS:',len(rows),'BOM/value/footprint/position matches;',len(vip),'via-in-pad entries;',holes)
