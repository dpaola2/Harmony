"""Apply the layout fixes of the 2026-11-21 pre-order review to the restored routing (KiCad Python).

rebuild.sh runs this right after `routing_snapshot.py restore`, so routing-final.json stays the checked
routing of 2026-11-17 and every change to it is listed here, in device coordinates (README, "Review
dispositions, November 21"). Each removal must match exactly one track or via, or the script stops: a
change upstream then shows up at once instead of leaving stale copper. Pad-relative routes for parts that
moved or are new are computed from the placed pads, like build_pcb.py does.

  ESP32-1  antenna open-end clearance: R31/R32 and their 3V3, SDA and SCL copper leave x 21.8..27.2,
           y -21.8..-18.2; I2C_SDA, VBUS and ESP_EN are re-routed left of x 21.8; SW1 pad 5 joins pad 3.
  L3, L4   U8 pin 2 GND via off its pad (moved in build_pcb.py too), DTR via clear of U2 pin 23,
           J3 pin 4 via clear of its pad.
  CONN-1   J3 hatched areas: VBAT leaves bar C (L1 bridge moved above it), SD_CD leaves strip B, the SD_CS,
           3V3_PERIPH and VBUS vias leave column A.
  PWR-1    Q4 gate network: PERIPH_DIV node, R34 and C26 (also in build_pcb.py).
"""
import math
import pcbnew as p
import wx
from design import *

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
nets = {n.GetNetname(): n for n in b.GetNetInfo().NetsByNetcode().values()}
LAY = {'F': p.F_Cu, 'L3': p.In2_Cu}
TOL = 0.0012


def dev(vec):
    return to_device(p.ToMM(vec.x), p.ToMM(vec.y))


def kv(q):
    kx, ky = to_kicad(*q)
    return p.VECTOR2I(p.FromMM(kx), p.FromMM(ky))


def same(a, z):
    return abs(a[0] - z[0]) < TOL and abs(a[1] - z[1]) < TOL


fps = {f.GetReference(): f for f in b.GetFootprints()}


def P(ref, num):
    return tuple(round(c, 4) for c in dev(fps[ref].FindPadByNumber(num).GetPosition()))


# --- copper removed from the 2026-11-17 routing (net, layer, a, z) and (net, via position) ----------------
REMOVE_TRACKS = [
    # ESP32-1: R31/R32 3V3 feed (L3 from the 3V3 via at (16.5, -13.6), F down to the old R31/R32 position)
    ('3V3', 'L3', (16.5204, -13.6312), (20.5681, -17.6789)), ('3V3', 'L3', (20.5681, -17.6789), (21.8125, -17.6789)),
    ('3V3', 'F', (21.8125, -17.6789), (23.2889, -17.6789)), ('3V3', 'F', (23.2889, -17.6789), (24.91, -19.3)),
    ('3V3', 'F', (24.91, -19.3), (24.91, -20.5)),
    # ESP32-1: SCL branch to the old R32, SDA stub to the old R31 and the SDA loop through the via at x 22.47
    ('I2C_SCL', 'F', (15.5823, -15.4), (20.6823, -20.5)), ('I2C_SCL', 'F', (20.6823, -20.5), (23.89, -20.5)),
    ('I2C_SDA', 'F', (23.89, -19.3), (22.4689, -19.3)),
    ('I2C_SDA', 'L3', (22.4689, -19.3), (22.4689, -17.6643)), ('I2C_SDA', 'L3', (22.4689, -17.6643), (17.9166, -13.112)),
    ('I2C_SDA', 'L3', (22.4689, -19.3), (19.6817, -22.0872)),
    # ESP32-1: VBUS drop to L3 at x 22.8 and its L3 approach
    ('VBUS', 'F', (22.8, -20.0), (19.85, -19.1)), ('VBUS', 'L3', (21.6, -21.65), (22.0, -21.25)),
    ('VBUS', 'L3', (22.0, -21.25), (22.8, -20.0)),
    # ESP32-1: ESP_EN via moved left of the new VBUS drop
    ('ESP_EN', 'F', (20.2, -20.9583), (21.4678, -20.9583)), ('ESP_EN', 'F', (20.2, -21.78), (20.2, -20.9583)),
    ('ESP_EN', 'L3', (21.1151, -21.311), (21.4678, -20.9583)),
    # ESP32-1: SW1 pad 5 GND stub and via inside the new keep-out
    ('GND', 'F', (26.45, -17.45), (26.45, -18.5)),
    # L3: U8 pin 2 GND stub to its in-pad via
    ('GND', 'F', (8.15, -45.6), (8.7, -45.6)),
    # L4: DTR via 0.02 from the U2 pin 23 opening
    ('DTR', 'F', (11.15, -47.55), (11.15, -48.17)), ('DTR', 'L3', (11.15, -48.17), (11.5, -47.82)),
    # L3: J3 pin 4 via touching its pad
    ('3V3_PERIPH', 'L3', (-13.6, -32.4), (-13.6, -30.04)),
    # CONN-1 bar C: VBAT L1 bridge across the hatched bar under J3
    ('VBAT', 'F', (-8.6, -39.55), (-16.75, -37.65)),
    # CONN-1 strip B: SD_CD inside the card-detect strip
    ('SD_CD', 'F', (-8.1, -36.85), (-8.05, -41.55)), ('SD_CD', 'F', (-8.05, -41.55), (-7.3, -43.1333)),
    # CONN-1 column A: SD_CS, 3V3_PERIPH and VBUS vias moved out
    ('SD_CS', 'F', (-9.8, -35.8), (-7.75, -35.0)), ('SD_CS', 'L3', (-7.75, -35.0), (-6.55, -35.0)),
    ('3V3_PERIPH', 'F', (-6.0067, -38.4), (-6.85, -38.6)), ('3V3_PERIPH', 'L3', (-6.85, -38.6), (-9.15, -35.95)),
    ('VBUS', 'F', (-6.7343, -40.7919), (-6.7343, -39.9032)), ('VBUS', 'F', (-6.7343, -39.9032), (-6.4, -41.3)),
    ('VBUS', 'L3', (-5.0979, -42.4283), (-6.7343, -40.7919)),
    # CONN-1 strip B: J3 pin 12 GND fan-out via touching the bottom of the strip
    ('GND', 'F', (-7.3, -47.89), (-8.209, -47.365)),
    # PWR-1: the old single gate node (Q4 gate, R13, R14, C18)
    ('PERIPH_GATE', 'F', (-13.05, -22.15), (-12.41, -22.79)), ('PERIPH_GATE', 'F', (-12.41, -22.79), (-12.41, -23.8)),
    ('PERIPH_GATE', 'F', (-12.41, -25.1), (-12.38, -26.4)),
]
REMOVE_VIAS = [('3V3', (21.8125, -17.6789)), ('I2C_SDA', (22.4689, -19.3)), ('VBUS', (22.8, -20.0)),
               ('ESP_EN', (21.4678, -20.9583)), ('GND', (26.45, -18.5)), ('GND', (8.7, -45.6)), ('DTR', (11.15, -48.17)),
               ('3V3_PERIPH', (-13.6, -32.4)), ('VBAT', (-8.6, -39.55)), ('SD_CS', (-7.75, -35.0)),
               ('3V3_PERIPH', (-6.85, -38.6)), ('VBUS', (-6.7343, -40.7919)), ('GND', (-8.209, -47.365))]
# PWR-1: R13 and R14 now meet at PERIPH_DIV; the segment between them changes net.
RENET = [('PERIPH_GATE', 'PERIPH_DIV', 'F', (-12.41, -23.8), (-12.41, -25.1))]

# --- copper added (net, layer, points, width) and vias ----------------------------------------------------
ADD_TRACKS = [
    # ESP32-1: I2C_SDA from U1 pin 34 rises on L3, crosses to L1 left of the BOOT and ESP_EN copper, runs up
    # between the VBUS and SD_MISO diagonals and returns to the L3 SDA run at its old right-hand end.
    ('I2C_SDA', 'L3', [(19.6817, -22.0872), (19.75, -22.0189), (19.75, -20.7)], 0.15),
    ('I2C_SDA', 'F', [(19.75, -20.7), (19.75, -19.96), (18.0, -18.21)], 0.15),
    ('I2C_SDA', 'L3', [(18.0, -18.21), (18.0, -13.19), (17.9166, -13.112)], 0.15),
    # ESP32-1: VBUS drops to L3 at x 21.45 (0.1 left of the keep-out) and joins its L3 run at x 21.6
    ('VBUS', 'F', [(19.85, -19.1), (21.45, -19.9)], 0.3),
    ('VBUS', 'L3', [(21.45, -19.9), (21.6, -20.05), (21.6, -21.65)], 0.4),
    # ESP32-1: ESP_EN via above the SW3 pin 1 pad, L3 joins its vertical at x 21.12
    ('ESP_EN', 'F', [(20.2, -21.78), (20.75, -21.33), (20.75, -20.75)], 0.15),
    ('ESP_EN', 'L3', [(20.75, -20.75), (21.1151, -21.1151), (21.1151, -21.311)], 0.15),
    # ESP32-1: SW1 pad 5 joins pad 3 below the Alps prohibited area, 0.27 clear of the guide-boss hole
    ('GND', 'F', [(26.45, -16.9), (24.5, -16.9)], 0.2),
    # L4: DTR via 0.15 clear of the U2 openings, L3 back onto the old DTR run
    ('DTR', 'F', [(11.15, -47.55), (11.15, -48.05), (11.4, -48.3), (11.6, -48.3)], 0.15),
    ('DTR', 'L3', [(11.6, -48.3), (11.5, -47.82)], 0.15),
    # L3: J3 pin 4 via 0.15 higher
    ('3V3_PERIPH', 'L3', [(-13.6, -32.25), (-13.6, -30.04)], 0.3),
    # CONN-1 bar C: VBAT crosses CHG_STAT on L1 above bar C (between the J3 contact row and the bar), then L3
    ('VBAT', 'F', [(-16.75, -37.65), (-13.2, -37.7)], 0.4),
    ('VBAT', 'L3', [(-13.2, -37.7), (-11.35, -39.55), (-8.6, -39.55)], 0.4),
    # CONN-1 strip B: SD_CD in the 0.35 mm corridor between strip B and column A, left of pad 10
    ('SD_CD', 'F', [(-8.1, -36.85), (-8.09, -38.9), (-7.855, -39.135), (-7.855, -42.6), (-7.3, -43.1333)], 0.15),
    # CONN-1 column A: vias moved just outside the column
    ('SD_CS', 'F', [(-9.8, -35.8), (-8.0, -34.4)], 0.15),
    ('SD_CS', 'L3', [(-8.0, -34.4), (-6.55, -35.0)], 0.15),
    ('3V3_PERIPH', 'F', [(-6.0067, -38.4), (-6.55, -38.6)], 0.4),
    ('3V3_PERIPH', 'L3', [(-6.55, -38.6), (-9.15, -35.95)], 0.4),
    ('VBUS', 'F', [(-6.55, -40.75), (-6.4, -41.3)], 0.4),
    ('VBUS', 'L3', [(-5.0979, -42.4283), (-6.55, -40.75)], 0.4),
    ('GND', 'F', [(-7.3, -47.89), (-8.25, -47.75)], 0.25),
]
ADD_VIAS = [('I2C_SDA', (19.75, -20.7)), ('I2C_SDA', (18.0, -18.21)), ('VBUS', (21.45, -19.9)),
            ('ESP_EN', (20.75, -20.75)), ('DTR', (11.6, -48.3)), ('3V3_PERIPH', (-13.6, -32.25)),
            ('VBAT', (-13.2, -37.7)), ('SD_CS', (-8.0, -34.4)), ('3V3_PERIPH', (-6.55, -38.6)), ('VBUS', (-6.55, -40.75)),
            ('GND', (-8.25, -47.75))]

# Pad-relative routes (the same expressions as build_pcb.py) for the parts that moved or are new.
u8 = P('U8', '2')
ADD_TRACKS.append((GND, 'F', [(u8[0], u8[1] - 0.1), (u8[0] - 0.85, u8[1] - 0.1), (u8[0] - 1.15, u8[1] - 0.4)], 0.25))
ADD_VIAS.append((GND, (u8[0] - 1.15, u8[1] - 0.4)))
r31a, r31b = P('R31', '1'), P('R31', '2')           # 3V3, I2C_SDA
ADD_TRACKS += [('3V3', 'F', [r31a, (r31a[0], -13.6297)], 0.4),
               ('I2C_SDA', 'F', [r31b, (r31b[0], r31b[1] - 0.8)], 0.15),
               ('I2C_SDA', 'L3', [(r31b[0], r31b[1] - 0.8), (r31b[0], -13.112)], 0.15)]
ADD_VIAS.append(('I2C_SDA', (r31b[0], r31b[1] - 0.8)))
r32a, r32b = P('R32', '1'), P('R32', '2')           # 3V3, I2C_SCL
ADD_TRACKS += [('3V3', 'F', [r32a, (14.0, -17.8)], 0.4),
               ('I2C_SCL', 'F', [r32b, (12.876, -19.3281)], 0.15)]
ADD_VIAS.append(('3V3', (14.0, -17.8)))
g1, g13, g14, g18 = P('Q4', '1'), P('R13', '2'), P('R14', '2'), P('C18', '1')
d34, g34, g26, p26 = P('R34', '1'), P('R34', '2'), P('C26', '1'), P('C26', '2')
ADD_TRACKS += [('PERIPH_DIV', 'F', [(g13[0], d34[1]), d34], 0.25),
               ('PERIPH_GATE', 'F', [g1, (g1[0], g1[1] - 0.6), (g34[0], g1[1] - 0.6 - (g1[0] - g34[0])), g34, g26], 0.25),
               ('PERIPH_GATE', 'F', [g26, (d34[0] + 0.04, g26[1]), (g18[0] - 0.62, g18[1] + 0.65), g18], 0.25),
               ('3V3_PERIPH', 'F', [p26, (-13.6, -26.4)], 0.25)]
ADD_VIAS.append(('3V3_PERIPH', (-13.6, -26.4)))

# --- apply ----------------------------------------------------------------------------------------------------
tracks = [t for t in b.GetTracks() if not isinstance(t, p.PCB_VIA)]
vias = [t for t in b.GetTracks() if isinstance(t, p.PCB_VIA)]
LN = {p.F_Cu: 'F', p.In2_Cu: 'L3'}


def find_track(net, layer, a, z):
    hit = [t for t in tracks if t.GetNetname() == net and LN.get(t.GetLayer()) == layer and
           ((same(dev(t.GetStart()), a) and same(dev(t.GetEnd()), z)) or (same(dev(t.GetStart()), z) and same(dev(t.GetEnd()), a)))]
    assert len(hit) == 1, 'review_fixes: expected one %s %s track %s-%s, found %d' % (net, layer, a, z, len(hit))
    return hit[0]


for net, layer, a, z in REMOVE_TRACKS:
    t = find_track(net, layer, a, z)
    b.Delete(t); tracks.remove(t)
for net, q in REMOVE_VIAS:
    hit = [v for v in vias if v.GetNetname() == net and same(dev(v.GetPosition()), q)]
    assert len(hit) == 1, 'review_fixes: expected one %s via at %s, found %d' % (net, q, len(hit))
    b.Delete(hit[0]); vias.remove(hit[0])
for old, new, layer, a, z in RENET:
    find_track(old, layer, a, z).SetNet(nets[new])
n_t = 0
for net, layer, pts, w in ADD_TRACKS:
    for a, z in zip(pts, pts[1:]):
        t = p.PCB_TRACK(b); t.SetStart(kv(a)); t.SetEnd(kv(z)); t.SetWidth(p.FromMM(w))
        t.SetLayer(LAY[layer]); t.SetNet(nets[net]); t.SetLocked(True); b.Add(t); n_t += 1
for net, q in ADD_VIAS:
    t = p.PCB_VIA(b); t.SetPosition(kv(q)); t.SetWidth(p.FromMM(0.5)); t.SetDrill(p.FromMM(0.3))
    t.SetViaType(p.VIATYPE_THROUGH); t.SetLayerPair(p.F_Cu, p.B_Cu); t.SetNet(nets[net]); t.SetLocked(True); b.Add(t)
p.ZONE_FILLER(b).Fill(b.Zones())
p.SaveBoard(str(PCB), b)
print('review fixes: removed %d tracks and %d vias, re-netted %d, added %d tracks and %d vias'
      % (len(REMOVE_TRACKS), len(REMOVE_VIAS), len(RENET), n_t, len(ADD_VIAS)))
