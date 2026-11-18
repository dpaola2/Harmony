"""Write the Specctra DSN for one routing phase. Never saves the board.

Phase S (every net not in design.PHASE_A_NETS: the switching signals) routes first on the empty board,
with two routing-only rule areas: no vias and no L3 tracks inside the electrode disc plus 0.5 mm
(design.WHEEL_KEEPOUT_R), so those nets cross the disc on L1 behind the L2 hatch.
Phase P (design.PHASE_A_NETS: DC and static nets and the electrode lines) routes second around the
locked phase-S tracks, without the wheel restrictions. A switching net that phase S left open is not
routed here; maze.py finishes it under the same rule.
Phase R (repair, optional) is phase P on a routed board with the DC copper unlocked, so that
Freerouting may rip it up and route it again around the fixed switching nets.
A separate process from build_pcb.py because pcbnew caches the project file it saved first.
"""
import math
import re
import sys
import pcbnew as p
import wx
from design import HERE, NAME, WHEEL_C, WHEEL_KEEPOUT_R, PHASE_A_NETS, USB_NETS, to_kicad

SIGNAL_NETS = None   # filled after the board loads

phase = sys.argv[1]
assert phase in ('S', 'P', 'R')
app = wx.App(False)
b = p.LoadBoard(str(HERE / (NAME + '.kicad_pcb')))
b.SynchronizeNetsAndNetClasses(True)


def keepout(name, layers, vias, tracks):
    z = p.ZONE(b)
    z.SetIsRuleArea(True); z.SetZoneName(name)
    ls = p.LSET()
    for l in layers:
        ls.AddLayer(l)
    z.SetLayerSet(ls)
    z.SetDoNotAllowTracks(tracks); z.SetDoNotAllowVias(vias); z.SetDoNotAllowCopperPour(False)
    z.SetDoNotAllowFootprints(False); z.SetDoNotAllowPads(False)
    o = z.Outline(); o.NewOutline()
    for i in range(96):
        a = 2 * math.pi * i / 96
        kx, ky = to_kicad(WHEEL_C[0] + WHEEL_KEEPOUT_R * math.cos(a), WHEEL_C[1] + WHEEL_KEEPOUT_R * math.sin(a))
        o.Append(p.FromMM(kx), p.FromMM(ky))
    b.Add(z)


if phase == 'S':
    keepout('ROUTE_ONLY_WHEEL_NO_VIAS', (p.F_Cu, p.In1_Cu, p.In2_Cu, p.B_Cu), True, False)
    keepout('ROUTE_ONLY_WHEEL_NO_L3', (p.In2_Cu,), False, True)
if phase == 'R':
    # Repair pass on a routed board: the DC and static nets and the electrode lines may be ripped up and
    # routed again (their copper is unlocked for the export, except hand routes); everything else stays fixed.
    import json
    HAND = json.loads((HERE / 'hand-routes.json').read_text())
    r3 = lambda q: tuple(round(c, 3) for c in q)
    hand_t = {r3(a) + r3(z) for a, z in HAND['tracks']} | {r3(z) + r3(a) for a, z in HAND['tracks']}
    hand_v = {r3(v) for v in HAND['vias']}
    from design import to_device
    dv = lambda q: to_device(p.ToMM(q.x), p.ToMM(q.y))
    for t in b.GetTracks():
        if t.GetNetname() in PHASE_A_NETS and t.GetNetname() != 'GND':
            hand = (r3(dv(t.GetPosition())) in hand_v) if isinstance(t, p.PCB_VIA) else (r3(dv(t.GetStart())) + r3(dv(t.GetEnd())) in hand_t)
            t.SetLocked(hand)
b.BuildConnectivity()
out = HERE / ('routing-%s.dsn' % phase.lower())
assert p.ExportSpecctraDSN(b, str(out))
if True:
    # Phase S: only switching nets (and the hand-routed USB pair). Phase P: the DC nets and electrode lines except GND,
    # which the L1/L3 pours and fixups.py's stitching vias connect to the L2 plane.
    allnets = [n.GetNetname() for n in b.GetNetInfo().NetsByNetcode().values() if n.GetNetname()]
    # Phase P routes only the DC and static nets and the electrode lines: a switching net that phase S
    # left open is finished by maze.py, which keeps it off L3 inside the disc.
    KEEP = [n for n in allnets if n not in PHASE_A_NETS] if phase == 'S' else [n for n in allnets if n in PHASE_A_NETS and n != 'GND']   # P and R
    text = out.read_text()
    i = text.index('  (network')
    head, net = text[:i], text[i:]
    def drop(m):
        return m.group(0) if m.group(1) in PHASE_A_NETS else ''
    # A net left out of this phase keeps its name with no pins: Freerouting then has nothing to route
    # for it, but still treats its hand-placed wires and vias as obstacles (a deleted net makes
    # Freerouting drop them: "via net ... not found").
    net = re.sub(r'    \(net ("?[^\s"]+"?)\n      \(pins[^)]*\)\n    \)\n',
                 lambda m: m.group(0) if m.group(1).strip('"') in KEEP else '    (net %s\n      (pins)\n    )\n' % m.group(1), net)
    def fix_class(m):
        names = [n for n in m.group(2).split() if n.strip('"') in KEEP]
        return m.group(1) + ' '.join(names) + '\n' if names else m.group(1) + '\n'
    net = re.sub(r'(    \(class \S+ )([^()]*)', fix_class, net)
    out.write_text(head + net)
print('DSN phase', phase, 'written:', out.name)
