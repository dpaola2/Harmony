"""Delete the routed tracks and vias of every switching net that breaks the wheel rule (KiCad Python).

Switching nets (not in design.WHEEL_TOLERANT_NETS) may not place a via inside the wheel keep-out circle or
run on L3 inside the electrode disc plus 0.5 mm (design.WHEEL_KEEPOUT_R). Phase P of Freerouting has no wheel rule, so a switching net that
phase S left open can come back routed through the wheel. The routed copper of such nets is removed
here (their hand routes in hand-routes.json stay) and close_open.sh routes them again with maze.py,
which applies the rule.
"""
import json
import math
import pcbnew as p
import wx
from design import (HERE, NAME, WHEEL_TOLERANT_NETS, USB_NETS, WHEEL_C, WHEEL_KEEPOUT_R, RING_R, to_device,
                    DISC_EDGE_CROSS_NETS, DISC_EDGE_CROSS_R)

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))


def dev(v):
    return to_device(p.ToMM(v.x), p.ToMM(v.y))


def r(q):
    return math.hypot(q[0] - WHEEL_C[0], q[1] - WHEEL_C[1])


bad = set()
for t in b.GetTracks():
    n = t.GetNetname()
    if n in WHEEL_TOLERANT_NETS or n in USB_NETS:
        continue
    lim = DISC_EDGE_CROSS_R if n in DISC_EDGE_CROSS_NETS else WHEEL_KEEPOUT_R
    if isinstance(t, p.PCB_VIA):
        if r(dev(t.GetPosition())) < lim:
            bad.add(n)
    elif t.GetLayer() == p.In2_Cu:
        a, z = dev(t.GetStart()), dev(t.GetEnd())
        if any(r((a[0] + (z[0] - a[0]) * k / 40, a[1] + (z[1] - a[1]) * k / 40)) < lim for k in range(41)):
            bad.add(n)
HAND = json.loads((HERE / 'hand-routes.json').read_text())
r3 = lambda q: tuple(round(c, 3) for c in q)
hand_t = {r3(a) + r3(z) for a, z in HAND['tracks']} | {r3(z) + r3(a) for a, z in HAND['tracks']}
hand_v = {r3(v) for v in HAND['vias']}


def is_hand(t):
    if isinstance(t, p.PCB_VIA):
        return r3(dev(t.GetPosition())) in hand_v
    return r3(dev(t.GetStart())) + r3(dev(t.GetEnd())) in hand_t


kill = [t for t in b.GetTracks() if t.GetNetname() in bad and not is_hand(t)]
for t in kill:
    b.Delete(t)
p.ZONE_FILLER(b).Fill(b.Zones())
p.SaveBoard(str(PCB), b)
print('wheel-rule violations removed for nets:', sorted(bad), '(%d items)' % len(kill))
