"""Save or restore every track and via of the finished board (KiCad Python).

Usage: routing_snapshot.py save      write routing-final.json from the board
       routing_snapshot.py restore   delete every track and via on the board, then add the saved ones

The repair loop (close_open.sh) is deterministic for one set of inputs, but it takes about an hour
and small changes upstream change its path. So rebuild.sh restores the checked routing from
routing-final.json by default, and routes again only with ROUTE=1 or ROUTE=loop. Coordinates are
stored in KiCad nanometres, so a restore gives the same copper exactly.
"""
import json
import sys
import pcbnew as p
import wx
from design import HERE, NAME

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
SNAP = HERE / 'routing-final.json'
b = p.LoadBoard(str(PCB))
nets = {n.GetNetname(): n for n in b.GetNetInfo().NetsByNetcode().values()}
LAYER = {'F.Cu': p.F_Cu, 'In1.Cu': p.In1_Cu, 'In2.Cu': p.In2_Cu, 'B.Cu': p.B_Cu}
NAMES = {v: k for k, v in LAYER.items()}

if sys.argv[1:] == ['save']:
    tracks, vias = [], []
    for t in b.GetTracks():
        if isinstance(t, p.PCB_VIA):
            q = t.GetPosition()
            vias.append([t.GetNetname(), q.x, q.y, t.GetWidth(), t.GetDrillValue(), int(t.IsLocked())])
        elif isinstance(t, p.PCB_ARC):
            sys.exit('arc tracks are not supported')
        else:
            a, z = t.GetStart(), t.GetEnd()
            tracks.append([t.GetNetname(), NAMES[t.GetLayer()], a.x, a.y, z.x, z.y, t.GetWidth(), int(t.IsLocked())])
    tracks.sort(); vias.sort()
    SNAP.write_text(json.dumps({'units': 'nm, KiCad board coordinates', 'tracks': tracks, 'vias': vias},
                               separators=(',', ':')).replace('],[', '],\n['))
    print('saved %d track segments and %d vias to %s' % (len(tracks), len(vias), SNAP.name))
elif sys.argv[1:] == ['restore']:
    snap = json.loads(SNAP.read_text())
    for t in list(b.GetTracks()):
        b.Delete(t)
    for net, lay, x1, y1, x2, y2, w, lk in snap['tracks']:
        t = p.PCB_TRACK(b); t.SetStart(p.VECTOR2I(x1, y1)); t.SetEnd(p.VECTOR2I(x2, y2)); t.SetWidth(w)
        t.SetLayer(LAYER[lay]); t.SetNet(nets[net]); t.SetLocked(bool(lk)); b.Add(t)
    for net, x, y, w, d, lk in snap['vias']:
        t = p.PCB_VIA(b); t.SetPosition(p.VECTOR2I(x, y)); t.SetWidth(w); t.SetDrill(d)
        t.SetViaType(p.VIATYPE_THROUGH); t.SetLayerPair(p.F_Cu, p.B_Cu); t.SetNet(nets[net]); t.SetLocked(bool(lk))
        b.Add(t)
    p.SaveBoard(str(PCB), b)
    print('restored %d track segments and %d vias from %s' % (len(snap['tracks']), len(snap['vias']), SNAP.name))
else:
    sys.exit(__doc__)
