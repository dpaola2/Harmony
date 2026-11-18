"""Add the L1 and L3 ground pours and fill every zone (after import_ses.py of phase B).

Freerouting necks a track down to 0.1124 mm at a few fine-pitch pins. SPEC 6 sets 0.127 as the
minimum track, so those tracks are widened to 0.127 first. They were routed with 0.13 space; DRC then
checks the 0.127 minimum space, and the repair loop reroutes any track that falls short.
"""
import math
import pcbnew as p
import wx
from design import *

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
nets = {n.GetNetname(): n for n in b.GetNetInfo().NetsByNetcode().values()}


def v(x, y):
    return p.VECTOR2I(p.FromMM(x), p.FromMM(y))


def vd(dx, dy):
    return v(*to_kicad(dx, dy))




def circle_pts(c, r, n=96):
    return [(c[0] + r * math.cos(2 * math.pi * i / n), c[1] + r * math.sin(2 * math.pi * i / n)) for i in range(n)]


def gnd_zone(layer, name, holes):
    z = p.ZONE(b)
    z.SetLayer(layer); z.SetNet(nets[GND]); z.SetZoneName(name)
    z.SetLocalClearance(p.FromMM(0.2)); z.SetMinThickness(p.FromMM(0.2))
    z.SetPadConnection(p.ZONE_CONNECTION_FULL)
    z.SetThermalReliefGap(p.FromMM(0.2)); z.SetThermalReliefSpokeWidth(p.FromMM(0.25))
    z.SetIslandRemovalMode(p.ISLAND_REMOVAL_MODE_ALWAYS)
    o = z.Outline(); o.NewOutline()
    for x, y in board_outline():
        k = vd(x, y); o.Append(k.x, k.y)
    for h in holes:
        hi = o.NewHole(0)
        for x, y in h:
            k = vd(x, y); o.Append(k.x, k.y, 0, hi)
    b.Add(z)


narrow = [t for t in b.GetTracks() if not isinstance(t, p.PCB_VIA) and t.GetWidth() < p.FromMM(0.127)]
for t in narrow:
    t.SetWidth(p.FromMM(0.127))
print('necked tracks widened to 0.127 mm:', len(narrow))

# The L1 and L3 ground pours stay outside the wheel. L3 lies 0.1 mm behind the electrodes: solid copper
# there would add tens of pF to every electrode. Under the wheel L3 carries only the DC and static
# tracks of design.DISC_L3_NETS and is otherwise empty; the L2 hatch is the ground under the wheel.
gnd_zone(p.F_Cu, 'L1_GND', [circle_pts(WHEEL_C, L4_POUR_CLEAR_R)])
gnd_zone(p.In2_Cu, 'L3_GND', [circle_pts(WHEEL_C, L4_POUR_CLEAR_R)])
filler = p.ZONE_FILLER(b)
filler.Fill(b.Zones())
p.SaveBoard(str(PCB), b)
tracks = [t for t in b.GetTracks() if not isinstance(t, p.PCB_VIA)]
vias = [t for t in b.GetTracks() if isinstance(t, p.PCB_VIA)]
print('finished: %d track segments, %d vias' % (len(tracks), len(vias)))
