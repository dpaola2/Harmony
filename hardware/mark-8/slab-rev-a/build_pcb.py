"""Place the Mark-8 slab board from design.py + netlist.xml and export the Specctra DSN.

Run with KiCad's bundled Python (see rebuild.sh). Produces:
  harmony-mark8-slab.kicad_pcb  placed board with zones, keep-outs and pre-routes (unrouted)
  routing.dsn                   input for Freerouting
Routing-only rule areas carry the name prefix ROUTE_ONLY; finish_pcb.py removes them.
"""
import json
import math
import sys
import xml.etree.ElementTree as ET
import pcbnew as p
import wx
from design import *
from wheel import electrode_polygons

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
PRO = HERE / (NAME + '.kicad_pro')
LIBPATH = str(LIBDIR / (LIBNAME + '.pretty'))


def v(x, y):
    return p.VECTOR2I(p.FromMM(x), p.FromMM(y))


def vd(dx, dy):
    """VECTOR2I at a device position."""
    return v(*to_kicad(dx, dy))


b = p.BOARD()
b.SetFileName(str(PCB))
b.SetCopperLayerCount(4)
b.SetLayerName(p.F_Cu, 'F.Cu')
b.SetLayerType(p.In1_Cu, p.LT_POWER)     # L2 solid GND (plane)
b.SetLayerType(p.In2_Cu, p.LT_SIGNAL)    # L3 power and routing
b.SetLayerType(p.B_Cu, p.LT_POWER)       # L4 touch side: electrodes + GND pour only
ds = b.GetDesignSettings()
ds.SetBoardThickness(p.FromMM(BOARD_T))

# --- nets from the schematic netlist ---------------------------------------------------------
root = ET.parse(HERE / 'netlist.xml')
nets, pin_net = {}, {}
for nn in root.findall('./nets/net'):
    name = nn.get('name').lstrip('/')
    if name.startswith('unconnected-'):
        continue
    ni = p.NETINFO_ITEM(b, name)
    b.Add(ni)
    nets[name] = ni
    for node in nn.findall('node'):
        pin_net[(node.get('ref'), node.get('pin'))] = name
comps = {c.get('ref'): c for c in root.findall('./components/comp')}

# --- outline ---------------------------------------------------------------------------------
outline = board_outline()
for a, z in zip(outline, outline[1:] + outline[:1]):
    e = p.PCB_SHAPE(b)
    e.SetShape(p.SHAPE_T_SEGMENT)
    e.SetStart(vd(*a)); e.SetEnd(vd(*z))
    e.SetLayer(p.Edge_Cuts); e.SetWidth(p.FromMM(0.05))
    b.Add(e)

# --- footprints --------------------------------------------------------------------------------
fps = {}


def place(ref, fpname, dpos, rot, value='', path=None):
    fp = p.FootprintLoad(LIBPATH, fpname)
    assert fp is not None, fpname
    fp.SetReference(ref)
    fp.SetValue(value or fpname)
    fp.SetFPID(p.LIB_ID(LIBNAME, fpname))
    fp.SetPosition(vd(*dpos))
    fp.SetOrientationDegrees(rot)
    if path:
        fp.SetPath(p.KIID_PATH(path))
    b.Add(fp)
    fps[ref] = fp
    return fp


for prt in PARTS:
    c = comps[prt['ref']]
    path = c.find('sheetpath').get('tstamps') + c.findtext('tstamps')
    fp = place(prt['ref'], prt['fp'], prt['pos'], prt['rot'], prt['value'], path)
    if prt['lcsc']:
        fp.SetField('LCSC', prt['lcsc'])
        fp.GetFieldByName('LCSC').SetVisible(False)
    for pad in fp.Pads():
        net = pin_net.get((prt['ref'], pad.GetNumber()))
        if net:
            pad.SetNet(nets[net])
    if not prt['bom']:
        fp.SetAttributes(fp.GetAttributes() | p.FP_EXCLUDE_FROM_BOM | p.FP_EXCLUDE_FROM_POS_FILES)

for i, pos in enumerate(LOCATING_HOLES, 1):
    place('H%d' % i, 'LocatingHole_NPTH_1.6', pos, 0, 'NPTH 1.6 locating')
for i, pos in enumerate(PRESS_PADS, 1):
    place('PP%d' % i, 'PressPad_4.0', pos, 0, 'Press pad 4.0')


# --- silkscreen labels (component side; reads correctly when the board is viewed from L1) -----
def silk(txt, dpos, size=0.8, angle=0, layer=p.F_SilkS, bold=False):
    t = p.PCB_TEXT(b)
    t.SetText(txt)
    t.SetPosition(vd(*dpos))
    t.SetTextSize(v(size, size))
    t.SetTextThickness(p.FromMM(0.15 if size >= 0.8 else 0.12))
    t.SetLayer(layer)
    t.SetTextAngle(p.EDA_ANGLE(angle, p.DEGREES_T))
    b.Add(t)
    return t


def pad_dev(ref, num):
    return to_device(*[p.ToMM(c) for c in (fps[ref].FindPadByNumber(num).GetPosition().x,
                                            fps[ref].FindPadByNumber(num).GetPosition().y)])


j4p, j4m = pad_dev('J4', '2'), pad_dev('J4', '1')
silk('+', (j4p[0] + 1.3, j4p[1] - 1.1), 1.0)
silk('-', (j4m[0] - 1.3, j4m[1] - 1.1), 1.0)
silk('BAT', (-26.3, -15.0), 0.7, angle=90)
silk('M+', (-23.5, -40.6), 0.6)
silk('M-', (-23.6, -43.7), 0.6)
silk('BOOT', (part_by_ref('SW2')['pos'][0] - 2.3, part_by_ref('SW2')['pos'][1]), 0.6, angle=90)
silk('RST', (part_by_ref('SW3')['pos'][0] - 2.3, part_by_ref('SW3')['pos'][1]), 0.6, angle=90)
silk('M8 SLAB A', (14.0, -10.9), 0.7)
silk('JLCJLCJLCJLC', (-14.0, -41.5), 0.8)   # JLC order number goes here, hidden under J3
silk('1', (J2_XC + 0.8, J2_YC - 2.3), 0.6)


# --- zones ---------------------------------------------------------------------------------
def poly_add(sps, pts, hole_of=None):
    if hole_of is None:
        sps.NewOutline()
        for x, y in pts:
            k = vd(x, y); sps.Append(k.x, k.y)
    else:
        h = sps.NewHole(hole_of)
        for x, y in pts:
            k = vd(x, y); sps.Append(k.x, k.y, hole_of, h)


def circle_pts(c, r, n=96):
    return [(c[0] + r * math.cos(2 * math.pi * i / n), c[1] + r * math.sin(2 * math.pi * i / n)) for i in range(n)]


def rect_pts(xr, yr):
    return [(xr[0], yr[0]), (xr[1], yr[0]), (xr[1], yr[1]), (xr[0], yr[1])]


def copper_zone(layer, net, pts, holes=(), priority=0, name='', hatch=False, clearance=0.2):
    z = p.ZONE(b)
    z.SetLayer(layer)
    z.SetNet(nets[net])
    z.SetZoneName(name)
    z.SetAssignedPriority(priority)
    z.SetLocalClearance(p.FromMM(clearance))
    z.SetMinThickness(p.FromMM(0.2))
    z.SetPadConnection(p.ZONE_CONNECTION_FULL)
    z.SetThermalReliefGap(p.FromMM(0.2))
    z.SetThermalReliefSpokeWidth(p.FromMM(0.25))
    z.SetIslandRemovalMode(p.ISLAND_REMOVAL_MODE_ALWAYS)
    if hatch:
        z.SetFillMode(p.ZONE_FILL_MODE_HATCH_PATTERN)
        z.SetHatchThickness(p.FromMM(HATCH_WIDTH))
        z.SetHatchGap(p.FromMM(HATCH_GAP))
        z.SetHatchOrientation(p.EDA_ANGLE(45, p.DEGREES_T))
        z.SetHatchBorderAlgorithm(1)
    o = z.Outline()
    poly_add(o, pts)
    for h in holes:
        poly_add(o, h, 0)
    b.Add(z)
    return z


def rule_area(name, layers, pts, tracks=True, vias=True, pour=True, footprints=False, pads=False):
    z = p.ZONE(b)
    z.SetIsRuleArea(True)
    z.SetZoneName(name)
    ls = p.LSET()
    for l in layers:
        ls.AddLayer(l)
    z.SetLayerSet(ls)
    z.SetDoNotAllowTracks(tracks)
    z.SetDoNotAllowVias(vias)
    z.SetDoNotAllowCopperPour(pour)
    z.SetDoNotAllowFootprints(footprints)
    z.SetDoNotAllowPads(pads)
    poly_add(z.Outline(), pts)
    b.Add(z)
    return z


ALLCU = [p.F_Cu, p.In1_Cu, p.In2_Cu, p.B_Cu]
copper_zone(p.In1_Cu, GND, outline, holes=[circle_pts(WHEEL_C, HATCH_R)], name='L2_GND_SOLID')
copper_zone(p.In1_Cu, GND, circle_pts(WHEEL_C, HATCH_R), name='L2_GND_HATCH_25PCT', hatch=True, priority=1)
copper_zone(p.B_Cu, GND, outline, holes=[circle_pts(WHEEL_C, L4_POUR_CLEAR_R)], name='L4_GND')
for num, pts in electrode_polygons().items():
    net = 'ELE0' if num == 'C' else 'ELE' + num
    z = copper_zone(p.B_Cu, net, pts, name='ELECTRODE_' + num, priority=2, clearance=0.3)
    z.SetPadConnection(p.ZONE_CONNECTION_FULL)
rule_area('ANTENNA_KEEPOUT', ALLCU, rect_pts(*ANTENNA_KEEPOUT), tracks=True, vias=True, pour=True,
          footprints=False, pads=True)


# --- documentation drawings on User.Drawings (device-frame zones, mirrored like the board) ----
def drawing(pts, closed=True, width=0.1):
    seq = pts + ([pts[0]] if closed else [])
    for a, z in zip(seq, seq[1:]):
        e = p.PCB_SHAPE(b); e.SetShape(p.SHAPE_T_SEGMENT); e.SetStart(vd(*a)); e.SetEnd(vd(*z))
        e.SetLayer(p.Dwgs_User); e.SetWidth(p.FromMM(width)); b.Add(e)


for xr, yr in RUN_ZONES:
    drawing(rect_pts(xr, yr))
drawing(rect_pts(*RAMP_ZONE), width=0.2)
drawing(rect_pts(*ANTENNA_REGION))
drawing(circle_pts(WHEEL_C, WHEEL_DISC_D / 2, 72))
for txt, pos in [('FPC RUN (max 4.9 tall)', (0.0, -11.2)), ('FPC LEG', (-10.2, -20.0)), ('FPC TAIL BAND', (-11.0, -46.4)),
                 ('RAMP (max 0.6 tall)', (8.0, J2_YC + 2.4)), ('ANTENNA', (24.5, U1_ORIGIN[1]))]:
    silk(txt, pos, 0.6, layer=p.Dwgs_User)

# --- pre-routes ----------------------------------------------------------------------------

HAND = dict(tracks=[], vias=[])
HAND_SEG, HAND_VIA = [], []      # (net, a, z, width, layer) and (net, pos), for the GND fan-out below


def track(net, pts, width, layer=p.F_Cu):
    HAND['tracks'] += [[list(a), list(z)] for a, z in zip(pts, pts[1:])]
    HAND_SEG.extend((net, tuple(a), tuple(z), width, layer) for a, z in zip(pts, pts[1:]))
    for a, z in zip(pts, pts[1:]):
        t = p.PCB_TRACK(b)
        t.SetStart(vd(*a)); t.SetEnd(vd(*z))
        t.SetWidth(p.FromMM(width)); t.SetLayer(layer); t.SetNet(nets[net]); t.SetLocked(True)
        b.Add(t)


VIAS = []


def via(net, pos, size=0.5, drill=0.3):
    t = p.PCB_VIA(b)
    t.SetPosition(vd(*pos)); t.SetWidth(p.FromMM(size)); t.SetDrill(p.FromMM(drill))
    t.SetViaType(p.VIATYPE_THROUGH); t.SetLayerPair(p.F_Cu, p.B_Cu); t.SetNet(nets[net]); t.SetLocked(True)
    b.Add(t)
    VIAS.append(pos)
    HAND['vias'].append(list(pos))
    HAND_VIA.append((net, tuple(pos)))


def P(ref, num):
    return pad_dev(ref, num)


# --- USB-C fan-out and the USB pair (hand-routed, locked) ----------------------------------------
# J1 pin order (device x): B6 D+ -0.75, A7 D- -0.25, A6 D+ 0.25, B7 D- 0.75. D- joins behind the
# pads and runs over the free rear ends; D+ joins under the receptacle, drops to L3 outside the
# wheel keep-out, and comes back up beside U8. U8 channel 1 carries D-, channel 2 D+, so the pair
# reaches U2 without a crossing.
a7, b7, a6, b6 = P('J1', 'A7'), P('J1', 'B7'), P('J1', 'A6'), P('J1', 'B6')
u8 = {n: P('U8', n) for n in '123456'}
u2dn, u2dp = P('U2', '4'), P('U2', '3')
REAR, FRONT = -42.0, -44.05
track('USB_DN', [a7, (a7[0], REAR), (b7[0], REAR), b7], 0.2)
track('USB_DN', [(b7[0], REAR), (u8['6'][0] - 0.4, REAR), (u8['6'][0], REAR - 0.4), u8['6']], 0.2)
track('USB_DN', [u8['1'], (u8['1'][0] + 0.45, u8['1'][1]), (u8['1'][0] + 1.15, u2dn[1]), u2dn], 0.2)
track('USB_DP', [b6, (b6[0], FRONT), (a7[0], FRONT)], 0.2)
track('USB_DP', [(a7[0], FRONT), (a6[0], FRONT), a6], 0.2)
dp_v1, dp_v2 = (a7[0], -45.0), (4.2, -46.3)
track('USB_DP', [(a7[0], FRONT), dp_v1], 0.2)
via('USB_DP', dp_v1)
track('USB_DP', [dp_v1, (dp_v1[0], dp_v2[1]), dp_v2], 0.2, p.In2_Cu)
via('USB_DP', dp_v2)
track('USB_DP', [dp_v2, (dp_v2[0] + 0.5, u8['4'][1]), u8['4']], 0.2)
track('USB_DP', [u8['3'], (u8['3'][0] + 0.45, u8['3'][1]), (u8['3'][0] + 1.15, u2dp[1]), u2dp], 0.2)
gv = (u8['2'][0] + 0.55, u8['2'][1])
track(GND, [u8['2'], gv], 0.25); via(GND, gv)
# CC pins and VBUS leave from the front ends; vias sit just outside the wheel keep-out.
c = P('J1', 'A5')
track('CC1', [c, (c[0], -45.0)], 0.2); via('CC1', (c[0], -45.0))
c = P('J1', 'B5')
track('CC2', [c, (c[0], -44.5), (c[0] + 0.3, -45.05)], 0.2); via('CC2', (c[0] + 0.3, -45.05))
vb1, vb2 = P('J1', 'A4B9'), P('J1', 'B4A9')
ux = abs(vb1[0]) - 0.2
# The two VBUS pin pairs join behind the CC vias, 0.4 wide (J1 to D1 and to the charger carry up to
# 0.7 A), and drop to L3 through two vias. Each drop steps in 0.05 below the B8 / B5 pad so that it
# keeps 0.2 from the receptacle's locating peg.
for s_, vb in ((1, vb1), (-1, vb2)):
    track('VBUS', [vb, (s_ * (ux + 0.05), vb[1] - 0.3), (s_ * (ux + 0.05), -43.7), (s_ * ux, -43.85), (s_ * ux, -45.7)], 0.4)
track('VBUS', [(ux, -45.7), (-ux, -45.7)], 0.4)
via('VBUS', (ux, -45.7)); via('VBUS', (-ux, -45.7))
# U8 pin 5 (the VBUS reference of the ESD array) straight to the VBUS via, between the D+ and D- pins.
track('VBUS', [(ux, -45.7), u8['5']], 0.3)
for gp, leg in (('A1B12', '4'), ('B1A12', '1')):
    g, l = P('J1', gp), P('J1', leg)
    track(GND, [g, (g[0], -43.2), (l[0], -43.2), l], 0.3)

# --- microSD pull-ups: supply pins to an L3 bus, one via each (the SD lines run between the parts on L1)
bus = []
for ref in ('R24', 'R22', 'R21', 'R23'):
    pin = P(ref, '1')
    v_ = (pin[0], pin[1] + 0.75)
    track('3V3_PERIPH', [pin, v_], 0.3); via('3V3_PERIPH', v_); bus.append(v_)
track('3V3_PERIPH', bus, 0.3, p.In2_Cu)
pin = P('R25', '1')
track('3V3', [pin, (pin[0], pin[1] + 0.75)], 0.3); via('3V3', (pin[0], pin[1] + 0.75))

# --- Backlight return LEDK: J2 pin 1 is the lowest pin of the slot-side row, so LEDK leaves it along
# the bottom of the ramp zone and rises to Q5 beside U1. The other slot-side pins keep their way out.
j21, q53 = P('J2', '1'), P('Q5', '3')
track('LCD_LEDK', [j21, (j21[0] + 0.6, j21[1])], 0.2)
track('LCD_LEDK', [(j21[0] + 0.6, j21[1]), (q53[0], j21[1]), q53], 0.5)

# --- MPR121 supply: VDD (pin 20, with ADDR) to its decoupling capacitor C13 -----------------------
u620, c131 = P('U6', '20'), P('C13', '1')
k620 = (u620[0] - 0.66, u620[1])
track('3V3', [u620, k620], 0.25)
track('3V3', [k620, c131], 0.4)

# --- microSD supply: J3 VDD (pin 4) up to C22 and C21 ------------------------------------------------
j34, c221, c211 = P('J3', '4'), P('C22', '1'), P('C21', '1')
jt = (j34[0], j34[1] + 0.94)
track('3V3_PERIPH', [j34, jt, c221], 0.4)
track('3V3_PERIPH', [jt, c211], 0.4)
# the J3 supply node reaches the pull-up bus through a via on its stem and a short L3 link
jv = (jt[0], jt[1] - 0.1)
via('3V3_PERIPH', jv)
track('3V3_PERIPH', [jv, (jv[0], bus[0][1])], 0.3, p.In2_Cu)

# --- MAX17048: VBAT pins 2 and 3 joined and taken down to L3; GND pins, the exposed pad and C12 joined
# and taken up to L2 (the pins at both ends of each row are GND, so nothing else gets in)
u5 = {n: P('U5', str(n)) for n in range(1, 10)}
vb = ((u5[2][0] + u5[3][0]) / 2, u5[2][1])
track('VBAT', [u5[2], u5[3]], 0.25)
track('VBAT', [vb, (vb[0], vb[1] - 0.81)], 0.3); via('VBAT', (vb[0], vb[1] - 0.81))
ep = u5[9]
track(GND, [u5[1], (u5[1][0], ep[1] - 0.25), (u5[1][0] - 0.3, ep[1] - 0.25)], 0.25)
track(GND, [u5[4], (u5[4][0], ep[1] - 0.25), (u5[4][0] + 0.3, ep[1] - 0.25)], 0.25)
track(GND, [u5[6], (u5[6][0], ep[1])], 0.25)
gv5 = (ep[0] - 1.2, ep[1])                        # GND via left of the exposed pad: pins 7 and 8 keep their way up
track(GND, [ep, gv5], 0.25); via(GND, gv5)
c121, c122 = P('C12', '1'), P('C12', '2')       # C12 turned: VBAT pin up, GND pin down beside U5 pin 1
track(GND, [c122, u5[1]], 0.25)
track('VBAT', [c121, (c121[0], c121[1] + 0.77)], 0.3); via('VBAT', (c121[0], c121[1] + 0.77))
# GND pins of the microSD decoupling caps (top row) drop to L2 above the 3V3_PERIPH L3 bus
for ref in ('C22', 'C21'):
    g_ = P(ref, '2')
    gv_ = (g_[0], -29.35)
    track(GND, [g_, gv_], 0.25); via(GND, gv_)

# --- CH9102F supply: VBUS pins 7 and 8 joined and taken over the NC pins to C25 --------------------
u27, u28, c251 = P('U2', '7'), P('U2', '8'), P('C25', '1')
yv = u28[1] + 0.7
track('VBUS', [u27, u28, (u28[0], yv), (c251[0] - 0.3, yv), c251], 0.3)

# --- ELE2: out of the MPR121's crowded right side through a via, then on L3 inside its own sector -----
u610, e12 = P('U6', '10'), ELECTRODE_VIAS['2']
ev2 = (u610[0] + 0.71, u610[1] - 0.5)
track('ELE2', [u610, ev2], 0.15); via('ELE2', ev2)
track('ELE2', [ev2, e12], 0.15, p.In2_Cu)
# --- ELE4 to ELE7: the MPR121's bottom row (0.4 pitch) drops to L3 at once through four staggered vias
# just below the package, so that the switching nets routed first on L1 leave room for them. Each line
# then runs on L3 to its own E1 pad (the electrode lines may use L3, SPEC 6).
u6b = {n: P('U6', str(n)) for n in (12, 13, 14, 15)}
for net, pin, pts in (('ELE7', 15, [(0.0, -0.46), (-0.35, -0.81), (-0.55, -0.81)]),
                      ('ELE6', 14, [(0.0, -0.81), (-0.35, -1.31)]),
                      ('ELE5', 13, [(0.0, -1.61)]),
                      ('ELE4', 12, [(0.0, -0.71), (0.35, -1.06)])):
    a = u6b[pin]
    path = [a] + [(a[0] + dx, a[1] + dy) for dx, dy in pts]
    track(net, path, 0.15); via(net, path[-1])

# --- MPR121 VREG cap C14 (turned): VREG pin beside pin 5, GND pin to pin 6 and a via to L2 ------------
c141, c142, u66 = P('C14', '1'), P('C14', '2'), P('U6', '6')
track(GND, [c142, (u66[0] + 0.35, u66[1] + 0.45), u66], 0.25)
gv14 = (c142[0] + 0.77, c142[1])
track(GND, [c142, gv14], 0.25); via(GND, gv14)

# --- three short links the routers left open in a crowded corner, placed first so they route around them
u25, c31 = P('U2', '5'), P('C3', '1')               # CH9102F VIO to its decoupling cap, outside the V3 link
track('3V3', [u25, (u25[0] - 0.5, u25[1]), (u25[0] - 1.0, u25[1] + 0.5), (u25[0] - 1.0, c31[1] - 0.55), c31], 0.25)
u127, tp7 = P('U1', '27'), P('TP7', '1')            # GPIO7 straight up to its test pad
track('GPIO7', [u127, (u127[0], u127[1] + 0.8), (u127[0] + 0.6, u127[1] + 1.4), tp7], 0.2)
u57 = P('U5', '7')                                   # MAX17048 SCL up between C9's pads to a via
sclv = (u57[0] - 0.25, u57[1] + 0.86)
track('I2C_SCL', [u57, sclv], 0.15); via('I2C_SCL', sclv)
j215, j214 = P('J2', '15'), P('J2', '14')            # the two LEDA pins joined under the connector body
track('LCD_LEDA', [j215, (j215[0] - 0.6, j215[1]), (j214[0] + 0.6, j214[1]), j214], 0.3)

# --- Q4 gate node: Q4 gate, R13, R14 and C18 share one column, joined before routing --------------
g1, g13, g14, g18 = P('Q4', '1'), P('R13', '2'), P('R14', '2'), P('C18', '1')
track('PERIPH_GATE', [g1, (g13[0], g1[1] - 0.64), g13, g14, g18], 0.25)

# --- DRV2605L: its two VDD pins (6 and 10) joined just outside the pin row, over pins 7 to 9 ------
u7a, u7b = P('U7', '6'), P('U7', '10')
yo = u7a[1] + 0.93          # 0.18 clear of the pin ends of 7, 8 and 9
track('VSYS', [u7a, (u7a[0], yo), (u7b[0], yo), u7b], 0.2)
u7g = P('U7', '8')          # GND pin 8 then drops to L2 under the body, between the pin rows
track(GND, [u7g, (u7g[0], u7g[1] - 1.15)], 0.25); via(GND, (u7g[0], u7g[1] - 1.15))

# --- MPR121: two links that only fit under the chip body (QFN-20 without an exposed pad) -------
u6 = {n: P('U6', str(n)) for n in (1, 4, 8, 20)}
# ADDR (pin 4) to VDD (pin 20) -> address 0x5B. The track runs under the package body (no exposed pad),
# 0.68 below the pin row: 0.14 from the inner ends of pins 1 to 3, 0.15 from pin 19.
ya = u6[4][1] - 0.68
track('3V3', [u6[4], (u6[4][0], ya), (u6[1][0], ya), u6[20]], 0.15)
track('ELE0', [u6[8], ELECTRODE_VIAS['C']], 0.15)                          # centre electrode pad under U6
# REXT (pin 7) to R10 straight out of the right side, before the electrode lines claim the gap.
u67, r101 = P('U6', '7'), P('R10', '1')
track('MPR_REXT', [u67, (u67[0] + 0.9, u67[1]), r101], 0.2)

# --- GND stitching vias -------------------------------------------------------------------------
# U1 exposed pad: one via in each of its nine sub-pads.
for pad in fps['U1'].Pads():
    if pad.GetNumber() == '49':
        via(GND, to_device(p.ToMM(pad.GetPosition().x), p.ToMM(pad.GetPosition().y)))

# CH9102F exposed pad: four vias in the pad (like U1's) and its GND pin 2 joined to it.
u2ep, u22 = P('U2', '25'), P('U2', '2')
for dx_, dy_ in ((-0.6, -0.6), (0.6, -0.6), (-0.6, 0.6), (0.6, 0.6)):
    via(GND, (u2ep[0] + dx_, u2ep[1] + dy_))
track(GND, [u22, (u2ep[0] - 0.9, u22[1])], 0.25)

# --- GND fan-out: every GND pad gets its via to L2 before anything is routed ---------------------------
# A real board gets its ground vias first; left to the end, a GND pad is often boxed in by signals.
# Each GND SMD pad without a hand-made GND connection gets a short 0.25 track to the nearest free spot
# (or an existing GND via within reach). Inside the wheel the via must land on an L2 hatch line.
import math as _m
# the zone filler needs a board read from a file: save, read back, fill that copy for the hatch shape
p.SaveBoard(str(PCB), b)
_b2 = p.LoadBoard(str(PCB))
p.ZONE_FILLER(_b2).Fill(_b2.Zones())
_hz = [z for z in _b2.Zones() if z.GetZoneName() == 'L2_GND_HATCH_25PCT'][0].GetFilledPolysList(p.In1_Cu)
_outline = board_outline()


def _dk(q):
    kx, ky = to_kicad(*q)
    return p.VECTOR2I(p.FromMM(kx), p.FromMM(ky))


def _box(pad):
    bb = pad.GetBoundingBox()
    a_ = to_device(p.ToMM(bb.GetLeft()), p.ToMM(bb.GetTop())); z_ = to_device(p.ToMM(bb.GetRight()), p.ToMM(bb.GetBottom()))
    return (min(a_[0], z_[0]), min(a_[1], z_[1]), max(a_[0], z_[0]), max(a_[1], z_[1]))


def _bd(bx, q):
    return _m.hypot(max(bx[0] - q[0], 0, q[0] - bx[2]), max(bx[1] - q[1], 0, q[1] - bx[3]))


def _sd(q, a_, c_):
    dx, dy = c_[0] - a_[0], c_[1] - a_[1]; L = dx * dx + dy * dy
    u = 0 if L == 0 else max(0, min(1, ((q[0] - a_[0]) * dx + (q[1] - a_[1]) * dy) / L))
    return _m.hypot(q[0] - a_[0] - u * dx, q[1] - a_[1] - u * dy)


_pads = [(f.GetReference(), pd.GetNumber(), pd.GetNetname(), _box(pd), pd.GetAttribute() != p.PAD_ATTRIB_SMD)
         for f in b.GetFootprints() for pd in f.Pads() if pd.IsOnLayer(p.F_Cu)]
_tracks = [(a_, z_, w_ / 2, n_, l_ == p.F_Cu) for n_, a_, z_, w_, l_ in HAND_SEG]
_vias = [(v_, n_) for n_, v_ in HAND_VIA]
_done = {(r_, n_) for r_, n_, net_, bx_, th_ in _pads if net_ == GND and th_}
for (a_, z_, hw_, n_, f_) in _tracks:
    if n_ == GND and f_:
        for r_, num_, net_, bx_, th_ in _pads:
            if net_ == GND and (_bd(bx_, a_) < 0.01 or _bd(bx_, z_) < 0.01):
                _done.add((r_, num_))


def _via_ok(q):
    if not MPath_inside(q) or min(_sd(q, e0, e1) for e0, e1 in zip(_outline, _outline[1:] + _outline[:1])) < 0.6:
        return False
    (ax0, ax1), (ay0, ay1) = ANTENNA_KEEPOUT
    if ax0 - 0.4 <= q[0] <= ax1 + 0.4 and ay0 - 0.4 <= q[1] <= ay1 + 0.4:
        return False
    for r_, n_, net_, bx_, th_ in _pads:
        if _bd(bx_, q) < 0.25 + (0.15 if net_ == GND else 0.2):
            return False
    for v_, n_ in _vias:
        if _m.hypot(q[0] - v_[0], q[1] - v_[1]) < 0.85:
            return False
    for a_, z_, hw_, n_, f_ in _tracks:
        if n_ != GND and _sd(q, a_, z_) < 0.25 + hw_ + 0.15:
            return False
    if _m.hypot(q[0] - WHEEL_C[0], q[1] - WHEEL_C[1]) < HATCH_R + 0.05 and not _hz.Collide(_dk(q), p.FromMM(0.12)):
        return False
    return True


def _path_ok(a_, c_, own):
    for r_, n_, net_, bx_, th_ in _pads:
        if net_ != GND:
            for k in range(13):
                q = (a_[0] + (c_[0] - a_[0]) * k / 12, a_[1] + (c_[1] - a_[1]) * k / 12)
                if _bd(bx_, q) < 0.125 + 0.15:
                    return False
    for v_, n_ in _vias:
        if n_ != GND and _sd(v_, a_, c_) < 0.25 + 0.125 + 0.15:
            return False
    for t0, t1, hw_, n_, f_ in _tracks:
        if n_ != GND and f_:
            for k in range(13):
                q = (a_[0] + (c_[0] - a_[0]) * k / 12, a_[1] + (c_[1] - a_[1]) * k / 12)
                if _sd(q, t0, t1) < 0.125 + hw_ + 0.15:
                    return False
    return True


def MPath_inside(q):
    x, y = q; c = False
    for (x0, y0), (x1, y1) in zip(_outline, _outline[1:] + _outline[:1]):
        if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
            c = not c
    return c


_fan = 0
for r_, num_, net_, bx_, th_ in sorted(_pads):
    if net_ != GND or th_ or (r_, num_) in _done or (r_, num_) in (('U1', '49'), ('U2', '25')):
        continue
    c_ = ((bx_[0] + bx_[2]) / 2, (bx_[1] + bx_[3]) / 2)
    best = None
    near = [v_ for v_, n_ in _vias if n_ == GND and _m.hypot(v_[0] - c_[0], v_[1] - c_[1]) < 1.6]
    for v_ in sorted(near, key=lambda v_: _m.hypot(v_[0] - c_[0], v_[1] - c_[1])):
        if _path_ok(c_, v_, (r_, num_)):
            best = ('join', v_); break
    if not best:
        for dist in (0.75, 0.9, 1.05, 1.25, 1.5, 1.8):
            for k in range(24):
                ang = 2 * _m.pi * k / 24
                q = (round(c_[0] + dist * _m.cos(ang), 3), round(c_[1] + dist * _m.sin(ang), 3))
                if _via_ok(q) and _path_ok(c_, q, (r_, num_)):
                    best = ('via', q); break
            if best:
                break
    if not best:
        print('GND fan-out: no spot for', r_, num_)
        continue
    kind, q = best
    track(GND, [c_, q], 0.25)
    if kind == 'via':
        via(GND, q); _vias.append((q, GND)); _fan += 1
    _tracks.append((c_, q, 0.125, GND, True))
print('GND fan-out vias:', _fan)

(HERE / "hand-routes.json").write_text(json.dumps(HAND))
p.SaveBoard(str(PCB), b)

DRU = '''(version 1)
# Board rules from SPEC 6: 0.127 minimum space everywhere (net classes route at 0.13), 0.2 hole clearance.
# The board-level floors in the project are lower only so the vendor land patterns below can pass.
(rule "board minimum space"
  (constraint clearance (min 0.127mm)))
(rule "board hole clearance"
  (constraint hole_clearance (min 0.2mm)))
# Vendor land patterns with pad gaps below 0.127 (JLCPCB 4-layer minimum space is 0.09).
(rule "J1 USB-C vendor land pattern"
  (condition "A.memberOfFootprint('J1') && B.memberOfFootprint('J1')")
  (constraint clearance (min 0.09mm)))
(rule "U6 MPR121 0.4 mm pitch land pattern"
  (condition "A.memberOfFootprint('U6') && B.memberOfFootprint('U6')")
  (constraint clearance (min 0.12mm)))
# SKRTLAE010 guide-boss holes sit 0.07 mm from the switch's own pads (Alps land pattern).
(rule "SW1 vendor guide-boss holes"
  (condition "A.memberOfFootprint('SW1') && B.memberOfFootprint('SW1')")
  (constraint hole_clearance (min 0.0mm)))
'''
# --- design rules and net classes live in the project file ---------------------------------
pro = json.loads(PRO.read_text())
rules = pro['board']['design_settings']['rules']
rules.update({'min_clearance': 0.09, 'min_track_width': 0.127, 'min_via_diameter': 0.5,
              'min_through_hole_diameter': 0.3, 'min_via_annular_width': 0.1, 'min_copper_edge_clearance': 0.3,
              'min_hole_clearance': 0.0, 'min_hole_to_hole': 0.25, 'min_silk_clearance': 0.0,
              'min_text_height': 0.6, 'min_text_thickness': 0.1})
pro['board']['design_settings']['defaults']['board_outline_line_width'] = 0.05
pro['board']['design_settings'].setdefault('track_widths', [])
pro['board']['design_settings']['track_widths'] = [0.0, 0.15, 0.2, 0.3, 0.4, 0.5]
pro['board']['design_settings']['via_dimensions'] = [{'diameter': 0.0, 'drill': 0.0}, {'diameter': 0.5, 'drill': 0.3}]
sev = pro['board']['design_settings'].setdefault('rule_severities', {})
classes = pro['net_settings']['classes']
default = [c for c in classes if c['name'] == 'Default'][0]
# The routers work at 0.13 space (SPEC 6: 0.127 minimum, 0.15 preferred): this board has no room for 0.15
# around the module, the QFNs and the microSD row.
default.update({'clearance': 0.13, 'track_width': 0.15, 'via_diameter': 0.5, 'via_drill': 0.3,
                'diff_pair_width': 0.2, 'diff_pair_gap': 0.2})
power = dict(default, name='Power', track_width=0.4, clearance=0.13)
usbc = dict(default, name='USB', track_width=0.2, clearance=0.15, diff_pair_width=0.2, diff_pair_gap=0.2)
gnd = dict(default, name='Ground', track_width=0.3, clearance=0.13)
pro['net_settings']['classes'] = [default, power, usbc, gnd]
pro['net_settings']['netclass_patterns'] = (
    [{'netclass': 'Power', 'pattern': nm} for nm in POWER_NETS if nm != GND] +
    [{'netclass': 'Ground', 'pattern': GND}] +
    [{'netclass': 'USB', 'pattern': nm} for nm in USB_NETS])
pro['net_settings']['netclass_assignments'] = None
PRO.write_text(json.dumps(pro, indent=2) + '\n')
(HERE / (NAME + '.kicad_dru')).write_text(DRU)

print('placed', len(list(b.GetFootprints())), 'footprints; rules written to', PRO.name)
