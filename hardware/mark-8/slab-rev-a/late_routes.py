"""Add the late hand routes in late-routes.json to the board (KiCad Python).

Run right after build_pcb.py, before any router: the routes are locked, so Freerouting treats them as
fixed wiring (and its sessions carry them back), and they are appended to hand-routes.json, so
drc_clean.py never deletes them.
"""
import json
import pcbnew as p
import wx
from design import HERE, NAME, to_kicad

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
nets = {n.GetNetname(): n for n in b.GetNetInfo().NetsByNetcode().values()}
LATE = json.loads((HERE / 'late-routes.json').read_text())
HAND = json.loads((HERE / 'hand-routes.json').read_text())
LAY = {'F.Cu': p.F_Cu, 'In2.Cu': p.In2_Cu}


def v(q):
    kx, ky = to_kicad(*q)
    return p.VECTOR2I(p.FromMM(kx), p.FromMM(ky))


n = 0
for t in LATE['tracks']:
    for a, z in zip(t['pts'], t['pts'][1:]):
        tr = p.PCB_TRACK(b); tr.SetStart(v(a)); tr.SetEnd(v(z)); tr.SetWidth(p.FromMM(t['width']))
        tr.SetLayer(LAY[t['layer']]); tr.SetNet(nets[t['net']]); tr.SetLocked(True); b.Add(tr); n += 1
        HAND['tracks'].append([list(a), list(z)])
for vi in LATE['vias']:
    t = p.PCB_VIA(b); t.SetPosition(v(vi['pos'])); t.SetWidth(p.FromMM(0.5)); t.SetDrill(p.FromMM(0.3))
    t.SetViaType(p.VIATYPE_THROUGH); t.SetLayerPair(p.F_Cu, p.B_Cu); t.SetNet(nets[vi['net']]); t.SetLocked(True)
    b.Add(t); n += 1
    HAND['vias'].append(list(vi['pos']))
(HERE / 'hand-routes.json').write_text(json.dumps(HAND))
p.ZONE_FILLER(b).Fill(b.Zones())
p.SaveBoard(str(PCB), b)
print('late routes added:', n, 'items')
