"""Touch-wheel electrode geometry in device coordinates (SPEC 4). Standard library only.

Eight ring sectors from RING_R[0] to RING_R[1] and a centre disc. Each boundary between two
neighbouring sectors is a radial zigzag (TOOTH_COUNT teeth, TOOTH_AMPLITUDE tangential half
amplitude). Each sector edge is the zigzag offset by half the gap with mitred corners, so every
point of one sector is at least ELECTRODE_GAP from its neighbour.
"""
import math
from design import WHEEL_C, RING_R, CENTER_R, ELECTRODE_GAP, TOOTH_COUNT, TOOTH_AMPLITUDE, SECTOR_ANGLES

ARC_STEP = math.radians(2.0)


def _boundary(beta_deg):
    """Zigzag boundary polyline (local x, y about the wheel centre) at mean angle beta, from inside
    RING_R[0] to outside RING_R[1]. Tangential displacement is measured counter-clockwise."""
    r0, r1 = RING_R
    period = (r1 - r0) / TOOTH_COUNT
    rs, ts = [r0 - 0.6], [0.0]
    for k in range(TOOTH_COUNT):
        for frac, t in ((0.25, 1.0), (0.5, 0.0), (0.75, -1.0), (1.0, 0.0)):
            rs.append(r0 + period * (k + frac)); ts.append(t * TOOTH_AMPLITUDE)
    rs.insert(1, r0); ts.insert(1, 0.0)
    rs.append(r1 + 0.6); ts.append(0.0)
    b = math.radians(beta_deg)
    er, et = (math.cos(b), math.sin(b)), (-math.sin(b), math.cos(b))
    return [(r * er[0] + t * et[0], r * er[1] + t * et[1]) for r, t in zip(rs, ts)]


def _offset(poly, d):
    """Offset an open polyline by d to its left (mitred joins)."""
    normals = []
    for (x0, y0), (x1, y1) in zip(poly, poly[1:]):
        L = math.hypot(x1 - x0, y1 - y0)
        normals.append((-(y1 - y0) / L, (x1 - x0) / L))
    out = []
    for i, (x, y) in enumerate(poly):
        if i == 0:
            n = normals[0]; s = 1.0
            out.append((x + d * n[0], y + d * n[1])); continue
        if i == len(poly) - 1:
            n = normals[-1]
            out.append((x + d * n[0], y + d * n[1])); continue
        n1, n2 = normals[i - 1], normals[i]
        k = 1.0 + n1[0] * n2[0] + n1[1] * n2[1]
        out.append((x + d * (n1[0] + n2[0]) / k, y + d * (n1[1] + n2[1]) / k))
    return out


def _cut(poly, radius, first):
    """Index and point where an outward polyline first (or last) crosses the circle `radius`."""
    rng = range(len(poly) - 1) if first else range(len(poly) - 2, -1, -1)
    for i in rng:
        (x0, y0), (x1, y1) = poly[i], poly[i + 1]
        dx, dy = x1 - x0, y1 - y0
        a = dx * dx + dy * dy; bq = 2 * (x0 * dx + y0 * dy); c = x0 * x0 + y0 * y0 - radius * radius
        disc = bq * bq - 4 * a * c
        if disc < 0:
            continue
        for s in sorted([(-bq - math.sqrt(disc)) / (2 * a), (-bq + math.sqrt(disc)) / (2 * a)]):
            if 0 <= s <= 1:
                return i, (x0 + s * dx, y0 + s * dy)
    raise ValueError('no crossing')


def _arc(radius, a0, a1):
    """Points on a circle from angle a0 to a1 (radians, either direction), excluding endpoints."""
    n = max(1, int(abs(a1 - a0) / ARC_STEP))
    return [(radius * math.cos(a0 + (a1 - a0) * k / n), radius * math.sin(a0 + (a1 - a0) * k / n)) for k in range(1, n)]


def _ang(pt):
    return math.atan2(pt[1], pt[0])


def sector_local(i):
    """Polygon of ring sector i (1..8) about the wheel centre, counter-clockwise."""
    theta = SECTOR_ANGLES[i]
    g = ELECTRODE_GAP / 2
    cw = _boundary(theta - 22.5)      # this sector lies to the LEFT (counter-clockwise) of cw
    ccw = _boundary(theta + 22.5)     # and to the RIGHT of ccw
    cw_off = _offset(cw, g)
    ccw_off = _offset(ccw, -g)
    r0, r1 = RING_R
    i0, p0 = _cut(cw_off, r0, True); i1, p1 = _cut(cw_off, r1, False)
    j0, q0 = _cut(ccw_off, r0, True); j1, q1 = _cut(ccw_off, r1, False)
    pts = [p0] + cw_off[i0 + 1:i1 + 1] + [p1]
    a_p1, a_q1 = _ang(p1), _ang(q1)
    if a_q1 < a_p1:
        a_q1 += 2 * math.pi
    pts += _arc(r1, a_p1, a_q1)
    pts += [q1] + ccw_off[j0 + 1:j1 + 1][::-1] + [q0]
    a_q0, a_p0 = _ang(q0), _ang(p0)
    if a_p0 > a_q0:
        a_p0 -= 2 * math.pi
    pts += _arc(r0, a_q0, a_p0)
    return pts


def electrode_polygons():
    """{'C': centre disc, '1'..'8': sectors} as device-coordinate point lists."""
    out = {'C': [(WHEEL_C[0] + CENTER_R * math.cos(2 * math.pi * k / 120),
                  WHEEL_C[1] + CENTER_R * math.sin(2 * math.pi * k / 120)) for k in range(120)]}
    for i in range(1, 9):
        out[str(i)] = [(WHEEL_C[0] + x, WHEEL_C[1] + y) for x, y in sector_local(i)]
    return out


def _seg_dist(p, a, b):
    ax, ay = a; bx, by = b; px, py = p
    dx, dy = bx - ax, by - ay
    L2 = dx * dx + dy * dy
    s = 0 if L2 == 0 else max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / L2))
    return math.hypot(px - ax - s * dx, py - ay - s * dy)


def min_gap(pa, pb):
    """Minimum distance between two polygons' boundaries (vertex-to-edge both ways)."""
    best = 1e9
    for P, Q in ((pa, pb), (pb, pa)):
        edges = list(zip(Q, Q[1:] + Q[:1]))
        for pt in P:
            for a, b in edges:
                best = min(best, _seg_dist(pt, a, b))
    return best


if __name__ == '__main__':
    polys = electrode_polygons()
    for i in range(1, 9):
        j = i % 8 + 1
        print('gap %d-%d %.3f' % (i, j, min_gap(polys[str(i)], polys[str(j)])), end='  ')
    print('\nring to centre %.3f' % min_gap(polys['1'], polys['C']))
