"""Small geometry helpers shared by the part modules."""
import math

import cadquery as cq

V = cq.Vector


def prism(points, vec):
    """Extrude a closed planar polygon (list of 3D tuples) by vec."""
    # Newell normal; orient the polygon so that it faces along vec.
    nx = ny = nz = 0.0
    for i, a in enumerate(points):
        b = points[(i + 1) % len(points)]
        nx += (a[1] - b[1]) * (a[2] + b[2])
        ny += (a[2] - b[2]) * (a[0] + b[0])
        nz += (a[0] - b[0]) * (a[1] + b[1])
    if nx * vec[0] + ny * vec[1] + nz * vec[2] < 0:
        points = points[::-1]
    w = cq.Wire.makePolygon([V(*p) for p in points], close=True)
    f = cq.Face.makeFromWires(w)
    return cq.Solid.extrudeLinear(f, V(*vec))


def box(x0, x1, y0, y1, z0, z1):
    return cq.Solid.makeBox(x1 - x0, y1 - y0, z1 - z0, V(x0, y0, z0))


def cyl_z(cx, cy, r, z0, z1):
    return cq.Solid.makeCylinder(r, z1 - z0, V(cx, cy, z0), V(0, 0, 1))


def cone_z(cx, cy, r0, r1, z0, z1):
    return cq.Solid.makeCone(r0, r1, z1 - z0, V(cx, cy, z0), V(0, 0, 1))


def rrect_xy(cx, cy, w, h, r, z0, z1):
    """Rounded rectangle prism with straight sides, axis Z."""
    wp = cq.Workplane("XY", origin=(cx, cy, z0)).rect(w, h)
    s = wp.extrude(z1 - z0)
    if r > 0:
        s = s.edges("|Z").fillet(min(r, min(w, h) / 2 - 1e-3))
    return s.val()


def rrect_xz(cx, cz, w, h, r, y0, y1):
    """Rounded rectangle in the XZ plane, extruded along Y from y0 to y1."""
    pl = cq.Plane(origin=(cx, y0, cz), xDir=(1, 0, 0), normal=(0, 1, 0))
    s = cq.Workplane(pl).rect(w, h).extrude(y1 - y0)
    if r > 0:
        s = s.edges("|Y").fillet(min(r, min(w, h) / 2 - 1e-3))
    return s.val()


def rrect_yz(cy, cz, w, h, r, x0, x1):
    """Rounded rectangle in the YZ plane (w along Y, h along Z), extruded along X."""
    pl = cq.Plane(origin=(x0, cy, cz), xDir=(0, 1, 0), normal=(1, 0, 0))
    s = cq.Workplane(pl).rect(w, h).extrude(x1 - x0)
    if r > 0:
        s = s.edges("|X").fillet(min(r, min(w, h) / 2 - 1e-3))
    return s.val()


def union(*shapes):
    shapes = [s for s in shapes if s is not None]
    out = shapes[0]
    for s in shapes[1:]:
        out = out.fuse(s)
    return out.clean()


def cut(base, *tools):
    out = base
    for t in tools:
        if t is not None:
            out = out.cut(t)
    return out.clean()


def one_solid(shape):
    """Return the largest solid of a shape (booleans sometimes return a compound)."""
    sols = shape.Solids()
    if len(sols) == 1:
        return sols[0]
    return max(sols, key=lambda s: s.Volume())


class Path2D:
    """A 2D centre line made of straight lines and arcs, tracked by heading.

    Coordinates are (u, v). Heading is in radians from +u. A left turn is a
    positive angle. sample() returns points and unit normals (left side).
    """

    def __init__(self, u, v, heading):
        self.segs = []
        self.u, self.v, self.h = u, v, heading
        self.start = (u, v, heading)

    def line(self, length):
        self.segs.append(("L", self.u, self.v, self.h, length))
        self.u += length * math.cos(self.h)
        self.v += length * math.sin(self.h)
        return self

    def arc(self, radius, angle):
        """Turn by angle (radians, + = left) on the given radius."""
        self.segs.append(("A", self.u, self.v, self.h, radius, angle))
        sgn = 1 if angle > 0 else -1
        cu = self.u - sgn * radius * math.sin(self.h)
        cv = self.v + sgn * radius * math.cos(self.h)
        h1 = self.h + angle
        self.u = cu + sgn * radius * math.sin(h1)
        self.v = cv - sgn * radius * math.cos(h1)
        self.h = h1
        return self

    def length(self):
        tot = 0.0
        for s in self.segs:
            tot += s[4] if s[0] == "L" else abs(s[4] * s[5])
        return tot

    def sample(self, step=0.1):
        pts = []
        for s in self.segs:
            if s[0] == "L":
                _, u, v, h, L = s
                n = max(1, int(math.ceil(L / step)))
                for i in range(n):
                    t = L * i / n
                    pts.append((u + t * math.cos(h), v + t * math.sin(h), h))
            else:
                _, u, v, h, R, a = s
                sgn = 1 if a > 0 else -1
                cu = u - sgn * R * math.sin(h)
                cv = v + sgn * R * math.cos(h)
                n = max(2, int(math.ceil(abs(R * a) / step)))
                for i in range(n):
                    hh = h + a * i / n
                    pts.append((cu + sgn * R * math.sin(hh), cv - sgn * R * math.cos(hh), hh))
        pts.append((self.u, self.v, self.h))
        return pts

    def thick(self, t, step=0.1):
        """Closed polygon (list of (u, v)) of the strip of thickness t around the path."""
        s = self.sample(step)
        left = [(u - math.sin(h) * t / 2, v + math.cos(h) * t / 2) for u, v, h in s]
        right = [(u + math.sin(h) * t / 2, v - math.cos(h) * t / 2) for u, v, h in s]
        poly = left + right[::-1]
        # drop consecutive duplicates
        out = [poly[0]]
        for p in poly[1:]:
            if abs(p[0] - out[-1][0]) > 1e-6 or abs(p[1] - out[-1][1]) > 1e-6:
                out.append(p)
        return out
