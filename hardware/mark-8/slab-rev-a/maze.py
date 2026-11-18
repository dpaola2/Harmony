"""Grid maze router that closes DRC's unconnected pairs (uv: numpy, scipy).

Usage: maze.py dump.json routes.json
Routes on L1 (F.Cu) and L3 (In2.Cu) with through vias, on a 0.05 mm grid, keeping every other-net
pad, track, via and hole at least CLEARANCE away (distance transform of the other nets' copper),
0.3 from the board edge, out of the antenna keep-out, and obeying the wheel rule: switching nets
(not in design.WHEEL_TOLERANT_NETS) use L1 only inside the wheel and place no via there.

Correctness rules: every new track and via is painted into both the full and the fixed copper maps, so
a later rip-up route never crosses it; victims of a rip-up are found from the final (string-pulled)
geometry, not the grid path; after a rip-up the copper map is repainted from the live items, so a
victim never erases a neighbour; a new via keeps 0.25 mm hole to hole from every drilled hole,
same net included.
"""
import heapq
import json
import math
import os
import re
import sys
from pathlib import Path
import numpy as np
from scipy import ndimage

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from design import (board_outline, WHEEL_C, WHEEL_KEEPOUT_R, RING_R, ANTENNA_KEEPOUT, PHASE_A_NETS,  # noqa: E402
                    WHEEL_TOLERANT_NETS, POWER_NETS, GND, DISC_EDGE_CROSS_NETS, DISC_EDGE_CROSS_R)

RES = 0.05
CLEAR = 0.16           # 0.15 net class clearance + margin for the grid
EDGE = 0.36           # DRC needs 0.3 to the true (arc) outline; the polygon and the grid each lose a little
VIA_R = 0.25
dump = json.loads(open(sys.argv[1]).read())
outline = board_outline()
X0, X1 = min(p[0] for p in outline) - 0.5, max(p[0] for p in outline) + 0.5
Y0, Y1 = min(p[1] for p in outline) - 0.5, max(p[1] for p in outline) + 0.5
NX, NY = int((X1 - X0) / RES) + 1, int((Y1 - Y0) / RES) + 1
xs = X0 + np.arange(NX) * RES
ys = Y0 + np.arange(NY) * RES
GX, GY = np.meshgrid(xs, ys, indexing='ij')
LAY = ['F.Cu', 'In2.Cu']

# board interior distance to the edge
from matplotlib.path import Path as MPath  # noqa: E402
inside = MPath(outline).contains_points(np.c_[GX.ravel(), GY.ravel()]).reshape(GX.shape)
edge_dist = ndimage.distance_transform_edt(inside) * RES
board_ok = edge_dist > EDGE
# distance from the antenna keep-out rectangle (0 inside): copper keeps 0.05 beyond its own half width
_ax = np.maximum(np.maximum(ANTENNA_KEEPOUT[0][0] - GX, GX - ANTENNA_KEEPOUT[0][1]), 0)
_ay = np.maximum(np.maximum(ANTENNA_KEEPOUT[1][0] - GY, GY - ANTENNA_KEEPOUT[1][1]), 0)
ant_d = np.hypot(_ax, _ay)
ant = ant_d <= 0.05
rwheel = np.hypot(GX - WHEEL_C[0], GY - WHEEL_C[1])

nets = sorted({it['net'] for k in ('pads', 'tracks', 'vias') for it in dump[k]} | {''})
NID = {n: i for i, n in enumerate(nets)}
label = {l: np.full(GX.shape, -1, np.int16) for l in LAY + ['thru']}       # all copper
hard = {l: np.full(GX.shape, -1, np.int16) for l in LAY + ['thru']}        # copper that may not be ripped up


def idx(x, y):
    return int(round((x - X0) / RES)), int(round((y - Y0) / RES))


def paint_box(arr, bx, nid, grow=0.0):
    i0, j0 = idx(bx[0] - grow, bx[1] - grow); i1, j1 = idx(bx[2] + grow, bx[3] + grow)
    arr[max(i0, 0):i1 + 1, max(j0, 0):j1 + 1] = nid


def paint_seg(arr, a, z, r, nid):
    i0, j0 = idx(min(a[0], z[0]) - r, min(a[1], z[1]) - r); i1, j1 = idx(max(a[0], z[0]) + r, max(a[1], z[1]) + r)
    i0, j0 = max(i0, 0), max(j0, 0)
    sx, sy = GX[i0:i1 + 1, j0:j1 + 1], GY[i0:i1 + 1, j0:j1 + 1]
    dx, dy = z[0] - a[0], z[1] - a[1]; L2 = dx * dx + dy * dy
    t = np.zeros_like(sx) if L2 == 0 else np.clip(((sx - a[0]) * dx + (sy - a[1]) * dy) / L2, 0, 1)
    m = np.hypot(sx - a[0] - t * dx, sy - a[1] - t * dy) <= r
    arr[i0:i1 + 1, j0:j1 + 1][m] = nid


# L2 hatch copper (even-odd fill of the dumped outlines and holes): a GND via inside the hatch circle
# must land on it, or it connects to nothing.
from design import HATCH_R  # noqa: E402
_hc = np.zeros(GX.shape, bool)
for _poly in dump.get('hatch', []):
    if len(_poly) >= 3:
        _hc ^= MPath(_poly).contains_points(np.c_[GX.ravel(), GY.ravel()]).reshape(GX.shape)
gnd_land = (rwheel > HATCH_R + 0.05) | ((ndimage.distance_transform_edt(~_hc) * RES) < 0.12)
NEW = []          # copper added by this run: (kind, layer, a, z, r, nid)
padmask = np.zeros(GX.shape, bool)       # every pad on L1, any net: no via in or against a pad
for _pd in dump['pads']:
    if 'F.Cu' in _pd['layers']:
        paint_box(padmask, _pd['box'], True)
pad_far = ndimage.distance_transform_edt(~padmask) * RES - RES * 0.5 > VIA_R + 0.1
HOLE_R = 0.15     # via drill radius
holes = np.zeros(GX.shape, bool)   # every drilled hole, any net


def paint_all():
    for arr in (label, hard):
        for l in arr:
            arr[l][:] = -1
    holes[:] = False
    for pd in dump['pads']:
        nid = NID[pd['net']] if pd['net'] else NID['']
        for arr in (label, hard):
            for l in LAY:
                if l in pd['layers']:
                    paint_box(arr[l], pd['box'], nid)
            if pd['drill']:
                paint_box(arr['thru'], [pd['c'][0] - pd['drill'] / 2, pd['c'][1] - pd['drill'] / 2,
                                        pd['c'][0] + pd['drill'] / 2, pd['c'][1] + pd['drill'] / 2], nid, 0.05)
        if pd['drill']:
            paint_seg(holes, pd['c'], pd['c'], pd['drill'] / 2, True)
    for tr in dump['tracks']:
        if tr['layer'] in LAY and not tr.get('gone'):
            for arr in ((label,) if tr.get('rip') else (label, hard)):
                paint_seg(arr[tr['layer']], tr['a'], tr['z'], tr['w'] / 2, NID[tr['net']])
    for v in dump['vias']:
        if v.get('gone'):
            continue
        for arr in ((label,) if v.get('rip') else (label, hard)):
            for l in LAY + ['thru']:
                paint_seg(arr[l], v['c'], v['c'], v['r'], NID[v['net']])
        paint_seg(holes, v['c'], v['c'], HOLE_R, True)
    for kind, l, a, z, r, nid in NEW:
        paint_new(kind, l, a, z, r, nid)


gnd_vias = np.zeros(GX.shape, bool)     # cells on a GND via that reaches L2: an escape may end there


def paint_new(kind, l, a, z, r, nid):
    if kind == 'via' and nid == NID.get(GND):
        paint_seg(gnd_vias, a, a, 0.15, True)
    for arr in (label, hard):
        if kind == 'track':
            paint_seg(arr[l], a, z, r, nid)
        else:
            for ll in LAY + ['thru']:
                paint_seg(arr[ll], a, a, r, nid)
    if kind == 'via':
        paint_seg(holes, a, a, HOLE_R, True)


paint_all()
for _v in dump['vias']:
    if _v['net'] == GND and (math.hypot(_v['c'][0] - WHEEL_C[0], _v['c'][1] - WHEEL_C[1]) > 17.65 or
                             gnd_land[idx(*_v['c'])]):
        paint_seg(gnd_vias, _v['c'], _v['c'], 0.15, True)
RIP_COST = 6.0
RIP_SCALE = 4.0     # a rip-up must save a long detour: crossing a 0.5 mm wide DC track costs about 10 mm of track
ripw = {l: np.zeros(GX.shape, np.float32) for l in LAY + ['thru']}


def paint_max(arr, a, z, r, val):
    i0, j0 = idx(min(a[0], z[0]) - r, min(a[1], z[1]) - r); i1, j1 = idx(max(a[0], z[0]) + r, max(a[1], z[1]) + r)
    i0, j0 = max(i0, 0), max(j0, 0)
    sx, sy = GX[i0:i1 + 1, j0:j1 + 1], GY[i0:i1 + 1, j0:j1 + 1]
    dx, dy = z[0] - a[0], z[1] - a[1]; L2 = dx * dx + dy * dy
    t = np.zeros_like(sx) if L2 == 0 else np.clip(((sx - a[0]) * dx + (sy - a[1]) * dy) / L2, 0, 1)
    msk = np.hypot(sx - a[0] - t * dx, sy - a[1] - t * dy) <= r
    win = arr[i0:i1 + 1, j0:j1 + 1]
    win[msk] = np.maximum(win[msk], val)


for tr in dump['tracks']:
    if tr['layer'] in LAY and tr.get('rip'):
        paint_max(ripw[tr['layer']], tr['a'], tr['z'], tr['w'] / 2 + CLEAR + 0.1, float(tr['rip']))
for v in dump['vias']:
    if v.get('rip'):
        for l in LAY:
            paint_max(ripw[l], v['c'], v['c'], v['r'] + CLEAR + 0.1, float(v['rip']))


def dist_other(net, arr=None):
    arr = arr or label
    nid = NID[net]
    res = {}
    for l in LAY + ['thru']:
        other = (arr[l] >= 0) & (arr[l] != nid)
        res[l] = ndimage.distance_transform_edt(~other) * RES - RES * 0.5
    return res


DIRS = [(1, 0, 1.0), (-1, 0, 1.0), (0, 1, 1.0), (0, -1, 1.0), (1, 1, 1.414), (1, -1, 1.414), (-1, 1, 1.414), (-1, -1, 1.414)]


def route(item_a, item_b, net, width, ripup=False, margin=6.0, cap=250000, escape=False):
    """A* from item_a to item_b. escape=True (GND): stay on L1 and stop at the nearest spot, at least
    0.75 mm from the start, where a via to the L2 plane fits; item_b is ignored."""
    dd = dist_other(net, hard if ripup else label)
    ds = dist_other(net, label) if ripup else dd
    switching = net not in WHEEL_TOLERANT_NETS
    edgecross = net in DISC_EDGE_CROSS_NETS       # may cross on L3 near the disc edge (r > 14), at a cost
    r_l3 = DISC_EDGE_CROSS_R if edgecross else WHEEL_KEEPOUT_R
    w2 = width / 2
    free, pen = {}, {}
    for k, l in enumerate(LAY):
        f = (dd[l] > CLEAR + w2) & (dd['thru'] > 0.2 + w2) & (edge_dist > EDGE + w2) & (ant_d > w2 + 0.05)
        if switching and l == 'In2.Cu':
            f &= rwheel > r_l3 + w2
        free[k] = f
        pen[k] = ~((ds[l] > CLEAR + w2) & (ds['thru'] > 0.2 + w2))
    via_ok = ((dd['F.Cu'] > CLEAR + VIA_R) & (dd['In2.Cu'] > CLEAR + VIA_R) & (dd['thru'] > 0.25 + VIA_R) &
              (edge_dist > EDGE + VIA_R) & (ant_d > VIA_R + 0.05))
    via_ok &= (ndimage.distance_transform_edt(~holes) * RES - RES * 0.5) > HOLE_R + 0.25 + 0.04
    via_pen = ~((ds['F.Cu'] > CLEAR + VIA_R) & (ds['In2.Cu'] > CLEAR + VIA_R) & (ds['thru'] > 0.25 + VIA_R))
    via_ok &= pad_far
    if net == GND:
        via_ok &= gnd_land
    if switching:
        via_ok &= rwheel > r_l3 + VIA_R
    l3_extra = (rwheel <= WHEEL_KEEPOUT_R + w2) * 10.0 if edgecross else None   # cost per cell of L3 inside the disc
    wx0 = min(item_a['pos'][0], item_b['pos'][0]) - margin; wx1 = max(item_a['pos'][0], item_b['pos'][0]) + margin
    wy0 = min(item_a['pos'][1], item_b['pos'][1]) - margin; wy1 = max(item_a['pos'][1], item_b['pos'][1]) + margin
    wi0, wj0 = idx(wx0, wy0); wi1, wj1 = idx(wx1, wy1)
    win = np.zeros(GX.shape, bool); win[max(wi0, 0):wi1 + 1, max(wj0, 0):wj1 + 1] = True
    for k in free:
        free[k] &= win
    sa = [LAY.index(l) for l in item_a['layers'] if l in LAY]
    sb = [LAY.index(l) for l in item_b['layers'] if l in LAY]
    ia, ja = idx(*item_a['pos']); ib, jb = idx(*item_b['pos'])
    # Start and goal cells sit on same-net copper; open a small disc around them.
    for k in set(sa + sb):
        for (ci, cj) in ((ia, ja), (ib, jb)):
            free[k][max(ci - 1, 0):ci + 2, max(cj - 1, 0):cj + 2] = True
    global LAST_FREE
    LAST_FREE = free
    goal = {(ib, jb, k) for k in sb}
    h = lambda i, j: math.hypot(i - ib, j - jb)
    if escape:
        sa = [0]
        goal = set()
        h = lambda i, j: 0.0
        far = int(0.75 / RES)
    openq = []
    best = {}
    for k in sa:
        heapq.heappush(openq, (h(ia, ja), 0.0, ia, ja, k, None))
        best[(ia, ja, k)] = 0.0
    came = {}
    n = 0
    while openq:
        f_, g, i, j, k, prev = heapq.heappop(openq)
        if best.get((i, j, k), 1e18) < g:
            continue
        came[(i, j, k)] = prev
        at_via = escape and k == 0 and gnd_vias[i, j] and max(abs(i - ia), abs(j - ja)) >= 4
        if (i, j, k) in goal or at_via or (escape and k == 0 and via_ok[i, j] and max(abs(i - ia), abs(j - ja)) >= far):
            if escape and not at_via:
                came[(i, j, 1)] = (i, j, 0)
                i, j, k = i, j, 1
            path = [(i, j, k)]
            while came[path[-1]] is not None:
                path.append(came[path[-1]])
            return path[::-1]
        n += 1
        if n > cap:
            return None
        for di, dj, c in DIRS:
            ni, nj = i + di, j + dj
            if 0 <= ni < NX and 0 <= nj < NY and free[k][ni, nj]:
                ng = g + c + (0.15 if k == 1 else 0.0) + (RIP_SCALE * max(RIP_COST, ripw[LAY[k]][ni, nj]) if ripup and pen[k][ni, nj] else 0.0)
                if k == 1 and l3_extra is not None:
                    ng += c * l3_extra[ni, nj]
                if ng < best.get((ni, nj, k), 1e18):
                    best[(ni, nj, k)] = ng
                    heapq.heappush(openq, (ng + h(ni, nj), ng, ni, nj, k, (i, j, k)))
        if via_ok[i, j] and not escape:
            nk = 1 - k
            ng = g + 12.0 + (4 * RIP_SCALE * RIP_COST if ripup and via_pen[i, j] else 0.0)
            if free[nk][i, j] and ng < best.get((i, j, nk), 1e18):
                best[(i, j, nk)] = ng
                heapq.heappush(openq, (ng + h(i, j), ng, i, j, nk, (i, j, k)))
    return None


LAST_FREE = None


def clear_line(k, p0, p1):
    """True when the straight segment p0-p1 (grid indices) stays on free cells of layer k."""
    n = int(max(abs(p1[0] - p0[0]), abs(p1[1] - p0[1])) * 4) + 1
    for s in range(n + 1):
        i = int(round(p0[0] + (p1[0] - p0[0]) * s / n)); j = int(round(p0[1] + (p1[1] - p0[1]) * s / n))
        if not LAST_FREE[k][i, j]:
            return False
    return True


def pull(run, k):
    """String-pull a run of grid points on one layer: keep only corners needed to stay on free cells."""
    out = [run[0]]
    i = 0
    while i < len(run) - 1:
        j = len(run) - 1
        while j > i + 1 and not clear_line(k, run[i], run[j]):
            j -= 1
        out.append(run[j]); i = j
    return out


def to_segments(path, a_pos, b_pos):
    runs, cur = [], [path[0]]
    for q in path[1:]:
        if q[2] != cur[-1][2]:
            runs.append(cur); cur = [q]
        else:
            cur.append(q)
    runs.append(cur)
    path = []
    for run in runs:
        path += [(i, j, run[0][2]) for i, j in pull([(q[0], q[1]) for q in run], run[0][2])]
    pts = [(X0 + i * RES, Y0 + j * RES, k) for i, j, k in path]
    segs, vias = [], []
    run = [pts[0]]
    for q in pts[1:]:
        if q[2] != run[-1][2]:
            segs.append((run, run[-1][2])); vias.append(q[:2]); run = [q]
        else:
            run.append(q)
    segs.append((run, run[-1][2]))
    out = []
    for n_, (run, k) in enumerate(segs):
        poly = [run[0][:2]]
        for m in range(1, len(run) - 1):
            d1 = (run[m][0] - run[m - 1][0], run[m][1] - run[m - 1][1])
            d2 = (run[m + 1][0] - run[m][0], run[m + 1][1] - run[m][1])
            if abs(d1[0] * d2[1] - d1[1] * d2[0]) > 1e-9:
                poly.append(run[m][:2])
        poly.append(run[-1][:2])
        if n_ == 0:
            poly[0] = tuple(a_pos)
        if n_ == len(segs) - 1:
            poly[-1] = tuple(b_pos)
        poly = [(round(x, 4), round(y, 4)) for x, y in poly]
        dedup = [poly[0]] + [q for pq, q in zip(poly, poly[1:]) if q != pq]
        if len(dedup) > 1:
            out.append(dict(layer=LAY[k], pts=dedup))
    return out, [(round(x, 4), round(y, 4)) for x, y in vias]


STRICT = ['VSYS', 'VBAT', '3V3', 'VBUS']     # at least 0.4 mm (VBUS: J1 to D1 and to U3 carry up to 0.7 A)


def ohms(v):
    v = v.strip().upper().replace('OHM', '').replace('R', '')
    mult = {'K': 1e3, 'M': 1e6}.get(v[-1:], 1)
    try:
        return float(v.rstrip('KM')) * mult
    except ValueError:
        return 0.0


TAP_PADS = {(pd['ref'], pd['num']) for pd in dump['pads'] if pd['ref'].startswith('R') and ohms(pd.get('value', '')) >= 1e4}


def is_tap(item):
    m_ = re.match(r'Pad (\S+) \[[^\]]*\] of (\S+)', item['desc'])
    return bool(m_) and (m_.group(2), m_.group(1)) in TAP_PADS


def ladder(net, a=None, b=None):
    """(width, rip-up) attempts, widest first. Strict power nets try 0.4 with rip-up before narrowing,
    except a branch to a pull-up or divider resistor of 10 k or more, which carries signal current."""
    if net in STRICT and a is not None and (is_tap(a) or is_tap(b)):
        return [(0.2, False), (0.15, False), (0.15, True)]
    if net in STRICT:
        return [(0.4, False), (0.4, True), (0.3, False), (0.3, True), (0.2, False), (0.2, True)]
    if net == GND:
        return [(0.3, False), (0.2, False), (0.2, True)]
    if net in POWER_NETS:
        return [(0.4, False), (0.3, False), (0.3, True), (0.2, False), (0.2, True)]
    return [(0.2, False), (0.15, False), (0.15, True), (0.127, False), (0.127, True)]


def seg_d(q, s0, s1):
    dx, dy = s1[0] - s0[0], s1[1] - s0[1]; L2 = dx * dx + dy * dy
    u = 0 if L2 == 0 else max(0, min(1, ((q[0] - s0[0]) * dx + (q[1] - s0[1]) * dy) / L2))
    return math.hypot(q[0] - s0[0] - u * dx, q[1] - s0[1] - u * dy)


def sample(segs):
    """Points every 0.02 mm along the final segments, with their layer."""
    out = []
    for sg in segs:
        for p0, p1 in zip(sg['pts'], sg['pts'][1:]):
            n = max(1, int(math.hypot(p1[0] - p0[0], p1[1] - p0[1]) / 0.02))
            out += [(p0[0] + (p1[0] - p0[0]) * k / n, p0[1] + (p1[1] - p0[1]) * k / n, sg['layer']) for k in range(n + 1)]
    return out


def find_victims(net, w, segs, vias):
    pts = sample(segs)
    victims = []
    M = 0.02    # margin over the DRC minimum
    for tr in dump['tracks']:
        if not tr.get('rip') or tr['net'] == net or tr.get('gone') or tr['layer'] not in LAY:
            continue
        lim = 0.127 + M + w / 2 + tr['w'] / 2
        box = (min(tr['a'][0], tr['z'][0]) - lim - VIA_R, max(tr['a'][0], tr['z'][0]) + lim + VIA_R,
               min(tr['a'][1], tr['z'][1]) - lim - VIA_R, max(tr['a'][1], tr['z'][1]) + lim + VIA_R)
        near = [q for q in pts if q[2] == tr['layer'] and box[0] <= q[0] <= box[1] and box[2] <= q[1] <= box[3]]
        if any(seg_d(q, tr['a'], tr['z']) < lim for q in near) or \
                any(seg_d(vq, tr['a'], tr['z']) < 0.127 + M + VIA_R + tr['w'] / 2 for vq in vias):
            victims.append(dict(kind='track', k=tr['k'])); tr['gone'] = True
    for vv in dump['vias']:
        if not vv.get('rip') or vv['net'] == net or vv.get('gone'):
            continue
        lim = 0.127 + M + w / 2 + vv['r']
        if any(abs(q[0] - vv['c'][0]) < lim and abs(q[1] - vv['c'][1]) < lim and
               math.hypot(q[0] - vv['c'][0], q[1] - vv['c'][1]) < lim for q in pts) or \
           any(math.hypot(vq[0] - vv['c'][0], vq[1] - vv['c'][1]) < max(0.127 + M + VIA_R + vv['r'], 0.6) for vq in vias):
            victims.append(dict(kind='via', k=vv['k'])); vv['gone'] = True
    return victims


results, failed = [], []
# Most constrained first: switching nets, then DC nets, GND last. Two passes: the first never rips
# anything up (and gives VSYS, VBAT and 3V3 only their full 0.4 width); the second takes what is left
# with the whole ladder, rip-up included. So nothing is ripped up for a connection that fits as it is.
dump['pairs'].sort(key=lambda pr: (pr[0]['net'] == GND, pr[0]['net'] in PHASE_A_NETS))
todo = []
for pair in dump['pairs']:
    if len(pair) != 2:
        continue
    a, b = pair
    if len([it for it in (a, b) if it['kind'] in ('pad', 'via', 'track')]) < 2:
        failed.append([it['desc'] for it in pair]); continue
    dist = math.hypot(a['pos'][0] - b['pos'][0], a['pos'][1] - b['pos'][1])
    esc = None
    if a['net'] == GND:
        # A GND pad only needs a via to the L2 plane: route it to the nearest spot where one fits.
        pads_ = [it for it in (a, b) if it['kind'] == 'pad' and 'F.Cu' in it['layers']]
        l1 = [it for it in (a, b) if 'F.Cu' in it['layers']]
        if pads_:
            esc = pads_[0]
        elif dist > 4.0 and l1:
            esc = l1[0]
        elif dist > 4.0:
            failed.append([it['desc'] for it in pair]); print('SKIP GND', a['desc'], '/', b['desc']); continue
    todo.append((a, b, esc))
work = [(1, pr) for pr in todo]
second = []
while work:
    pas, (a, b, esc) = work.pop(0)
    if esc is not None:
        a = b = esc
    net = a['net']
    full = ladder(net, a, b)
    if os.environ.get('MAZE_NORIP') == '1':
        full = [(w_, r_) for w_, r_ in full if not r_]
    if pas == 1:
        tries = [(w, r) for w, r in full if not r]
        if net in STRICT and full[0][0] == 0.4:
            tries = tries[:1]
    else:
        tries = full
    path = None
    span = (abs(a['pos'][0] - b['pos'][0]) + 16) * (abs(a['pos'][1] - b['pos'][1]) + 16) / RES ** 2
    for w, rip in tries:
        path = route(a, b, net, w, ripup=rip, margin=8.0 if rip else 6.0,
                     cap=int(max(400000 if rip else 200000, 1.5 * span)), escape=esc is not None)
        if not path and rip and esc is None:
            # a ripped-up route may need a wider window than the pair's own bounding box
            path = route(a, b, net, w, ripup=rip, margin=20.0, cap=2000000, escape=False)
        if path:
            break
    if not path and pas == 1 and net != GND and esc is None:
        # before anything is ripped up: a detour anywhere on the board, widest width first
        rip = False
        widths = [0.4, 0.3] if (net in STRICT and full[0][0] == 0.4) else [[w_ for w_, r_ in full if not r_][-1]]
        for w in widths:
            path = route(a, b, net, w, ripup=False, margin=60.0, cap=2500000)
            if path:
                print('whole-board route', net, w)
                break
    if not path:
        if pas == 1:
            second.append((2, (a, b, esc)))
            if not work:
                work, second = second, []
            continue
        failed.append([a['desc'], b['desc']]); print('FAILED', net, a['desc'], '/', b['desc'])
        continue
    end_pos = (X0 + path[-1][0] * RES, Y0 + path[-1][1] * RES) if esc is not None else b['pos']
    segs, vias = to_segments(path, a['pos'], end_pos)
    victims = find_victims(net, w, segs, vias) if rip else []
    if victims:
        paint_all()
    results.append(dict(net=net, width=w, segs=segs, vias=vias, victims=victims))
    for sg in segs:
        for p0, p1 in zip(sg['pts'], sg['pts'][1:]):
            NEW.append(('track', sg['layer'], p0, p1, w / 2, NID[net]))
            paint_new('track', sg['layer'], p0, p1, w / 2, NID[net])
    for v in vias:
        NEW.append(('via', None, v, v, VIA_R, NID[net]))
        paint_new('via', None, v, v, VIA_R, NID[net])
    print('routed %-12s w %.3f  %d segs  %d vias  %d ripped' % (net, w, sum(len(sg['pts']) - 1 for sg in segs), len(vias), len(victims)))
    if not work:
        work, second = second, []
open(sys.argv[2], 'w').write(json.dumps(dict(routes=results, failed=failed)))
print('routed', len(results), 'failed', len(failed))
