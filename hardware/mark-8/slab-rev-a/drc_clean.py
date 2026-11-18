"""Delete the routed copper that DRC objects to, so maze.py can route those connections again (KiCad Python).

Usage: drc_clean.py [--dangling | --dangling-closed]
(runs kicad-cli DRC itself, up to twelve passes, until a pass removes nothing)
For every DRC error between copper items (clearance, short, crossing, hole spacing, edge clearance),
delete one movable item of the pair: never a pad, zone or hand route (hand-routes.json); a GND item
before a signal item (a stitching via is cheap to place again); otherwise the shorter track.
With --dangling, also delete every dangling track and via, hand routes included: a stub with an open
end carries nothing (a hand stub is left over when the router reached its pad another way).
Run that only once routing is complete: while a connection is still open, its two halves are both
"dangling", and deleting them would unravel the whole route. With --dangling-closed, delete only the
dangling items of nets with no open connection: those are leftovers of ripped routes (a rescue round
leaves many) and only block the router. Zones are refilled and the board saved.
"""
import json
import subprocess
import sys
import pcbnew as p
import wx
from design import HERE, NAME, GND, KICAD, to_device

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
ERRORS = {'clearance', 'shorting_items', 'tracks_crossing', 'hole_clearance', 'hole_near_hole',
          'copper_edge_clearance', 'via_diameter', 'annular_width', 'drill_out_of_range'}
DANGLING = {'track_dangling', 'via_dangling'} if {'--dangling', '--dangling-closed'} & set(sys.argv) else set()
CLOSED_ONLY = '--dangling-closed' in sys.argv

HAND = json.loads((HERE / 'hand-routes.json').read_text())
hand_t = {tuple(round(c, 3) for c in a + z) for a, z in HAND['tracks']} | {tuple(round(c, 3) for c in z + a) for a, z in HAND['tracks']}
hand_v = {tuple(round(c, 3) for c in v) for v in HAND['vias']}
TMP = HERE / 'review' / '_clean-drc.json'


def dev(v):
    return to_device(p.ToMM(v.x), p.ToMM(v.y))


def movable(t):
    if t is None:
        return False
    if isinstance(t, p.PCB_VIA):
        return tuple(round(c, 3) for c in dev(t.GetPosition())) not in hand_v
    return tuple(round(c, 3) for c in dev(t.GetStart()) + dev(t.GetEnd())) not in hand_t


def length(t):
    return 0 if isinstance(t, p.PCB_VIA) else p.ToMM(t.GetLength())


total = {}
for rnd in range(12):
    subprocess.run([str(KICAD / 'MacOS/kicad-cli'), 'pcb', 'drc', '--format', 'json', '--severity-all', '--output', str(TMP),
                    str(PCB)], check=True, capture_output=True)
    drc = json.loads(TMP.read_text())
    b = p.LoadBoard(str(PCB))
    items = {t.m_Uuid.AsString(): t for t in b.GetTracks()}
    kill = {}
    open_nets = {it['description'].split('[')[1].split(']')[0] for u in drc['unconnected_items'] for it in u['items']
                 if '[' in it['description']}
    for v in drc['violations']:
        if v['type'] in ERRORS and v['severity'] == 'error':
            cand = [items.get(it.get('uuid')) for it in v['items']]
            mov = [t for t in cand if movable(t)]
            if not mov:
                print('cannot fix (fixed items):', v['type'], ' | '.join(it['description'] for it in v['items']))
                continue
            if any(t is not None and t.m_Uuid.AsString() in kill for t in cand):
                continue
            gnd = [t for t in mov if t.GetNetname() == GND]
            pick = gnd[0] if gnd and len(gnd) < len(mov) else min(mov, key=length)
            kill[pick.m_Uuid.AsString()] = (v['type'], pick)
        elif v['type'] in DANGLING:
            for it in v['items']:
                t = items.get(it.get('uuid'))
                if CLOSED_ONLY and t is not None and t.GetNetname() in open_nets:
                    continue
                if movable(t) or (t is not None and '--dangling' in sys.argv):
                    kill[t.m_Uuid.AsString()] = (v['type'], t)
    by = {}
    for k, (typ, t) in kill.items():
        by[typ] = by.get(typ, 0) + 1
        b.Delete(t)
    p.ZONE_FILLER(b).Fill(b.Zones())
    p.SaveBoard(str(PCB), b)
    print('drc_clean removed', len(kill), 'items', by)
    for k_, v_ in by.items():
        total[k_] = total.get(k_, 0) + v_
    if not kill:
        break
TMP.unlink()
print('drc_clean total', total)
