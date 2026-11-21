"""The solids every drawing uses, with their fill colours. The battery is the
planned YDL 403450 (ydl.py); the case model's pack and its wires are left out
of the drawings (they are still in the clearance table)."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import common as C  # noqa: E402
import drawing as D  # noqa: E402
import load  # noqa: E402
import ydl  # noqa: E402

YDL = "battery YDL 403450 (planned)"
METAL = ("J1", "J2", "J3", "SW1", "U1")
_CACHE = {}


def solids(with_model_pack=False):
    if "S" not in _CACHE:
        A = load.assembly()
        S = dict(A)
        S[YDL] = ydl.solid(A)
        _CACHE["S"] = S
        _CACHE["A"] = A
    S = dict(_CACHE["S"])
    if not with_model_pack:
        S.pop("battery pack", None)
        S.pop("battery wires", None)
    return S


def fill(n):
    F = D.FILL
    if n in ("front shell", "back plate", "button cap"):
        return F["printed"]
    if n == "wheel disc":
        return F["disc"]
    if n == "board PCB":
        return F["pcb"]
    if n.startswith("board J1 leg"):
        return F["metal"]
    if n.startswith("board "):
        return F["metal"] if n[6:].startswith(METAL) else F["part"]
    if n == "screen body":
        return F["screen"]
    if n.startswith("screen FPC"):
        return F["fpc"]
    if n.startswith("screen "):
        return F["glass"]
    if n.startswith("FPC"):
        return F["fpc"]
    if n == YDL:
        return F["planned"]
    if n == "battery pack":
        return F["battery"]
    if n == "battery foam":
        return F["foam"]
    if n.startswith("battery plug"):
        return F["plug"]
    if n.startswith("battery wires"):
        return F["screw"]
    if n == "motor":
        return F["motor"]
    if n.startswith("insert"):
        return F["brass"]
    if n.startswith("screw"):
        return F["screw"]
    return "#dddddd"


def zorder(n):
    if n.startswith("screen ") and n != "screen body":
        return 3
    if n.startswith("board ") and n != "board PCB":
        return 3
    if n.startswith("FPC") or n.startswith("screen FPC"):
        return 4
    return 2


def draw_section(ax, S, axis, value, win, skip=(), only=None, lw=0.6, hatch_for=None, alpha=1.0, outer_only=(), fills=None):
    """Fill the section of every solid that crosses the plane inside the window.
    win = (u0, u1, v0, v1) in plane coordinates."""
    ia, ib = {"x": (1, 2), "y": (0, 2), "z": (0, 1)}[axis]
    k = "xyz".index(axis)
    drawn = []
    for n, s in S.items():
        if n in skip or (only and n not in only):
            continue
        b = C.bb(s)
        if not (b[2 * k] - 1e-6 <= value <= b[2 * k + 1] + 1e-6):
            continue
        if b[2 * ia + 1] < win[0] or b[2 * ia] > win[1] or b[2 * ib + 1] < win[2] or b[2 * ib] > win[3]:
            continue
        faces = C.section(s, axis, value)
        if not faces:
            continue
        if n in outer_only:
            faces = [[f[0]] for f in faces]
        fc = (fills or {}).get(n, fill(n))
        D.fill_faces(ax, faces, fc, lw=lw, z=zorder(n), hatch=(hatch_for or {}).get(n), alpha=alpha)
        drawn.append(n)
    return drawn
