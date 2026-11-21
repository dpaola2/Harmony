"""Exact geometry helpers on OCP shapes: distances, overlaps, ray probes, sections."""
import math

import cadquery as cq
from OCP.BRepAlgoAPI import BRepAlgoAPI_Common
from OCP.BRepClass3d import BRepClass3d_SolidClassifier
from OCP.BRepExtrema import BRepExtrema_DistShapeShape
from OCP.GProp import GProp_GProps
from OCP.BRepGProp import BRepGProp
from OCP.gp import gp_Dir, gp_Lin, gp_Pnt
from OCP.IntCurvesFace import IntCurvesFace_ShapeIntersector
from OCP.TopAbs import TopAbs_IN, TopAbs_ON, TopAbs_REVERSED

V = cq.Vector


def w(s):
    return s.wrapped if hasattr(s, "wrapped") else s


def bb(s):
    b = cq.Shape.cast(w(s)).BoundingBox() if not hasattr(s, "BoundingBox") else s.BoundingBox()
    return (b.xmin, b.xmax, b.ymin, b.ymax, b.zmin, b.zmax)


def bb_gap(a, b):
    dx = max(0.0, max(a[0], b[0]) - min(a[1], b[1]))
    dy = max(0.0, max(a[2], b[2]) - min(a[3], b[3]))
    dz = max(0.0, max(a[4], b[4]) - min(a[5], b[5]))
    return math.sqrt(dx * dx + dy * dy + dz * dz)


def dist(a, b):
    """Exact minimum distance between two shapes, with the two witness points."""
    d = BRepExtrema_DistShapeShape(w(a), w(b))
    d.Perform()
    if not d.IsDone() or d.NbSolution() == 0:
        return None, None, None
    p, q = d.PointOnShape1(1), d.PointOnShape2(1)
    return d.Value(), (p.X(), p.Y(), p.Z()), (q.X(), q.Y(), q.Z())


def volume(s):
    g = GProp_GProps()
    BRepGProp.VolumeProperties_s(w(s), g)
    return g.Mass()


def common(a, b):
    """(volume, cq.Shape or None) of the common part of two solids."""
    op = BRepAlgoAPI_Common(w(a), w(b))
    op.Build()
    if not op.IsDone():
        return None, None
    sh = op.Shape()
    v = volume(sh)
    return v, cq.Shape.cast(sh)


def inside(shape, p, tol=1e-6):
    c = BRepClass3d_SolidClassifier(w(shape), gp_Pnt(*p), tol)
    return c.State() == TopAbs_IN


def ray(shape, origin, direction, tmin=-200.0, tmax=200.0):
    """Material intervals of `shape` along the line origin + t*direction.
    Returns a list of (t0, t1) with t measured along the unit direction."""
    d = list(direction)
    n = math.sqrt(sum(v * v for v in d))
    d = [v / n for v in d]
    lin = gp_Lin(gp_Pnt(*origin), gp_Dir(*d))
    hits = []
    shp = w(shape)
    from OCP.TopExp import TopExp_Explorer
    from OCP.TopAbs import TopAbs_SOLID
    ex = TopExp_Explorer(shp, TopAbs_SOLID)
    solids = []
    while ex.More():
        solids.append(ex.Current())
        ex.Next()
    if not solids:
        solids = [shp]
    out = []
    for so in solids:
        it = IntCurvesFace_ShapeIntersector()
        it.Load(so, 1e-7)
        it.Perform(lin, tmin, tmax)
        ts = sorted([tmin, tmax] + [it.WParameter(i + 1) for i in range(it.NbPnt())])
        uniq = []
        for t in ts:
            if not uniq or t - uniq[-1] > 1e-6:
                uniq.append(t)
        for t0, t1 in zip(uniq[:-1], uniq[1:]):
            m = (t0 + t1) / 2
            p = (origin[0] + d[0] * m, origin[1] + d[1] * m, origin[2] + d[2] * m)
            c = BRepClass3d_SolidClassifier(so, gp_Pnt(*p), 1e-7)
            if c.State() == TopAbs_IN:
                out.append((t0, t1))
    out.sort()
    merged = []
    for a, b_ in out:
        if merged and a <= merged[-1][1] + 1e-6:
            merged[-1] = (merged[-1][0], max(merged[-1][1], b_))
        else:
            merged.append((a, b_))
    return merged


def zspan(shape, x, y):
    """Material intervals along Z at (x, y), as (z0, z1) ascending."""
    return [(-50.0 + a, -50.0 + b_) for a, b_ in ray(shape, (x, y, -50.0), (0, 0, 1), 0.0, 100.0)]


def xspan(shape, y, z):
    return [(-100.0 + a, -100.0 + b_) for a, b_ in ray(shape, (-100.0, y, z), (1, 0, 0), 0.0, 200.0)]


def yspan(shape, x, z):
    return [(-100.0 + a, -100.0 + b_) for a, b_ in ray(shape, (x, -100.0, z), (0, 1, 0), 0.0, 200.0)]


def section(shape, axis, value, step=0.04):
    """Cut of `shape` by the plane axis = value (axis 'x', 'y' or 'z').
    Returns a list of faces; each face is a list of loops (outer loop first,
    then holes) in the plane coordinates: x-cut -> (y, z), y-cut -> (x, z),
    z-cut -> (x, y)."""
    n = {"x": (1, 0, 0), "y": (0, 1, 0), "z": (0, 0, 1)}[axis]
    o = [0.0, 0.0, 0.0]
    o["xyz".index(axis)] = value
    plane = cq.Face.makePlane(600, 600, V(*o), V(*n))
    s = shape if hasattr(shape, "intersect") else cq.Shape.cast(shape)
    try:
        sec = s.intersect(plane)
    except Exception:  # noqa: BLE001
        return []
    ia, ib = {"x": (1, 2), "y": (0, 2), "z": (0, 1)}[axis]
    faces = []
    for f in sec.Faces():
        loops = []
        for wire in [f.outerWire()] + f.innerWires():
            pts = []
            for e in _ordered_edges(wire):
                L = e.Length()
                k = 1 if e.geomType() == "LINE" else max(2, int(L / step))
                ps = [e.positionAt(i / k).toTuple() for i in range(k + 1)]
                ps = [(p[ia], p[ib]) for p in ps]
                # follow the edge's orientation in the wire
                if e.wrapped.Orientation() == TopAbs_REVERSED:
                    ps = ps[::-1]
                if pts and math.dist(pts[-1], ps[-1]) + 1e-6 < math.dist(pts[-1], ps[0]):
                    ps = ps[::-1]
                for pt in ps:
                    if not pts or math.dist(pts[-1], pt) > 1e-7:
                        pts.append(pt)
            if len(pts) >= 3:
                loops.append(pts)
        if loops:
            faces.append(loops)
    return faces


def _ordered_edges(wire):
    from OCP.BRepTools import BRepTools_WireExplorer
    from OCP.TopoDS import TopoDS
    ex = BRepTools_WireExplorer(TopoDS.Wire_s(wire.wrapped))
    out = []
    while ex.More():
        out.append(cq.Edge(ex.Current()))
        ex.Next()
    return out


def size(shape):
    b = bb(shape)
    return (b[1] - b[0], b[3] - b[2], b[5] - b[4])
