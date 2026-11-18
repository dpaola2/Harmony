"""Renders from the real CAD: VTK for shaded views, matplotlib for callouts and
the section. Every image is at least 1600 px wide."""
import math
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import vtk  # noqa: E402
from matplotlib.patches import PathPatch  # noqa: E402
from matplotlib.path import Path as MPath  # noqa: E402
from vtk.util.numpy_support import vtk_to_numpy  # noqa: E402

import cadquery as cq  # noqa: E402

_TESS = {}


def polydata(shape, tol=0.03, ang=0.2):
    key = (id(shape), tol)
    if key not in _TESS:
        _TESS[key] = (shape, shape.toVtkPolyData(tol, ang, normals=True))
    return _TESS[key][1]


def _actor(pd, color, opacity=1.0, offset=(0, 0, 0), specular=0.15):
    m = vtk.vtkPolyDataMapper()
    m.SetInputData(pd)
    m.ScalarVisibilityOff()
    a = vtk.vtkActor()
    a.SetMapper(m)
    p = a.GetProperty()
    p.SetColor(*color)
    p.SetOpacity(opacity)
    p.SetAmbient(0.25)
    p.SetDiffuse(0.75)
    p.SetSpecular(specular)
    p.SetSpecularPower(20)
    p.SetInterpolationToPhong()
    a.SetPosition(*offset)
    return a


def _edges(pd, offset=(0, 0, 0), color=(0.15, 0.15, 0.15), angle=40.0, width=1.2):
    fe = vtk.vtkFeatureEdges()
    fe.SetInputData(pd)
    fe.SetFeatureAngle(angle)
    fe.BoundaryEdgesOn()
    fe.FeatureEdgesOn()
    fe.ManifoldEdgesOff()
    fe.NonManifoldEdgesOff()
    fe.ColoringOff()
    m = vtk.vtkPolyDataMapper()
    m.SetInputConnection(fe.GetOutputPort())
    m.ScalarVisibilityOff()
    m.SetResolveCoincidentTopologyToPolygonOffset()
    a = vtk.vtkActor()
    a.SetMapper(m)
    a.GetProperty().SetColor(*color)
    a.GetProperty().SetLineWidth(width)
    a.SetPosition(*offset)
    return a


class Scene:
    def __init__(self, size=(2400, 1800)):
        self.r = vtk.vtkRenderer()
        self.r.SetBackground(1, 1, 1)
        self.r.UseFXAAOn()
        self.w = vtk.vtkRenderWindow()
        self.w.SetOffScreenRendering(1)
        self.w.SetSize(*size)
        self.w.AddRenderer(self.r)
        kit = vtk.vtkLightKit()
        kit.SetKeyLightIntensity(0.85)
        kit.AddLightsToRenderer(self.r)
        self.size = size

    def add(self, shape, color, opacity=1.0, offset=(0, 0, 0), edges=True, tol=0.03, edge_angle=40.0):
        pd = polydata(shape, tol)
        self.r.AddActor(_actor(pd, color, opacity, offset))
        if edges:
            self.r.AddActor(_edges(pd, offset, angle=edge_angle))

    def camera(self, direction, up, focal=None, scale=None, pad=1.08):
        cam = self.r.GetActiveCamera()
        cam.ParallelProjectionOn()
        d = np.array(direction, float)
        d /= np.linalg.norm(d)
        self.r.ResetCamera()
        b = self.r.ComputeVisiblePropBounds()
        c = np.array([(b[0] + b[1]) / 2, (b[2] + b[3]) / 2, (b[4] + b[5]) / 2]) if focal is None else np.array(focal)
        cam.SetFocalPoint(*c)
        cam.SetPosition(*(c + d * 500))
        cam.SetViewUp(*up)
        cam.SetClippingRange(1, 2000)
        if scale is None:
            # fit the visible bounds
            self.r.ResetCamera()
            cam.SetFocalPoint(*c)
            cam.SetPosition(*(c + d * 500))
            cam.SetViewUp(*up)
            pts = [(x, y, z) for x in b[:2] for y in b[2:4] for z in b[4:]]
            self.r.ResetCameraClippingRange()
            uv = [self._view_uv(p) for p in pts]
            us = [p[0] for p in uv]
            vs = [p[1] for p in uv]
            aspect = self.size[0] / self.size[1]
            half_h = max((max(vs) - min(vs)) / 2, (max(us) - min(us)) / 2 / aspect) * pad
            cam.SetParallelScale(half_h)
            # recentre on the projected box
            cu, cv = (max(us) + min(us)) / 2, (max(vs) + min(vs)) / 2
            right, upv = self._basis()
            c2 = c + right * cu + upv * cv
            cam.SetFocalPoint(*c2)
            cam.SetPosition(*(c2 + d * 500))
        else:
            cam.SetParallelScale(scale)
        cam.SetClippingRange(1, 2000)

    def _basis(self):
        cam = self.r.GetActiveCamera()
        d = np.array(cam.GetDirectionOfProjection())
        up = np.array(cam.GetViewUp())
        right = np.cross(d, up)
        right /= np.linalg.norm(right)
        upv = np.cross(right, d)
        return right, upv

    def _view_uv(self, p):
        cam = self.r.GetActiveCamera()
        f = np.array(cam.GetFocalPoint())
        right, upv = self._basis()
        q = np.array(p) - f
        return float(q @ right), float(q @ upv)

    def project(self, p):
        """World point to image pixel (x right, y down)."""
        coord = vtk.vtkCoordinate()
        coord.SetCoordinateSystemToWorld()
        coord.SetValue(*p)
        x, y = coord.GetComputedDoubleDisplayValue(self.r)
        return x, self.size[1] - y

    def save(self, path):
        self.w.Render()
        f = vtk.vtkWindowToImageFilter()
        f.SetInput(self.w)
        f.ReadFrontBufferOff()
        f.Update()
        img = f.GetOutput()
        dims = img.GetDimensions()
        arr = vtk_to_numpy(img.GetPointData().GetScalars()).reshape(dims[1], dims[0], -1)[::-1]
        plt.imsave(path, arr[:, :, :3])
        return arr[:, :, :3]


def callouts(img, anchors, out_base, title=None, table=None, label_side=None):
    """Draw numbered callouts. anchors: list of (number, (px, py)).
    Labels go to the nearer side margin, spaced to avoid overlaps."""
    h, w = img.shape[:2]
    dpi = 200
    fig = plt.figure(figsize=(w / dpi, h / dpi), dpi=dpi)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.imshow(img)
    ax.set_xlim(0, w)
    ax.set_ylim(h, 0)
    ax.axis("off")
    left, right = [], []
    for n, (px, py) in anchors:
        side = label_side.get(n) if label_side else None
        if side is None:
            side = "L" if px < w / 2 else "R"
        (left if side == "L" else right).append([n, px, py])
    gap = 0.045 * h
    for group, lx in ((left, 0.05 * w), (right, 0.95 * w)):
        group.sort(key=lambda a: a[2])
        ys = [a[2] for a in group]
        for i in range(1, len(ys)):
            ys[i] = max(ys[i], ys[i - 1] + gap)
        # pull back up if we ran off the bottom
        over = (ys[-1] - 0.95 * h) if ys else 0
        if over > 0:
            ys = [y - over for y in ys]
            for i in range(len(ys) - 2, -1, -1):
                ys[i] = min(ys[i], ys[i + 1] - gap)
        for (n, px, py), ly in zip(group, ys):
            ax.plot([lx, px], [ly, py], color="#222222", lw=1.0)
            ax.plot([px], [py], "o", color="#222222", ms=3)
            ax.text(lx, ly, str(n), ha="center", va="center", fontsize=11, fontweight="bold",
                    bbox=dict(boxstyle="circle,pad=0.3", fc="white", ec="#222222", lw=1.2))
    if title:
        ax.text(0.5 * w, 0.03 * h, title, ha="center", va="center", fontsize=12)
    fig.savefig(out_base + ".png", dpi=dpi)
    fig.savefig(out_base + ".svg")
    plt.close(fig)


# ------------------------------------------------------------------ section
def section_faces(shape, x):
    """Faces of the cut of shape by the plane X = x, as (triangles, edge polylines)
    in (y, z)."""
    plane = cq.Face.makePlane(400, 400, cq.Vector(x, 0, 0), cq.Vector(1, 0, 0))
    try:
        sec = shape.intersect(plane)
    except Exception:  # noqa: BLE001
        return [], []
    tris, lines = [], []
    for f in sec.Faces():
        try:
            v, t = f.tessellate(0.01, 0.1)
        except Exception:  # noqa: BLE001
            continue
        pts = [(p.y, p.z) for p in v]
        tris += [[pts[a], pts[b], pts[c]] for a, b, c in t]
        for e in f.Edges():
            n = max(2, int(e.Length() / 0.05))
            lines.append([(e.positionAt(i / n).y, e.positionAt(i / n).z) for i in range(n + 1)])
    return tris, lines
