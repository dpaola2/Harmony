"""Dump copper geometry and DRC's unconnected pairs for maze.py (KiCad's bundled Python).

Usage: route_dump.py drc.json out.json
Coordinates are device coordinates (mm). Pads are axis-aligned bounding boxes (every pad on this
board is at 0/90/180/270 degrees; circles and custom shapes become their bounding box, which is
conservative). Zones are not dumped: KiCad refills them around new copper.
"""
import json
import os
import re
import sys
import pcbnew as p
import wx
from design import HERE, NAME, to_device, PHASE_A_NETS, WHEEL_TOLERANT_NETS, GND

app = wx.App(False)
drc = json.loads(open(sys.argv[1]).read())
b = p.LoadBoard(str(HERE / (NAME + '.kicad_pcb')))
LAYERS = {p.F_Cu: 'F.Cu', p.In1_Cu: 'In1.Cu', p.In2_Cu: 'In2.Cu', p.B_Cu: 'B.Cu'}


def d(v):
    return list(to_device(p.ToMM(v.x), p.ToMM(v.y)))


def box(bb):
    a = d(p.VECTOR2I(bb.GetLeft(), bb.GetTop())); z = d(p.VECTOR2I(bb.GetRight(), bb.GetBottom()))
    return [min(a[0], z[0]), min(a[1], z[1]), max(a[0], z[0]), max(a[1], z[1])]


HAND = json.loads((HERE / 'hand-routes.json').read_text())
hand_t = {tuple(round(c, 3) for c in a + z) for a, z in HAND['tracks']} | {tuple(round(c, 3) for c in z + a) for a, z in HAND['tracks']}
hand_v = {tuple(round(c, 3) for c in v) for v in HAND['vias']}


def ripable(net, key, kind):
    """Rip-up cost class: 0 = fixed, else a positive weight. Only GND stubs and stitching vias may be
    ripped up (fixups.py and the GND escape in maze.py replace them at once). Every signal and supply
    track is fixed: ripping those up started cascades that never settled. A signal net that cannot be
    finished is instead ripped up whole by unroute_failed.py and routed again from its pads."""
    if key in (hand_v if kind == 'via' else hand_t):
        return 0
    if os.environ.get('RIP_NETS'):             # targeted rescue: only the listed nets may move
        return 8 if net in os.environ['RIP_NETS'].split(',') else (4 if net == GND else 0)
    if os.environ.get('RIP_ALL') == '1':       # rescue round (close_open.sh): any routed copper may move
        return 8
    if os.environ.get('RIP_ALL') == 'dc':      # gentle rescue round: DC and static nets and the electrode
        return 8 if net in WHEEL_TOLERANT_NETS and net != GND else (4 if net == GND else 0)   # lines may move
    return 4 if net == GND else 0


out = dict(pads=[], tracks=[], vias=[], pairs=[], hatch=[])
# L2 under the wheel is a 25 percent hatch: a GND via there connects only where it lands on a hatch line,
# so maze.py gets the filled hatch polygons to place GND vias on copper.
for z in b.Zones():
    if z.GetZoneName() == 'L2_GND_HATCH_25PCT':
        fp_ = z.GetFilledPolysList(p.In1_Cu)
        for i in range(fp_.OutlineCount()):
            ln = fp_.Outline(i)
            out['hatch'].append([d(ln.CPoint(k)) for k in range(ln.PointCount())])
            for h in range(fp_.HoleCount(i)):
                hl = fp_.Hole(i, h)
                out['hatch'].append([d(hl.CPoint(k)) for k in range(hl.PointCount())])
for f in b.GetFootprints():
    for pad in f.Pads():
        layers = [n for l, n in LAYERS.items() if pad.IsOnLayer(l)]
        drill = p.ToMM(max(pad.GetDrillSize().x, pad.GetDrillSize().y)) if pad.GetAttribute() in (p.PAD_ATTRIB_PTH, p.PAD_ATTRIB_NPTH) else 0
        out['pads'].append(dict(ref=f.GetReference(), num=pad.GetNumber(), net=pad.GetNetname(), box=box(pad.GetBoundingBox()),
                                value=f.GetValue(),
                                c=d(pad.GetPosition()), layers=layers, drill=drill,
                                npth=pad.GetAttribute() == p.PAD_ATTRIB_NPTH))
for t in b.GetTracks():
    if isinstance(t, p.PCB_VIA):
        c = d(t.GetPosition())
        out['vias'].append(dict(net=t.GetNetname(), c=c, r=p.ToMM(t.GetWidth()) / 2,
                                rip=ripable(t.GetNetname(), tuple(round(x, 3) for x in c), 'via'),
                                k=[t.GetPosition().x, t.GetPosition().y]))
    else:
        a, z = d(t.GetStart()), d(t.GetEnd())
        out['tracks'].append(dict(net=t.GetNetname(), a=a, z=z, w=p.ToMM(t.GetWidth()),
                                  layer=LAYERS.get(t.GetLayer(), '?'),
                                  rip=ripable(t.GetNetname(), tuple(round(x, 3) for x in a + z), 'track'),
                                  k=[t.GetStart().x, t.GetStart().y, t.GetEnd().x, t.GetEnd().y, t.GetLayer()]))
for u in drc['unconnected_items']:
    items = []
    for it in u['items']:
        s = it['description']
        net = re.search(r'\[([^\]]*)\]', s).group(1)
        pos = [it['pos']['x'], it['pos']['y']]
        pos = list(to_device(pos[0], pos[1]))
        if s.startswith('Zone'):
            kind, layers = 'zone', [re.search(r' on (\S+)', s).group(1)]
        elif s.startswith('Via'):
            kind, layers = 'via', ['F.Cu', 'In2.Cu']
        elif s.startswith('PTH pad'):
            kind, layers = 'pad', ['F.Cu', 'In2.Cu']
        elif s.startswith('Pad'):
            kind, layers = 'pad', [re.search(r' on (\S+)', s).group(1)]
        elif s.startswith('Track'):
            kind, layers = 'track', [re.search(r' on (\S+?),', s).group(1)]
        else:
            kind, layers = 'other', []
        items.append(dict(kind=kind, net=net, pos=pos, layers=layers, desc=s))
    out['pairs'].append(items)
# GND pads that fixups.py could not stitch (often inside an L1 pour island DRC reports only as zone
# fragments): give maze.py one task per pad, which it routes to the nearest spot for a via to L2.
orph = HERE / 'review' / '_gnd_orphans.json'
if orph.exists():
    pads_by = {(pd['ref'], pd['num']): pd for pd in out['pads']}
    for ref, num in json.loads(orph.read_text()):
        pd = pads_by.get((ref, num))
        if pd and 'F.Cu' in pd['layers']:
            it = dict(kind='pad', net=GND, pos=pd['c'], layers=['F.Cu'], desc='Pad %s [GND] of %s (no via yet)' % (num, ref))
            out['pairs'].append([it, dict(it)])
open(sys.argv[2], 'w').write(json.dumps(out))
print('dumped', len(out['pads']), 'pads', len(out['tracks']), 'tracks', len(out['vias']), 'vias', len(out['pairs']), 'unconnected pairs')
