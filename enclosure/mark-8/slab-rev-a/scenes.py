"""The diagrams: exploded isometric, exploded section, assembled views and
close-ups. All geometry comes from model.build()."""
import os

import numpy as np

import model
import params as P
import render

# Explode offsets in device coordinates. The case is assembled face down, so
# parts stack toward -Z ("up" on the bench).
EXPLODE = {1: (0, 0, 0), 2: (0, 0, -14), 3: (16, 0, 0), 4: (0, 0, -14), 5: (0, 0, -34),
           6: (0, 0, -78), 7: (0, 0, -56), 8: (0, 0, -98), 9: (0, 0, -98), 10: (0, 0, -130), 11: (0, 0, -146)}
SECTION_DZ = {1: 0, 2: -5, 5: -11, 7: -18, 6: -26, 8: -34, 10: -43}
SECTION_X = -3.4

ANCHORS = {
    1: (-10.0, -51.75, -5.0),
    2: (-12.0, -36.0, -1.0),
    3: (29.8, -15.6, -3.5),
    4: (-24.7, -47.15, -7.7),
    5: (22.0, 30.0, -3.15),
    6: (18.6, -39.0, -7.9),
    7: (-18.0, -30.0, -1.8),
    8: (20.0, 14.0, -6.3),
    9: (-20.0, -39.5, -5.9),
    10: (-22.0, -5.0, -9.5),
    11: (-24.7, -47.15, -9.5),
}


METAL = ("board J1", "board J3", "board J2")


def _color(item, name=None):
    if name is not None and item == 7 and name != "board PCB":
        return (0.72, 0.72, 0.74) if name.startswith(METAL) else (0.24, 0.24, 0.26)
    return model.ITEM[item][2]


def _edges(it):
    return it["group"] in ("printed", "battery", "motor", "screen", "hardware")


def render_all(solids, meta, outdir):
    os.makedirs(outdir, exist_ok=True)
    exploded_iso(solids, outdir)
    exploded_section(solids, outdir)
    assembled(solids, outdir)
    closeups(solids, outdir)


def exploded_iso(solids, outdir):
    s = render.Scene((2400, 3300))
    for it in solids:
        off = EXPLODE[it["item"]]
        s.add(it["shape"], _color(it["item"], it["name"]), offset=off, edges=_edges(it), tol=0.04)
    el, az = np.radians(30), np.radians(-55)
    d = (np.cos(el) * np.cos(az), np.cos(el) * np.sin(az), -np.sin(el))
    s.camera(d, (0, 0, -1), pad=1.12)
    img = s.save(os.path.join(outdir, "_raw_exploded_iso.png"))
    anchors = []
    for n, p in ANCHORS.items():
        off = EXPLODE[n]
        anchors.append((n, s.project((p[0] + off[0], p[1] + off[1], p[2] + off[2]))))
    render.callouts(img, anchors, os.path.join(outdir, "exploded-isometric"),
                    title="Harmony Mark-8 slab rev A, exploded. The case lies face down; parts go in from above in number order.")
    os.remove(os.path.join(outdir, "_raw_exploded_iso.png"))


def exploded_section(solids, outdir):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.collections import LineCollection, PolyCollection

    groups = {}
    for it in solids:
        n = it["item"]
        if n not in SECTION_DZ:
            continue
        b = it["shape"].BoundingBox()
        if not (b.xmin - 0.01 <= SECTION_X <= b.xmax + 0.01):
            continue
        tris, lines = render.section_faces(it["shape"], SECTION_X)
        if tris:
            g = groups.setdefault((n, _color(n, it["name"])), [[], [], it])
            g[0] += tris
            g[1] += lines

    def draw(ax, explode, lw):
        for (n, col), (tris, lines, it) in groups.items():
            dz = SECTION_DZ[n] if explode else 0
            tt = [[(y, -(z + dz)) for y, z in t] for t in tris]
            ll = [[(y, -(z + dz)) for y, z in ln] for ln in lines]
            ax.add_collection(PolyCollection(tt, facecolors=[col], edgecolors=[col], linewidths=0.25))
            ax.add_collection(LineCollection(ll, colors="#1a1a1a", linewidths=lw))
        ax.set_aspect("equal")
        ax.set_yticks([])
        for sname in ("top", "right", "left"):
            ax.spines[sname].set_visible(False)

    fig = plt.figure(figsize=(16, 15.5), dpi=150)
    ax = fig.add_axes([0.03, 0.36, 0.90, 0.60])
    draw(ax, True, 0.5)
    ax.set_xlim(-54, 54)
    ax.set_ylim(-2, 54)
    ax.set_title(f"Exploded section at x = {SECTION_X} (through press post PP2, the buzzer, J2 and the USB-C receptacle), "
                 "seen from the left side.\nFront skin at the bottom, back plate on top, as on the bench.", fontsize=11)
    # callouts: a dotted line from a point on the part to a number on the right
    pts = {1: (-47, -0.5), 2: (-20, -0.5), 5: (20, -2.0), 7: (-35, -1.4), 6: (-12.6, -5.0),
           8: (30, -6.3), 10: (-40, -8.9)}
    present = {k[0] for k in groups}
    for n, (y, z) in pts.items():
        if n not in present:
            continue
        zz = -(z + SECTION_DZ[n])
        ax.plot([y, 55.5], [zz, zz], color="#666666", lw=0.7, ls=":")
        ax.plot([y], [zz], "o", color="#222222", ms=3)
        ax.text(56.5, zz, str(n), ha="left", va="center", fontsize=12, fontweight="bold", clip_on=False,
                bbox=dict(boxstyle="circle,pad=0.3", fc="white", ec="#222222", lw=1.2))
    ax.set_xlabel("device y (mm): bottom edge with the USB-C opening on the left, screen end on the right")
    ax2 = fig.add_axes([0.03, 0.05, 0.90, 0.25])
    draw(ax2, False, 0.4)
    ax2.set_xlim(-53, -5)
    ax2.set_ylim(-0.3, 10.0)
    ax2.set_title("Same cut, assembled, bottom half enlarged: skin 1.0 with the disc set in it, board 0.8, parts, "
                  "FPC tail in its channel, back plate 1.2 with press post PP2", fontsize=10)
    ax2.set_xlabel("device y (mm)")
    fig.savefig(os.path.join(outdir, "exploded-section.png"), dpi=150)
    fig.savefig(os.path.join(outdir, "exploded-section.svg"))
    plt.close(fig)


def _scene(solids, skip_items=(), skip_names=(), size=(2400, 1800), tol=0.03, edges=True):
    s = render.Scene(size)
    for it in solids:
        if it["item"] in skip_items or it["name"] in skip_names:
            continue
        s.add(it["shape"], _color(it["item"], it["name"]), edges=edges and _edges(it), tol=tol)
    return s


def assembled(solids, outdir):
    s = _scene(solids)
    s.camera((0.42, -0.55, 1.35), (0, 1, 0), pad=1.06)
    s.save(os.path.join(outdir, "assembled-front.png"))
    s = _scene(solids)
    s.camera((-0.42, -0.55, -1.35), (0, 1, 0), pad=1.06)
    s.save(os.path.join(outdir, "assembled-back.png"))


def closeups(solids, outdir):
    # USB-C and microSD openings, from below the bottom edge.
    s = _scene(solids, size=(2400, 1500))
    s.camera((0.18, -1.0, 0.32), (0, 0, 1), focal=(-6.5, -51.75, -4.6), scale=11)
    s.save(os.path.join(outdir, "closeup-usb-microsd.png"))
    # Same, back plate off, to show the receptacle and the card socket in the wall.
    s = _scene(solids, skip_items=(10, 11), size=(2400, 1500))
    s.camera((0.25, -0.8, -0.9), (0, 0, -1), focal=(-6.5, -49.5, -4.5), scale=11)
    s.save(os.path.join(outdir, "closeup-usb-microsd-inside.png"))
    # FPC fold: back plate, battery and motor off, seen from the back.
    s = _scene(solids, skip_items=(8, 9, 10, 11), size=(2400, 1800))
    s.camera((0.35, -0.45, -1.0), (0, 1, 0), focal=(3.0, -28.0, -5.0), scale=26)
    s.save(os.path.join(outdir, "closeup-fpc-fold.png"))
    # Side button cap from outside.
    s = _scene(solids, size=(2000, 1400))
    s.camera((1.0, -0.35, 0.45), (0, 0, 1), focal=(29.3, -15.6, -4.0), scale=7)
    s.save(os.path.join(outdir, "closeup-side-button.png"))
