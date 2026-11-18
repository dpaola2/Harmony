"""Add maze.py's routes to the board as locked tracks and vias, refill zones, save (KiCad Python)."""
import json
import sys
import pcbnew as p
import wx
from design import HERE, NAME, to_kicad

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
nets = {n.GetNetname(): n for n in b.GetNetInfo().NetsByNetcode().values()}
LAY = {'F.Cu': p.F_Cu, 'In2.Cu': p.In2_Cu}


def v(x, y):
    kx, ky = to_kicad(x, y)
    return p.VECTOR2I(p.FromMM(kx), p.FromMM(ky))


n = 0
routes = json.loads(open(sys.argv[1]).read())['routes']
kill_t = {tuple(v['k']) for r in routes for v in r.get('victims', []) if v['kind'] == 'track'}
kill_v = {tuple(v['k']) for r in routes for v in r.get('victims', []) if v['kind'] == 'via'}
dead = []
for t in b.GetTracks():
    if isinstance(t, p.PCB_VIA):
        if (t.GetPosition().x, t.GetPosition().y) in kill_v:
            dead.append(t)
    elif (t.GetStart().x, t.GetStart().y, t.GetEnd().x, t.GetEnd().y, t.GetLayer()) in kill_t:
        dead.append(t)
for t in dead:
    b.Delete(t)
print('ripped up', len(dead), 'items')
for r in routes:
    for s in r['segs']:
        for a, z in zip(s['pts'], s['pts'][1:]):
            t = p.PCB_TRACK(b); t.SetStart(v(*a)); t.SetEnd(v(*z)); t.SetWidth(p.FromMM(r['width']))
            t.SetLayer(LAY[s['layer']]); t.SetNet(nets[r['net']]); t.SetLocked(True); b.Add(t); n += 1
    for c in r['vias']:
        t = p.PCB_VIA(b); t.SetPosition(v(*c)); t.SetWidth(p.FromMM(0.5)); t.SetDrill(p.FromMM(0.3))
        t.SetViaType(p.VIATYPE_THROUGH); t.SetLayerPair(p.F_Cu, p.B_Cu); t.SetNet(nets[r['net']]); t.SetLocked(True)
        b.Add(t); n += 1
p.ZONE_FILLER(b).Fill(b.Zones())
p.SaveBoard(str(PCB), b)
print('applied', n, 'tracks and vias')
