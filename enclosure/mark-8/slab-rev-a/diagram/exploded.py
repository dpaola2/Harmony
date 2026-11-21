"""Exploded isometric: every part moved along the stacking axis (Z) in assembly
order, shaded with VTK from the STEP solids, with name and overall size labels
and thin dashed lines to where each part goes.

The battery shown is the planned YDL 403450 (34 x 52 x 4.0) at the place
ASSEMBLY.md step 13 gives it, with a simple model of its two leads.
"""
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import cadquery as cq  # noqa: E402
import vtk  # noqa: E402
from vtk.util.numpy_support import vtk_to_numpy  # noqa: E402

import common as C  # noqa: E402
import drawing as D  # noqa: E402
import load  # noqa: E402
import ydl  # noqa: E402


def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))


METAL_REFS = ("J1", "J3", "J2", "SW1", "U1")

# key, label, prefixes, colour
ORDER = [
    ("front_shell", "Front shell", ["front shell"], "#e6e2d8"),
    ("wheel_disc", "Wheel disc", ["wheel disc"], "#3a3a40"),
    ("button_cap", "Side button cap", ["button cap"], "#e6e2d8"),
    ("screen", "Screen with foam", ["screen ", "battery foam"], "#5d6f84"),
    ("fpc", "Screen FPC (routed)", ["FPC "], "#e0a040"),
    ("board", "Main board", ["board "], "#2e7d4f"),
    ("battery", "Battery YDL 403450 with plug", ["YDL", "battery plug", "YDL leads"], "#c9d3e0"),
    ("motor", "Vibration motor", ["motor"], "#9a9aa2"),
    ("inserts", "Heat-set inserts (4)", ["insert "], "#c99a3a"),
    ("back_plate", "Back plate", ["back plate"], "#e6e2d8"),
    ("screws", "Screws M2 x 4 (4)", ["screw "], "#505056"),
]
GAP = 13.0


def solids():
    A = load.assembly()
    S = dict(A)
    S.pop("battery pack", None)
    S.pop("battery wires", None)
    S["YDL"] = ydl.solid(A)
    # two simple leads from the plug's back to the pack's near end (lead exit assumed near J4)
    plug = C.bb(A["battery plug PHR-2"])
    pack = ydl.placement(A)
    leads = None
    for dx in (-0.5, 0.5):
        x0, y0, z0 = (plug[0] + plug[1]) / 2 + dx, plug[3], (plug[4] + plug[5]) / 2
        x1, y1, z1 = -15.0 + dx, pack[2], (pack[4] + pack[5]) / 2
        pts = [cq.Vector(x0, y0, z0), cq.Vector(x0, (y0 + y1) / 2, z0), cq.Vector(x1, (y0 + y1) / 2, z1), cq.Vector(x1, y1, z1)]
        for p, q in zip(pts[:-1], pts[1:]):
            v = q - p
            if v.Length < 1e-6:
                continue
            seg = cq.Solid.makeCylinder(0.45, v.Length, p, v.normalized())
            leads = seg if leads is None else leads.fuse(seg)
        for p in pts[1:-1]:
            leads = leads.fuse(cq.Solid.makeSphere(0.45, p, angleDegrees1=-90, angleDegrees2=90))
    S["YDL leads"] = leads
    return A, S


def members(S, pre):
    return [n for n in S if any(n.startswith(p) for p in pre)]


def offsets(S):
    """Z offset per group: each group sits GAP above (toward -Z) the previous one."""
    offs = {}
    prev_low = None
    for key, _, pre, _ in ORDER:
        ms = members(S, pre)
        zs = [C.bb(S[n]) for n in ms]
        zmin, zmax = min(b[4] for b in zs), max(b[5] for b in zs)
        if prev_low is None:
            off = 0.0
        else:
            off = prev_low - GAP - zmax
        offs[key] = off
        prev_low = zmin + off
    return offs


def polydata(shape, tol=0.05):
    sh = shape if hasattr(shape, "toVtkPolyData") else cq.Shape.cast(shape)
    return sh.toVtkPolyData(tol, 0.3, normals=True)


def actor(pd, rgb, off, spec=0.12):
    m = vtk.vtkPolyDataMapper()
    m.SetInputData(pd)
    m.ScalarVisibilityOff()
    a = vtk.vtkActor()
    a.SetMapper(m)
    p = a.GetProperty()
    p.SetColor(*rgb)
    p.SetAmbient(0.3)
    p.SetDiffuse(0.72)
    p.SetSpecular(spec)
    p.SetSpecularPower(18)
    p.SetInterpolationToPhong()
    a.SetPosition(*off)
    return a


def edges(pd, off, angle=35.0, width=1.4):
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
    a.GetProperty().SetColor(0.12, 0.12, 0.12)
    a.GetProperty().SetLineWidth(width)
    a.SetPosition(*off)
    return a


def dashed(p0, p1, dash=1.6, gap=1.1, width=2.0, rgb=(0.35, 0.35, 0.35)):
    pts = vtk.vtkPoints()
    cells = vtk.vtkCellArray()
    p0, p1 = np.array(p0, float), np.array(p1, float)
    L = np.linalg.norm(p1 - p0)
    u = (p1 - p0) / L
    t = 0.0
    while t < L:
        a = p0 + u * t
        b = p0 + u * min(L, t + dash)
        i = pts.InsertNextPoint(*a)
        j = pts.InsertNextPoint(*b)
        ln = vtk.vtkLine()
        ln.GetPointIds().SetId(0, i)
        ln.GetPointIds().SetId(1, j)
        cells.InsertNextCell(ln)
        t += dash + gap
    pd = vtk.vtkPolyData()
    pd.SetPoints(pts)
    pd.SetLines(cells)
    m = vtk.vtkPolyDataMapper()
    m.SetInputData(pd)
    a = vtk.vtkActor()
    a.SetMapper(m)
    a.GetProperty().SetColor(*rgb)
    a.GetProperty().SetLineWidth(width)
    return a


def render(size=(1500, 2600), el=20.0, az=-14.0):
    A, S = solids()
    offs = offsets(S)
    r = vtk.vtkRenderer()
    r.SetBackground(1, 1, 1)
    r.UseFXAAOn()
    w = vtk.vtkRenderWindow()
    w.SetOffScreenRendering(1)
    w.SetSize(*size)
    w.AddRenderer(r)
    kit = vtk.vtkLightKit()
    kit.SetKeyLightIntensity(0.9)
    kit.AddLightsToRenderer(r)
    group_of = {}
    for key, _, pre, col in ORDER:
        for n in members(S, pre):
            group_of[n] = key
            off = (0, 0, offs[key])
            rgb = hex2rgb(col)
            if key == "board" and n != "board PCB":
                ref = n[6:]
                rgb = (0.70, 0.72, 0.75) if ref.startswith(METAL_REFS) else (0.22, 0.22, 0.24)
                if ref.startswith("J4"):
                    rgb = (0.93, 0.92, 0.88)
            if key == "screen" and n == "battery foam":
                rgb = hex2rgb("#f0d49c")
            if key == "battery" and n == "battery plug PHR-2":
                rgb = (0.95, 0.94, 0.90)
            if key == "battery" and n == "YDL leads":
                rgb = (0.75, 0.15, 0.15)
            pd = polydata(S[n], 0.05 if key != "board" else 0.08)
            r.AddActor(actor(pd, rgb, off))
            if key not in ("board",) or n == "board PCB":
                r.AddActor(edges(pd, off))
    # dashed lines to where each part goes
    lines = []
    sb = C.bb(S["screen body"])
    bosses = [(-24.7, -47.15), (24.7, -47.15), (-24.7, 47.15), (24.7, 47.15)]
    screw_bottom = C.bb(S["screw 1"])[4]
    boss_face = C.bb(S["insert 1"])[4]          # inserts sit flush with the boss faces
    plate_in = C.zspan(S["back plate"], 0.0, 0.0)[0][1]
    for bx, by in bosses:
        lines.append(((bx, by, screw_bottom + offs["screws"]), (bx, by, boss_face)))
    lines.append(((0, -27.75 + 17.0, -1.0 + offs["wheel_disc"]), (0, -27.75 + 17.0, -1.0)))
    lines.append(((0, -27.75 - 17.0, -1.0 + offs["wheel_disc"]), (0, -27.75 - 17.0, -1.0)))
    lines.append(((28.4, -15.6, -4.8 + offs["button_cap"]), (28.4, -15.6, -4.8)))
    for x in (sb[0] + 1.0, sb[1] - 1.0):
        lines.append(((x, sb[3] - 1.0, sb[4] + offs["screen"]), (x, sb[3] - 1.0, sb[4])))
    for hx, hy in ((-12.0, -11.4), (24.6, -40.6)):
        lines.append(((hx, hy, -1.8 + offs["board"]), (hx, hy, -2.4)))
    tb = C.bb(S["FPC tail"])
    lines.append(((tb[0], -39.0, -2.2 + offs["fpc"]), (tb[0], -39.0, -2.2 + offs["board"])))
    pk = C.bb(S["YDL"])
    for x in (pk[0] + 1, pk[1] - 1):
        lines.append(((x, pk[2] + 1, pk[5] + offs["battery"]), (x, pk[2] + 1, C.bb(S["battery foam"])[4] + offs["screen"])))
    pl = C.bb(S["battery plug PHR-2"])
    lines.append((((pl[0] + pl[1]) / 2, (pl[2] + pl[3]) / 2, pl[5] + offs["battery"]),
                  ((pl[0] + pl[1]) / 2, (pl[2] + pl[3]) / 2, -1.8 + offs["board"])))
    mb = C.bb(S["motor"])
    lines.append((((mb[0] + mb[1]) / 2, (mb[2] + mb[3]) / 2, mb[4] + offs["motor"]),
                  ((mb[0] + mb[1]) / 2, (mb[2] + mb[3]) / 2, plate_in + offs["back_plate"])))
    for p0, p1 in lines:
        r.AddActor(dashed(p0, p1))
    # camera: from the back (up = -Z), slightly from the +X side
    cam = r.GetActiveCamera()
    cam.ParallelProjectionOn()
    e, a = math.radians(el), math.radians(az)
    d = np.array([math.cos(e) * math.cos(a), math.cos(e) * math.sin(a), -math.sin(e)])
    r.ResetCamera()
    b = r.ComputeVisiblePropBounds()
    c = np.array([(b[0] + b[1]) / 2, (b[2] + b[3]) / 2, (b[4] + b[5]) / 2])
    cam.SetFocalPoint(*c)
    cam.SetPosition(*(c + d * 600))
    cam.SetViewUp(0, 0, -1)
    up = np.array([0, 0, -1.0])
    right = np.cross(-d, up)
    right /= np.linalg.norm(right)
    upv = np.cross(right, -d)
    pts = [np.array((x, y, z)) for x in b[:2] for y in b[2:4] for z in b[4:]]
    us = [float((p - c) @ right) for p in pts]
    vs = [float((p - c) @ upv) for p in pts]
    aspect = size[0] / size[1]
    half = max((max(vs) - min(vs)) / 2, (max(us) - min(us)) / 2 / aspect) * 1.03
    cc = c + right * (max(us) + min(us)) / 2 + upv * (max(vs) + min(vs)) / 2
    cam.SetFocalPoint(*cc)
    cam.SetPosition(*(cc + d * 600))
    cam.SetParallelScale(half)
    cam.SetClippingRange(1, 3000)
    w.Render()
    f = vtk.vtkWindowToImageFilter()
    f.SetInput(w)
    f.ReadFrontBufferOff()
    f.Update()
    img = f.GetOutput()
    dims = img.GetDimensions()
    arr = vtk_to_numpy(img.GetPointData().GetScalars()).reshape(dims[1], dims[0], -1)[::-1][:, :, :3]

    def project(p):
        co = vtk.vtkCoordinate()
        co.SetCoordinateSystemToWorld()
        co.SetValue(*p)
        x, y = co.GetComputedDoubleDisplayValue(r)
        return x, size[1] - y
    project.keep = (w, r)      # keep the window alive so projections stay valid
    return A, S, offs, arr, project


def labels_and_save(parts_table, stem="exploded-isometric"):
    A, S, offs, img, project = render()
    h, w = img.shape[:2]
    # anchor point per group: a visible point on the part (device coords) moved by its offset
    sb = C.bb(S["screen body"])
    pk = C.bb(S["YDL"])
    anchors = {
        "front_shell": (-29.3, 20.0, -4.0),
        "wheel_disc": (-14.0, -27.75, -1.0),
        "button_cap": (29.8, -15.6, -3.5),
        "screen": (-20.0, 30.0, sb[4]),
        "fpc": (18.6, -39.0, -8.0),
        "board": (-27.2, -30.0, -1.4),
        "battery": (pk[0], 30.0, pk[4]),
        "motor": (-20.0, -34.6, -7.0),
        "inserts": (24.7, 47.15 + 1.6, -6.0),
        "back_plate": (-29.3, 0.0, -9.0),
        "screws": (24.7, 47.15 + 1.75, -9.0),
    }
    by = {r["key"]: r for r in parts_table}
    texts = {}
    for key, lab, pre, col in ORDER:
        num = by["screen" if key == "screen" else key]["item"]
        if key == "screen":
            s_ = by["screen"]["size"]
            fo = by["foam"]["size"]
            txt = (f"{lab}\nscreen {s_[0]:.2f} x {s_[1]:.2f} x {s_[2]:.2f} mm\nfoam {fo[0]:.0f} x {fo[1]:.0f} x {fo[2]:.1f} mm on its back")
        elif key == "battery":
            txt = f"{lab}\npack 34.0 x 52.0 x 4.0 mm (planned)\nplug 4.5 x 2.5 x 4.5 mm, leads 50 mm"
        elif key == "board":
            s_ = by["board"]["size_bare"]
            t = by["board"]["size"]
            txt = f"{lab}\nboard {s_[0]:.1f} x {s_[1]:.1f} x {s_[2]:.1f} mm\nwith parts {t[0]:.2f} x {t[1]:.2f} x {t[2]:.2f} mm"
        elif key in ("inserts", "screws"):
            s_ = by[key]["size_each"]
            txt = f"{lab}\n{s_[0]:.2f} x {s_[1]:.2f} x {s_[2]:.2f} mm each"
        else:
            s_ = by[key]["size"]
            txt = f"{lab}\n{s_[0]:.2f} x {s_[1]:.2f} x {s_[2]:.2f} mm"
        texts[key] = (num, txt)
    fig_w = 10.0
    img_frac = 0.56
    fig_h = fig_w * img_frac * h / w + 1.3
    fig = D.new(fig_w, fig_h)
    ax_rect = [(1 - img_frac) / 2, 0.2 / fig_h, img_frac, img_frac * fig_w * h / w / fig_h]
    ax = fig.add_axes(ax_rect)
    ax.imshow(img, interpolation="antialiased")
    ax.set_xlim(0, w)
    ax.set_ylim(h, 0)
    ax.axis("off")
    # label columns in figure coordinates
    pts = {}
    for key, (num, txt) in texts.items():
        p = anchors[key]
        off = offs[key]
        px, py = project((p[0], p[1], p[2] + off))
        pts[key] = (px, py)
    left = ["front_shell", "screen", "board", "motor", "back_plate", "button_cap"]
    right = [k for k in texts if k not in left]

    def to_fig(px, py):
        fx = ax_rect[0] + ax_rect[2] * px / w
        fy = ax_rect[1] + ax_rect[3] * (1 - py / h)
        return fx, fy

    line_h = 0.46 / fig_h
    for side, keys in (("L", left), ("R", right)):
        items = sorted(keys, key=lambda k: pts[k][1])
        ys = []
        for k in items:
            fx, fy = to_fig(*pts[k])
            ys.append(fy)
        # push labels apart (top to bottom in figure: decreasing fy)
        n_lines = [texts[k][1].count("\n") + 1 for k in items]
        for i in range(1, len(ys)):
            need = (n_lines[i - 1] + n_lines[i]) / 2 * line_h + 0.012
            ys[i] = min(ys[i], ys[i - 1] - need)
        for k, fy in zip(items, ys):
            num, txt = texts[k]
            fx, fyp = to_fig(*pts[k])
            lx = 0.015 if side == "L" else 0.985
            ha = "left" if side == "L" else "right"
            first, rest = txt.split("\n", 1)
            fig.text(lx, fy + 0.25 * line_h, f"{num}  {first}", fontsize=10, fontweight="bold", ha=ha, va="bottom", color=D.INK)
            fig.text(lx, fy + 0.1 * line_h, rest, fontsize=9, ha=ha, va="top", color=D.INK, linespacing=1.25)
            ex = (ax_rect[0] - 0.005) if side == "L" else (ax_rect[0] + ax_rect[2] + 0.005)
            ex = min(ex, fx) if side == "L" else max(ex, fx)
            fig.add_artist(matplotlib_line([lx + (0.205 if side == "L" else -0.205), ex, fx], [fy + 0.2 * line_h, fy + 0.2 * line_h, fyp]))
            fig.add_artist(matplotlib_dot(fx, fyp))
    D.title(fig, "Harmony Mark-8 slab rev A: exploded view",
            "Parts move along the stacking axis in assembly order, back of the device up. Sizes are overall X x Y x Z from the STEP solids, mm. "
            "Dashed lines show where each part goes. The battery is the planned YDL 403450 on 0.5 foam.")
    return D.save(fig, stem, dpi=170)


def matplotlib_line(xs, ys):
    from matplotlib.lines import Line2D
    import matplotlib.pyplot as plt
    ln = Line2D(xs, ys, color=D.MUTED, lw=0.6)
    ln.set_transform(plt.gcf().transFigure)
    return ln


def matplotlib_dot(x, y):
    from matplotlib.lines import Line2D
    import matplotlib.pyplot as plt
    ln = Line2D([x], [y], marker="o", ms=2.5, color=D.INK, lw=0)
    ln.set_transform(plt.gcf().transFigure)
    return ln


if __name__ == "__main__":
    import json
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    print(labels_and_save(m["parts"]))
