"""Close what the router and the pours left open, then refill. Run after finish_pcb.py.

1. HAND: explicit tracks and vias for the few signal connections Freerouting did not finish
   (device coordinates, checked by DRC like everything else).
2. GND: for every GND pad that DRC still reports unconnected, a stitching via at the nearest free
   spot beside the pad (inside the wheel too: a GND via only adds baseline capacitance) with a
   short track. Up to three rounds, refilling the zones each time.
3. L1 pour islands: every filled fragment of the L1 GND pour without a GND via or GND hole in it
   gets one stitching via to L2 at a free point inside the fragment.
A stitching via keeps clear of other-net copper on L1 and L3 (it passes through every layer).
"""
import json
import math
import re
import subprocess
import pcbnew as p
import wx
from design import *

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
CLI = str(KICAD / 'MacOS/kicad-cli')
TMP = HERE / 'review' / '_fixups-drc.json'

# (net, layer, [device points], width) and (net, device point) for hand-finished connections.
HAND_TRACKS = []
HAND_VIAS = []


def v(x, y):
    return p.VECTOR2I(p.FromMM(x), p.FromMM(y))


def vd(x, y):
    return v(*to_kicad(x, y))


def dev(vec):
    return to_device(p.ToMM(vec.x), p.ToMM(vec.y))


def load():
    b = p.LoadBoard(str(PCB))
    return b, {n.GetNetname(): n for n in b.GetNetInfo().NetsByNetcode().values()}


def add_track(b, nets, net, pts, width, layer):
    for a, z in zip(pts, pts[1:]):
        t = p.PCB_TRACK(b); t.SetStart(vd(*a)); t.SetEnd(vd(*z)); t.SetWidth(p.FromMM(width))
        t.SetLayer(layer); t.SetNet(nets[net]); t.SetLocked(True); b.Add(t)


def add_via(b, nets, net, pos):
    t = p.PCB_VIA(b); t.SetPosition(vd(*pos)); t.SetWidth(p.FromMM(0.5)); t.SetDrill(p.FromMM(0.3))
    t.SetViaType(p.VIATYPE_THROUGH); t.SetLayerPair(p.F_Cu, p.B_Cu); t.SetNet(nets[net]); t.SetLocked(True); b.Add(t)


def save_fill(b):
    p.ZONE_FILLER(b).Fill(b.Zones())
    p.SaveBoard(str(PCB), b)


def drc():
    subprocess.run([CLI, 'pcb', 'drc', '--format', 'json', '--severity-all', '--output', str(TMP), str(PCB)],
                   check=True, capture_output=True)
    return json.loads(TMP.read_text())


b, nets = load()
for net, layer, pts, w in HAND_TRACKS:
    add_track(b, nets, net, pts, w, {'F.Cu': p.F_Cu, 'In2.Cu': p.In2_Cu}[layer])
for net, pos in HAND_VIAS:
    add_via(b, nets, net, pos)
save_fill(b)

ANT = ANTENNA_KEEPOUT


def lands_on_l2(b, q):
    """True when a GND via at device point q touches L2 copper: always outside the hatch circle, and on a
    hatch line inside it (a via in a hatch hole connects to nothing)."""
    if math.hypot(q[0] - WHEEL_C[0], q[1] - WHEEL_C[1]) > HATCH_R + 0.05:
        return True
    for z in b.Zones():
        if z.GetZoneName() == 'L2_GND_HATCH_25PCT':
            return z.GetFilledPolysList(p.In1_Cu).Collide(vd(*q), p.FromMM(0.12))
    return True


def inside(q, poly):
    x, y = q; c = False
    for (x0, y0), (x1, y1) in zip(poly, poly[1:] + poly[:1]):
        if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
            c = not c
    return c


def stitch_islands():
    """One via in every L1 GND fragment that has no GND via or GND hole (pad or via) inside it."""
    b, nets = load()
    anchors = [dev(t.GetPosition()) for t in b.GetTracks() if isinstance(t, p.PCB_VIA) and t.GetNetname() == GND]
    anchors += [dev(pd.GetPosition()) for f in b.GetFootprints() for pd in f.Pads()
                if pd.GetNetname() == GND and pd.GetAttribute() == p.PAD_ATTRIB_PTH]
    obst, s1, s3 = [], [], []
    for f in b.GetFootprints():
        for pad in f.Pads():
            bb = pad.GetBoundingBox()
            a, z = dev(p.VECTOR2I(bb.GetLeft(), bb.GetTop())), dev(p.VECTOR2I(bb.GetRight(), bb.GetBottom()))
            obst.append((min(a[0], z[0]), min(a[1], z[1]), max(a[0], z[0]), max(a[1], z[1]), pad.GetNetname(), pad.GetAttribute() != p.PAD_ATTRIB_SMD))
    for t in b.GetTracks():
        if isinstance(t, p.PCB_VIA):
            c = dev(t.GetPosition())
            obst.append((c[0] - 0.25, c[1] - 0.25, c[0] + 0.25, c[1] + 0.25, t.GetNetname(), True))
        elif t.GetLayer() in (p.F_Cu, p.In2_Cu):
            (s1 if t.GetLayer() == p.F_Cu else s3).append((dev(t.GetStart()), dev(t.GetEnd()), p.ToMM(t.GetWidth()) / 2, t.GetNetname()))

    def seg_dist(q, a, c):
        dx, dy = c[0] - a[0], c[1] - a[1]; L2 = dx * dx + dy * dy
        s_ = 0 if L2 == 0 else max(0, min(1, ((q[0] - a[0]) * dx + (q[1] - a[1]) * dy) / L2))
        return math.hypot(q[0] - a[0] - s_ * dx, q[1] - a[1] - s_ * dy)

    def ok(q):
        if ANT[0][0] - 0.5 <= q[0] <= ANT[0][1] and ANT[1][0] - 0.5 <= q[1] <= ANT[1][1]:
            return False
        for x0, y0, x1, y1, net, through in obst:
            dx = max(x0 - q[0], 0, q[0] - x1); dy = max(y0 - q[1], 0, q[1] - y1)
            if math.hypot(dx, dy) < 0.25 + 0.2:     # no via in a pad, 0.2 hole/copper spacing
                return False
        for a, c, hw, net in s3 + s1:
            if net != GND and seg_dist(q, a, c) < 0.25 + hw + 0.2:
                return False
        return True

    added = 0
    orphans = []
    for z in b.Zones():
        if z.GetZoneName() != 'L1_GND':
            continue
        fp_ = z.GetFilledPolysList(p.F_Cu)
        for i in range(fp_.OutlineCount()):
            ln = fp_.Outline(i)
            poly = [dev(ln.CPoint(k)) for k in range(ln.PointCount())]
            hls = [[dev(fp_.Hole(i, h).CPoint(k)) for k in range(fp_.Hole(i, h).PointCount())] for h in range(fp_.HoleCount(i))]
            if any(inside(q, poly) and not any(inside(q, hh) for hh in hls) for q in anchors):
                continue
            xs_, ys_ = [q[0] for q in poly], [q[1] for q in poly]
            edges = list(zip(poly, poly[1:] + poly[:1])) + [e for hh in hls for e in zip(hh, hh[1:] + hh[:1])]
            spot = None
            y = min(ys_)
            while y <= max(ys_) and not spot:
                x = min(xs_)
                while x <= max(xs_):
                    q = (round(x, 3), round(y, 3))
                    if inside(q, poly) and not any(inside(q, hh) for hh in hls) and \
                            min(seg_dist(q, e0, e1) for e0, e1 in edges) >= 0.26 and ok(q):
                        spot = q; break
                    x += 0.1
                y += 0.1
            if spot:
                add_via(b, nets, GND, spot); anchors.append(spot); added += 1
                obst.append((spot[0] - 0.25, spot[1] - 0.25, spot[0] + 0.25, spot[1] + 0.25, GND, True))
            else:
                orphans.extend((f.GetReference(), pd.GetNumber()) for f in b.GetFootprints() for pd in f.Pads()
                               if pd.GetNetname() == GND and inside(dev(pd.GetPosition()), poly))
    save_fill(b)
    print('L1 pour islands stitched:', added, ' islands left to their pads:', len(orphans))
    return orphans


orphans = stitch_islands()
unplaced = set()
for rnd in range(3):
    unplaced = set()
    d = drc()
    todo = []
    for u in d['unconnected_items']:
        for it in u['items']:
            m = re.match(r'Pad (\S+) \[GND\] of (\S+)', it['description'])
            if m:
                todo.append((m.group(2), m.group(1)))
    if rnd == 0:
        todo += orphans
    todo = sorted(set(todo))
    if not todo:
        break
    b, nets = load()
    fps = {f.GetReference(): f for f in b.GetFootprints()}
    # obstacles: every copper item on F.Cu plus all vias and holes (device-frame boxes)
    boxes = []
    for f in b.GetFootprints():
        for pad in f.Pads():
            bb = pad.GetBoundingBox()
            a, z = dev(p.VECTOR2I(bb.GetLeft(), bb.GetTop())), dev(p.VECTOR2I(bb.GetRight(), bb.GetBottom()))
            boxes.append((min(a[0], z[0]), min(a[1], z[1]), max(a[0], z[0]), max(a[1], z[1]), pad.GetNetname(),
                          pad.GetAttribute() != p.PAD_ATTRIB_SMD))
    segs, segs3 = [], []
    for t in b.GetTracks():
        if isinstance(t, p.PCB_VIA):
            c = dev(t.GetPosition()); r = p.ToMM(t.GetWidth()) / 2
            boxes.append((c[0] - r, c[1] - r, c[0] + r, c[1] + r, t.GetNetname(), True))
        elif t.GetLayer() == p.F_Cu:
            segs.append((dev(t.GetStart()), dev(t.GetEnd()), p.ToMM(t.GetWidth()) / 2, t.GetNetname()))
        elif t.GetLayer() == p.In2_Cu:
            segs3.append((dev(t.GetStart()), dev(t.GetEnd()), p.ToMM(t.GetWidth()) / 2, t.GetNetname()))
    outline = board_outline()

    def seg_dist(q, a, c):
        dx, dy = c[0] - a[0], c[1] - a[1]; L2 = dx * dx + dy * dy
        s = 0 if L2 == 0 else max(0, min(1, ((q[0] - a[0]) * dx + (q[1] - a[1]) * dy) / L2))
        return math.hypot(q[0] - a[0] - s * dx, q[1] - a[1] - s * dy)

    def edge_ok(q):
        return all(seg_dist(q, a, c) > 0.8 for a, c in zip(outline, outline[1:] + outline[:1]))

    def free(q, pad_box, cl=0.2):
        """Via of radius 0.25 at q: 0.2 from every pad, via and other-net track; may touch its own pad box edge."""
        if not edge_ok(q) or (ANT[0][0] - 0.5 <= q[0] <= ANT[0][1] and ANT[1][0] - 0.5 <= q[1] <= ANT[1][1]):
            return False
        if not lands_on_l2(b, q):
            return False
        for x0, y0, x1, y1, net, through in boxes:
            dx = max(x0 - q[0], 0, q[0] - x1); dy = max(y0 - q[1], 0, q[1] - y1)
            need = 0.3 if (x0, y0, x1, y1) == pad_box else 0.25 + cl
            if math.hypot(dx, dy) < need:
                return False
        for a, c, hw, net in segs + segs3:
            if net != GND and seg_dist(q, a, c) < 0.25 + hw + cl:
                return False
        return True

    def path_ok(a, c):
        for x0, y0, x1, y1, net, through in boxes:
            if net == GND:
                continue
            for k in range(11):
                q = (a[0] + (c[0] - a[0]) * k / 10, a[1] + (c[1] - a[1]) * k / 10)
                dx = max(x0 - q[0], 0, q[0] - x1); dy = max(y0 - q[1], 0, q[1] - y1)
                if math.hypot(dx, dy) < 0.125 + 0.15:
                    return False
        for a2, c2, hw, net in segs:
            if net == GND:
                continue
            for k in range(11):
                q = (a[0] + (c[0] - a[0]) * k / 10, a[1] + (c[1] - a[1]) * k / 10)
                if seg_dist(q, a2, c2) < 0.125 + hw + 0.15:
                    return False
        return True

    added = 0
    for ref, num in todo:
        pad = fps[ref].FindPadByNumber(num)
        c = dev(pad.GetPosition())
        bb = pad.GetBoundingBox()
        a, z = dev(p.VECTOR2I(bb.GetLeft(), bb.GetTop())), dev(p.VECTOR2I(bb.GetRight(), bb.GetBottom()))
        pbox = (min(a[0], z[0]), min(a[1], z[1]), max(a[0], z[0]), max(a[1], z[1]))
        best = None
        for dist in (0.7, 0.9, 1.1, 1.4, 1.8, 2.2, 2.7):
            for k in range(32):
                ang = 2 * math.pi * k / 32
                q = (round(c[0] + dist * math.cos(ang), 3), round(c[1] + dist * math.sin(ang), 3))
                if free(q, pbox) and path_ok(c, q):
                    best = q; break
            if best:
                break
        if not best:
            print('no GND via spot for', ref, num)
            unplaced.add((ref, num))
            continue
        add_track(b, nets, GND, [c, best], 0.25, p.F_Cu)
        add_via(b, nets, GND, best)
        boxes.append((best[0] - 0.25, best[1] - 0.25, best[0] + 0.25, best[1] + 0.25, GND, True))
        added += 1
    print('round', rnd + 1, ': GND pads open', len(todo), ', stitching vias added', added)
    save_fill(b)


left = set(stitch_islands()) | unplaced
# GND pads that found no straight via spot: maze.py routes each one to the nearest place a via fits.
(HERE / 'review' / '_gnd_orphans.json').write_text(json.dumps(sorted(left)))
d = drc()
print('remaining unconnected:', len(d['unconnected_items']))
for u in d['unconnected_items'][:40]:
    print('  ', ' / '.join(i['description'] for i in u['items']))
TMP.unlink()
