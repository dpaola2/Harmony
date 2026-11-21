"""Verify the routed Mark-8 slab board and write mechanical-interface.json (device coordinates).

Run with KiCad's bundled Python after finish_pcb.py, ERC and DRC. Every position is re-derived
from the saved .kicad_pcb (footprint position and angle) plus footprint-local facts: the vendor
drawings (cited) and lib/model_geometry.json (measured from the STEP models by measure_models.py).
Exits non-zero when a check fails.
"""
import json
import math
import sys
import hashlib
import xml.etree.ElementTree as ET
import pcbnew as p
import wx
from design import *
DISC_L3_ACCEPTED = globals().get('DISC_L3_ACCEPTED', {})        # net -> (mm L3 inside r 17.1, vias inside r 17.1)
VBUS_PATH_ACCEPTED = globals().get('VBUS_PATH_ACCEPTED', None)  # accepted VBUS path widths (step C), else None
import wheel

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
b.BuildConnectivity()
GEOM = json.loads((LIBDIR / 'model_geometry.json').read_text())
fps = {f.GetReference(): f for f in b.GetFootprints()}
FAIL, NOTES = [], []


def check(cond, msg):
    if not cond:
        FAIL.append(msg)
    return cond


def r3(x):
    return round(x, 3)


def dev(vec):
    return to_device(p.ToMM(vec.x), p.ToMM(vec.y))


def origin(ref):
    return dev(fps[ref].GetPosition())


def angle(ref):
    return fps[ref].GetOrientationDegrees() % 360


def L(ref, local):
    return tuple(r3(c) for c in local_to_device(origin(ref), angle(ref), local))


def pad_dev(ref, num):
    return tuple(r3(c) for c in dev(fps[ref].FindPadByNumber(num).GetPosition()))


def ddir(ref, local):
    d = device_dir(angle(ref), local)
    return (round(d[0], 6) + 0.0, round(d[1], 6) + 0.0)


def zc(h):
    """Device z of a point h above the component surface."""
    return r3(Z_COMP - h)


def model_box(ref):
    """Device-frame xy box and height of the part body from the measured STEP geometry."""
    name = str(fps[ref].GetFPID().GetLibItemName())
    g = GEOM.get(name)
    if not g:
        return None
    pts = [L(ref, (x, y)) for x in g['x'] for y in g['y']]
    return dict(x=[r3(min(q[0] for q in pts)), r3(max(q[0] for q in pts))],
                y=[r3(min(q[1] for q in pts)), r3(max(q[1] for q in pts))],
                height=r3(g['z'][1]), below_surface=r3(-min(0.0, g['z'][0])), model=g['model'], geom=g)


def overlaps(box, zone):
    (zx0, zx1), (zy0, zy1) = zone
    return box['x'][0] < zx1 and box['x'][1] > zx0 and box['y'][0] < zy1 and box['y'][1] > zy0


# --- 1. netlist parity ------------------------------------------------------------------------
pin_net = {}
for nn in ET.parse(HERE / 'netlist.xml').findall('./nets/net'):
    name = nn.get('name').lstrip('/')
    for node in nn.findall('node'):
        pin_net[(node.get('ref'), node.get('pin'))] = '' if name.startswith('unconnected-') else name
comps = {c.get('ref') for c in ET.parse(HERE / 'netlist.xml').findall('./components/comp')}
check(comps <= set(fps), 'schematic parts missing on the board: %s' % sorted(comps - set(fps)))
mism = []
for ref in comps:
    for pad in fps[ref].Pads():
        if pad.GetNumber() == '':
            continue
        want = pin_net.get((ref, pad.GetNumber()), '')
        if pad.GetNetname() != want:
            mism.append((ref, pad.GetNumber(), pad.GetNetname(), want))
check(not mism, 'pad nets differ from the netlist: %s' % mism[:10])

# --- 2. part placement facts ---------------------------------------------------------------------
iface = {}
# USB-C (HRO TYPE-C-31-M-12 drawing; mating face and opening measured on the vendor STEP)
g = GEOM['USB-C_HRO_TYPE-C-31-M-12']
face = L('J1', (0, g['y'][1]))
op = [o for o in g['opening_z_on_axis'] if o[1] - o[0] > 0.5]
open_lo, open_hi = op[0][0], op[-1][1]
check(abs(face[1] - (-50.4)) <= 0.2, 'J1 mating face y %.3f not -50.4 +-0.2' % face[1])
check(abs(face[0]) < 0.01, 'J1 not centred at x = 0')
check(ddir('J1', (0, 1)) == (0.0, -1.0), 'J1 does not face -Y')
iface['usb_c'] = dict(
    ref='J1', part='HRO TYPE-C-31-M-12 (LCSC C165948)', mating_direction=[0, -1],
    mating_face_y=face[1], centre_x=face[0], z_centre_line=zc((open_lo + open_hi) / 2),
    z_centre_line_datasheet=zc(3.26 / 2),
    shell_outer=dict(width_x=8.94, height_z=3.26, x=[r3(face[0] - 4.47), r3(face[0] + 4.47)], z=[zc(0), zc(3.26)]),
    receptacle_opening=dict(width_x=8.34, height_z=2.56, z=[zc(open_lo), zc(open_hi)]),
    body_y_range=[L('J1', (0, g['y'][1]))[1], L('J1', (0, -2.42))[1]],
    overhang_past_board_edge=r3(BOARD_Y[0] - face[1]),
    note='Opening z from the STEP on the receptacle axis; datasheet opening 8.34 x 2.56 inside an 8.94 x 3.26 shell.')
# microSD
g = GEOM['DM3AT-SF-PEJM5']
cl_x = L('J3', (-0.35, 0))[0]
entry = L('J3', (0, g['y'][1]))
slot = [o for o in g['card_opening_z'] if o[1] - o[0] > 0.7][0]
check(ddir('J3', (0, 1)) == (0.0, -1.0), 'J3 card entry does not face -Y')
iface['microsd'] = dict(
    ref='J3', part='Hirose DM3AT-SF-PEJM5 push-push (LCSC C114218)', card_entry_direction=[0, -1],
    card_entry_face_y=entry[1], card_centre_line_x=r3(cl_x), card_width=11.0,
    card_slot_x_range=[r3(cl_x - 5.5), r3(cl_x + 5.5)], card_slot_z_range=[zc(slot[1]), zc(slot[0])],
    card_plane_z=zc((slot[0] + slot[1]) / 2), connector_height=1.68,
    body_x_range=model_box('J3')['x'], body_y_range=model_box('J3')['y'],
    eject_stroke_beyond_body=r3(21.55 - 15.95),
    note=('Card centre line 3.2 mm from contact 1 (Hirose DM3AT drawing). Slot z range = free gap in the STEP '
          '0.3 mm inside the front face on the card centre line. Push-push: an ejected card stands '
          '5.6 mm proud of the connector front face (lock 17.55, eject 21.55 from the rear).'))
# side button
g = GEOM['SW_SKRTLAE010']
tip = L('SW1', (0, g['y'][1]))
check(ddir('SW1', (0, 1)) == (1.0, 0.0), 'SW1 actuator does not point +X')
iface['side_button'] = dict(
    ref='SW1', part='Alps SKRTLAE010 side push (LCSC C110293)', actuator_axis=[1, 0],
    actuator_tip=[tip[0], tip[1], zc(1.7)], actuator_diameter=2.0, actuator_centre_height_above_board=1.7,
    body_front_x=L('SW1', (0, 0.98))[0], travel=0.2, operating_force_N=1.6,
    body_y_range=model_box('SW1')['y'], height=3.3,
    note='Actuator centre 1.7 above the board and 2.0 diameter per the Alps drawing; tip x from the STEP.')
# screen connector
g = GEOM['FH35C-15S-0.3SHW']
mouth = L('J2', (0, g['y'][1]))
p1, p15 = pad_dev('J2', '1'), pad_dev('J2', '15')
check(ddir('J2', (0, 1)) == (1.0, 0.0), 'J2 slot does not face +X')
check(p1[1] < p15[1], 'J2 pin 1 is not at the -Y end of the slot')
yc = origin('J2')[1]
check(-42 <= yc <= -38, 'J2 slot centre line y_c %.2f outside -42..-38' % yc)
check(-6 <= mouth[0] <= 6, 'J2 slot mouth x_c %.2f outside -6..+6' % mouth[0])
check(abs(mouth[0] - J2_XC) < 0.05 and abs(yc - J2_YC) < 0.01, 'J2 not at design x_c/y_c')
iface['screen_connector'] = dict(
    ref='J2', part='Hirose FH35C-15S-0.3SHW(50) (LCSC C2889267)', slot_facing=[1, 0],
    slot_mouth_x=mouth[0], slot_centre_line_y=r3(yc), slot_width_y=r3(abs(p15[1] - p1[1]) + 0.3 + 2 * 0.0),
    pin1=dict(x=pad_dev('J2', '1')[0], y=p1[1], end='-Y'), pin15=dict(x=pad_dev('J2', '15')[0], y=p15[1], end='+Y'),
    fpc_entry_z=zc(0.4), connector_height=0.9, actuator='flip lock on the -X (rear) side, opens upward about 90 deg',
    ramp_zone=dict(x=[r3(mouth[0]), r3(mouth[0] + 18.0)], y=[r3(yc - 3.0), r3(yc + 3.0)], max_part_height=H_RAMP),
    body_x_range=model_box('J2')['x'], body_y_range=model_box('J2')['y'],
    note='Contacts are dual sided. FPC tail 4.80 wide, 0.20 thick; pin n at y_c - 2.4 + 0.3 n.')
# antenna
ant_end = L('U1', (0, -11.0))
check(abs(ant_end[0] - BOARD_X[1]) < 0.05, 'U1 antenna end x %.3f is not at the board edge' % ant_end[0])
check(ddir('U1', (0, -1)) == (1.0, 0.0), 'U1 antenna does not point +X')
mb = model_box('U1')
iface['antenna'] = dict(
    ref='U1', part='ESP32-PICO-MINI-02-N8R2 (LCSC C2980306)', antenna_end_x=ant_end[0],
    module_x_range=mb['x'], module_y_range=mb['y'], module_centre_y=origin('U1')[1], module_height=2.4,
    antenna_region=dict(x=list(ANTENNA_REGION[0]), y=[r3(mb['y'][0]), r3(mb['y'][1])]),
    copper_keepout_all_layers=dict(x=list(ANTENNA_KEEPOUT[0]), y=list(ANTENNA_KEEPOUT[1])),
    open_end_copper_clearance=r3(ANTENNA_KEEPOUT[1][1] - mb['y'][1]), feed_end_copper_clearance=r3(mb['y'][0] - ANTENNA_KEEPOUT[1][0]),
    enclosure_advice='No metal, screws, inserts or ribs thicker than the wall within the keep-out and 5 mm beyond the +X wall.')
# battery connector
g = GEOM['JST_PH_S2B-PH-SM4-TB']
bb = model_box('J4')
check(ddir('J4', (0, 1)) == (0.0, 1.0), 'J4 cable entry does not face +Y')
check(not any(overlaps(bb, z) for z in RUN_ZONES), 'J4 overlaps an FPC run zone')
iface['battery_connector'] = dict(
    ref='J4', part='JST PH 2.0 side entry S2B-PH-SM4-TB type (LCSC C54582899)', cable_entry_direction=[0, 1],
    entry_face_y=L('J4', (0, g['y'][1]))[1], body_x_range=bb['x'], body_y_range=bb['y'], height=bb['height'],
    z_range=[zc(bb['height']), Z_COMP], pin_minus=pad_dev('J4', '1'), pin_plus=pad_dev('J4', '2'),
    note='Silkscreen + beside pin 2 and - beside pin 1. Plug enters from +Y and the cable leaves toward the battery.')
# buzzer, LED, motor pads
bz = model_box('BZ1')
iface['buzzer'] = dict(ref='BZ1', part='MLT-5020 magnetic (LCSC C94598)', centre=list(origin('BZ1')),
                       body_x_range=bz['x'], body_y_range=bz['y'], height=bz['height'],
                       top_z=zc(bz['height']), grille_advice='Back-plate grille centred here, about 4 mm diameter.')
check(not any(overlaps(bz, z) for z in RUN_ZONES + [RAMP_ZONE]), 'BZ1 body overlaps an FPC zone')
led = model_box('LED1')
iface['charge_led'] = dict(ref='LED1', part='KT-0603R red (LCSC C2286)', centre=list(origin('LED1')),
                           top_z=zc(led['height']), light_hole_diameter=1.0)
check(not any(overlaps(led, z) for z in RUN_ZONES + [RAMP_ZONE]), 'LED1 lies under an FPC zone')
iface['motor_pads'] = dict(pads={'M+': pad_dev('M1', '1'), 'M-': pad_dev('M2', '1')}, pad_size=[1.5, 2.0],
                           motor='LCM1027A2445F 10 x 2.7 coin (optional, LCSC C2759984), hand-soldered')
iface['boot_reset_buttons'] = {r: dict(centre=list(origin(r)), height=1.95, function=fps[r].GetValue()) for r in ('SW2', 'SW3')}
iface['test_pads'] = {fps[r].GetValue(): list(origin(r)) for r in sorted(fps) if r.startswith('TP')}
iface['locating_holes'] = [dict(ref='H%d' % i, centre=list(origin('H%d' % i)), diameter=LOCATING_HOLE_D,
                                note='NPTH; front skin pin about 1.5 diameter') for i in range(1, len(LOCATING_HOLES) + 1)]
iface['press_pads'] = [dict(ref='PP%d' % i, centre=list(origin('PP%d' % i)), diameter=PRESS_PAD_D)
                       for i in range(1, len(PRESS_PADS) + 1)]
for h in iface['locating_holes']:
    c = h['centre']
    check(math.hypot(c[0] - WHEEL_C[0], c[1] - WHEEL_C[1]) > WHEEL_DISC_D / 2 + 1.0, '%s inside the wheel' % h['ref'])
for pp in iface['press_pads']:
    c, r = pp['centre'], PRESS_PAD_D / 2
    box = dict(x=[c[0] - r, c[0] + r], y=[c[1] - r, c[1] + r])
    check(not any(overlaps(box, z) for z in RUN_ZONES + [RAMP_ZONE]), '%s overlaps an FPC zone' % pp['ref'])
# L4 protrusions: through-hole legs whose solder can stand proud of the touch side
prot = []
for ref in fps:
    for pad in fps[ref].Pads():
        if pad.GetAttribute() == p.PAD_ATTRIB_PTH and ref != 'E1':
            bbx = pad.GetBoundingBox()
            a, z2 = dev(p.VECTOR2I(bbx.GetLeft(), bbx.GetTop())), dev(p.VECTOR2I(bbx.GetRight(), bbx.GetBottom()))
            prot.append(dict(ref=ref, pad=pad.GetNumber(), centre=list(pad_dev(ref, pad.GetNumber())),
                             x=[r3(min(a[0], z2[0])), r3(max(a[0], z2[0]))], y=[r3(min(a[1], z2[1])), r3(max(a[1], z2[1]))]))
iface['touch_side_protrusions'] = dict(
    items=prot, max_height_above_L4=0.4,
    advice='Shell legs are soldered through a 0.8 board; solder and leg ends can stand up to about 0.4 above L4 '
           '(z = -1.0). Give the front skin a 0.5 deep relief, 0.5 larger than each pad, at these positions.')

# --- 3. heights by zone ---------------------------------------------------------------------------
parts = []
for ref in sorted(fps):
    mb = model_box(ref)
    if not mb:
        continue
    limit, zone = H_GENERAL, 'general'
    if any(overlaps(mb, z) for z in RUN_ZONES):
        limit, zone = H_RUN, 'FPC run zone'
    if overlaps(mb, RAMP_ZONE):
        limit, zone = H_RAMP, 'FPC ramp zone'
    ok = mb['height'] <= limit + 1e-3
    check(ok, '%s height %.2f exceeds %.1f (%s)' % (ref, mb['height'], limit, zone))
    parts.append(dict(ref=ref, value=fps[ref].GetValue(), centre=list(origin(ref)), kicad_angle=r3(angle(ref)),
                      x=mb['x'], y=mb['y'], z=[zc(mb['height']), Z_COMP], height=mb['height'],
                      zone=zone, limit=limit, ok=ok))
iface['parts'] = parts
iface['tallest_part'] = max(parts, key=lambda q: q['height'])['ref']
iface['lowest_component_z'] = min(q['z'][0] for q in parts)

# --- 4. copper rules ----------------------------------------------------------------------------
tracks = [t for t in b.GetTracks() if not isinstance(t, p.PCB_VIA)]
vias = [t for t in b.GetTracks() if isinstance(t, p.PCB_VIA)]
wc = WHEEL_C


def in_rect(pt, rect, m=0.0):
    (x0, x1), (y0, y1) = rect
    return x0 - m <= pt[0] <= x1 + m and y0 - m <= pt[1] <= y1 + m


bad = [t.GetNetname() for t in tracks if in_rect(dev(t.GetStart()), ANTENNA_KEEPOUT) or in_rect(dev(t.GetEnd()), ANTENNA_KEEPOUT)]
bad += [v.GetNetname() for v in vias if in_rect(dev(v.GetPosition()), ANTENNA_KEEPOUT, 0.25)]
for z in b.Zones():
    if z.GetIsRuleArea():
        continue
    for layer in z.GetLayerSet().Seq():
        fp_ = z.GetFilledPolysList(layer)
        for i in range(fp_.OutlineCount()):
            ln = fp_.Outline(i)
            for k in range(ln.PointCount()):
                if in_rect(dev(ln.CPoint(k)), ANTENNA_KEEPOUT, -0.01):
                    bad.append(z.GetZoneName()); break
check(not bad, 'copper inside the antenna keep-out: %s' % sorted(set(bad))[:5])
d_ant = min(abs(ANTENNA_KEEPOUT[0][0] - wc[0]), math.hypot(ANTENNA_KEEPOUT[0][0] - wc[0], 0))
check(ANTENNA_KEEPOUT[0][0] - wc[0] > HATCH_R, 'antenna keep-out overlaps the wheel hatch')
# Inside the electrode disc plus 0.5 mm (r <= WHEEL_KEEPOUT_R = 17.1) only design.WHEEL_TOLERANT_NETS
# (DC and static nets, the electrode lines, GND) may run on L3 or place vias: L3 is 0.1 mm behind the
# electrodes with no ground between them.
def rw(q):
    return math.hypot(q[0] - wc[0], q[1] - wc[1])


def len_inside(a, z, r, n=200):
    """Length of the segment a-z (track centre line) that lies inside radius r of the wheel centre."""
    L = math.hypot(z[0] - a[0], z[1] - a[1])
    return sum(L / n for k in range(n) if rw((a[0] + (z[0] - a[0]) * (k + 0.5) / n, a[1] + (z[1] - a[1]) * (k + 0.5) / n)) <= r)


in_wheel_vias = [v.GetNetname() for v in vias if rw(dev(v.GetPosition())) < WHEEL_KEEPOUT_R]
foreign = sorted(set(v.GetNetname() for v in vias if rw(dev(v.GetPosition())) < WHEEL_KEEPOUT_R and v.GetNetname() not in WHEEL_TOLERANT_NETS
                     and v.GetNetname() not in DISC_L3_ACCEPTED
                     and not (v.GetNetname() in DISC_EDGE_CROSS_NETS and rw(dev(v.GetPosition())) > DISC_EDGE_CROSS_R)))
check(not foreign, 'switching-net vias inside r %.1f: %s' % (WHEEL_KEEPOUT_R, foreign))
# Accepted exceptions (design.DISC_L3_ACCEPTED): a net there may keep at most its measured via count inside r 17.1.
for n_, (mm_, nv_) in DISC_L3_ACCEPTED.items():
    k_ = sum(1 for v in vias if v.GetNetname() == n_ and rw(dev(v.GetPosition())) < WHEEL_KEEPOUT_R)
    check(k_ <= nv_, '%s has %d vias inside r %.1f (accepted at most %d)' % (n_, k_, WHEEL_KEEPOUT_R, nv_))
l3_disc = {}          # net -> [mm inside the electrode disc (r <= 16.6), mm inside the disc plus 0.5 (r <= 17.1)]
l3_min_r = {}         # net -> smallest radius of its L3 track centre line
for t in tracks:
    if t.GetLayer() == p.In2_Cu:
        a, z = dev(t.GetStart()), dev(t.GetEnd())
        l_in, l_m = len_inside(a, z, RING_R[1]), len_inside(a, z, WHEEL_KEEPOUT_R)
        if l_m > 0:
            v_ = l3_disc.setdefault(t.GetNetname(), [0.0, 0.0]); v_[0] += l_in; v_[1] += l_m
            rmin = min(rw((a[0] + (z[0] - a[0]) * k / 40, a[1] + (z[1] - a[1]) * k / 40)) for k in range(41))
            l3_min_r[t.GetNetname()] = min(rmin, l3_min_r.get(t.GetNetname(), 99))
l3_disc = {n: [r3(x) for x in v_] for n, v_ in sorted(l3_disc.items())}
l3_in = sorted(l3_disc)
# The listed switching nets: no L3 track inside r 17.1, except the short crossings of
# design.DISC_EDGE_CROSS_NETS (at most three slow nets), which must stay outside r 14 and below the length cap.
edge_cross = {n: dict(l3_mm_r_le_17_1=l3_disc[n][1], l3_mm_r_le_16_6=l3_disc[n][0], min_radius=r3(l3_min_r[n]))
              for n in DISC_EDGE_CROSS_NETS if n in l3_disc}
check(len(DISC_EDGE_CROSS_NETS) <= 3, 'more than three nets with an L3 crossing near the disc edge')
# DISC_EDGE_CROSS_R = 0 means the crossing may be at any radius; the length cap then counts the L3 track
# inside the electrode disc itself (r <= 16.6), as the touch review's step B states it.
for n, e in edge_cross.items():
    l_cap = e['l3_mm_r_le_16_6'] if DISC_EDGE_CROSS_R <= 0 else e['l3_mm_r_le_17_1']
    check((DISC_EDGE_CROSS_R <= 0 or e['min_radius'] > DISC_EDGE_CROSS_R) and l_cap <= DISC_EDGE_CROSS_MAX_MM,
          '%s L3 crossing inside the disc: %.1f mm, down to r %.1f (limit %.1f mm, r > %.1f)'
          % (n, l_cap, e['min_radius'], DISC_EDGE_CROSS_MAX_MM, DISC_EDGE_CROSS_R))
forbidden = {n: l3_disc[n][1] for n in DISC_L3_FORBIDDEN if n in l3_disc and n not in DISC_EDGE_CROSS_NETS
             and n not in DISC_L3_ACCEPTED}
for n_, (mm_, nv_) in DISC_L3_ACCEPTED.items():
    got_ = l3_disc.get(n_, [0.0, 0.0])[1]
    check(got_ <= mm_ + 0.005, '%s has %.1f mm of L3 track inside r %.1f (accepted at most %.1f)' % (n_, got_, WHEEL_KEEPOUT_R, mm_))
check(not forbidden, 'listed switching nets with L3 track inside r %.1f (mm): %s' % (WHEEL_KEEPOUT_R, forbidden))
others = [n for n in l3_in if n not in WHEEL_TOLERANT_NETS and n not in DISC_EDGE_CROSS_NETS and n not in DISC_L3_ACCEPTED]
check(not others, 'other non-DC nets with L3 track inside r %.1f: %s' % (WHEEL_KEEPOUT_R, others))
# No solid copper on L3 under the electrodes: every L3 zone stays out of the disc plus 0.5 mm.
l3_zone_hits = []
for z in b.Zones():
    if z.GetIsRuleArea() or not z.IsOnLayer(p.In2_Cu):
        continue
    for i in range(-35, 36):
        for j in range(-35, 36):
            q = (wc[0] + i * 0.5, wc[1] + j * 0.5)
            if rw(q) <= WHEEL_KEEPOUT_R:
                kx, ky = to_kicad(*q)
                if z.HitTestFilledArea(p.In2_Cu, p.VECTOR2I(p.FromMM(kx), p.FromMM(ky))):
                    l3_zone_hits.append(z.GetZoneName()); break
        else:
            continue
        break
check(not l3_zone_hits, 'L3 zone copper inside the electrode disc: %s' % l3_zone_hits)
check(not [t for t in tracks if t.GetLayer() in (p.B_Cu, p.In1_Cu)], 'tracks on L2 or L4')
check(not [d for d in b.GetDrawings() if d.GetLayer() == p.B_SilkS] and
      not [g for f in fps.values() for g in f.GraphicalItems() if g.GetLayer() == p.B_SilkS], 'silkscreen on L4')
check(all(f.GetLayer() == p.F_Cu for f in fps.values()), 'a footprint is on the bottom side')

# electrodes
ezones = {z.GetZoneName(): z for z in b.Zones() if z.GetZoneName().startswith('ELECTRODE_')}
check(len(ezones) == 9, 'expected 9 electrode zones, found %d' % len(ezones))
polys = {}
for name, z in ezones.items():
    o = z.Outline().Outline(0)
    polys[name.split('_')[1]] = [dev(o.CPoint(k)) for k in range(o.PointCount())]
    want = 'ELE0' if name.endswith('_C') else 'ELE' + name.split('_')[1]
    check(z.GetNetname() == want and z.GetLayer() == p.B_Cu, '%s net/layer wrong' % name)
gaps = {}
for i in range(1, 9):
    j = i % 8 + 1
    gaps['%d-%d' % (i, j)] = r3(wheel.min_gap(polys[str(i)], polys[str(j)]))
    check(gaps['%d-%d' % (i, j)] >= ELECTRODE_GAP - 0.002, 'electrode gap %d-%d below 0.4' % (i, j))
angles = {}
for i in range(1, 9):
    cx = sum(q[0] for q in polys[str(i)]) / len(polys[str(i)]); cy = sum(q[1] for q in polys[str(i)]) / len(polys[str(i)])
    a = math.degrees(math.atan2(cy - wc[1], cx - wc[0]))
    angles[i] = r3(a)
    check(abs(((a - SECTOR_ANGLES[i]) + 180) % 360 - 180) < 3, 'sector %d not at %d deg' % (i, SECTOR_ANGLES[i]))
mpr = {pad.GetNumber(): pad.GetNetname() for pad in fps['U6'].Pads()}
check([mpr[str(n)] for n in range(8, 17)] == ['ELE%d' % k for k in range(9)], 'MPR121 ELE pin mapping wrong')
rad = [math.hypot(q[0] - wc[0], q[1] - wc[1]) for i in range(1, 9) for q in polys[str(i)]]
check(min(rad) >= RING_R[0] - 1e-3 and max(rad) <= RING_R[1] + 1e-3, 'ring radius out of 7.8..16.6')
crad = max(math.hypot(q[0] - wc[0], q[1] - wc[1]) for q in polys['C'])
check(crad <= CENTER_R + 1e-3, 'centre electrode larger than r 7.0')
# L2 hatch copper fraction
hz = [z for z in b.Zones() if z.GetZoneName() == 'L2_GND_HATCH_25PCT'][0]
filled = hz.GetFilledPolysList(p.In1_Cu)
area = filled.Area() / 1e12
frac = area / (math.pi * HATCH_R ** 2)
check(0.18 <= frac <= 0.40, 'L2 hatch copper fraction %.2f not about 25 percent' % frac)
solid = [z for z in b.Zones() if z.GetZoneName() == 'L2_GND_SOLID'][0]
# power track widths
widths = {}
for t in tracks:
    widths.setdefault(t.GetNetname(), []).append((p.ToMM(t.GetWidth()), p.ToMM(t.GetLength())))
power_min = {n: r3(min(w for w, l in widths.get(n, [(0, 0)]))) for n in ['VBUS', 'VSYS', 'VBAT', 'BAT_P', '3V3', '3V3_PERIPH', 'LCD_LEDA', 'LCD_LEDK']}
narrow = {n: r3(sum(l for w, l in widths.get(n, []) if w < 0.399)) for n in power_min}
# A track of a strict power net may be narrower than 0.4 only where it carries signal current:
#  (a) a pin neck-down: both ends within 1.0 mm of pads of the same net that are narrower than 0.4
#      (QFN, SOT, MSOP and module pins), or
#  (b) a signal tap: a branch of narrow tracks whose only pads are resistors of 10 k or more (pull-ups,
#      the 1 M battery divider) or pins narrower than 0.4 (logic straps and the MPR121 supply pin).
def _ohms(v):
    v = v.strip().upper().replace('OHM', '').replace('R', '')
    mult = {'K': 1e3, 'M': 1e6}.get(v[-1:], 1)
    try:
        return float(v.rstrip('KM')) * mult
    except ValueError:
        return 0.0


pad_info = {}     # net -> [(box, small, tap)]
for f in fps.values():
    is_hi_r = f.GetReference().startswith('R') and _ohms(f.GetValue()) >= 1e4
    for pd in f.Pads():
        bb = pd.GetBoundingBox()
        a_, z_ = dev(p.VECTOR2I(bb.GetLeft(), bb.GetTop())), dev(p.VECTOR2I(bb.GetRight(), bb.GetBottom()))
        small = min(p.ToMM(pd.GetSize().x), p.ToMM(pd.GetSize().y)) < 0.4
        pad_info.setdefault(pd.GetNetname(), []).append(
            ((min(a_[0], z_[0]), min(a_[1], z_[1]), max(a_[0], z_[0]), max(a_[1], z_[1])), small, small or is_hi_r))


def _boxd(bx, q):
    return math.hypot(max(bx[0] - q[0], 0, q[0] - bx[2]), max(bx[1] - q[1], 0, q[1] - bx[3]))


def near_small_pad(t, reach=1.0):
    pads_ = [bx for bx, small, tap in pad_info.get(t.GetNetname(), []) if small]
    return all(any(_boxd(bx, q) <= reach for bx in pads_) for q in (dev(t.GetStart()), dev(t.GetEnd())))


def tap_tracks(net):
    """Narrow tracks of net that sit in a branch touching only tap pads."""
    nar = [t for t in tracks if t.GetNetname() == net and p.ToMM(t.GetWidth()) < 0.399]
    par = {}

    def find(k):
        while par.setdefault(k, k) != k:
            par[k] = par[par[k]]; k = par[k]
        return k

    def key(q):
        return (round(q[0], 3), round(q[1], 3))
    for t in nar:
        par[find(key(dev(t.GetStart())))] = find(key(dev(t.GetEnd())))
    groups = {}
    for t in nar:
        groups.setdefault(find(key(dev(t.GetStart()))), []).append(t)
    wide_pts = {key(q) for t in tracks if t.GetNetname() == net and p.ToMM(t.GetWidth()) >= 0.399
                for q in (dev(t.GetStart()), dev(t.GetEnd()))}
    trunk_pads = {i for i, (bx, small, tap) in enumerate(pad_info.get(net, [])) if any(_boxd(bx, q) <= 0.01 for q in wide_pts)}
    ok = set()
    for g in groups.values():
        pts = {key(q) for t in g for q in (dev(t.GetStart()), dev(t.GetEnd()))}
        touched = {i for i, (bx, small, tap) in enumerate(pad_info.get(net, [])) if any(_boxd(bx, q) <= 0.01 for q in pts)}
        loads = touched - trunk_pads
        # join points: trunk pads the branch touches, plus wide-track ends that are not on one of those pads
        # (a branch that starts on a trunk pad joins the trunk once, not twice)
        on_trunk = touched & trunk_pads
        wide_joins = {q for q in pts & wide_pts if not any(_boxd(pad_info[net][i][0], q) <= 0.01 for i in on_trunk)}
        joins = len(wide_joins) + len(on_trunk)
        # a branch that leaves the trunk at one point and feeds only tap pads
        if loads and all(pad_info[net][i][2] for i in loads) and joins <= 1:
            ok |= {id(t) for t in g}
    return ok


STRICT_POWER = ['VSYS', 'VBAT', '3V3', 'LCD_LEDA', 'LCD_LEDK']
narrow_free = {}
for n in STRICT_POWER:
    taps = tap_tracks(n)
    narrow_free[n] = r3(sum(p.ToMM(t.GetLength()) for t in tracks if t.GetNetname() == n and p.ToMM(t.GetWidth()) < 0.399
                            and id(t) not in taps and not near_small_pad(t)))
for n in STRICT_POWER:
    check(narrow_free[n] <= 0.5, '%s has %.1f mm of track narrower than 0.4 outside pin neck-downs and signal taps' % (n, narrow_free[n]))
usb_len = {n: r3(sum(l for w, l in widths.get(n, []))) for n in USB_NETS}

# VBUS main paths: USB-C J1 to D1 (VBUS to VSYS) and J1 to the charger input U3 pin 4 carry up to about
# 0.7 A. Each must have a path of tracks at least 0.4 mm wide, except within 1.0 mm of those pins
# (neck-downs into the pads). The other VBUS branches (CH9102F, ESD U8, sense divider, charge LED,
# capacitors) may be narrow. The check finds the widest path (largest smallest width) through the
# VBUS tracks, vias and pads.
def vbus_paths():
    import heapq
    net = 'VBUS'
    term = {('J1', 'A4B9'), ('J1', 'B4A9'), ('D1', '2'), ('U3', '4')}
    vpads = [(f.GetReference(), pd) for f in fps.values() for pd in f.Pads() if pd.GetNetname() == net]
    tboxes = []
    for ref, pd in vpads:
        bb = pd.GetBoundingBox()
        a_, z_ = dev(p.VECTOR2I(bb.GetLeft(), bb.GetTop())), dev(p.VECTOR2I(bb.GetRight(), bb.GetBottom()))
        box = (min(a_[0], z_[0]), min(a_[1], z_[1]), max(a_[0], z_[0]), max(a_[1], z_[1]))
        if (ref, pd.GetNumber()) in term:
            tboxes.append(box)
    near_term = lambda q: any(_boxd(bx, q) <= 1.0 for bx in tboxes)
    key = lambda lay, q: (lay, round(q[0], 3), round(q[1], 3))
    adj = {}

    def edge(u, v, w, L=0.0, lay=None):
        adj.setdefault(u, []).append((v, w, L, lay)); adj.setdefault(v, []).append((u, w, L, lay))
    segs = [(t.GetLayer(), dev(t.GetStart()), dev(t.GetEnd()), p.ToMM(t.GetWidth())) for t in tracks if t.GetNetname() == net]
    INF = 99.0
    for lay, a_, z_, w in segs:
        edge(key(lay, a_), key(lay, z_), INF if (near_term(a_) and near_term(z_)) else w, math.dist(a_, z_), lay)
    pts = {(lay, q) for lay, a_, z_, w in segs for q in (a_, z_)}

    def on_seg(q, a_, z_):
        dx, dy = z_[0] - a_[0], z_[1] - a_[1]; L2 = dx * dx + dy * dy
        t_ = 0 if L2 == 0 else max(0, min(1, ((q[0] - a_[0]) * dx + (q[1] - a_[1]) * dy) / L2))
        return math.hypot(q[0] - a_[0] - t_ * dx, q[1] - a_[1] - t_ * dy) < 0.01
    for lay, q in pts:                                   # T-junctions
        for lay2, a_, z_, w in segs:
            if lay2 == lay and on_seg(q, a_, z_):
                edge(key(lay, q), key(lay, a_), INF if near_term(q) and near_term(a_) else w, math.dist(q, a_), lay)
                edge(key(lay, q), key(lay, z_), INF if near_term(q) and near_term(z_) else w, math.dist(q, z_), lay)
    for v in vias:
        if v.GetNetname() == net:
            c = dev(v.GetPosition())
            for lay, q in pts:
                if math.hypot(q[0] - c[0], q[1] - c[1]) <= p.ToMM(v.GetWidth()) / 2:
                    edge(('via', round(c[0], 3), round(c[1], 3)), key(lay, q), INF)
    for ref, pd in vpads:
        node = ('pad', ref, pd.GetNumber())
        for lay, q in pts:
            if pd.IsOnLayer(lay) and pd.HitTest(p.VECTOR2I(*[p.FromMM(c) for c in to_kicad(*q)])):
                edge(node, key(lay, q), INF)

    def widest(src, dst):
        best = {s_: INF for s_ in src}
        heap = [(-INF, i_, s_) for i_, s_ in enumerate(src)]
        cnt = len(heap)
        while heap:
            nw, _, u = heapq.heappop(heap); w = -nw
            if u == dst:
                return w
            if w < best.get(u, -1):
                continue
            for v, ew, _, _ in adj.get(u, []):
                m = min(w, ew)
                if m > best.get(v, -1):
                    best[v] = m; cnt += 1; heapq.heappush(heap, (-m, cnt, v))
        return 0.0
    def least_narrow(src, dst):
        # the path with the least track narrower than 0.4 mm; returns that track in mm by layer and width
        dist_ = {s_: 0.0 for s_ in src}; prev_ = {}
        heap = [(0.0, i_, s_) for i_, s_ in enumerate(src)]; cnt = len(heap)
        while heap:
            d_, _, u = heapq.heappop(heap)
            if u == dst:
                break
            if d_ > dist_.get(u, 1e18):
                continue
            for v, ew, L, lay in adj.get(u, []):
                nd = d_ + (L * 1000 if ew < 0.399 else L)
                if nd < dist_.get(v, 1e18):
                    dist_[v] = nd; prev_[v] = (u, ew, L, lay); cnt += 1; heapq.heappush(heap, (nd, cnt, v))
        out_ = {}; u = dst
        while u in prev_:
            u, ew, L, lay = prev_[u]
            if ew < 0.399 and L > 0:
                b_ = '%s %.2f' % ({p.F_Cu: 'L1', p.In2_Cu: 'L3'}.get(lay, str(lay)), ew)
                out_[b_] = out_.get(b_, 0.0) + L
        return {b_: r3(v_) for b_, v_ in sorted(out_.items())}
    src = [('pad', 'J1', 'A4B9'), ('pad', 'J1', 'B4A9')]
    return {k_: dict(widest=r3(min(widest(src, d_), INF)), narrow_mm=least_narrow(src, d_))
            for k_, d_ in (('J1_to_D1', ('pad', 'D1', '2')), ('J1_to_U3_VIN', ('pad', 'U3', '4')))}


vbus_paths = vbus_paths()
for k_, e_ in vbus_paths.items():
    if VBUS_PATH_ACCEPTED:          # step C: the measured narrow track is the cap, so it can only shrink
        caps_ = VBUS_PATH_ACCEPTED['max_mm']
        over_ = {b_: mm_ for b_, mm_ in e_['narrow_mm'].items() if mm_ > caps_.get(b_, 0.0) + 0.05}
        check(e_['widest'] >= VBUS_PATH_ACCEPTED['min_width'] - 0.001 and not over_,
              'VBUS %s: widest %.2f mm, narrow track over the accepted caps: %s' % (k_, e_['widest'], over_))
    else:
        check(e_['widest'] >= 0.399, 'VBUS %s: the widest path narrows to %.2f mm away from the pins' % (k_, e_['widest']))

# --- 4b. checks added by the 2026-11-21 pre-order review ------------------------------------------------
# (a) design.py and the schematic netlist agree pin for pin (the board is checked against netlist.xml above).
dmis = []
for prt in PARTS:
    for num, net in prt['pins'].items():
        if pin_net.get((prt['ref'], num), '') != (net or ''):
            dmis.append((prt['ref'], num, pin_net.get((prt['ref'], num)), net))
check(not dmis, 'netlist.xml differs from design.py: %s' % dmis[:10])


def rect_dist(pt, rect):
    (x0, x1), (y0, y1) = rect
    return math.hypot(max(x0 - pt[0], 0, pt[0] - x1), max(y0 - pt[1], 0, pt[1] - y1))


def copper_in_rect(rect, layer=p.F_Cu):
    """Tracks and vias that overlap the device rect on the layer, and whether a zone fill reaches into it."""
    hits = []
    for t in tracks:
        if t.GetLayer() != layer:
            continue
        a, z = dev(t.GetStart()), dev(t.GetEnd()); hw = p.ToMM(t.GetWidth()) / 2
        if any(rect_dist((a[0] + (z[0] - a[0]) * k / 60, a[1] + (z[1] - a[1]) * k / 60), rect) < hw - 1e-3 for k in range(61)):
            hits.append(('track', t.GetNetname()))
    for v_ in vias:
        if rect_dist(dev(v_.GetPosition()), rect) < p.ToMM(v_.GetWidth()) / 2 - 1e-3:
            hits.append(('via', v_.GetNetname()))
    (x0, x1), (y0, y1) = rect
    for z in b.Zones():
        if z.GetIsRuleArea() or not z.IsOnLayer(layer):
            continue
        nx, ny = max(2, int((x1 - x0) / 0.05)), max(2, int((y1 - y0) / 0.05))
        if any(z.HitTestFilledArea(layer, p.VECTOR2I(*[p.FromMM(c) for c in to_kicad(x0 + 0.02 + (x1 - x0 - 0.04) * i / nx,
                                                                                          y0 + 0.02 + (y1 - y0 - 0.04) * j / ny)]))
               for i in range(nx + 1) for j in range(ny + 1)):
            hits.append(('zone', z.GetZoneName()))
    return hits


# (b) makers' no-copper areas: Hirose DM3AT hatched areas under J3, Alps SKRTLAE010 area under SW1 (CONN-1, L5)
no_copper = {}
_j3o, _j3r = origin('J3'), angle('J3')
for k_, ((x0_, x1_), (y0_, y1_)) in sorted(J3_NO_TRACE_LOCAL.items()):
    c_ = [local_to_device(_j3o, _j3r, q) for q in ((x0_, y0_), (x1_, y1_))]
    rect_ = ((min(c_[0][0], c_[1][0]), max(c_[0][0], c_[1][0])), (min(c_[0][1], c_[1][1]), max(c_[0][1], c_[1][1])))
    hits_ = copper_in_rect(rect_)
    bad_ = [h for h in hits_ if not (k_ == 'A' and h[0] == 'track' and h[1] in J3_NO_TRACE_A_NETS)]
    no_copper['J3_' + k_] = dict(rect=[[r3(x) for x in rect_[0]], [r3(y) for y in rect_[1]]],
                                 copper=sorted(set('%s %s' % h for h in hits_)))
    check(not bad_, 'copper in the J3 hatched area %s: %s' % (k_, sorted(set(bad_))))
hits_ = copper_in_rect(SW1_NO_COPPER)
no_copper['SW1'] = dict(rect=[list(SW1_NO_COPPER[0]), list(SW1_NO_COPPER[1])], copper=sorted(set('%s %s' % h for h in hits_)))
check(not hits_, 'copper in the SW1 prohibited area: %s' % sorted(set(hits_)))

# (c) vias against the L1 solder-mask openings of pads (L3, L4): no via within 0.1 of another net's opening,
# and the only vias in a pad opening are the thermal-pad vias of U1 and U2.
openings = []
for f in fps.values():
    for pd in f.Pads():
        if pd.IsOnLayer(p.F_Mask):
            sps_ = p.SHAPE_POLY_SET()
            pd.TransformShapeToPolygon(sps_, p.F_Mask, pd.GetSolderMaskExpansion(), p.FromMM(0.002))
            openings.append((f.GetReference() + '.' + pd.GetNumber(), pd.GetNetname(), sps_))
via_mask = []
for v_ in vias:
    c_ = v_.GetPosition(); rr_ = p.ToMM(v_.GetWidth()) / 2
    for name_, net_, sps_ in openings:
        d_ = -1.0 if sps_.Contains(c_) else math.sqrt(sps_.SquaredDistance(c_)) / 1e6 - rr_
        via_mask.append((d_, v_.GetNetname(), name_, net_, [r3(x) for x in dev(c_)]))
other = [x for x in via_mask if x[1] != x[3]]
in_pad = sorted(set((x[2], tuple(x[4])) for x in via_mask if x[0] < 0))
worst_other = min(other, key=lambda x: x[0])
check(worst_other[0] >= 0.1, 'via %s at %s is %.3f from the %s opening (%s)' % (worst_other[1], worst_other[4], worst_other[0],
                                                                              worst_other[2], worst_other[3]))
check({n_.split('.')[0] for n_, q_ in in_pad} <= {'U1', 'U2'}, 'vias in pad openings outside U1/U2: %s' % in_pad)
per_via = {}
for d_, vn_, pn_, pnet_, q_ in via_mask:
    k_ = tuple(q_)
    if k_ not in per_via or d_ < per_via[k_]:
        per_via[k_] = d_
via_plug = dict(in_pad=[('%s' % n_, list(q_)) for n_, q_ in in_pad],
                closest_other_net=dict(distance=r3(worst_other[0]), via=worst_other[1], pad=worst_other[2], at=worst_other[4]),
                closer_than_0p35_to_an_opening=sum(1 for d_ in per_via.values() if d_ < 0.35), total=len(per_via))

# (d) land-pattern gaps inside J1 and U6 (review L1, FP-2, FP-8): no 0.09 / 0.12 exceptions any more
gaps_lp = {}
for ref_ in ('J1', 'U6'):
    pads_ = [pd for pd in fps[ref_].Pads() if pd.IsOnLayer(p.F_Cu) and pd.GetAttribute() == p.PAD_ATTRIB_SMD]
    best_ = 99.0

    def _cu(pd):
        sps_ = p.SHAPE_POLY_SET()
        pd.TransformShapeToPolygon(sps_, p.F_Cu, 0, p.FromMM(0.002))
        return sps_
    for i_, pa in enumerate(pads_):
        sa = _cu(pa)
        for pb in pads_[i_ + 1:]:
            sb = _cu(pb)
            # distance between the two pad outlines (outline vertices of each against the other shape)
            o_ = sa.Outline(0)
            d_ = min(math.sqrt(sb.SquaredDistance(o_.CPoint(k))) for k in range(o_.PointCount())) / 1e6
            o2 = sb.Outline(0)
            d_ = min(d_, min(math.sqrt(sa.SquaredDistance(o2.CPoint(k))) for k in range(o2.PointCount())) / 1e6)
            best_ = min(best_, d_)
    gaps_lp[ref_] = r3(best_)
    check(best_ >= 0.127 - 1e-3, '%s pad gap %.3f below 0.127' % (ref_, best_))

# --- 5. ERC / DRC results -------------------------------------------------------------------------
drc = json.loads((HERE / 'drc.json').read_text())
erc = json.loads((HERE / 'erc.json').read_text())
drc_err = [v for v in drc['violations'] if v['severity'] == 'error']
drc_warn = [v for v in drc['violations'] if v['severity'] == 'warning']
erc_v = [v for s in erc['sheets'] for v in s['violations']]
check(not drc_err, 'DRC errors: %d' % len(drc_err))
check(not drc['unconnected_items'], 'unconnected items: %d' % len(drc['unconnected_items']))
check(not [v for v in erc_v if v['severity'] == 'error'], 'ERC errors')

summary = dict(
    status='PASS' if not FAIL else 'FAIL', failures=FAIL,
    erc_errors=len([v for v in erc_v if v['severity'] == 'error']), erc_warnings=len([v for v in erc_v if v['severity'] == 'warning']),
    drc_errors=len(drc_err), drc_warnings=len(drc_warn), unconnected=len(drc['unconnected_items']),
    drc_warning_types=sorted(set(v['type'] for v in drc_warn)),
    netlist_pads_checked=sum(1 for r in comps for pd in fps[r].Pads() if pd.GetNumber()),
    electrode_gaps=gaps, sector_centroid_angles=angles, l2_hatch_copper_fraction=r3(frac),
    power_net_min_width=power_min, power_net_length_below_0p4=narrow, power_net_narrow_away_from_pins=narrow_free, usb_track_length=usb_len,
    track_segments=len(tracks), vias=len(vias),
    vias_in_wheel_by_net={n: in_wheel_vias.count(n) for n in sorted(set(in_wheel_vias))},
    no_copper_areas=no_copper, via_mask=via_plug, land_pattern_min_gap=gaps_lp,
    l3_nets_above_electrodes=l3_in, l3_track_in_disc_mm=l3_disc, disc_edge_crossings=edge_cross, vbus_main_paths=vbus_paths,
    sha256={f: hashlib.sha256((HERE / f).read_bytes()).hexdigest() for f in [NAME + '.kicad_pcb', NAME + '.kicad_sch', 'netlist.xml']})
iface = dict(
    coordinate_system=('Device coordinates in mm (SPEC 1): origin at the body-outline centre on the front face, +X right '
                       'seen from the front, +Y toward the screen, +Z out of the front face. KiCad origin of the device '
                       'origin: (%.1f, %.1f); device_x = -(kicad_x - x0), device_y = -(kicad_y - y0).' % (X0, Y0)),
    board=dict(outline=[[r3(x), r3(y)] for x, y in board_outline()], thickness=BOARD_T, z_touch_side=Z_TOUCH,
               z_component_side=Z_COMP, layers='L1 parts, L2 GND (25% hatch under the wheel), L3 power/routing, L4 electrodes + GND',
               boss_clearance=BOSS_CLEAR, bosses=BOSSES[:2]),
    wheel=dict(centre=list(WHEEL_C), disc_diameter=WHEEL_DISC_D, ring_r=list(RING_R), centre_r=CENTER_R,
               sectors='ELE1 at 12 o\'clock seen from the front, then clockwise', l4_ground_clear_r=L4_POUR_CLEAR_R),
    fpc_zones=dict(dive=DIVE_ZONE, run=RUN_ZONES, ramp=RAMP_ZONE),
    **iface, verification=summary)
def _round(o):
    if isinstance(o, float):
        return round(o, 3) + 0.0
    if isinstance(o, dict):
        return {k: _round(v) for k, v in o.items()}
    if isinstance(o, (list, tuple)):
        return [_round(v) for v in o]
    return o


iface = _round(iface)
(HERE / 'mechanical-interface.json').write_text(json.dumps(iface, indent=1) + '\n')
(HERE / 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=1))
sys.exit(1 if FAIL else 0)
