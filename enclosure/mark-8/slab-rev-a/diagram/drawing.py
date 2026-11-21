"""Drawing helpers: matplotlib on a white page, dark outlines, one accent colour
for dimensions. All coordinates are device millimetres."""
import math
import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.patches import PathPatch, Rectangle  # noqa: E402
from matplotlib.path import Path  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))

INK = "#1a1a1a"
ACC = "#0a5fd6"          # dimensions only
MUTED = "#5a5a5a"
PAGE = "#ffffff"

FILL = {
    "printed": "#ebe8e1",
    "disc": "#4a4a50",
    "pcb": "#9cc7a8",
    "part": "#c3c3c9",
    "metal": "#a9b1ba",
    "screen": "#b8c8d8",
    "glass": "#d6e2ee",
    "fpc": "#e9b25c",
    "battery": "#d3d8df",
    "planned": "#cfe0f5",
    "foam": "#f3dfb4",
    "plug": "#f7f6f0",
    "motor": "#b3b3ba",
    "brass": "#d8b35c",
    "screw": "#6a6a70",
    "card": "#f0f0f0",
    "keepout": "#ffffff",
}

plt.rcParams.update({
    "font.family": ["Arial", "Helvetica", "DejaVu Sans"],
    "font.size": 9,
    "svg.fonttype": "none",
    "axes.edgecolor": INK,
    "savefig.facecolor": PAGE,
    "figure.facecolor": PAGE,
    "axes.facecolor": PAGE,
})

FS_DIM = 8.5      # dimension numbers
FS_LABEL = 9      # part labels
FS_TITLE = 12
FS_NOTE = 8.5


def new(w_in, h_in):
    return plt.figure(figsize=(w_in, h_in))


def panel(fig, rect, xlim, ylim, title=None, xlabel=None, ylabel=None, frame=False):
    ax = fig.add_axes(rect)
    ax.set_xlim(*xlim)
    ax.set_ylim(*ylim)
    ax.set_aspect("equal", adjustable="box")
    for s in ax.spines.values():
        s.set_visible(frame)
        s.set_color("#bbbbbb")
        s.set_linewidth(0.6)
    ax.set_xticks([])
    ax.set_yticks([])
    if title:
        ax.set_title(title, fontsize=10, loc="left", color=INK, pad=4)
    if xlabel:
        ax.set_xlabel(xlabel, fontsize=8, color=MUTED)
    if ylabel:
        ax.set_ylabel(ylabel, fontsize=8, color=MUTED)
    return ax


def _signed_area(L):
    return 0.5 * sum(L[i][0] * L[(i + 1) % len(L)][1] - L[(i + 1) % len(L)][0] * L[i][1] for i in range(len(L)))


def face_path(loops):
    verts, codes = [], []
    for k, L in enumerate(loops):
        a = _signed_area(L)
        if (k == 0 and a < 0) or (k > 0 and a > 0):
            L = L[::-1]
        verts += list(L) + [L[0]]
        codes += [Path.MOVETO] + [Path.LINETO] * (len(L) - 1) + [Path.CLOSEPOLY]
    return Path(verts, codes)


def fill_faces(ax, faces, fc, ec=INK, lw=0.7, z=2, hatch=None, alpha=1.0, ls="-"):
    for loops in faces:
        p = face_path(loops)
        ax.add_patch(PathPatch(p, facecolor=fc, edgecolor=ec, lw=lw, zorder=z, hatch=hatch, alpha=alpha,
                               linestyle=ls, joinstyle="round"))


def rect(ax, x0, y0, x1, y1, fc="none", ec=INK, lw=0.7, z=3, ls="-", hatch=None, alpha=1.0):
    ax.add_patch(Rectangle((x0, y0), x1 - x0, y1 - y0, facecolor=fc, edgecolor=ec, lw=lw, zorder=z, linestyle=ls,
                           hatch=hatch, alpha=alpha))


def _arrow(ax, p, q, both=True, lw=0.8, z=8):
    ax.annotate("", xy=q, xytext=p, zorder=z,
                arrowprops=dict(arrowstyle="<|-|>" if both else "-|>", color=ACC, lw=lw, shrinkA=0, shrinkB=0,
                                mutation_scale=7))


def fmt(v, nd=2):
    if v is None:
        return "?"
    s = f"{v:.{nd}f}"
    return s


def dim(ax, p, q, text, off=0.0, orient="h", tpos=0.5, tside=1, ext=True, fs=FS_DIM, inside=None, toff=None, z=8):
    """Linear dimension between points p and q.
    orient 'h': measures along x; the dimension line is `off` above the higher point (below the lower one if off < 0).
    orient 'v': measures along y; the line is `off` right of the rightmost point (left of the leftmost if off < 0).
    Text sits beside the line (tside +1 above or right, -1 below or left)."""
    (px, py), (qx, qy) = p, q
    if orient == "h":
        yl = (max(py, qy) + off) if off >= 0 else (min(py, qy) + off)
        if ext:
            ax.plot([px, px], [py, yl], color=ACC, lw=0.45, zorder=z)
            ax.plot([qx, qx], [qy, yl], color=ACC, lw=0.45, zorder=z)
        _arrow(ax, (px, yl), (qx, yl), z=z)
        tx = px + (qx - px) * tpos
        if toff is None:
            toff = 0.0
        ax.text(tx, yl + toff, text, ha="center", va="bottom" if tside > 0 else "top", fontsize=fs, color=ACC, zorder=z + 1,
                bbox=dict(boxstyle="square,pad=0.08", fc=PAGE, ec="none", alpha=0.85))
    else:
        xl = (max(px, qx) + off) if off >= 0 else (min(px, qx) + off)
        if ext:
            ax.plot([px, xl], [py, py], color=ACC, lw=0.45, zorder=z)
            ax.plot([qx, xl], [qy, qy], color=ACC, lw=0.45, zorder=z)
        _arrow(ax, (xl, py), (xl, qy), z=z)
        ty = py + (qy - py) * tpos
        if toff is None:
            toff = 0.0
        ax.text(xl + toff, ty, text, ha="left" if tside > 0 else "right", va="center", fontsize=fs, color=ACC, zorder=z + 1,
                rotation=0, bbox=dict(boxstyle="square,pad=0.08", fc=PAGE, ec="none", alpha=0.85))


def gap(ax, a, b, at, text, orient="h", arm=None, tx=None, ty=None, fs=FS_DIM, ha="left", va="center", z=9):
    """Small gap between coordinates a < b along x (orient 'h') or y ('v'),
    drawn with two arrows from outside pointing in, at the other coordinate
    `at`. Text at (tx, ty) with a thin leader if given."""
    span = abs(b - a)
    arm = arm if arm is not None else max(0.6, span * 1.5)
    if orient == "h":
        ax.annotate("", xy=(a, at), xytext=(a - arm, at), zorder=z,
                    arrowprops=dict(arrowstyle="-|>", color=ACC, lw=0.8, shrinkA=0, shrinkB=0, mutation_scale=7))
        ax.annotate("", xy=(b, at), xytext=(b + arm, at), zorder=z,
                    arrowprops=dict(arrowstyle="-|>", color=ACC, lw=0.8, shrinkA=0, shrinkB=0, mutation_scale=7))
        ax.plot([a, b], [at, at], color=ACC, lw=0.8, zorder=z)
        cx, cy = (a + b) / 2, at
    else:
        ax.annotate("", xy=(at, a), xytext=(at, a - arm), zorder=z,
                    arrowprops=dict(arrowstyle="-|>", color=ACC, lw=0.8, shrinkA=0, shrinkB=0, mutation_scale=7))
        ax.annotate("", xy=(at, b), xytext=(at, b + arm), zorder=z,
                    arrowprops=dict(arrowstyle="-|>", color=ACC, lw=0.8, shrinkA=0, shrinkB=0, mutation_scale=7))
        ax.plot([at, at], [a, b], color=ACC, lw=0.8, zorder=z)
        cx, cy = at, (a + b) / 2
    if tx is None:
        tx, ty = (cx + arm + 0.2, cy) if orient == "h" else (cx + 0.2, cy + arm + 0.2)
    else:
        ax.plot([cx, tx], [cy, ty], color=ACC, lw=0.45, zorder=z)
    ax.text(tx, ty, text, fontsize=fs, color=ACC, ha=ha, va=va, zorder=z + 1,
            bbox=dict(boxstyle="square,pad=0.1", fc=PAGE, ec="none", alpha=0.9))


def zline(ax, z, x0, x1, text=None, side="right", fs=FS_DIM):
    """Level marker: a short accent tick line with its value."""
    ax.plot([x0, x1], [z, z], color=ACC, lw=0.5, ls=(0, (4, 2)), zorder=7)
    if text:
        ax.text(x1 + 0.15 if side == "right" else x0 - 0.15, z, text, fontsize=fs, color=ACC,
                ha="left" if side == "right" else "right", va="center", zorder=9,
                bbox=dict(boxstyle="square,pad=0.08", fc=PAGE, ec="none", alpha=0.85))


def label(ax, xy, text, xytext, fs=FS_LABEL, ha="left", va="center", color=INK, z=10, bold=False):
    ax.annotate(text, xy=xy, xytext=xytext, fontsize=fs, color=color, ha=ha, va=va, zorder=z,
                fontweight="bold" if bold else "normal",
                arrowprops=dict(arrowstyle="-", color=MUTED, lw=0.5, shrinkA=1, shrinkB=0),
                bbox=dict(boxstyle="square,pad=0.12", fc=PAGE, ec="none", alpha=0.9))


def note(fig, x, y, text, fs=FS_NOTE, ha="left", va="top", color=INK, width=None, **kw):
    import textwrap
    if width:
        text = "\n".join(textwrap.fill(p, width) for p in text.split("\n"))
    fig.text(x, y, text, fontsize=fs, ha=ha, va=va, color=color, **kw)


def title(fig, text, sub=None):
    fig.text(0.03, 0.985, text, fontsize=FS_TITLE, fontweight="bold", ha="left", va="top", color=INK)
    if sub:
        import textwrap
        fig.text(0.03, 0.985 - 0.022 * (1 + 0.0), "\n".join(textwrap.wrap(sub, 120)), fontsize=8.5, ha="left", va="top", color=MUTED)


def scale_bar(ax, x, y, length=1.0, text=None):
    ax.plot([x, x + length], [y, y], color=INK, lw=1.2, zorder=9)
    ax.plot([x, x], [y - length * 0.05, y + length * 0.05], color=INK, lw=0.8, zorder=9)
    ax.plot([x + length, x + length], [y - length * 0.05, y + length * 0.05], color=INK, lw=0.8, zorder=9)
    ax.text(x + length / 2, y + length * 0.08, text or f"{length:g} mm", fontsize=7.5, ha="center", va="bottom", color=INK)


def save(fig, stem, dpi=180):
    svg = os.path.join(HERE, stem + ".svg")
    png = os.path.join(HERE, stem + ".png")
    fig.savefig(svg, dpi=dpi)
    fig.savefig(png, dpi=dpi)
    plt.close(fig)
    _shrink_png(png)
    return svg, png


def _shrink_png(png, limit=1_000_000):
    """Quantise the PNG to a palette if it is over the limit (drawings use few colours)."""
    if os.path.getsize(png) <= limit:
        return
    try:
        from PIL import Image
        im = Image.open(png).convert("RGB")
        im = im.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
        im.save(png, optimize=True)
    except Exception:  # noqa: BLE001
        pass
